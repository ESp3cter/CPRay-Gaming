import 'package:flutter/services.dart';

class AudioFeedbackService {
  static bool isEnabled = true;

  static void playConnectSound() {
    if (!isEnabled) return;
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  static void playDisconnectSound() {
    if (!isEnabled) return;
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  static void playSwitchSound() {
    if (!isEnabled) return;
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  static void playPingSound() {
    if (!isEnabled) return;
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }
}
