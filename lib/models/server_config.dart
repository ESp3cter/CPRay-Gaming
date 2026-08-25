class ServerConfig {
  final String id;
  final String name;
  final String protocol; // vless, vmess, trojan, hysteria2, tuic, wireguard, shadowsocks
  final String server;
  final int port;
  final String? uuid; // Or password
  final String? security; // tls, reality, none
  final String? sni;
  final String? pbk; // Reality public key
  final String? sid; // Reality short ID
  final String? spx; // SpiderX
  final String? flow;
  final String? network; // tcp, ws, grpc, httpupgrade
  final String? path;
  final String? host;
  final String? alpn;
  final String? fingerprint;
  final String? rawUri;
  
  // Wireguard specific
  final String? privateKey;
  final String? localAddress;
  final String? peerPublicKey;
  final String? presharedKey;

  // Runtime fields
  int? ping; // in milliseconds (-1 for timeout / fail)
  bool isTestingPing;

  ServerConfig({
    required this.id,
    required this.name,
    required this.protocol,
    required this.server,
    required this.port,
    this.uuid,
    this.security,
    this.sni,
    this.pbk,
    this.sid,
    this.spx,
    this.flow,
    this.network,
    this.path,
    this.host,
    this.alpn,
    this.fingerprint,
    this.rawUri,
    this.privateKey,
    this.localAddress,
    this.peerPublicKey,
    this.presharedKey,
    this.ping,
    this.isTestingPing = false,
  });

  bool get isUdpCapable {
    final p = protocol.toLowerCase();
    return p == 'hysteria2' || p == 'hy2' || p == 'tuic' || p == 'wireguard' || p == 'vless' || p == 'shadowsocks';
  }

  int get gamingScore {
    if (ping == null || ping! <= 0) return 0;

    int score = 0;

    // Latency Score (Up to 55 points)
    if (ping! < 50) {
      score += 55;
    } else if (ping! < 80) {
      score += 48;
    } else if (ping! < 110) {
      score += 38;
    } else if (ping! < 150) {
      score += 25;
    } else {
      score += 10;
    }

    // Protocol Score (Up to 30 points)
    final p = protocol.toLowerCase();
    if (p == 'hysteria2' || p == 'hy2' || p == 'tuic') {
      score += 30; // UDP-based BBR congestion control
    } else if (p == 'vless' && security == 'reality') {
      score += 26; // Direct TLS without web proxy overhead
    } else if (p == 'vless') {
      score += 22;
    } else if (p == 'trojan' || p == 'shadowsocks') {
      score += 18;
    } else {
      score += 10;
    }

    // Network Transport Score (Up to 15 points)
    final net = (network ?? 'tcp').toLowerCase();
    if (net == 'grpc' || net == 'tcp') {
      score += 15; // Low packet overhead
    } else if (net == 'httpupgrade') {
      score += 10;
    } else {
      score += 5; // WebSocket (more header overhead)
    }

    return score.clamp(0, 100);
  }

  String get gamingGrade {
    final s = gamingScore;
    if (s >= 85) return 'S+';
    if (s >= 70) return 'A';
    if (s >= 50) return 'B';
    return 'C';
  }

  String get gamingRecommendation {
    final g = gamingGrade;
    if (g == 'S+') return '👑 Best For Gaming (Ultra Low Jitter & UDP)';
    if (g == 'A') return '⚡ Competitive Gaming Grade';
    if (g == 'B') return '🎮 Playable Casual Gaming';
    return '🌐 Web Browsing / Download Only';
  }

  ServerConfig copyWith({
    String? id,
    String? name,
    String? protocol,
    String? server,
    int? port,
    String? uuid,
    String? security,
    String? sni,
    String? pbk,
    String? sid,
    String? spx,
    String? flow,
    String? network,
    String? path,
    String? host,
    String? alpn,
    String? fingerprint,
    String? rawUri,
    String? privateKey,
    String? localAddress,
    String? peerPublicKey,
    String? presharedKey,
    int? ping,
    bool? isTestingPing,
  }) {
    return ServerConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      protocol: protocol ?? this.protocol,
      server: server ?? this.server,
      port: port ?? this.port,
      uuid: uuid ?? this.uuid,
      security: security ?? this.security,
      sni: sni ?? this.sni,
      pbk: pbk ?? this.pbk,
      sid: sid ?? this.sid,
      spx: spx ?? this.spx,
      flow: flow ?? this.flow,
      network: network ?? this.network,
      path: path ?? this.path,
      host: host ?? this.host,
      alpn: alpn ?? this.alpn,
      fingerprint: fingerprint ?? this.fingerprint,
      rawUri: rawUri ?? this.rawUri,
      privateKey: privateKey ?? this.privateKey,
      localAddress: localAddress ?? this.localAddress,
      peerPublicKey: peerPublicKey ?? this.peerPublicKey,
      presharedKey: presharedKey ?? this.presharedKey,
      ping: ping ?? this.ping,
      isTestingPing: isTestingPing ?? this.isTestingPing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'protocol': protocol,
      'server': server,
      'port': port,
      'uuid': uuid,
      'security': security,
      'sni': sni,
      'pbk': pbk,
      'sid': sid,
      'spx': spx,
      'flow': flow,
      'network': network,
      'path': path,
      'host': host,
      'alpn': alpn,
      'fingerprint': fingerprint,
      'rawUri': rawUri,
      'privateKey': privateKey,
      'localAddress': localAddress,
      'peerPublicKey': peerPublicKey,
      'presharedKey': presharedKey,
      'ping': ping,
    };
  }

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      protocol: json['protocol'] as String,
      server: json['server'] as String,
      port: json['port'] as int,
      uuid: json['uuid'] as String?,
      security: json['security'] as String?,
      sni: json['sni'] as String?,
      pbk: json['pbk'] as String?,
      sid: json['sid'] as String?,
      spx: json['spx'] as String?,
      flow: json['flow'] as String?,
      network: json['network'] as String?,
      path: json['path'] as String?,
      host: json['host'] as String?,
      alpn: json['alpn'] as String?,
      fingerprint: json['fingerprint'] as String?,
      rawUri: json['rawUri'] as String?,
      privateKey: json['privateKey'] as String?,
      localAddress: json['localAddress'] as String?,
      peerPublicKey: json['peerPublicKey'] as String?,
      presharedKey: json['presharedKey'] as String?,
      ping: json['ping'] as int?,
    );
  }
}
