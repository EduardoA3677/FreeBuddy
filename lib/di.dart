import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

import 'headphones/cubit/headphones_connection_cubit.dart';
import 'headphones/cubit/headphones_mock_cubit.dart';

/// Flag to determine if we should use mock headphones
/// Returns true if USE_HEADPHONES_MOCK is enabled or if we're not on Android
bool isMock = kIsWeb || !Platform.isAndroid || const bool.fromEnvironment('USE_HEADPHONES_MOCK');

/// Gets real or mock headphones connection cubit based on platform and configuration
HeadphonesConnectionCubit getHeadphonesCubit() => isMock
    ? HeadphonesMockCubit()
    : HeadphonesConnectionCubit(bluetooth: TheLastBluetooth.instance);
