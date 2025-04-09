import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'di.dart' as di;
import 'edge2egde.dart';
import 'headphones/cubit/headphones_connection_cubit.dart';
import 'headphones/cubit/headphones_cubit_objects.dart';
import 'platform_stuff/android/appwidgets/battery_appwidget.dart';
import 'platform_stuff/android/background/periodic.dart' as android_periodic;
import 'ui/app_settings.dart';
import 'ui/navigation/router.dart';
import 'ui/theme/themes.dart';

void main() async {
  final bind = WidgetsFlutterBinding.ensureInitialized();

  // Configurar animaciones globales
  Animate.restartOnHotReload = true;

  // Optimizar edge-to-edge en todas las versiones de Android
  await settingUpSystemUIOverlay();

  // Mantener la pantalla splash mientras se conecta a los auriculares
  FlutterNativeSplash.preserve(widgetsBinding: bind);

  // Inicializar funciones específicas de Android
  if (!kIsWeb && Platform.isAndroid) {
    await _initializeAndroid();
  }

  runApp(const MyAppWrapper());
}

Future<void> _initializeAndroid() async {
  // Iniciar tareas periódicas
  android_periodic.init();

  // Verificar versión de Android para adaptarse
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;

  // Registro de versión del sistema para posibles adaptaciones
  debugPrint(
      'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})');
}

class MyAppWrapper extends StatefulWidget {
  const MyAppWrapper({super.key});

  @override
  State<MyAppWrapper> createState() => _MyAppWrapperState();
}

class _MyAppWrapperState extends State<MyAppWrapper>
    with WidgetsBindingObserver {
  final _btCubit = di.getHeadphonesCubit();
  late final StreamingSharedPreferences _preferences;
  bool _isPrefsInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPreferences();
    _setupSplashRemoval();
  }

  Future<void> _initPreferences() async {
    _preferences = await StreamingSharedPreferences.instance;
    setState(() {
      _isPrefsInitialized = true;
    });
  }

  void _setupSplashRemoval() {
    // Remover splash cuando se conecten los auriculares o después de 1.5 segundos
    _btCubit.stream
        .firstWhere((e) => e is HeadphonesConnectedOpen)
        .timeout(
          const Duration(milliseconds: 1500),
          onTimeout: () => const HeadphonesNotPaired(),
        )
        .then((_) => FlutterNativeSplash.remove());
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar un indicador de carga mientras se inicializan las preferencias
    if (!_isPrefsInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Provider<AppSettings>(
      create: (context) =>
          SharedPreferencesAppSettings(Future.value(_preferences)),
      child: MultiBlocProvider(
        providers: [BlocProvider.value(value: _btCubit)],
        child:
            BlocListener<HeadphonesConnectionCubit, HeadphonesConnectionState>(
          listener: batteryHomeWidgetHearBloc,
          listenWhen: (p, c) => !kIsWeb && Platform.isAndroid,
          child: const MyApp(),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // Optimización de ciclo de vida para evitar fugas de memoria y uso de batería
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      await _btCubit.close();
    } else if (state == AppLifecycleState.resumed) {
      // Reconectar si es necesario cuando la app vuelva a primer plano
      _btCubit.tryConnectIfNeeded();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() async {
    await _btCubit.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp.router(
        routerConfig: router,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: lightTheme(lightDynamic),
        darkTheme: darkTheme(darkDynamic),
        themeMode: ThemeMode.system,
        // Añadir animaciones de transición por defecto
        builder: (context, child) {
          return child!.animate().fadeIn(duration: 300.ms);
        },
      ),
    );
  }
}
