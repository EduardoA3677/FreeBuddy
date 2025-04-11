import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../huawei/huawei_headphones_sim.dart';
import '../model_definition/huawei_models_definition.dart';
import 'headphones_connection_cubit.dart';
import 'headphones_cubit_objects.dart';

class HeadphonesMockCubit extends Cubit<HeadphonesConnectionState>
    implements HeadphonesConnectionCubit {
  HeadphonesMockCubit()
      : super(HeadphonesDisconnected(HuaweiHeadphonesSimPlaceholder(HuaweiModels.freeBudsPro3))) {
    // i do this because otherwise initial data isn't even emitted and
    // [BlocListener]s don't work >:(
    Future.microtask(
        () => emit(HeadphonesConnectedOpen(HuaweiHeadphonesSim(HuaweiModels.freeBudsPro3))));
  }
  @override
  Future<void> connect() async {}

  @override
  Future<bool> enableBluetooth() async => false;

  @override
  Future<void> openBluetoothSettings() async {}

  @override
  Future<void> requestPermission() async {}
}
