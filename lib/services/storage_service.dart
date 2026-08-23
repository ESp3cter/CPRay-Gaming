import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/server_config.dart';

class StorageService {
  static const String _keySettings = 'cpray_settings';
  static const String _keyServers = 'cpray_servers';
  static const String _keySubUrl = 'cpray_sub_url';

  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keySettings);
    if (data != null) {
      try {
        return AppSettings.fromJson(jsonDecode(data));
      } catch (_) {}
    }
    return AppSettings();
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, jsonEncode(settings.toJson()));
  }

  static Future<List<ServerConfig>> loadServers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyServers);
    if (data != null) {
      try {
        final List<dynamic> list = jsonDecode(data);
        return list.map((e) => ServerConfig.fromJson(e)).toList();
      } catch (_) {}
    }
    return [];
  }

  static Future<void> saveServers(List<ServerConfig> servers) async {
    final prefs = await SharedPreferences.getInstance();
    final list = servers.map((e) => e.toJson()).toList();
    await prefs.setString(_keyServers, jsonEncode(list));
  }

  static Future<String?> loadSubscriptionUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySubUrl);
  }

  static Future<void> saveSubscriptionUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySubUrl, url);
  }
}
