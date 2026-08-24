import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../models/game_profile.dart';
import '../models/server_config.dart';
import '../services/audio_feedback_service.dart';
import '../services/localization_service.dart';
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

  // Jitter & Stability Metrics
  final List<double> _pingHistory = [65, 68, 64, 70, 66, 65, 67, 63, 69, 65];
  double _currentJitter = 2.4;
  double _packetLoss = 0.0;

  // Auto-failover counter
  int _consecutiveFailures = 0;

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
  List<double> get pingHistory => List.unmodifiable(_pingHistory);
  double get currentJitter => _currentJitter;
  double get packetLoss => _packetLoss;

  bool get isConnected => _status == VpnStatus.connected;
  bool get isConnecting => _status == VpnStatus.connecting;

  VpnProvider() {
    _init();
  }

  Future<void> _init() async {
    _settings = await StorageService.loadSettings();
    LocalizationService.currentLanguage = _settings.language;
    AudioFeedbackService.isEnabled = _settings.soundEffectsEnabled;
    notifyListeners();

    _statusSub = VpnService.statusStream.listen((newStatus) {
      _status = newStatus;
      if (_status == VpnStatus.connected) {
        AudioFeedbackService.playConnectSound();
        _startSpeedSimulation();
      } else if (_status == VpnStatus.disconnected) {
        AudioFeedbackService.playDisconnectSound();
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

  Future<void> setLanguage(String lang) async {
    LocalizationService.currentLanguage = lang;
    _settings = _settings.copyWith(language: lang);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setSoundEffects(bool enabled) async {
    AudioFeedbackService.isEnabled = enabled;
    _settings = _settings.copyWith(soundEffectsEnabled: enabled);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setAutoFailover(bool enabled) async {
    _settings = _settings.copyWith(autoFailoverEnabled: enabled);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setAntiSanctionMode(bool enabled, {String? provider}) async {
    _settings = _settings.copyWith(
      antiSanctionMode: enabled,
      antiSanctionProvider: provider ?? _settings.antiSanctionProvider,
    );
    await StorageService.saveSettings(_settings);
    notifyListeners();

    if (isConnected && _selectedServer != null) {
      await connect();
    }
  }

  Future<void> applyGameProfile(GameProfile profile) async {
    _settings = _settings.copyWith(
      activeGameProfileId: profile.id,
      selectedDns: profile.optimalDns,
      antiSanctionMode: profile.antiSanctionEnabled,
      splitTunnelMode: SplitTunnelMode.inclusive,
      splitTunnelApps: profile.processNames,
    );
    await StorageService.saveSettings(_settings);
    AudioFeedbackService.playSwitchSound();
    notifyListeners();

    if (isConnected && _selectedServer != null) {
      await connect();
    }
  }

  Future<void> setVpnMode(VpnMode mode) async {
    _settings = _settings.copyWith(vpnMode: mode);
    await StorageService.saveSettings(_settings);
    AudioFeedbackService.playSwitchSound();
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
    _speedTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (isConnected) {
        _downloadSpeed = (180.0 + (DateTime.now().millisecond % 840)).toDouble();
        _uploadSpeed = (48.0 + (DateTime.now().millisecond % 240)).toDouble();

        // Simulate rolling ping & jitter
        final basePing = _selectedServer?.ping != null && _selectedServer!.ping! > 0
            ? _selectedServer!.ping!.toDouble()
            : 65.0;
        final jitterDelta = (Random().nextDouble() * 6.0) - 3.0;
        final currentSample = (basePing + jitterDelta).clamp(20.0, 300.0);

        _pingHistory.add(currentSample);
        if (_pingHistory.length > 30) _pingHistory.removeAt(0);

        _currentJitter = (jitterDelta.abs() * 1.5).clamp(0.5, 12.0);
        _packetLoss = Random().nextInt(100) > 96 ? 1.0 : 0.0;
      } else {
        _downloadSpeed = 0.0;
        _uploadSpeed = 0.0;
        _currentJitter = 0.0;
        _packetLoss = 0.0;
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
