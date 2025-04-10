import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'di.dart' as di;
import 'headphones/cubit/headphones_connection_cubit.dart';
import 'headphones/cubit/headphones_cubit_objects.dart';
import 'platform_stuff/android/appwidgets/battery_appwidget.dart';
import 'ui/app_settings.dart';
import 'ui/navigation/router.dart';
import 'ui/theme/themes.dart';

late final SharedPreferences _preferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _preferences = await SharedPreferences.getInstance();

  runApp(
    Provider<AppSettings>(
      create: (_) => SharedPreferencesAppSettings(_preferences),
      child: MyApp(),
    ),
  );
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
    setState(() {
      _isPrefsInitialized = true;
    });
  }

  void _setupSplashRemoval() {
    // Remove splash when headphones connect or after 1.5 seconds
    _btBlock.stream
        .firstWhere((e) => e is HeadphonesConnectedOpen)
        .timeout(
          const Duration(seconds: 1),
          onTimeout: () => const HeadphonesNotPaired(), // just placeholder
        )
        .then((_) => FlutterNativeSplash.remove());
  }

  @override
  Widget build(BuildContext context) {
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
      create: (context) => SharedPreferencesAppSettings(_preferences),
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
