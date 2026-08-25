import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/game_target.dart';
import '../models/server_config.dart';
import '../services/audio_feedback_service.dart';
import '../services/game_ping_service.dart';
import '../services/ping_service.dart';
import '../services/storage_service.dart';
import '../services/subscription_service.dart';

class ServerProvider extends ChangeNotifier {
  List<ServerConfig> _servers = [];
  String? _subscriptionUrl;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<GameTarget> _gameTargets = List.from(GamePingService.defaultTargets);
  Timer? _autoHealthTimer;

  List<ServerConfig> get servers => List.unmodifiable(_servers);
  String? get subscriptionUrl => _subscriptionUrl;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  List<GameTarget> get gameTargets => List.unmodifiable(_gameTargets);

  List<ServerConfig> get filteredServers {
    if (_searchQuery.trim().isEmpty) return _servers;
    final query = _searchQuery.toLowerCase();
    return _servers.where((s) {
      return s.name.toLowerCase().contains(query) ||
          s.server.toLowerCase().contains(query) ||
          s.protocol.toLowerCase().contains(query);
    }).toList();
  }

  ServerProvider() {
    _loadInitialData();
    _startBackgroundAutoHealth();
  }

  Future<void> _loadInitialData() async {
    _servers = await StorageService.loadServers();
    final subUrl = await StorageService.loadSubscriptionUrl();
    final settings = await StorageService.loadSettings();
    _subscriptionUrl = (subUrl != null && subUrl.isNotEmpty) ? subUrl : settings.subscriptionUrl;
    notifyListeners();

    if (_servers.isNotEmpty) {
      testAllPings();
    }
  }

  void _startBackgroundAutoHealth() {
    _autoHealthTimer?.cancel();
    _autoHealthTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      if (_servers.isNotEmpty) {
        testAllPings();
      }
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> updateSubscription(String url) async {
    if (url.trim().isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await SubscriptionService.fetchSubscription(url);
      if (fetched.isEmpty) {
        _errorMessage = 'No valid servers found in this subscription URL.';
      } else {
        _servers = fetched;
        _subscriptionUrl = url;
        await StorageService.saveServers(_servers);
        await StorageService.saveSubscriptionUrl(url);

        final settings = await StorageService.loadSettings();
        await StorageService.saveSettings(settings.copyWith(subscriptionUrl: url));

        AudioFeedbackService.playPingSound();
        testAllPings();
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch subscription: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addManualConfig(String configLink) async {
    final parsed = SubscriptionService.parseSingleConfig(configLink);
    if (parsed != null) {
      _servers.insert(0, parsed);
      await StorageService.saveServers(_servers);
      testSinglePing(parsed);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> deleteServer(String id) async {
    _servers.removeWhere((s) => s.id == id);
    await StorageService.saveServers(_servers);
    notifyListeners();
  }

  Future<void> testAllPings() async {
    await PingService.testAllServers(_servers, onProgress: () {
      notifyListeners();
    });
    // Sort fastest servers to top
    _servers.sort((a, b) {
      final pA = (a.ping != null && a.ping! > 0) ? a.ping! : 9999;
      final pB = (b.ping != null && b.ping! > 0) ? b.ping! : 9999;
      return pA.compareTo(pB);
    });
    await StorageService.saveServers(_servers);
    notifyListeners();
  }

  Future<void> testSinglePing(ServerConfig server) async {
    final index = _servers.indexWhere((s) => s.id == server.id);
    if (index == -1) return;

    _servers[index].isTestingPing = true;
    notifyListeners();

    await PingService.testServerPing(_servers[index]);

    // Re-sort after ping
    _servers.sort((a, b) {
      final pA = (a.ping != null && a.ping! > 0) ? a.ping! : 9999;
      final pB = (b.ping != null && b.ping! > 0) ? b.ping! : 9999;
      return pA.compareTo(pB);
    });

    await StorageService.saveServers(_servers);
    notifyListeners();
  }

  Future<void> testGameTargetPing(GameTarget target) async {
    target.isTesting = true;
    notifyListeners();

    final ping = await GamePingService.testTargetPing(target);
    target.ping = ping;
    target.isTesting = false;
    notifyListeners();
  }

  Future<void> testAllGameTargets() async {
    for (final target in _gameTargets) {
      target.isTesting = true;
    }
    notifyListeners();

    const chunkSize = 10;
    for (var i = 0; i < _gameTargets.length; i += chunkSize) {
      final end = (i + chunkSize < _gameTargets.length) ? i + chunkSize : _gameTargets.length;
      final chunk = _gameTargets.sublist(i, end);

      await Future.wait(chunk.map((target) async {
        final ping = await GamePingService.testTargetPing(target);
        target.ping = ping;
        target.isTesting = false;
      }));
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _autoHealthTimer?.cancel();
    super.dispose();
  }
}
