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
        size: Size(1040, 680),
        minimumSize: Size(960, 620),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        title: 'CPRay Gaming',
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
