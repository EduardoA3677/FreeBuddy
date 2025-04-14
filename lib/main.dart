import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'di.dart' as di;
import 'headphones/cubit/headphones_connection_cubit.dart';
import 'headphones/cubit/headphones_cubit_objects.dart';
import 'logger.dart';
import 'platform_stuff/android/appwidgets/battery_appwidget.dart';
import 'ui/app_settings.dart';

late final StreamingSharedPreferences _preferences;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.setupGlobalErrorHandling();
  AppLogger.log(LogLevel.info, "FreeBuddy iniciando...");
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  try {
    _preferences = await StreamingSharedPreferences.instance;
    AppLogger.log(LogLevel.debug, "Preferencias inicializadas correctamente");
    runApp(
      Provider<AppSettings>(
        create: (context) => SharedPreferencesAppSettings(Future.value(_preferences)),
        child: const MyAppWrapper(),
      ),
    );
  } catch (e, stackTrace) {
    AppLogger.log(LogLevel.critical, "Error al iniciar la aplicación",
        error: e, stackTrace: stackTrace);
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Error al iniciar FreeBuddy. Por favor reinicia la aplicación."),
        ),
      ),
    ));
  }
}

class MyAppWrapper extends StatefulWidget {
  const MyAppWrapper({super.key});
  @override
  State<MyAppWrapper> createState() => _MyAppWrapperState();
}

// Definir constantes globales para mensajes utilizados frecuentemente
const String kLoadingErrorMsg = 'Error al iniciar FreeBuddy. Por favor reinicia la aplicación.';
const String kInitializingAppMsg = 'Iniciando FreeBuddy...';

class _MyAppWrapperState extends State<MyAppWrapper> with WidgetsBindingObserver {
  final _headphonesCubit = di.getHeadphonesCubit();

  bool _isReadyToLaunch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadSharedPreferences();
    _setupSplashScreenRemoval();
  }

  Future<void> _loadSharedPreferences() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _isReadyToLaunch = true;
      });
    }
  }

  void _setupSplashScreenRemoval() {
    _headphonesCubit.stream
        .firstWhere((state) => state is HeadphonesConnectedOpen)
        .timeout(
          const Duration(seconds: 1),
          onTimeout: () => const HeadphonesNotPaired(),
        )
        .then((_) => FlutterNativeSplash.remove())
        .catchError((_) => FlutterNativeSplash.remove());
  }

  Widget _buildLoadingScreen() {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                kInitializingAppMsg,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReadyToLaunch) {
      return _buildLoadingScreen();
    }

    return Provider<AppSettings>(
      create: (_) => SharedPreferencesAppSettings(Future.value(_preferences)),
      child: MultiBlocProvider(
        providers: [BlocProvider.value(value: _headphonesCubit)],
        child: BlocListener<HeadphonesConnectionCubit, HeadphonesConnectionState>(
          listener: batteryHomeWidgetHearBloc,
          listenWhen: (_, __) => !kIsWeb && Platform.isAndroid,
          child: const MyAppWrapper(),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      await _closeHeadphonesCubit();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() async {
    await _closeHeadphonesCubit();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _closeHeadphonesCubit() async {
    await _headphonesCubit.close();
  }
}
