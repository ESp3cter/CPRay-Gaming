class GameProfile {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String optimalDns;
  final List<String> processNames;
  final String targetRegion;
  final bool antiSanctionEnabled;

  const GameProfile({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.optimalDns,
    required this.processNames,
    required this.targetRegion,
    this.antiSanctionEnabled = false,
  });

  static const List<GameProfile> defaultProfiles = [
    GameProfile(
      id: 'cs2',
      title: 'Counter-Strike 2 Competitive',
      description: 'Optimized for lowest UDP jitter and Vienna/Frankfurt matchmaking.',
      icon: '🎯',
      optimalDns: '1.1.1.1',
      processNames: ['cs2.exe', 'steam.exe', 'steamwebhelper.exe'],
      targetRegion: 'Vienna / Frankfurt',
    ),
    GameProfile(
      id: 'valorant',
      title: 'Valorant Anti-Sanction & Vanguard',
      description: 'Anti-sanction bypass with Vanguard anti-cheat direct routing.',
      icon: '⚔️',
      optimalDns: '10.202.10.10',
      processNames: ['valorant.exe', 'riotclientservices.exe', 'vgc.exe'],
      targetRegion: 'Frankfurt / Istanbul',
      antiSanctionEnabled: true,
    ),
    GameProfile(
      id: 'dota2',
      title: 'Dota 2 Europe Low Jitter',
      description: 'Zero packet loss smoothing for Europe West ranked matchmaking.',
      icon: '🛡️',
      optimalDns: '8.8.8.8',
      processNames: ['dota2.exe', 'steam.exe'],
      targetRegion: 'Luxembourg / Vienna',
    ),
    GameProfile(
      id: 'discord',
      title: 'Discord Voice & Streaming',
      description: 'Prioritizes WebRTC voice packets and high-bitrate streaming.',
      icon: '🎙️',
      optimalDns: '1.1.1.1',
      processNames: ['discord.exe', 'obs64.exe'],
      targetRegion: 'Rotterdam / Frankfurt',
    ),
    GameProfile(
      id: 'warzone',
      title: 'Call of Duty: Warzone & Apex',
      description: 'Low-latency routing tailored for EA and Battle.net multiplayer.',
      icon: '🔥',
      optimalDns: '9.9.9.9',
      processNames: ['cod.exe', 'r5apex.exe', 'battle.net.exe'],
      targetRegion: 'EU Central / Bahrain',
    ),
  ];
}
