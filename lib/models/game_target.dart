class GameTarget {
  final String id;
  final String gameName;
  final String region;
  final String host;
  final int port;
  final String icon;
  final String category;
  int? ping;
  bool isTesting;

  GameTarget({
    required this.id,
    required this.gameName,
    required this.region,
    required this.host,
    required this.port,
    required this.icon,
    this.category = 'Tactical Shooter',
    this.ping,
    this.isTesting = false,
  });
}
