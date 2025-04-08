import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:freebuddy/headphones/framework/anc.dart';
import 'package:freebuddy/headphones/framework/lrc_battery.dart';
import 'package:freebuddy/headphones/huawei/huawei_headphones_impl.dart';
import 'package:freebuddy/headphones/huawei/mbb.dart';
import 'package:freebuddy/headphones/huawei/model_definition.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

void main() {
  group("Huawei headphones implementation tests", () {
    // test with keyword "info" test if impl reacts to info *from* buds
    // ones with "set" test if impl sends correct bytes *to* buds

    late StreamController<Uint8List> inputCtrl;
    late StreamController<Uint8List> outputCtrl;
    late StreamChannel<Uint8List> channel;
    late HuaweiHeadphonesImpl headphones;
    late HuaweiModelDefinition testModel;

    setUp(() {
      inputCtrl = StreamController<Uint8List>.broadcast();
      outputCtrl = StreamController<Uint8List>();
      channel = StreamChannel<Uint8List>(inputCtrl.stream, outputCtrl.sink);

      // Use the FreeBuds Pro 3 model for testing, but could be any model
      testModel = HuaweiModels.freeBudsPro3;

      // Use the generalized implementation with the model definition
      headphones = HuaweiHeadphonesImpl(
        modelDefinition: testModel,
        bluetoothDevice: const FakeBtDev(),
        mbb: mbbChannel(channel),
      );
    });

    tearDown(() {
      inputCtrl.close();
      outputCtrl.close();
    });

    test("Request data on start", () async {
      expect(
        outputCtrl.stream.bytesToList(),
        emitsInAnyOrder([
          [90, 0, 3, 0, 1, 8, 223, 115],
          [90, 0, 3, 0, 43, 42, 50, 126],
        ]),
      );
    });

    test("ANC mode set", () async {
      await headphones.setAncMode(AncMode.noiseCancelling);
      expect(
        outputCtrl.stream.bytesToList(),
        emitsThrough([90, 0, 7, 0, 43, 4, 1, 2, 1, 255, 255, 236]),
      );
    });

    test("ANC mode info", () async {
      const cmds = [
        MbbCommand(43, 42, {
          1: [4, 1]
        }),
        MbbCommand(43, 42, {
          1: [0, 0]
        }),
        MbbCommand(43, 42, {
          1: [0, 2]
        }),
        MbbCommand(43, 42, {
          1: [0, 2]
        }),
      ];
      for (var c in cmds) {
        inputCtrl.add(c.toPayload());
      }
      expect(
        headphones.ancMode,
        emitsInOrder([
          AncMode.noiseCancelling,
          AncMode.off,
          AncMode.transparency,
          AncMode.transparency,
        ]),
      );
    });

    test("Battery info", () async {
      inputCtrl.add(const MbbCommand(1, 39, {
        1: [35],
        2: [35, 70, 99],
        3: [1, 0, 1]
      }).toPayload());
      expect(
        headphones.lrcBattery,
        emits(const LRCBatteryLevels(35, 70, 99, true, false, true)),
      );
    });

    test("Properly closes", () async {
      expectLater(
        headphones.ancMode,
        emitsInOrder([AncMode.noiseCancelling, emitsDone]),
      );
      expectLater(headphones.lrcBattery, emitsDone);
      inputCtrl.add(const MbbCommand(43, 42, {
        1: [4, 1]
      }).toPayload());
      await inputCtrl.close();
    });
  });

  group("Different model tests", () {
    test("Model selection works", () {
      final freeBuds4i = HuaweiModels.freeBuds4i;
      expect(freeBuds4i.supportsAnc, true);
      expect(freeBuds4i.supportsAutoPause, false);

      final freeBudsPro3 = HuaweiModels.freeBudsPro3;
      expect(freeBudsPro3.supportsAnc, true);
      expect(freeBudsPro3.supportsAutoPause, true);
    });

    test("Finding model by name", () {
      final model = HuaweiModels.findModelByName("HUAWEI FreeBuds Pro 3");
      expect(model.name, "FreeBuds Pro 3");

      final model2 = HuaweiModels.findModelByName("HUAWEI FreeBuds 4i");
      expect(model2.name, "FreeBuds 4i");

      expect(
          () => HuaweiModels.findModelByName("Unknown Model"), throwsException);
    });
  });
}

class FakeBtDev implements BluetoothDevice {
  const FakeBtDev();

  @override
  ValueStream<String> get alias => Stream.value("FreeBuds 😺").shareValue();

  @override
  ValueStream<int> get battery => Stream.value(100).shareValue();

  @override
  ValueStream<bool> get isConnected => Stream.value(true).shareValue();

  @override
  String get mac => "00:11:22:33:44:55";

  @override
  ValueStream<String> get name =>
      Stream.value("HUAWEI FreeBuds Pro 3").shareValue();

  @override
  Future<Set<String>> get uuids => Future.value({});
}

extension on Stream<Uint8List> {
  Stream<List<int>> bytesToList() => map((event) => event.toList());
}
