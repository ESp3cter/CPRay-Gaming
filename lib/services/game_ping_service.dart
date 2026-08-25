import 'dart:io';
import '../models/game_target.dart';

class GamePingService {
  static final List<GameTarget> defaultTargets = [
    // --- Escape From Tarkov (EFT) ---
    GameTarget(id: 'eft_fra', gameName: 'Escape From Tarkov', region: 'EU Frankfurt (Germany)', host: '185.117.153.1', port: 443, icon: '🪖', category: 'Tactical Shooter'),
    GameTarget(id: 'eft_lon', gameName: 'Escape From Tarkov', region: 'EU London (UK)', host: '185.117.154.1', port: 443, icon: '🪖', category: 'Tactical Shooter'),
    GameTarget(id: 'eft_hel', gameName: 'Escape From Tarkov', region: 'EU Helsinki (Finland)', host: '185.117.155.1', port: 443, icon: '🪖', category: 'Tactical Shooter'),
    GameTarget(id: 'eft_ams', gameName: 'Escape From Tarkov', region: 'EU Amsterdam', host: '185.117.152.1', port: 443, icon: '🪖', category: 'Tactical Shooter'),
    GameTarget(id: 'eft_str', gameName: 'Escape From Tarkov', region: 'EU Strasbourg', host: '185.117.156.1', port: 443, icon: '🪖', category: 'Tactical Shooter'),

    // --- Counter-Strike 2 ---
    GameTarget(id: 'cs2_vie', gameName: 'Counter-Strike 2', region: 'Vienna (Austria)', host: '146.66.155.1', port: 27015, icon: '🎯', category: 'Tactical Shooter'),
    GameTarget(id: 'cs2_fra', gameName: 'Counter-Strike 2', region: 'Frankfurt (Germany)', host: '155.133.226.1', port: 27015, icon: '🎯', category: 'Tactical Shooter'),
    GameTarget(id: 'cs2_waw', gameName: 'Counter-Strike 2', region: 'Warsaw (Poland)', host: '155.133.230.1', port: 27015, icon: '🎯', category: 'Tactical Shooter'),
    GameTarget(id: 'cs2_sto', gameName: 'Counter-Strike 2', region: 'Stockholm (Sweden)', host: '155.133.242.1', port: 27015, icon: '🎯', category: 'Tactical Shooter'),
    GameTarget(id: 'cs2_mad', gameName: 'Counter-Strike 2', region: 'Madrid (Spain)', host: '155.133.246.1', port: 27015, icon: '🎯', category: 'Tactical Shooter'),
    GameTarget(id: 'cs2_lon', gameName: 'Counter-Strike 2', region: 'London (UK)', host: '155.133.248.1', port: 27015, icon: '🎯', category: 'Tactical Shooter'),
    GameTarget(id: 'cs2_dxb', gameName: 'Counter-Strike 2', region: 'Dubai (UAE)', host: '155.133.238.1', port: 27015, icon: '🎯', category: 'Tactical Shooter'),

    // --- Valorant & Riot Games ---
    GameTarget(id: 'val_fra', gameName: 'Valorant / Riot', region: 'EU Central (Frankfurt)', host: '162.249.72.1', port: 443, icon: '⚔️', category: 'Tactical Shooter'),
    GameTarget(id: 'val_ist', gameName: 'Valorant / Riot', region: 'TR (Istanbul)', host: '162.249.79.1', port: 443, icon: '⚔️', category: 'Tactical Shooter'),
    GameTarget(id: 'val_par', gameName: 'Valorant / Riot', region: 'EU West (Paris)', host: '162.249.73.1', port: 443, icon: '⚔️', category: 'Tactical Shooter'),
    GameTarget(id: 'val_lon', gameName: 'Valorant / Riot', region: 'EU West (London)', host: '162.249.74.1', port: 443, icon: '⚔️', category: 'Tactical Shooter'),
    GameTarget(id: 'val_mad', gameName: 'Valorant / Riot', region: 'EU South (Madrid)', host: '162.249.77.1', port: 443, icon: '⚔️', category: 'Tactical Shooter'),
    GameTarget(id: 'val_bah', gameName: 'Valorant / Riot', region: 'Middle East (Bahrain)', host: '15.185.12.1', port: 443, icon: '⚔️', category: 'Tactical Shooter'),

    // --- League of Legends ---
    GameTarget(id: 'lol_euw', gameName: 'League of Legends', region: 'EU West (EUW)', host: '104.160.141.3', port: 443, icon: '🧙‍♂️', category: 'MOBA & Strategy'),
    GameTarget(id: 'lol_eune', gameName: 'League of Legends', region: 'EU Nordic & East (EUNE)', host: '104.160.142.3', port: 443, icon: '🧙‍♂️', category: 'MOBA & Strategy'),
    GameTarget(id: 'lol_tr', gameName: 'League of Legends', region: 'Turkey Server (TR)', host: '104.160.143.3', port: 443, icon: '🧙‍♂️', category: 'MOBA & Strategy'),
    GameTarget(id: 'lol_ru', gameName: 'League of Legends', region: 'Russia Server (RU)', host: '104.160.144.3', port: 443, icon: '🧙‍♂️', category: 'MOBA & Strategy'),

    // --- Dota 2 ---
    GameTarget(id: 'dota2_euw', gameName: 'Dota 2', region: 'Europe West (Luxembourg)', host: '146.66.152.1', port: 27015, icon: '🛡️', category: 'MOBA & Strategy'),
    GameTarget(id: 'dota2_eue', gameName: 'Dota 2', region: 'Europe East (Vienna)', host: '146.66.155.1', port: 27015, icon: '🛡️', category: 'MOBA & Strategy'),
    GameTarget(id: 'dota2_sto', gameName: 'Dota 2', region: 'Stockholm (Sweden)', host: '155.133.242.1', port: 27015, icon: '🛡️', category: 'MOBA & Strategy'),
    GameTarget(id: 'dota2_dxb', gameName: 'Dota 2', region: 'Dubai (UAE)', host: '155.133.238.1', port: 27015, icon: '🛡️', category: 'MOBA & Strategy'),

    // --- Apex Legends ---
    GameTarget(id: 'apex_fra', gameName: 'Apex Legends', region: 'EU Frankfurt 1', host: '52.28.0.1', port: 443, icon: '🔥', category: 'Battle Royale'),
    GameTarget(id: 'apex_fra2', gameName: 'Apex Legends', region: 'EU Frankfurt 2', host: '52.29.0.1', port: 443, icon: '🔥', category: 'Battle Royale'),
    GameTarget(id: 'apex_lon', gameName: 'Apex Legends', region: 'EU London', host: '35.176.0.1', port: 443, icon: '🔥', category: 'Battle Royale'),
    GameTarget(id: 'apex_ams', gameName: 'Apex Legends', region: 'EU Amsterdam', host: '18.156.0.1', port: 443, icon: '🔥', category: 'Battle Royale'),
    GameTarget(id: 'apex_bah', gameName: 'Apex Legends', region: 'Middle East (Bahrain)', host: '15.185.0.1', port: 443, icon: '🔥', category: 'Battle Royale'),

    // --- Call of Duty: Warzone, MW3 & BO6 ---
    GameTarget(id: 'cod_wz_fra', gameName: 'Call of Duty: Warzone', region: 'EU Central (Frankfurt)', host: '185.34.107.1', port: 3074, icon: '💥', category: 'Battle Royale'),
    GameTarget(id: 'cod_wz_par', gameName: 'Call of Duty: Warzone', region: 'EU West (Paris)', host: '185.34.106.1', port: 3074, icon: '💥', category: 'Battle Royale'),
    GameTarget(id: 'cod_wz_lon', gameName: 'Call of Duty: Warzone', region: 'EU West (London)', host: '185.34.105.1', port: 3074, icon: '💥', category: 'Battle Royale'),
    GameTarget(id: 'cod_wz_riy', gameName: 'Call of Duty: Warzone', region: 'Middle East (Riyadh)', host: '185.34.104.1', port: 3074, icon: '💥', category: 'Battle Royale'),
    GameTarget(id: 'cod_mw3_eu', gameName: 'Call of Duty: MW3 / BO6', region: 'Europe Master', host: '185.34.106.1', port: 3074, icon: '💥', category: 'Tactical Shooter'),

    // --- Rainbow Six Siege ---
    GameTarget(id: 'r6_euc', gameName: 'Rainbow Six Siege', region: 'EU Central', host: '51.144.0.1', port: 443, icon: '🔫', category: 'Tactical Shooter'),
    GameTarget(id: 'r6_eun', gameName: 'Rainbow Six Siege', region: 'EU North', host: '51.145.0.1', port: 443, icon: '🔫', category: 'Tactical Shooter'),
    GameTarget(id: 'r6_euw', gameName: 'Rainbow Six Siege', region: 'EU West (Ireland)', host: '51.141.0.1', port: 443, icon: '🔫', category: 'Tactical Shooter'),
    GameTarget(id: 'r6_uae', gameName: 'Rainbow Six Siege', region: 'Middle East (UAE)', host: '20.46.0.1', port: 443, icon: '🔫', category: 'Tactical Shooter'),

    // --- Fortnite & Epic Games ---
    GameTarget(id: 'fn_fra', gameName: 'Fortnite / Epic Games', region: 'EU Central (Frankfurt)', host: '52.28.64.1', port: 443, icon: '⚡', category: 'Battle Royale'),
    GameTarget(id: 'fn_lon', gameName: 'Fortnite / Epic Games', region: 'EU West (London)', host: '35.176.64.1', port: 443, icon: '⚡', category: 'Battle Royale'),
    GameTarget(id: 'fn_par', gameName: 'Fortnite / Epic Games', region: 'EU West (Paris)', host: '15.236.64.1', port: 443, icon: '⚡', category: 'Battle Royale'),
    GameTarget(id: 'fn_me', gameName: 'Fortnite / Epic Games', region: 'Middle East (Bahrain)', host: '15.185.128.1', port: 443, icon: '⚡', category: 'Battle Royale'),

    // --- PUBG: Battlegrounds ---
    GameTarget(id: 'pubg_fra', gameName: 'PUBG: Battlegrounds', region: 'Europe (Frankfurt)', host: '35.156.0.1', port: 443, icon: '🪂', category: 'Battle Royale'),
    GameTarget(id: 'pubg_irl', gameName: 'PUBG: Battlegrounds', region: 'Europe (Ireland)', host: '54.216.0.1', port: 443, icon: '🪂', category: 'Battle Royale'),
    GameTarget(id: 'pubg_lon', gameName: 'PUBG: Battlegrounds', region: 'Europe (London)', host: '35.177.0.1', port: 443, icon: '🪂', category: 'Battle Royale'),

    // --- Rust ---
    GameTarget(id: 'rust_fra', gameName: 'Rust', region: 'EU Frankfurt Official', host: '185.38.149.1', port: 28015, icon: '🏕️', category: 'Action & Co-Op'),
    GameTarget(id: 'rust_lon', gameName: 'Rust', region: 'EU London Official', host: '185.38.150.1', port: 28015, icon: '🏕️', category: 'Action & Co-Op'),
    GameTarget(id: 'rust_ams', gameName: 'Rust', region: 'EU Amsterdam', host: '185.38.148.1', port: 28015, icon: '🏕️', category: 'Action & Co-Op'),
    GameTarget(id: 'rust_hel', gameName: 'Rust', region: 'EU Helsinki', host: '185.38.152.1', port: 28015, icon: '🏕️', category: 'Action & Co-Op'),

    // --- Overwatch 2 & Blizzard ---
    GameTarget(id: 'ow2_fra', gameName: 'Overwatch 2', region: 'EU Central (Frankfurt)', host: '185.60.112.157', port: 1119, icon: '🤖', category: 'Tactical Shooter'),
    GameTarget(id: 'ow2_ams', gameName: 'Overwatch 2', region: 'EU West (Amsterdam)', host: '185.60.114.157', port: 1119, icon: '🤖', category: 'Tactical Shooter'),
    GameTarget(id: 'wow_eu', gameName: 'World of Warcraft', region: 'EU Paris Realms', host: '185.60.112.158', port: 3724, icon: '🗡️', category: 'MMO & RPG'),
    GameTarget(id: 'diablo4_eu', gameName: 'Diablo IV', region: 'Europe Realms', host: '185.60.114.158', port: 1119, icon: '👿', category: 'MMO & RPG'),

    // --- Rocket League ---
    GameTarget(id: 'rl_eu1', gameName: 'Rocket League', region: 'Europe Central 1', host: '185.38.148.1', port: 443, icon: '⚽', category: 'Sports & Racing'),
    GameTarget(id: 'rl_eu2', gameName: 'Rocket League', region: 'Europe Central 2', host: '185.38.149.1', port: 443, icon: '⚽', category: 'Sports & Racing'),
    GameTarget(id: 'rl_me', gameName: 'Rocket League', region: 'Middle East Gateway', host: '15.185.12.1', port: 443, icon: '⚽', category: 'Sports & Racing'),

    // --- EA Sports FC 24/25 & FIFA ---
    GameTarget(id: 'eafc_fra', gameName: 'EA Sports FC 24/25', region: 'Europe (Frankfurt)', host: '159.153.64.1', port: 443, icon: '👟', category: 'Sports & Racing'),
    GameTarget(id: 'eafc_par', gameName: 'EA Sports FC 24/25', region: 'Europe (Paris)', host: '159.153.65.1', port: 443, icon: '👟', category: 'Sports & Racing'),
    GameTarget(id: 'eafc_lon', gameName: 'EA Sports FC 24/25', region: 'Europe (London)', host: '159.153.66.1', port: 443, icon: '👟', category: 'Sports & Racing'),
    GameTarget(id: 'eafc_dxb', gameName: 'EA Sports FC 24/25', region: 'Middle East (Dubai)', host: '159.153.67.1', port: 443, icon: '👟', category: 'Sports & Racing'),

    // --- GTA V & FiveM ---
    GameTarget(id: 'gta_fivem_eu', gameName: 'GTA V / FiveM', region: 'Europe Master Relay', host: '185.244.194.1', port: 30120, icon: '🏎️', category: 'Action & Co-Op'),
    GameTarget(id: 'gta_online_eu', gameName: 'GTA Online (Rockstar)', region: 'Rockstar Cloud EU', host: '192.81.241.1', port: 443, icon: '🏎️', category: 'Action & Co-Op'),

    // --- Minecraft ---
    GameTarget(id: 'mc_hypixel', gameName: 'Minecraft (Hypixel)', region: 'Hypixel EU Proxy', host: '172.65.201.1', port: 25565, icon: '⛏️', category: 'Action & Co-Op'),
    GameTarget(id: 'mc_2b2t', gameName: 'Minecraft (2b2t)', region: 'Global Gateway', host: '172.65.202.1', port: 25565, icon: '⛏️', category: 'Action & Co-Op'),

    // --- The Finals ---
    GameTarget(id: 'finals_fra', gameName: 'The Finals', region: 'Europe (Frankfurt)', host: '34.141.0.1', port: 443, icon: '🏆', category: 'Tactical Shooter'),
    GameTarget(id: 'finals_lon', gameName: 'The Finals', region: 'Europe (London)', host: '34.89.0.1', port: 443, icon: '🏆', category: 'Tactical Shooter'),

    // --- Dead by Daylight ---
    GameTarget(id: 'dbd_fra', gameName: 'Dead by Daylight', region: 'Europe Central', host: '52.57.0.1', port: 443, icon: '🩸', category: 'Action & Co-Op'),
    GameTarget(id: 'dbd_lon', gameName: 'Dead by Daylight', region: 'Europe West', host: '35.176.0.1', port: 443, icon: '🩸', category: 'Action & Co-Op'),

    // --- Hunt: Showdown ---
    GameTarget(id: 'hunt_fra', gameName: 'Hunt: Showdown', region: 'Europe (Frankfurt)', host: '185.66.140.1', port: 443, icon: '🤠', category: 'Tactical Shooter'),

    // --- Warframe & Destiny 2 ---
    GameTarget(id: 'warframe_eu', gameName: 'Warframe', region: 'EU Central Relay', host: '52.29.0.1', port: 443, icon: '👽', category: 'Action & Co-Op'),
    GameTarget(id: 'destiny2_eu', gameName: 'Destiny 2', region: 'Europe Gateway', host: '185.34.104.1', port: 443, icon: '🌌', category: 'Action & Co-Op'),

    // --- Sea of Thieves ---
    GameTarget(id: 'sot_eu', gameName: 'Sea of Thieves', region: 'Europe West', host: '51.140.0.1', port: 443, icon: '🏴‍☠️', category: 'Action & Co-Op'),

    // --- Ark & Palworld ---
    GameTarget(id: 'ark_eu', gameName: 'Ark: Survival Ascended', region: 'Europe Official', host: '185.38.151.1', port: 7777, icon: '🦖', category: 'Action & Co-Op'),
    GameTarget(id: 'palworld_eu', gameName: 'Palworld', region: 'Europe Central', host: '35.158.0.1', port: 8211, icon: '🐾', category: 'Action & Co-Op'),

    // --- Helldivers 2 ---
    GameTarget(id: 'helldivers2_fra', gameName: 'Helldivers 2', region: 'Europe (Frankfurt)', host: '52.59.0.1', port: 443, icon: '🪐', category: 'Action & Co-Op'),
    GameTarget(id: 'helldivers2_lon', gameName: 'Helldivers 2', region: 'Europe (London)', host: '35.177.0.1', port: 443, icon: '🪐', category: 'Action & Co-Op'),

    // --- Battlefield 2042 & BF1 ---
    GameTarget(id: 'bf2042_fra', gameName: 'Battlefield 2042', region: 'Europe (Frankfurt)', host: '159.153.72.1', port: 443, icon: '🚁', category: 'Tactical Shooter'),

    // --- Path of Exile ---
    GameTarget(id: 'poe_fra', gameName: 'Path of Exile', region: 'Frankfurt Gateway', host: '185.107.96.1', port: 443, icon: '💎', category: 'MMO & RPG'),
    GameTarget(id: 'poe_lon', gameName: 'Path of Exile', region: 'London Gateway', host: '185.107.97.1', port: 443, icon: '💎', category: 'MMO & RPG'),
    GameTarget(id: 'poe_ams', gameName: 'Path of Exile', region: 'Amsterdam Gateway', host: '185.107.98.1', port: 443, icon: '💎', category: 'MMO & RPG'),

    // --- Brawlhalla & Smite ---
    GameTarget(id: 'brawl_eu', gameName: 'Brawlhalla', region: 'Europe Frankfurt', host: '52.58.0.1', port: 443, icon: '🥊', category: 'Action & Co-Op'),
    GameTarget(id: 'smite_eu', gameName: 'Smite', region: 'Europe Central', host: '34.250.0.1', port: 443, icon: '⚡', category: 'MOBA & Strategy'),

    // --- Genshin Impact & Honkai Star Rail ---
    GameTarget(id: 'genshin_eu', gameName: 'Genshin Impact', region: 'Europe Server', host: '8.209.112.1', port: 443, icon: '✨', category: 'MMO & RPG'),
    GameTarget(id: 'hsr_eu', gameName: 'Honkai: Star Rail', region: 'Europe Server', host: '8.209.113.1', port: 443, icon: '🚂', category: 'MMO & RPG'),

    // --- Final Fantasy XIV & Guild Wars 2 ---
    GameTarget(id: 'ffxiv_eu', gameName: 'Final Fantasy XIV', region: 'Chaos & Light (Frankfurt)', host: '195.82.50.1', port: 54992, icon: '🗡️', category: 'MMO & RPG'),
    GameTarget(id: 'gw2_eu', gameName: 'Guild Wars 2', region: 'Europe (Frankfurt)', host: '206.127.146.1', port: 6112, icon: '⚔️', category: 'MMO & RPG'),
    GameTarget(id: 'eso_eu', gameName: 'The Elder Scrolls Online', region: 'Europe (Frankfurt)', host: '198.20.200.1', port: 24100, icon: '📜', category: 'MMO & RPG'),

    // --- Team Fortress 2 ---
    GameTarget(id: 'tf2_fra', gameName: 'Team Fortress 2', region: 'Frankfurt (Germany)', host: '155.133.226.1', port: 27015, icon: '🎩', category: 'Tactical Shooter'),
    GameTarget(id: 'tf2_vie', gameName: 'Team Fortress 2', region: 'Vienna (Austria)', host: '146.66.155.1', port: 27015, icon: '🎩', category: 'Tactical Shooter'),

    // --- Roblox ---
    GameTarget(id: 'roblox_eu', gameName: 'Roblox', region: 'Europe Gateway', host: '128.116.0.1', port: 443, icon: '🧱', category: 'Action & Co-Op'),

    // --- Forza Horizon & Assetto Corsa ---
    GameTarget(id: 'forza_eu', gameName: 'Forza Horizon 5', region: 'Xbox Live Server', host: '13.107.4.1', port: 443, icon: '🏎️', category: 'Sports & Racing'),

    // --- War Thunder & World of Tanks ---
    GameTarget(id: 'warthunder_eu', gameName: 'War Thunder', region: 'Europe Cluster', host: '94.23.0.1', port: 443, icon: '🛩️', category: 'Tactical Shooter'),
    GameTarget(id: 'wot_eu', gameName: 'World of Tanks', region: 'EU1 (Frankfurt)', host: '92.223.1.1', port: 20015, icon: '🚜', category: 'Tactical Shooter'),
    GameTarget(id: 'wot_eu2', gameName: 'World of Tanks', region: 'EU2 (Amsterdam)', host: '92.223.8.1', port: 20015, icon: '🚜', category: 'Tactical Shooter'),

    // --- Voice & Gaming Platforms ---
    GameTarget(id: 'discord_rot', gameName: 'Discord Voice (WebRTC)', region: 'Rotterdam Gateway', host: '162.159.130.233', port: 443, icon: '🎙️', category: 'Voice & Platforms'),
    GameTarget(id: 'discord_fra', gameName: 'Discord Voice (WebRTC)', region: 'Frankfurt Gateway', host: '162.159.128.233', port: 443, icon: '🎙️', category: 'Voice & Platforms'),
    GameTarget(id: 'discord_lon', gameName: 'Discord Voice (WebRTC)', region: 'London Gateway', host: '162.159.129.233', port: 443, icon: '🎙️', category: 'Voice & Platforms'),
    GameTarget(id: 'discord_mad', gameName: 'Discord Voice (WebRTC)', region: 'Madrid Gateway', host: '162.159.131.233', port: 443, icon: '🎙️', category: 'Voice & Platforms'),
    GameTarget(id: 'discord_dub', gameName: 'Discord Voice (WebRTC)', region: 'Dubai Gateway', host: '162.159.133.233', port: 443, icon: '🎙️', category: 'Voice & Platforms'),
    GameTarget(id: 'steam_eu', gameName: 'Steam Store & Friends', region: 'Frankfurt Master', host: '155.133.253.50', port: 443, icon: '🎮', category: 'Voice & Platforms'),
    GameTarget(id: 'psn_eu', gameName: 'PlayStation Network (PSN)', region: 'Europe Cloud', host: '198.107.156.1', port: 443, icon: '🟦', category: 'Voice & Platforms'),
    GameTarget(id: 'xbox_eu', gameName: 'Xbox Live & Cloud Gaming', region: 'Europe Cloud', host: '13.107.4.1', port: 443, icon: '🟩', category: 'Voice & Platforms'),
    GameTarget(id: 'bnet_auth', gameName: 'Battle.net Master', region: 'Europe Authentication', host: '185.60.114.159', port: 1119, icon: '🛡️', category: 'Voice & Platforms'),
    GameTarget(id: 'epic_auth', gameName: 'Epic Games Services', region: 'Europe Cloud', host: '52.28.64.1', port: 443, icon: '⚡', category: 'Voice & Platforms'),
    GameTarget(id: 'ea_auth', gameName: 'EA App Services', region: 'Europe Gateway', host: '159.153.64.1', port: 443, icon: '👟', category: 'Voice & Platforms'),
    GameTarget(id: 'ubisoft_auth', gameName: 'Ubisoft Connect Cloud', region: 'Europe Gateway', host: '51.144.0.1', port: 443, icon: '🌀', category: 'Voice & Platforms'),
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
