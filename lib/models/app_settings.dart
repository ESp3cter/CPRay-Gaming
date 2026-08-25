enum VpnMode {
  tun, // Full Gaming TUN Mode (Wintun)
  systemProxy, // Windows System Proxy (Browsers & Apps via HTTP/SOCKS)
  antiSanctionOnly, // 0-Latency Anti-Sanction DNS Mode
}

enum SplitTunnelMode {
  disabled,
  inclusive, // Only proxy listed apps
  exclusive, // Proxy all EXCEPT listed apps
}

class AppSettings {
  final VpnMode vpnMode;
  final bool autoStartOnBoot;
  final bool autoConnectOnLaunch;
  final bool bypassIranianTraffic;
  final bool isAutoDns;
  final String selectedDns;
  final String customDns;
  final SplitTunnelMode splitTunnelMode;
  final List<String> splitTunnelApps;
  final int socksPort;
  final int httpPort;
  final String? subscriptionUrl;
  final String? lastSelectedServerId;

  final String language; // 'en' or 'fa'
  final bool soundEffectsEnabled;
  final bool autoFailoverEnabled;
  final bool antiSanctionMode;
  final String antiSanctionProvider; // 'radar', 'electro', 'shecan', 'dns4s'

  // Per-App Game Optimizer Boosted IDs (max 5)
  final List<String> boostedGameIds;
  final List<String> customGameExes;

  // Compatibility getter
  bool get isGamingTunMode => vpnMode == VpnMode.tun;

  AppSettings({
    this.vpnMode = VpnMode.tun,
    this.autoStartOnBoot = false,
    this.autoConnectOnLaunch = false,
    this.bypassIranianTraffic = true,
    this.isAutoDns = true,
    this.selectedDns = "1.1.1.1",
    this.customDns = "1.1.1.1",
    this.splitTunnelMode = SplitTunnelMode.disabled,
    this.splitTunnelApps = const [],
    this.socksPort = 20808,
    this.httpPort = 20809,
    this.subscriptionUrl,
    this.lastSelectedServerId,
    this.language = 'en',
    this.soundEffectsEnabled = true,
    this.autoFailoverEnabled = true,
    this.antiSanctionMode = false,
    this.antiSanctionProvider = 'radar',
    this.boostedGameIds = const [],
    this.customGameExes = const [],
  });

  AppSettings copyWith({
    VpnMode? vpnMode,
    bool? autoStartOnBoot,
    bool? autoConnectOnLaunch,
    bool? bypassIranianTraffic,
    bool? isAutoDns,
    String? selectedDns,
    String? customDns,
    SplitTunnelMode? splitTunnelMode,
    List<String>? splitTunnelApps,
    int? socksPort,
    int? httpPort,
    String? subscriptionUrl,
    String? lastSelectedServerId,
    String? language,
    bool? soundEffectsEnabled,
    bool? autoFailoverEnabled,
    bool? antiSanctionMode,
    String? antiSanctionProvider,
    List<String>? boostedGameIds,
    List<String>? customGameExes,
  }) {
    return AppSettings(
      vpnMode: vpnMode ?? this.vpnMode,
      autoStartOnBoot: autoStartOnBoot ?? this.autoStartOnBoot,
      autoConnectOnLaunch: autoConnectOnLaunch ?? this.autoConnectOnLaunch,
      bypassIranianTraffic: bypassIranianTraffic ?? this.bypassIranianTraffic,
      isAutoDns: isAutoDns ?? this.isAutoDns,
      selectedDns: selectedDns ?? this.selectedDns,
      customDns: customDns ?? this.customDns,
      splitTunnelMode: splitTunnelMode ?? this.splitTunnelMode,
      splitTunnelApps: splitTunnelApps ?? this.splitTunnelApps,
      socksPort: socksPort ?? this.socksPort,
      httpPort: httpPort ?? this.httpPort,
      subscriptionUrl: subscriptionUrl ?? this.subscriptionUrl,
      lastSelectedServerId: lastSelectedServerId ?? this.lastSelectedServerId,
      language: language ?? this.language,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      autoFailoverEnabled: autoFailoverEnabled ?? this.autoFailoverEnabled,
      antiSanctionMode: antiSanctionMode ?? this.antiSanctionMode,
      antiSanctionProvider: antiSanctionProvider ?? this.antiSanctionProvider,
      boostedGameIds: boostedGameIds ?? this.boostedGameIds,
      customGameExes: customGameExes ?? this.customGameExes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vpnMode': vpnMode.index,
      'autoStartOnBoot': autoStartOnBoot,
      'autoConnectOnLaunch': autoConnectOnLaunch,
      'bypassIranianTraffic': bypassIranianTraffic,
      'isAutoDns': isAutoDns,
      'selectedDns': selectedDns,
      'customDns': customDns,
      'splitTunnelMode': splitTunnelMode.index,
      'splitTunnelApps': splitTunnelApps,
      'socksPort': socksPort,
      'httpPort': httpPort,
      'subscriptionUrl': subscriptionUrl,
      'lastSelectedServerId': lastSelectedServerId,
      'language': language,
      'soundEffectsEnabled': soundEffectsEnabled,
      'autoFailoverEnabled': autoFailoverEnabled,
      'antiSanctionMode': antiSanctionMode,
      'antiSanctionProvider': antiSanctionProvider,
      'boostedGameIds': boostedGameIds,
      'customGameExes': customGameExes,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      vpnMode: json['vpnMode'] != null ? VpnMode.values[json['vpnMode'] as int] : VpnMode.tun,
      autoStartOnBoot: json['autoStartOnBoot'] as bool? ?? false,
      autoConnectOnLaunch: json['autoConnectOnLaunch'] as bool? ?? false,
      bypassIranianTraffic: json['bypassIranianTraffic'] as bool? ?? true,
      isAutoDns: json['isAutoDns'] as bool? ?? true,
      selectedDns: json['selectedDns'] as String? ?? "1.1.1.1",
      customDns: json['customDns'] as String? ?? "1.1.1.1",
      splitTunnelMode: json['splitTunnelMode'] != null
          ? SplitTunnelMode.values[json['splitTunnelMode'] as int]
          : SplitTunnelMode.disabled,
      splitTunnelApps: (json['splitTunnelApps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      socksPort: json['socksPort'] as int? ?? 20808,
      httpPort: json['httpPort'] as int? ?? 20809,
      subscriptionUrl: json['subscriptionUrl'] as String?,
      lastSelectedServerId: json['lastSelectedServerId'] as String?,
      language: json['language'] as String? ?? 'en',
      soundEffectsEnabled: json['soundEffectsEnabled'] as bool? ?? true,
      autoFailoverEnabled: json['autoFailoverEnabled'] as bool? ?? true,
      antiSanctionMode: json['antiSanctionMode'] as bool? ?? false,
      antiSanctionProvider: json['antiSanctionProvider'] as String? ?? 'radar',
      boostedGameIds: (json['boostedGameIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      customGameExes: (json['customGameExes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
