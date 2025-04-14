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
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.setupGlobalErrorHandling();
  AppLogger.log(LogLevel.info, "FreeBuddy iniciando...");
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  try {
    _preferences = await StreamingSharedPreferences.instance;
    AppLogger.log(LogLevel.debug, "Preferencias inicializadas correctamente");

    runApp(
      Provider<AppSettings>(
        create: (context) =>
            SharedPreferencesAppSettings(Future.value(_preferences)),
        child: const MyAppWrapper(),
      ),
    );
  } catch (e, stackTrace) {
    AppLogger.log(LogLevel.critical, "Error al iniciar la aplicación",
        error: e, stackTrace: stackTrace);
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
              "Error al iniciar FreeBuddy. Por favor reinicia la aplicación."),
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

class _MyAppWrapperState extends State<MyAppWrapper>
    with WidgetsBindingObserver {
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
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _isPrefsInitialized = true;
      });
    }
  }

  void _setupSplashRemoval() {
    _btBlock.stream
        .firstWhere((e) => e is HeadphonesConnectedOpen)
        .timeout(
          const Duration(seconds: 1),
          onTimeout: () => const HeadphonesNotPaired(),
        )
        .then((_) {
      FlutterNativeSplash.remove();
    }).catchError((error) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPrefsInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
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

    return Provider<AppSettings>(
      create: (context) =>
          SharedPreferencesAppSettings(Future.value(_preferences)),
      child: MultiBlocProvider(
        providers: [BlocProvider.value(value: _btBlock)],
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
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: lightTheme(dynamicScheme: lightDynamic),
            darkTheme: darkTheme(dynamicScheme: darkDynamic),
            themeMode: snapshot.data!,
            builder: (context, child) {
              if (child == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return child
                  .animate()
                  .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic)
                  .slideY(
                      begin: 0.05,
                      end: 0,
                      duration: 300.ms,
                      curve: Curves.easeOutCubic);
            },
          );
        },
      ),
    );
  }
}
