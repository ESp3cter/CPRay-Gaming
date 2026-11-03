import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/flavor_config.dart';
import '../models/update_info.dart';
import 'vpn_service.dart';

class UpdaterService {
  static String repoOwner = 'ESp3cter';
  static const String repoName = 'CPRay-Gaming';

  static bool isDownloading = false;
  static double downloadProgress = 0.0;
  static File? downloadedFile;
  static UpdateInfo? readyUpdate;

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

  /// Automatically check for updates and download in the background silently.
  /// When 100% complete, invokes [onReadyToInstall].
  static Future<void> checkAndDownloadInBackground({
    Function(UpdateInfo info, File file)? onReadyToInstall,
  }) async {
    if (isDownloading) return;

    final update = await checkForUpdates();
    if (update == null || !update.hasUpdate || update.downloadUrl.isEmpty) {
      return;
    }

    readyUpdate = update;

    final tempDir = await getTemporaryDirectory();
    final ext = Platform.isAndroid ? '.apk' : (Platform.isWindows ? '.exe' : '');
    final appSlug = FlavorConfig.isVpn ? 'vpn' : 'gaming';
    final completedFileName = 'cpray_${appSlug}_v${update.version}$ext';
    final completedFile = File(p.join(tempDir.path, completedFileName));

    // If already downloaded and valid, notify immediately
    if (await completedFile.exists()) {
      final length = await completedFile.length();
      if (length > 1024 * 1024) {
        downloadedFile = completedFile;
        isDownloading = false;
        downloadProgress = 1.0;
        onReadyToInstall?.call(update, completedFile);
        return;
      } else {
        try {
          await completedFile.delete();
        } catch (_) {}
      }
    }

    // Start silent background download
    isDownloading = true;
    downloadProgress = 0.0;

    final partFile = File(p.join(tempDir.path, '$completedFileName.part'));
    if (await partFile.exists()) {
      try {
        await partFile.delete();
      } catch (_) {}
    }

    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(update.downloadUrl));
      request.headers['User-Agent'] = 'CPRay-Updater';
      final response = await client.send(request);

      if (response.statusCode != 200) {
        isDownloading = false;
        return;
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;
      final sink = partFile.openWrite();

      await response.stream.listen((chunk) {
        receivedBytes += chunk.length;
        sink.add(chunk);
        if (totalBytes > 0) {
          downloadProgress = receivedBytes / totalBytes;
        }
      }).asFuture();

      await sink.flush();
      await sink.close();

      if (await partFile.exists()) {
        if (await completedFile.exists()) {
          await completedFile.delete();
        }
        await partFile.rename(completedFile.path);
        downloadedFile = completedFile;
        downloadProgress = 1.0;
        isDownloading = false;

        onReadyToInstall?.call(update, completedFile);
      } else {
        isDownloading = false;
      }
    } catch (_) {
      isDownloading = false;
      try {
        if (await partFile.exists()) await partFile.delete();
      } catch (_) {}
    } finally {
      client.close();
    }
  }

  /// Installs an already-downloaded update package.
  static Future<void> applyDownloadedUpdate(File installerFile) async {
    try {
      await VpnService.stopVpn();
    } catch (_) {}

    if (Platform.isAndroid) {
      final openResult = await OpenFilex.open(installerFile.path);
      if (openResult.type != ResultType.done && readyUpdate?.downloadUrl != null && readyUpdate!.downloadUrl.isNotEmpty) {
        final uri = Uri.parse(readyUpdate!.downloadUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
      return;
    }

    if (Platform.isWindows) {
      final programFiles = Platform.environment['ProgramFiles'] ?? r'C:\Program Files';
      final targetExe = p.join(programFiles, 'CPRay Gaming', 'cpray_gaming.exe');

      final script =
          'Start-Process -FilePath "${installerFile.path}" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART", "/SP-", "/CLOSEAPPLICATIONS", "/FORCECLOSEAPPLICATIONS" -Wait; '
          'Start-Sleep -Seconds 1; '
          'if (-not (Get-Process -Name "cpray_gaming" -ErrorAction SilentlyContinue)) { '
          '  if (Test-Path "$targetExe") { Start-Process -FilePath "$targetExe" } '
          '  else { Start-Process -FilePath "${Platform.resolvedExecutable}" } '
          '}';

      await Process.start(
        'powershell.exe',
        ['-NoProfile', '-WindowStyle', 'Hidden', '-Command', script],
        mode: ProcessStartMode.detached,
      );
      exit(0);
    } else {
      await Process.start(
        installerFile.path,
        [],
        mode: ProcessStartMode.detached,
      );
      exit(0);
    }
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
      final fileName = Platform.isAndroid ? 'cpray_update.apk' : 'cpray_update_setup.exe';
      final installerFile = File(p.join(tempDir.path, fileName));
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

      await applyDownloadedUpdate(installerFile);
    } finally {
      client.close();
    }
  }
}
