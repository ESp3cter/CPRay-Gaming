import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/update_info.dart';
import 'vpn_service.dart';

class UpdaterService {
  static String repoOwner = 'ESp3cter';
  static const String repoName = 'CPRay-Gaming';

  static Future<UpdateInfo?> checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final url = Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest');
      final response = await http.get(url, headers: {
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'CPRay-Gaming-Updater',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final updateInfo = UpdateInfo.fromJson(json, currentVersion);
        return updateInfo;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> downloadAndApplyUpdate({
    required String downloadUrl,
    required Function(double progress, int receivedBytes, int totalBytes) onProgress,
  }) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(downloadUrl));
      request.headers['User-Agent'] = 'CPRay-Gaming-Updater';
      final response = await client.send(request);

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      final tempDir = await getTemporaryDirectory();
      final installerFile = File(p.join(tempDir.path, 'cpray_update_setup.exe'));
      if (await installerFile.exists()) {
        await installerFile.delete();
      }

      final sink = installerFile.openWrite();

      await response.stream.listen((chunk) {
        receivedBytes += chunk.length;
        sink.add(chunk);
        if (totalBytes > 0) {
          final progress = receivedBytes / totalBytes;
          onProgress(progress, receivedBytes, totalBytes);
        }
      }).asFuture();

      await sink.flush();
      await sink.close();

      // Ensure VPN tunnel is cleanly closed before replacing binaries
      await VpnService.stopVpn();

      // Run Inno Setup installer silently and restart application
      await Process.start(
        installerFile.path,
        [
          '/VERYSILENT',
          '/NORESTART',
          '/SP-',
          '/CLOSEAPPLICATIONS',
          '/RESTARTAPPLICATIONS',
        ],
        mode: ProcessStartMode.detached,
      );

      // Exit current running instance so installer can update files cleanly
      exit(0);
    } finally {
      client.close();
    }
  }
}
