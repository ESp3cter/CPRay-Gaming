class AppSettings {
  final bool isGamingTunMode;
  final bool autoStartOnBoot;
  final bool autoConnectOnLaunch;
  final String selectedDns; // "1.1.1.1", "8.8.8.8", "77.88.8.8"
  final bool bypassDomesticIps;
  final int socksPort;
  final int httpPort;
  final String? subscriptionUrl;
  final String? lastSelectedServerId;

  AppSettings({
    this.isGamingTunMode = true,
    this.autoStartOnBoot = false,
    this.autoConnectOnLaunch = false,
    this.selectedDns = "1.1.1.1",
    this.bypassDomesticIps = true,
    this.socksPort = 20808,
    this.httpPort = 20809,
    this.subscriptionUrl,
    this.lastSelectedServerId,
  });

  AppSettings copyWith({
    bool? isGamingTunMode,
    bool? autoStartOnBoot,
    bool? autoConnectOnLaunch,
    String? selectedDns,
    bool? bypassDomesticIps,
    int? socksPort,
    int? httpPort,
    String? subscriptionUrl,
    String? lastSelectedServerId,
  }) {
    return AppSettings(
      isGamingTunMode: isGamingTunMode ?? this.isGamingTunMode,
      autoStartOnBoot: autoStartOnBoot ?? this.autoStartOnBoot,
      autoConnectOnLaunch: autoConnectOnLaunch ?? this.autoConnectOnLaunch,
      selectedDns: selectedDns ?? this.selectedDns,
      bypassDomesticIps: bypassDomesticIps ?? this.bypassDomesticIps,
      socksPort: socksPort ?? this.socksPort,
      httpPort: httpPort ?? this.httpPort,
      subscriptionUrl: subscriptionUrl ?? this.subscriptionUrl,
      lastSelectedServerId: lastSelectedServerId ?? this.lastSelectedServerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isGamingTunMode': isGamingTunMode,
      'autoStartOnBoot': autoStartOnBoot,
      'autoConnectOnLaunch': autoConnectOnLaunch,
      'selectedDns': selectedDns,
      'bypassDomesticIps': bypassDomesticIps,
      'socksPort': socksPort,
      'httpPort': httpPort,
      'subscriptionUrl': subscriptionUrl,
      'lastSelectedServerId': lastSelectedServerId,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isGamingTunMode: json['isGamingTunMode'] as bool? ?? true,
      autoStartOnBoot: json['autoStartOnBoot'] as bool? ?? false,
      autoConnectOnLaunch: json['autoConnectOnLaunch'] as bool? ?? false,
      selectedDns: json['selectedDns'] as String? ?? "1.1.1.1",
      bypassDomesticIps: json['bypassDomesticIps'] as bool? ?? true,
      socksPort: json['socksPort'] as int? ?? 20808,
      httpPort: json['httpPort'] as int? ?? 20809,
      subscriptionUrl: json['subscriptionUrl'] as String?,
      lastSelectedServerId: json['lastSelectedServerId'] as String?,
    );
  }
}
