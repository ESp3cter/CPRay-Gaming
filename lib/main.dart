import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    try {
      await windowManager.ensureInitialized();
      const windowOptions = WindowOptions(
        size: Size(440, 680),
        minimumSize: Size(400, 620),
        maximumSize: Size(600, 850),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        title: 'CPRay Gaming',
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    } catch (_) {}
  }

  runApp(const CPRayGamingApp());
}
