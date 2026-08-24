enum VpnMode {
  tun, // Full Gaming TUN Mode (Wintun)
  systemProxy, // Windows System Proxy (Browsers & Apps via HTTP/SOCKS)
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
  final String selectedDns; // "1.1.1.1", "8.8.8.8", "77.88.8.8"
  final String customDns;
  final SplitTunnelMode splitTunnelMode;
  final List<String> splitTunnelApps;
  final int socksPort;
  final int httpPort;
  final String? subscriptionUrl;
  final String? lastSelectedServerId;

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
    this.splitTunnelApps = const ['steam.exe', 'discord.exe', 'cs2.exe', 'valorant.exe'],
    this.socksPort = 20808,
    this.httpPort = 20809,
    this.subscriptionUrl,
    this.lastSelectedServerId,
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
          ['steam.exe', 'discord.exe', 'cs2.exe', 'valorant.exe'],
      socksPort: json['socksPort'] as int? ?? 20808,
      httpPort: json['httpPort'] as int? ?? 20809,
      subscriptionUrl: json['subscriptionUrl'] as String?,
      lastSelectedServerId: json['lastSelectedServerId'] as String?,
    );
  }
}
