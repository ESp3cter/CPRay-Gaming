import 'package:flutter/foundation.dart';
import '../models/server_config.dart';
import '../services/ping_service.dart';
import '../services/storage_service.dart';
import '../services/subscription_service.dart';

class ServerProvider extends ChangeNotifier {
  List<ServerConfig> _servers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _subscriptionUrl;

  List<ServerConfig> get servers => _servers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get subscriptionUrl => _subscriptionUrl;

  List<ServerConfig> get filteredServers {
    if (_searchQuery.isEmpty) return _servers;
    return _servers.where((s) {
      return s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.protocol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.server.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  ServerProvider() {
    _init();
  }

  Future<void> _init() async {
    _servers = await StorageService.loadServers();
    _subscriptionUrl = await StorageService.loadSubscriptionUrl();
    notifyListeners();
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
        _errorMessage = 'No valid VPN nodes found in subscription link.';
      } else {
        _servers = fetched;
        _subscriptionUrl = url.trim();
        await StorageService.saveSubscriptionUrl(_subscriptionUrl!);
        await StorageService.saveServers(_servers);
        
        // Auto test ping on all fetched servers
        testAllPings();
      }
    } catch (e) {
      _errorMessage = 'Failed to update subscription: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addManualConfig(String rawConfig) async {
    final server = SubscriptionService.parseUri(rawConfig.trim(), 'manual_${DateTime.now().millisecondsSinceEpoch}');
    if (server != null) {
      _servers.insert(0, server);
      await StorageService.saveServers(_servers);
      notifyListeners();
      PingService.testServerPing(server).then((_) => notifyListeners());
      return true;
    }
    return false;
  }

  Future<void> testAllPings() async {
    await PingService.testAllServers(_servers, onProgress: () {
      notifyListeners();
    });
    // Sort servers by lowest ping (placing timed-out / -1 at end)
    _servers.sort((a, b) {
      final pingA = (a.ping != null && a.ping! > 0) ? a.ping! : 99999;
      final pingB = (b.ping != null && b.ping! > 0) ? b.ping! : 99999;
      return pingA.compareTo(pingB);
    });
    await StorageService.saveServers(_servers);
    notifyListeners();
  }

  Future<void> testSinglePing(ServerConfig server) async {
    await PingService.testServerPing(server);
    notifyListeners();
  }

  Future<void> deleteServer(String id) async {
    _servers.removeWhere((s) => s.id == id);
    await StorageService.saveServers(_servers);
    notifyListeners();
  }
}
