import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'config/flavor_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlavorConfig.initFromPlatform();

  if (Platform.isWindows) {
    try {
      await windowManager.ensureInitialized();
      final windowOptions = WindowOptions(
        size: const Size(1040, 680),
        minimumSize: const Size(960, 620),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        title: FlavorConfig.appName,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
      await _ensureWindowsAdminCompatibility();
    } catch (_) {}
  }

  runApp(const CPRayGamingApp());
}

Future<void> _ensureWindowsAdminCompatibility() async {
  if (!Platform.isWindows) return;
  try {
    final exePath = Platform.resolvedExecutable;
    await Process.run('reg.exe', [
      'add',
      r'HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers',
      '/v',
      exePath,
      '/t',
      'REG_SZ',
      '/d',
      '~ RUNASADMIN',
      '/f',
    ]);
  } catch (_) {}
}
