class GameTarget {
  final String id;
  final String gameName;
  final String region;
  final String host;
  final int port;
  final String icon;
  int? ping;
  bool isTesting;

  GameTarget({
    required this.id,
    required this.gameName,
    required this.region,
    required this.host,
    required this.port,
    required this.icon,
    this.ping,
    this.isTesting = false,
  });
}
