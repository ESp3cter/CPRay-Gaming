import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../models/server_config.dart';
import '../services/storage_service.dart';
import '../services/vpn_service.dart';

class VpnProvider extends ChangeNotifier {
  VpnStatus _status = VpnStatus.disconnected;
  AppSettings _settings = AppSettings();
  ServerConfig? _selectedServer;
  int _connectedSeconds = 0;
  List<String> _logs = [];

  double _uploadSpeed = 0.0;
  double _downloadSpeed = 0.0;
  Timer? _speedTimer;

  StreamSubscription<VpnStatus>? _statusSub;
  StreamSubscription<int>? _timerSub;
  StreamSubscription<String>? _logSub;

  VpnStatus get status => _status;
  AppSettings get settings => _settings;
  ServerConfig? get selectedServer => _selectedServer;
  int get connectedSeconds => _connectedSeconds;
  List<String> get logs => _logs;
  double get uploadSpeed => _uploadSpeed;
  double get downloadSpeed => _downloadSpeed;

  bool get isConnected => _status == VpnStatus.connected;
  bool get isConnecting => _status == VpnStatus.connecting;

  VpnProvider() {
    _init();
  }

  Future<void> _init() async {
    _settings = await StorageService.loadSettings();
    notifyListeners();

    _statusSub = VpnService.statusStream.listen((newStatus) {
      _status = newStatus;
      if (_status == VpnStatus.connected) {
        _startSpeedSimulation();
      } else {
        _stopSpeedSimulation();
      }
      notifyListeners();
    });

    _timerSub = VpnService.timerStream.listen((sec) {
      _connectedSeconds = sec;
      notifyListeners();
    });

    _logSub = VpnService.logStream.listen((log) {
      _logs = VpnService.logs;
      notifyListeners();
    });
  }

  void setSelectedServer(ServerConfig? server) {
    _selectedServer = server;
    if (server != null) {
      _settings = _settings.copyWith(lastSelectedServerId: server.id);
      StorageService.saveSettings(_settings);
    }
    notifyListeners();
  }

  Future<void> setVpnMode(VpnMode mode) async {
    _settings = _settings.copyWith(vpnMode: mode);
    await StorageService.saveSettings(_settings);
    notifyListeners();

    if (isConnected && _selectedServer != null) {
      await connect();
    }
  }

  Future<void> setBypassIranianTraffic(bool val) async {
    _settings = _settings.copyWith(bypassIranianTraffic: val);
    await StorageService.saveSettings(_settings);
    notifyListeners();

    if (isConnected && _selectedServer != null) {
      await connect();
    }
  }

  Future<void> setSplitTunneling(SplitTunnelMode mode, List<String> apps) async {
    _settings = _settings.copyWith(splitTunnelMode: mode, splitTunnelApps: apps);
    await StorageService.saveSettings(_settings);
    notifyListeners();

    if (isConnected && _selectedServer != null) {
      await connect();
    }
  }

  Future<void> setDnsSettings({required bool isAuto, required String customDns, String? selectedDns}) async {
    _settings = _settings.copyWith(
      isAutoDns: isAuto,
      customDns: customDns,
      selectedDns: selectedDns,
    );
    await StorageService.saveSettings(_settings);
    notifyListeners();

    if (isConnected && _selectedServer != null) {
      await connect();
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  void clearLogs() {
    VpnService.clearLogs();
    _logs = VpnService.logs;
    notifyListeners();
  }

  Future<void> toggleConnection() async {
    if (isConnected || isConnecting) {
      await disconnect();
    } else {
      await connect();
    }
  }

  Future<void> connect() async {
    if (_selectedServer == null) return;
    await VpnService.startVpn(
      server: _selectedServer!,
      settings: _settings,
    );
  }

  Future<void> disconnect() async {
    await VpnService.stopVpn();
  }

  void _startSpeedSimulation() {
    _speedTimer?.cancel();
    _speedTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (isConnected) {
        _downloadSpeed = (145.0 + (DateTime.now().millisecond % 920)).toDouble();
        _uploadSpeed = (42.0 + (DateTime.now().millisecond % 280)).toDouble();
      } else {
        _downloadSpeed = 0.0;
        _uploadSpeed = 0.0;
      }
      notifyListeners();
    });
  }

  void _stopSpeedSimulation() {
    _speedTimer?.cancel();
    _uploadSpeed = 0.0;
    _downloadSpeed = 0.0;
    notifyListeners();
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _timerSub?.cancel();
    _logSub?.cancel();
    _speedTimer?.cancel();
    super.dispose();
  }
}
