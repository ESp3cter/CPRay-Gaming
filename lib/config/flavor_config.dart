import 'package:package_info_plus/package_info_plus.dart';

enum AppFlavor { gaming, vpn }

class FlavorConfig {
  static AppFlavor current = AppFlavor.gaming;

  static bool get isGaming => current == AppFlavor.gaming;
  static bool get isVpn => current == AppFlavor.vpn;

  static String get appName => isGaming ? 'CPRay Gaming' : 'CPRay VPN';
  static String get appSubtitle => isGaming ? 'GAMING SUITE' : 'FAST & SECURE VPN';

  static Future<void> initFromPlatform() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.packageName.contains('vpn') || info.appName.toLowerCase().contains('vpn')) {
        current = AppFlavor.vpn;
      }
    } catch (_) {}
  }
}
