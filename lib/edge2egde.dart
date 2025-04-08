import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//Support edge to edge on Android < 15
Future settingUpSystemUIOverlay() async {
  // Setting SystemUIOverlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: false,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  // Setting SystemUIMode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}
