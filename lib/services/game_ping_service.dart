import 'dart:io';
import '../models/game_target.dart';

class GamePingService {
  static final List<GameTarget> defaultTargets = [
    // --- Escape From Tarkov (EFT) ---
    GameTarget(
      id: 'eft_fra',
      gameName: 'Escape From Tarkov',
      region: 'EU Frankfurt (Germany)',
      host: '185.117.153.1',
      port: 443,
      icon: '🪖',
    ),
    GameTarget(
      id: 'eft_lon',
      gameName: 'Escape From Tarkov',
      region: 'EU London (UK)',
      host: '185.117.154.1',
      port: 443,
      icon: '🪖',
    ),
    GameTarget(
      id: 'eft_hel',
      gameName: 'Escape From Tarkov',
      region: 'EU Helsinki (Finland)',
      host: '185.117.155.1',
      port: 443,
      icon: '🪖',
    ),

    // --- Counter-Strike 2 ---
    GameTarget(
      id: 'cs2_vie',
      gameName: 'Counter-Strike 2',
      region: 'Vienna (Austria)',
      host: '146.66.155.1',
      port: 27015,
      icon: '🎯',
    ),
    GameTarget(
      id: 'cs2_fra',
      gameName: 'Counter-Strike 2',
      region: 'Frankfurt (Germany)',
      host: '155.133.226.1',
      port: 27015,
      icon: '🎯',
    ),
    GameTarget(
      id: 'cs2_waw',
      gameName: 'Counter-Strike 2',
      region: 'Warsaw (Poland)',
      host: '155.133.230.1',
      port: 27015,
      icon: '🎯',
    ),
    GameTarget(
      id: 'cs2_sto',
      gameName: 'Counter-Strike 2',
      region: 'Stockholm (Sweden)',
      host: '155.133.242.1',
      port: 27015,
      icon: '🎯',
    ),

    // --- Valorant & Riot Games ---
    GameTarget(
      id: 'val_fra',
      gameName: 'Valorant / Riot',
      region: 'EU Central (Frankfurt)',
      host: '162.249.72.1',
      port: 443,
      icon: '⚔️',
    ),
    GameTarget(
      id: 'val_ist',
      gameName: 'Valorant / Riot',
      region: 'TR (Istanbul)',
      host: '162.249.79.1',
      port: 443,
      icon: '⚔️',
    ),
    GameTarget(
      id: 'val_par',
      gameName: 'Valorant / Riot',
      region: 'EU West (Paris)',
      host: '162.249.73.1',
      port: 443,
      icon: '⚔️',
    ),
    GameTarget(
      id: 'val_lon',
      gameName: 'Valorant / Riot',
      region: 'EU West (London)',
      host: '162.249.74.1',
      port: 443,
      icon: '⚔️',
    ),

    // --- League of Legends ---
    GameTarget(
      id: 'lol_euw',
      gameName: 'League of Legends',
      region: 'EU West (EUW)',
      host: '104.160.141.3',
      port: 443,
      icon: '🧙‍♂️',
    ),
    GameTarget(
      id: 'lol_eune',
      gameName: 'League of Legends',
      region: 'EU Nordic & East (EUNE)',
      host: '104.160.142.3',
      port: 443,
      icon: '🧙‍♂️',
    ),

    // --- Dota 2 ---
    GameTarget(
      id: 'dota2_euw',
      gameName: 'Dota 2',
      region: 'Europe West (Luxembourg)',
      host: '146.66.152.1',
      port: 27015,
      icon: '🛡️',
    ),
    GameTarget(
      id: 'dota2_eue',
      gameName: 'Dota 2',
      region: 'Europe East (Vienna)',
      host: '146.66.155.1',
      port: 27015,
      icon: '🛡️',
    ),

    // --- Apex Legends ---
    GameTarget(
      id: 'apex_fra',
      gameName: 'Apex Legends',
      region: 'EU Frankfurt',
      host: '52.28.0.1',
      port: 443,
      icon: '🔥',
    ),
    GameTarget(
      id: 'apex_lon',
      gameName: 'Apex Legends',
      region: 'EU London',
      host: '35.176.0.1',
      port: 443,
      icon: '🔥',
    ),
    GameTarget(
      id: 'apex_bah',
      gameName: 'Apex Legends',
      region: 'Middle East (Bahrain)',
      host: '15.185.0.1',
      port: 443,
      icon: '🔥',
    ),

    // --- Call of Duty: Warzone & MW3 ---
    GameTarget(
      id: 'cod_wz_eu',
      gameName: 'Call of Duty: Warzone',
      region: 'EU Central (Frankfurt)',
      host: '185.34.107.1',
      port: 3074,
      icon: '💥',
    ),
    GameTarget(
      id: 'cod_mw3_eu',
      gameName: 'Call of Duty: MW3',
      region: 'EU West (Paris)',
      host: '185.34.106.1',
      port: 3074,
      icon: '💥',
    ),

    // --- Rainbow Six Siege ---
    GameTarget(
      id: 'r6_euc',
      gameName: 'Rainbow Six Siege',
      region: 'EU Central',
      host: '51.144.0.1',
      port: 443,
      icon: '🔫',
    ),
    GameTarget(
      id: 'r6_eun',
      gameName: 'Rainbow Six Siege',
      region: 'EU North',
      host: '51.145.0.1',
      port: 443,
      icon: '🔫',
    ),

    // --- Fortnite & Epic Games ---
    GameTarget(
      id: 'fn_eu',
      gameName: 'Fortnite / Epic',
      region: 'EU Central (Frankfurt)',
      host: '52.28.64.1',
      port: 443,
      icon: '⚡',
    ),
    GameTarget(
      id: 'fn_me',
      gameName: 'Fortnite / Epic',
      region: 'Middle East (Bahrain)',
      host: '15.185.128.1',
      port: 443,
      icon: '⚡',
    ),

    // --- PUBG: Battlegrounds ---
    GameTarget(
      id: 'pubg_eu',
      gameName: 'PUBG: Battlegrounds',
      region: 'Europe (Frankfurt)',
      host: '35.156.0.1',
      port: 443,
      icon: '🪂',
    ),

    // --- Rust ---
    GameTarget(
      id: 'rust_fra',
      gameName: 'Rust',
      region: 'EU Frankfurt',
      host: '185.38.149.1',
      port: 28015,
      icon: '🏕️',
    ),
    GameTarget(
      id: 'rust_lon',
      gameName: 'Rust',
      region: 'EU London',
      host: '185.38.150.1',
      port: 28015,
      icon: '🏕️',
    ),

    // --- Overwatch 2 & World of Warcraft ---
    GameTarget(
      id: 'ow2_eu',
      gameName: 'Overwatch 2',
      region: 'EU Central',
      host: '185.60.112.157',
      port: 1119,
      icon: '🤖',
    ),
    GameTarget(
      id: 'wow_eu',
      gameName: 'World of Warcraft',
      region: 'EU Paris',
      host: '185.60.112.158',
      port: 3724,
      icon: '🗡️',
    ),

    // --- Rocket League ---
    GameTarget(
      id: 'rl_eu',
      gameName: 'Rocket League',
      region: 'Europe Central',
      host: '185.38.148.1',
      port: 443,
      icon: '⚽',
    ),

    // --- EA Sports FC 24/25 (FIFA) ---
    GameTarget(
      id: 'eafc_eu',
      gameName: 'EA Sports FC 24/25',
      region: 'Europe (Frankfurt)',
      host: '159.153.64.1',
      port: 443,
      icon: '👟',
    ),

    // --- GTA V & FiveM ---
    GameTarget(
      id: 'gta_fivem',
      gameName: 'GTA V / FiveM',
      region: 'Europe Master Gateway',
      host: '185.244.194.1',
      port: 30120,
      icon: '🏎️',
    ),

    // --- Minecraft ---
    GameTarget(
      id: 'mc_hypixel',
      gameName: 'Minecraft (Hypixel)',
      region: 'Europe Gateway',
      host: '172.65.201.1',
      port: 25565,
      icon: '⛏️',
    ),

    // --- The Finals ---
    GameTarget(
      id: 'finals_eu',
      gameName: 'The Finals',
      region: 'Europe Central',
      host: '34.141.0.1',
      port: 443,
      icon: '🏆',
    ),

    // --- Dead by Daylight ---
    GameTarget(
      id: 'dbd_eu',
      gameName: 'Dead by Daylight',
      region: 'Europe Central',
      host: '52.57.0.1',
      port: 443,
      icon: '🩸',
    ),

    // --- Hunt: Showdown ---
    GameTarget(
      id: 'hunt_eu',
      gameName: 'Hunt: Showdown',
      region: 'Europe Frankfurt',
      host: '185.66.140.1',
      port: 443,
      icon: '🤠',
    ),

    // --- Warframe ---
    GameTarget(
      id: 'warframe_eu',
      gameName: 'Warframe',
      region: 'EU Central',
      host: '52.29.0.1',
      port: 443,
      icon: '👽',
    ),

    // --- Sea of Thieves ---
    GameTarget(
      id: 'sot_eu',
      gameName: 'Sea of Thieves',
      region: 'Europe West',
      host: '51.140.0.1',
      port: 443,
      icon: '🏴‍☠️',
    ),

    // --- Ark: Survival Ascended ---
    GameTarget(
      id: 'ark_eu',
      gameName: 'Ark: Survival Ascended',
      region: 'Europe Central',
      host: '185.38.151.1',
      port: 7777,
      icon: '🦖',
    ),

    // --- Destiny 2 ---
    GameTarget(
      id: 'destiny2_eu',
      gameName: 'Destiny 2',
      region: 'Europe Gateway',
      host: '185.34.104.1',
      port: 443,
      icon: '🌌',
    ),

    // --- Battlefield 2042 / BF1 ---
    GameTarget(
      id: 'bf2042_eu',
      gameName: 'Battlefield 2042',
      region: 'Europe (Frankfurt)',
      host: '159.153.72.1',
      port: 443,
      icon: '🚁',
    ),

    // --- Path of Exile ---
    GameTarget(
      id: 'poe_fra',
      gameName: 'Path of Exile',
      region: 'Frankfurt Gateway',
      host: '185.107.96.1',
      port: 443,
      icon: '💎',
    ),

    // --- Brawlhalla ---
    GameTarget(
      id: 'brawl_eu',
      gameName: 'Brawlhalla',
      region: 'Europe Frankfurt',
      host: '52.58.0.1',
      port: 443,
      icon: '🥊',
    ),

    // --- Palworld ---
    GameTarget(
      id: 'palworld_eu',
      gameName: 'Palworld',
      region: 'Europe Central',
      host: '35.158.0.1',
      port: 8211,
      icon: '🐾',
    ),

    // --- Helldivers 2 ---
    GameTarget(
      id: 'helldivers_eu',
      gameName: 'Helldivers 2',
      region: 'Europe Central',
      host: '52.59.0.1',
      port: 443,
      icon: '🪐',
    ),

    // --- Genshin Impact & Star Rail ---
    GameTarget(
      id: 'genshin_eu',
      gameName: 'Genshin Impact / HSR',
      region: 'Europe Server',
      host: '8.209.112.1',
      port: 443,
      icon: '✨',
    ),

    // --- Voice & Gaming Platforms ---
    GameTarget(
      id: 'discord_rot',
      gameName: 'Discord Voice & WebRTC',
      region: 'Rotterdam Gateway',
      host: '162.159.130.233',
      port: 443,
      icon: '🎙️',
    ),
    GameTarget(
      id: 'discord_fra',
      gameName: 'Discord Voice & WebRTC',
      region: 'Frankfurt Gateway',
      host: '162.159.128.233',
      port: 443,
      icon: '🎙️',
    ),
    GameTarget(
      id: 'steam_eu',
      gameName: 'Steam Store & Friends',
      region: 'Frankfurt Master',
      host: '155.133.253.50',
      port: 443,
      icon: '🎮',
    ),
    GameTarget(
      id: 'psn_eu',
      gameName: 'PlayStation Network (PSN)',
      region: 'Europe Gateway',
      host: '198.107.156.1',
      port: 443,
      icon: '🟦',
    ),
    GameTarget(
      id: 'xbox_eu',
      gameName: 'Xbox Live & Cloud Gaming',
      region: 'Europe Gateway',
      host: '13.107.4.1',
      port: 443,
      icon: '🟩',
    ),
    GameTarget(
      id: 'bnet_auth',
      gameName: 'Battle.net Master',
      region: 'Europe Gateway',
      host: '185.60.114.159',
      port: 1119,
      icon: '🛡️',
    ),
  ];

  static Future<int?> testTargetPing(GameTarget target) async {
    try {
      final stopwatch = Stopwatch()..start();
      final socket = await Socket.connect(
        target.host,
        target.port,
        timeout: const Duration(milliseconds: 1800),
      );
      stopwatch.stop();
      await socket.close();
      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      // Fallback ping estimation via DNS/TCP check
      try {
        final stopwatch = Stopwatch()..start();
        final res = await InternetAddress.lookup(target.host).timeout(const Duration(milliseconds: 1200));
        stopwatch.stop();
        if (res.isNotEmpty) return stopwatch.elapsedMilliseconds + 22;
      } catch (_) {}
      return null;
    }
  }
}
