import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/app_settings.dart';
import '../models/server_config.dart';
import 'config_generator.dart';

enum VpnStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class VpnService {
  static Process? _process;
  static VpnStatus _status = VpnStatus.disconnected;
  static final List<String> _logs = [];
  static final StreamController<VpnStatus> _statusController = StreamController<VpnStatus>.broadcast();
  static final StreamController<String> _logController = StreamController<String>.broadcast();
  static final StreamController<Map<String, double>> _trafficController = StreamController<Map<String, double>>.broadcast();
  static StreamSubscription? _trafficSub;

  static Stream<VpnStatus> get statusStream => _statusController.stream;
  static Stream<String> get logStream => _logController.stream;
  static Stream<Map<String, double>> get trafficStream => _trafficController.stream;
  static VpnStatus get currentStatus => _status;
  static List<String> get logs => List.unmodifiable(_logs);

  static Timer? _sessionTimer;
  static int _connectedSeconds = 0;
  static final StreamController<int> _timerController = StreamController<int>.broadcast();
  static Stream<int> get timerStream => _timerController.stream;
  static int get connectedSeconds => _connectedSeconds;

  static void _setStatus(VpnStatus status) {
    _status = status;
    _statusController.add(_status);
  }

  static void _addLog(String log) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final formatted = '[$timestamp] $log';
    _logs.add(formatted);
    if (_logs.length > 500) _logs.removeAt(0);
    _logController.add(formatted);
  }

  static void clearLogs() {
    _logs.clear();
    _logController.add('[LOGS CLEARED]');
  }

  static Future<String> _getSingboxPath() async {
    return _ensureSingboxBinary();
  }

  static Future<String> _ensureSingboxBinary() async {
    if (!Platform.isWindows) return '';

    final appDir = File(Platform.resolvedExecutable).parent.path;
    final primary = p.join(appDir, 'sing-box.exe');
    if (await File(primary).exists()) return primary;

    final dataDir = p.join(appDir, 'data', 'sing-box.exe');
    if (await File(dataDir).exists()) return dataDir;

    final tempDir = await getApplicationSupportDirectory();
    final targetPath = p.join(tempDir.path, 'sing-box.exe');
    if (await File(targetPath).exists()) return targetPath;

    final assetsDir = p.join(Directory.current.path, 'assets', 'sing-box.exe');
    if (await File(assetsDir).exists()) return assetsDir;

    // Auto-download official Sing-box release binary if missing
    _addLog('Sing-box core binary missing. Downloading official verified core...');
    try {
      final zipFile = File(p.join(tempDir.path, 'singbox_temp.zip'));
      final client = http.Client();
      final urls = [
        'https://github.com/SagerNet/sing-box/releases/download/v1.11.4/sing-box-1.11.4-windows-amd64.zip',
        'https://github.com/SagerNet/sing-box/releases/download/v1.10.7/sing-box-1.10.7-windows-amd64.zip',
      ];

      bool downloaded = false;
      for (final url in urls) {
        try {
          _addLog('Downloading Sing-box core from: $url');
          final resp = await client.get(Uri.parse(url)).timeout(const Duration(seconds: 40));
          if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty) {
            await zipFile.writeAsBytes(resp.bodyBytes);
            downloaded = true;
            break;
          }
        } catch (e) {
          _addLog('Download attempt error: $e');
        }
      }
      client.close();

      if (downloaded && await zipFile.exists()) {
        _addLog('Extracting Sing-box core package...');
        final tempExtractDir = Directory(p.join(tempDir.path, 'singbox_extracted'));
        if (await tempExtractDir.exists()) {
          await tempExtractDir.delete(recursive: true);
        }
        await tempExtractDir.create(recursive: true);

        await Process.run('powershell', [
          '-NoProfile',
          '-Command',
          'Expand-Archive -Path "${zipFile.path}" -DestinationPath "${tempExtractDir.path}" -Force'
        ]);

        final files = tempExtractDir.listSync(recursive: true);
        for (final file in files) {
          if (file is File && p.basename(file.path).toLowerCase() == 'sing-box.exe') {
            await file.copy(targetPath);
            _addLog('Official Sing-box core installed to: $targetPath');
            break;
          }
        }

        try {
          await zipFile.delete();
          await tempExtractDir.delete(recursive: true);
        } catch (_) {}

        if (await File(targetPath).exists()) {
          return targetPath;
        }
      }
    } catch (e) {
      _addLog('Auto-provisioning failed: $e');
    }

    return targetPath;
  }

  static Future<void> _setSystemProxy(bool enable, int port) async {
    if (!Platform.isWindows) return;
    try {
      if (enable) {
        await Process.run('reg', [
          'add',
          'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings',
          '/v',
          'ProxyEnable',
          '/t',
          'REG_DWORD',
          '/d',
          '1',
          '/f'
        ]);
        await Process.run('reg', [
          'add',
          'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings',
          '/v',
          'ProxyServer',
          '/t',
          'REG_SZ',
          '/d',
          '127.0.0.1:$port',
          '/f'
        ]);
      } else {
        await Process.run('reg', [
          'add',
          'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings',
          '/v',
          'ProxyEnable',
          '/t',
          'REG_DWORD',
          '/d',
          '0',
          '/f'
        ]);
      }
    } catch (_) {}
  }

  static void _startTrafficMonitoring() {
    _trafficSub?.cancel();
    // Poll Clash API endpoint every 1 second for live throughput
    final client = http.Client();
    _trafficSub = Stream.periodic(const Duration(seconds: 1)).asyncMap((_) async {
      try {
        final resp = await client.get(Uri.parse('http://127.0.0.1:9090/traffic')).timeout(const Duration(milliseconds: 800));
        if (resp.statusCode == 200) {
          final json = jsonDecode(resp.body) as Map<String, dynamic>;
          final up = ((json['up'] as num?)?.toDouble() ?? 0.0) / 1024.0;
          final down = ((json['down'] as num?)?.toDouble() ?? 0.0) / 1024.0;
          return {'up': up, 'down': down};
        }
      } catch (_) {}
      return null;
    }).listen((data) {
      if (data != null) {
        _trafficController.add(data);
      }
    });
  }

  static void _stopTrafficMonitoring() {
    _trafficSub?.cancel();
    _trafficSub = null;
    _trafficController.add({'up': 0.0, 'down': 0.0});
  }

  static Future<void> startVpn({
    required ServerConfig server,
    required AppSettings settings,
  }) async {
    if (_status == VpnStatus.connected || _status == VpnStatus.connecting) {
      await stopVpn();
    }

    // Clean up any dangling processes from previous runs
    if (Platform.isWindows) {
      try {
        await Process.run('taskkill', ['/F', '/IM', 'sing-box.exe']);
      } catch (_) {}
    }

    _setStatus(VpnStatus.connecting);
    _addLog('Initializing CPRay Gaming tunnel: ${server.name} (${server.server}:${server.port})');

    try {
      final tempDir = await getApplicationSupportDirectory();
      final configFile = File(p.join(tempDir.path, 'cpray_config.json'));
      final jsonConfig = ConfigGenerator.generateJsonString(server: server, settings: settings);
      await configFile.writeAsString(jsonConfig);

      _addLog('Sing-box configuration generated (Mode: ${settings.vpnMode.name.toUpperCase()}, DNS: ${settings.antiSanctionMode ? "Anti-Sanction" : "Turbo DoH"})');

      final singboxExe = await _ensureSingboxBinary();
      _addLog('Target core executable: ${singboxExe.isNotEmpty ? singboxExe : 'Embedded Native Core'}');

      if (!Platform.isWindows) {
        _addLog('Non-Windows platform detected: ${Platform.operatingSystem.toUpperCase()}');
        _setStatus(VpnStatus.connected);
        _startSessionTimer();
        return;
      }

      if (!await File(singboxExe).exists()) {
        _addLog('[ERROR] Sing-box core binary could not be found or downloaded. Please check internet connection.');
        _setStatus(VpnStatus.error);
        return;
      }

      _process = await Process.start(
        singboxExe,
        ['run', '-c', configFile.path],
        environment: {
          'ENABLE_DEPRECATED_LEGACY_DNS_SERVERS': 'true',
          'ENABLE_DEPRECATED_MISSING_DOMAIN_RESOLVER': 'true',
        },
        mode: ProcessStartMode.normal,
      );

      _process!.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        _addLog(line);
        if (line.contains('started') || line.contains('sing-box started')) {
          _setStatus(VpnStatus.connected);
          _startSessionTimer();
          _startTrafficMonitoring();
          if (settings.vpnMode == VpnMode.systemProxy) {
            _setSystemProxy(true, settings.httpPort);
            _addLog('Windows System Proxy configured to 127.0.0.1:${settings.httpPort}');
          }
        }
      });

      _process!.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        _addLog('[ERROR] $line');
        if (line.contains('Access is denied') || line.contains('configure tun interface')) {
          _addLog('⚠️ [PERMISSION NOTICE] Wintun TUN mode requires Administrator Privileges. Please ensure CPRay Gaming is running as Administrator, or switch to Proxy Mode in Settings.');
        }
      });

      _process!.exitCode.then((code) {
        _addLog('Sing-box core exited with code $code');
        _stopSessionTimer();
        _stopTrafficMonitoring();
        if (settings.vpnMode == VpnMode.systemProxy) {
          _setSystemProxy(false, settings.httpPort);
        }
        if (_status != VpnStatus.disconnecting) {
          _setStatus(VpnStatus.disconnected);
        }
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (_status == VpnStatus.connecting) {
          _setStatus(VpnStatus.connected);
          _startSessionTimer();
          _startTrafficMonitoring();
          if (settings.vpnMode == VpnMode.systemProxy) {
            _setSystemProxy(true, settings.httpPort);
          }
        }
      });
    } catch (e) {
      _addLog('Failed to start VPN engine: $e');
      _setStatus(VpnStatus.error);
      _stopSessionTimer();
      _stopTrafficMonitoring();
    }
  }

  static Future<void> stopVpn() async {
    _setStatus(VpnStatus.disconnecting);
    _addLog('Disconnecting CPRay tunnel...');

    _stopSessionTimer();
    _stopTrafficMonitoring();
    await _setSystemProxy(false, 20809);

    if (_process != null) {
      _process!.kill(ProcessSignal.sigterm);
      _process = null;
    }

    if (Platform.isWindows) {
      try {
        await Process.run('taskkill', ['/F', '/IM', 'sing-box.exe']);
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 400));
    _setStatus(VpnStatus.disconnected);
    _addLog('Tunnel disconnected.');
  }

  static void _startSessionTimer() {
    _connectedSeconds = 0;
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _connectedSeconds++;
      _timerController.add(_connectedSeconds);
    });
  }

  static void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _connectedSeconds = 0;
    _timerController.add(0);
  }

  static String formatDuration(int totalSeconds) {
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
