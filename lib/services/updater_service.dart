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

  static Future<File> getPersistentInstallerFile(String version) async {
    final baseDir = await getApplicationSupportDirectory();
    final updatesDir = Directory(p.join(baseDir.path, 'updates'));
    if (!await updatesDir.exists()) {
      await updatesDir.create(recursive: true);
    }
    final ext = Platform.isAndroid ? '.apk' : (Platform.isWindows ? '.exe' : '');
    final appSlug = FlavorConfig.isVpn ? 'vpn' : 'gaming';
    final fileName = 'cpray_${appSlug}_v$version$ext';
    return File(p.join(updatesDir.path, fileName));
  }

  static Future<File?> _copyToPublicDownloads(File source, String version) async {
    if (!Platform.isAndroid) return null;
    try {
      final appName = FlavorConfig.isVpn ? 'CPRay-VPN' : 'CPRay-Gaming';
      final downloadDirs = ['/storage/emulated/0/Download', '/sdcard/Download'];
      for (final dirPath in downloadDirs) {
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          final target = File(p.join(dirPath, '$appName-v$version.apk'));
          if (!await target.exists() || await target.length() != await source.length()) {
            return await source.copy(target.path);
          }
          return target;
        }
      }
    } catch (_) {}
    return null;
  }

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

    // Persist file in application support directory so Android OS never purges it
    final completedFile = await getPersistentInstallerFile(update.version);

    // If already downloaded and valid, NEVER re-download!
    if (await completedFile.exists()) {
      final length = await completedFile.length();
      if (length > 1024 * 1024) {
        downloadedFile = completedFile;
        isDownloading = false;
        downloadProgress = 1.0;
        if (Platform.isAndroid) {
          _copyToPublicDownloads(completedFile, update.version);
        }
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

    final partFile = File('${completedFile.path}.part');
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

        if (Platform.isAndroid) {
          await _copyToPublicDownloads(completedFile, update.version);
        }

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
      if (readyUpdate != null) {
        await _copyToPublicDownloads(installerFile, readyUpdate!.version);
      }
      // Open the package installer directly over the persistent APK
      await OpenFilex.open(installerFile.path);
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
    final update = readyUpdate ?? await checkForUpdates();
    final version = update?.version ?? 'latest';
    final installerFile = await getPersistentInstallerFile(version);

    if (await installerFile.exists() && await installerFile.length() > 1024 * 1024) {
      downloadedFile = installerFile;
      onProgress(1.0, await installerFile.length(), await installerFile.length());
      await applyDownloadedUpdate(installerFile);
      return;
    }

    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(downloadUrl));
      request.headers['User-Agent'] = 'CPRay-Gaming-Updater';
      final response = await client.send(request);

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      final partFile = File('${installerFile.path}.part');
      if (await partFile.exists()) {
        try {
          await partFile.delete();
        } catch (_) {}
      }

      final sink = partFile.openWrite();

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

      if (await partFile.exists()) {
        if (await installerFile.exists()) {
          await installerFile.delete();
        }
        await partFile.rename(installerFile.path);
        downloadedFile = installerFile;
      }

      await applyDownloadedUpdate(installerFile);
    } finally {
      client.close();
    }
  }
}
