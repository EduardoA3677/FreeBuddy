import 'dart:io';

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
import 'headphones/cubit/headphones_connection_cubit.dart';
import 'headphones/cubit/headphones_cubit_objects.dart';
import 'logger.dart';
import 'platform_stuff/android/appwidgets/battery_appwidget.dart';
import 'ui/app_settings.dart';
import 'ui/navigation/router.dart';
import 'ui/theme/themes.dart';

late final StreamingSharedPreferences _preferences;

void main() async {
  // Asegurarse de que el binding de widgets esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar el sistema de logging para capturar todos los errores
  AppLogger.setupGlobalErrorHandling();

  // Registrar inicio de la aplicación
  log(LogLevel.info, "FreeBuddy iniciando...");

  // Preservar la pantalla de splash mientras se inicializa la app
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  try {
    // Inicializar preferencias compartidas
    _preferences = await StreamingSharedPreferences.instance;
    log(LogLevel.debug, "Preferencias inicializadas correctamente");

    // Iniciar la aplicación con el MyAppWrapper para gestionar el ciclo de vida
    runApp(
      Provider<AppSettings>(
        create: (context) => SharedPreferencesAppSettings(Future.value(_preferences)),
        child: const MyAppWrapper(),
      ),
    );
  } catch (e, stackTrace) {
    log(LogLevel.critical, "Error al iniciar la aplicación", error: e, stackTrace: stackTrace);
    // Reintentar con una configuración mínima para mostrar el error al usuario
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

class _MyAppWrapperState extends State<MyAppWrapper> with WidgetsBindingObserver {
  final _btBlock = di.getHeadphonesCubit();
  bool _isPrefsInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPreferences();
    _setupSplashRemoval();
  }

  Future<void> _initPreferences() async {
    // Simulamos una pequeña carga para dar tiempo a la inicialización
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _isPrefsInitialized = true;
      });
    }
  }

  void _setupSplashRemoval() {
    // Eliminar splash cuando los auriculares se conecten o después de 1 segundo
    _btBlock.stream
        .firstWhere((e) => e is HeadphonesConnectedOpen)
        .timeout(
          const Duration(seconds: 1),
          onTimeout: () => const HeadphonesNotPaired(),
        )
        .then((_) {
      FlutterNativeSplash.remove();
    }).catchError((error) {
      // Asegurarse de eliminar el splash incluso si hay errores
      FlutterNativeSplash.remove();
    });

    // No inicializar Bluetooth automáticamente
    // Los permisos serán solicitados después de la introducción
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar un indicador de carga mientras se inicializan las preferencias
    if (!_isPrefsInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Indicador de carga con estilo mejorado
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                // Mensaje informativo para el usuario
                Text(
                  'Iniciando FreeBuddy...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Una vez inicializado, configurar los providers y la estructura principal
    return Provider<AppSettings>(
      create: (context) => SharedPreferencesAppSettings(Future.value(_preferences)),
      child: MultiBlocProvider(
        providers: [BlocProvider.value(value: _btBlock)],
        child: BlocListener<HeadphonesConnectionCubit, HeadphonesConnectionState>(
          listener: batteryHomeWidgetHearBloc,
          listenWhen: (p, c) => !kIsWeb && Platform.isAndroid,
          child: const MyApp(),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      await _btBlock.close();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() async {
    await _btBlock.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => StreamBuilder<ThemeMode>(
        stream: context.read<AppSettings>().themeMode,
        initialData: ThemeMode.system,
        builder: (context, snapshot) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false, // Eliminar la etiqueta de debug
            routerConfig: router,
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: lightTheme(lightDynamic),
            darkTheme: darkTheme(darkDynamic),
            themeMode: snapshot.data!, // Añadir animaciones de transición mejoradas
            builder: (context, child) {
              if (child == null) {
                // Proporcionar un fallback en caso de que child sea null
                return const Center(child: CircularProgressIndicator());
              }
              // Añadir animación de aparición suave
              return child
                  .animate()
                  .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.05, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
            },
          );
        },
      ),
    );
  }
}
