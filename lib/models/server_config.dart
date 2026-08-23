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
