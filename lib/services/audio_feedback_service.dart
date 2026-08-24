import 'dart:io';

class AudioFeedbackService {
  static bool isEnabled = true;

  static void playConnectSound() {
    if (!isEnabled || !Platform.isWindows) return;
    try {
      Process.run('powershell', [
        '-NoProfile',
        '-Command',
        '[console]::beep(523,100); [console]::beep(659,100); [console]::beep(784,150); [console]::beep(1046,250)'
      ]);
    } catch (_) {}
  }

  static void playDisconnectSound() {
    if (!isEnabled || !Platform.isWindows) return;
    try {
      Process.run('powershell', [
        '-NoProfile',
        '-Command',
        '[console]::beep(784,120); [console]::beep(523,200)'
      ]);
    } catch (_) {}
  }

  static void playSwitchSound() {
    if (!isEnabled || !Platform.isWindows) return;
    try {
      Process.run('powershell', [
        '-NoProfile',
        '-Command',
        '[console]::beep(880,80); [console]::beep(1174,120)'
      ]);
    } catch (_) {}
  }

  static void playPingSound() {
    if (!isEnabled || !Platform.isWindows) return;
    try {
      Process.run('powershell', [
        '-NoProfile',
        '-Command',
        '[console]::beep(1318,60)'
      ]);
    } catch (_) {}
  }
}
