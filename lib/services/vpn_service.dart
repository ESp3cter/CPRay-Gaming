import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

  static Stream<VpnStatus> get statusStream => _statusController.stream;
  static Stream<String> get logStream => _logController.stream;
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
    final appDir = File(Platform.resolvedExecutable).parent.path;
    final primary = p.join(appDir, 'sing-box.exe');
    if (await File(primary).exists()) return primary;

    final dataDir = p.join(appDir, 'data', 'sing-box.exe');
    if (await File(dataDir).exists()) return dataDir;

    final tempDir = await getApplicationSupportDirectory();
    return p.join(tempDir.path, 'sing-box.exe');
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

  static Future<void> startVpn({
    required ServerConfig server,
    required AppSettings settings,
  }) async {
    if (_status == VpnStatus.connected || _status == VpnStatus.connecting) {
      await stopVpn();
    }

    _setStatus(VpnStatus.connecting);
    _addLog('Initializing CPRay tunnel for server: ${server.name} (${server.server}:${server.port})');

    try {
      final tempDir = await getApplicationSupportDirectory();
      final configFile = File(p.join(tempDir.path, 'cpray_config.json'));
      final jsonConfig = ConfigGenerator.generateJsonString(server: server, settings: settings);
      await configFile.writeAsString(jsonConfig);

      _addLog('Generated Sing-box configuration with Mode: ${settings.vpnMode.name.toUpperCase()}');

      final singboxExe = await _getSingboxPath();
      _addLog('Target core executable: $singboxExe');

      if (!await File(singboxExe).exists()) {
        _addLog('Core binary not found at $singboxExe. Simulating connection for UI testing.');
        await Future.delayed(const Duration(milliseconds: 1500));
        _setStatus(VpnStatus.connected);
        _startSessionTimer();
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
          if (settings.vpnMode == VpnMode.systemProxy) {
            _setSystemProxy(true, settings.httpPort);
          }
        }
      });
    } catch (e) {
      _addLog('Failed to start VPN engine: $e');
      _setStatus(VpnStatus.error);
      _stopSessionTimer();
    }
  }

  static Future<void> stopVpn() async {
    _setStatus(VpnStatus.disconnecting);
    _addLog('Disconnecting CPRay tunnel...');

    _stopSessionTimer();
    await _setSystemProxy(false, 20809);

    if (_process != null) {
      _process!.kill(ProcessSignal.sigterm);
      _process = null;
    }

    await Future.delayed(const Duration(milliseconds: 500));
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
