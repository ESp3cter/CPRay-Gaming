class DetectableGame {
  final String id;
  final String name;
  final String category;
  final String icon;
  final List<String> processNames;
  final String defaultExe;

  const DetectableGame({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.processNames,
    required this.defaultExe,
  });
}

class GameDetectorService {
  static final List<DetectableGame> defaultGames = [
    // --- Launchers & Platforms ---
    const DetectableGame(
      id: 'steam',
      name: 'Steam Client & Store',
      category: 'Launchers & Store',
      icon: '🎮',
      processNames: ['steam.exe', 'steamwebhelper.exe'],
      defaultExe: 'steam.exe',
    ),
    const DetectableGame(
      id: 'epic',
      name: 'Epic Games Launcher',
      category: 'Launchers & Store',
      icon: '⚡',
      processNames: ['EpicGamesLauncher.exe', 'EpicWebHelper.exe'],
      defaultExe: 'EpicGamesLauncher.exe',
    ),
    const DetectableGame(
      id: 'ea_app',
      name: 'EA App (Origin)',
      category: 'Launchers & Store',
      icon: '👟',
      processNames: ['EADesktop.exe', 'EALauncher.exe'],
      defaultExe: 'EADesktop.exe',
    ),
    const DetectableGame(
      id: 'riot_client',
      name: 'Riot Client & Vanguard',
      category: 'Launchers & Store',
      icon: '🧙‍♂️',
      processNames: ['RiotClientServices.exe', 'vgc.exe'],
      defaultExe: 'RiotClientServices.exe',
    ),
    const DetectableGame(
      id: 'bnet',
      name: 'Battle.net Launcher',
      category: 'Launchers & Store',
      icon: '🛡️',
      processNames: ['Battle.net.exe', 'Agent.exe'],
      defaultExe: 'Battle.net.exe',
    ),
    const DetectableGame(
      id: 'ubisoft',
      name: 'Ubisoft Connect',
      category: 'Launchers & Store',
      icon: '🌀',
      processNames: ['upc.exe', 'UbisoftConnect.exe'],
      defaultExe: 'upc.exe',
    ),
    const DetectableGame(
      id: 'discord',
      name: 'Discord (Voice & WebRTC)',
      category: 'Voice & Social',
      icon: '🎙️',
      processNames: ['Discord.exe', 'Update.exe'],
      defaultExe: 'Discord.exe',
    ),

    // --- Tactical FPS & Shooters ---
    const DetectableGame(
      id: 'cs2',
      name: 'Counter-Strike 2 (CS2)',
      category: 'Tactical Shooter',
      icon: '🎯',
      processNames: ['cs2.exe'],
      defaultExe: 'cs2.exe',
    ),
    const DetectableGame(
      id: 'valorant',
      name: 'Valorant',
      category: 'Tactical Shooter',
      icon: '⚔️',
      processNames: ['VALORANT-Win64-Shipping.exe', 'valorant.exe'],
      defaultExe: 'valorant.exe',
    ),
    const DetectableGame(
      id: 'eft',
      name: 'Escape From Tarkov (EFT)',
      category: 'Hardcore Shooter',
      icon: '🪖',
      processNames: ['EscapeFromTarkov.exe', 'BsgLauncher.exe'],
      defaultExe: 'EscapeFromTarkov.exe',
    ),
    const DetectableGame(
      id: 'r6',
      name: 'Tom Clancy\'s Rainbow Six Siege',
      category: 'Tactical Shooter',
      icon: '🔫',
      processNames: ['RainbowSix.exe', 'RainbowSix_Vulkan.exe'],
      defaultExe: 'RainbowSix.exe',
    ),

    // --- Battle Royale ---
    const DetectableGame(
      id: 'warzone',
      name: 'Call of Duty: Warzone & MW3',
      category: 'Battle Royale',
      icon: '💥',
      processNames: ['cod.exe', 'bootstrapper.exe'],
      defaultExe: 'cod.exe',
    ),
    const DetectableGame(
      id: 'apex',
      name: 'Apex Legends',
      category: 'Battle Royale',
      icon: '🔥',
      processNames: ['r5apex.exe'],
      defaultExe: 'r5apex.exe',
    ),
    const DetectableGame(
      id: 'fortnite',
      name: 'Fortnite',
      category: 'Battle Royale',
      icon: '⚡',
      processNames: ['FortniteClient-Win64-Shipping.exe'],
      defaultExe: 'FortniteClient-Win64-Shipping.exe',
    ),
    const DetectableGame(
      id: 'pubg',
      name: 'PUBG: Battlegrounds',
      category: 'Battle Royale',
      icon: '🪂',
      processNames: ['TslGame.exe'],
      defaultExe: 'TslGame.exe',
    ),

    // --- MOBA & Strategy ---
    const DetectableGame(
      id: 'dota2',
      name: 'Dota 2',
      category: 'MOBA',
      icon: '🛡️',
      processNames: ['dota2.exe'],
      defaultExe: 'dota2.exe',
    ),
    const DetectableGame(
      id: 'lol',
      name: 'League of Legends',
      category: 'MOBA',
      icon: '🧙‍♂️',
      processNames: ['League of Legends.exe', 'LeagueClient.exe'],
      defaultExe: 'LeagueClient.exe',
    ),

    // --- Action & Survival ---
    const DetectableGame(
      id: 'rust',
      name: 'Rust',
      category: 'Survival',
      icon: '🏕️',
      processNames: ['RustClient.exe'],
      defaultExe: 'RustClient.exe',
    ),
    const DetectableGame(
      id: 'gta5',
      name: 'GTA V / FiveM Online',
      category: 'Open World',
      icon: '🏎️',
      processNames: ['GTA5.exe', 'FiveM.exe', 'FiveM_b2699_GTAProcess.exe'],
      defaultExe: 'GTA5.exe',
    ),
    const DetectableGame(
      id: 'finals',
      name: 'The Finals',
      category: 'Action FPS',
      icon: '🏆',
      processNames: ['Discovery.exe'],
      defaultExe: 'Discovery.exe',
    ),
    const DetectableGame(
      id: 'ow2',
      name: 'Overwatch 2',
      category: 'Hero Shooter',
      icon: '🤖',
      processNames: ['Overwatch.exe'],
      defaultExe: 'Overwatch.exe',
    ),
    const DetectableGame(
      id: 'rl',
      name: 'Rocket League',
      category: 'Sports & Arcade',
      icon: '⚽',
      processNames: ['RocketLeague.exe'],
      defaultExe: 'RocketLeague.exe',
    ),
    const DetectableGame(
      id: 'eafc',
      name: 'EA Sports FC 24/25 (FIFA)',
      category: 'Sports',
      icon: '👟',
      processNames: ['FC24.exe', 'FC25.exe'],
      defaultExe: 'FC24.exe',
    ),
    const DetectableGame(
      id: 'minecraft',
      name: 'Minecraft (Java & Bedrock)',
      category: 'Sandbox',
      icon: '⛏️',
      processNames: ['Minecraft.exe', 'javaw.exe', 'Minecraft.Windows.exe'],
      defaultExe: 'Minecraft.exe',
    ),
    const DetectableGame(
      id: 'palworld',
      name: 'Palworld',
      category: 'Co-Op Survival',
      icon: '🐾',
      processNames: ['Palworld-Win64-Shipping.exe'],
      defaultExe: 'Palworld-Win64-Shipping.exe',
    ),
    const DetectableGame(
      id: 'helldivers2',
      name: 'Helldivers 2',
      category: 'Co-Op Shooter',
      icon: '🪐',
      processNames: ['helldivers2.exe'],
      defaultExe: 'helldivers2.exe',
    ),
    const DetectableGame(
      id: 'dbd',
      name: 'Dead by Daylight',
      category: 'Horror / Survival',
      icon: '🩸',
      processNames: ['DeadByDaylight-Win64-Shipping.exe'],
      defaultExe: 'DeadByDaylight-Win64-Shipping.exe',
    ),
    const DetectableGame(
      id: 'warframe',
      name: 'Warframe',
      category: 'Action MMO',
      icon: '👽',
      processNames: ['Warframe.x64.exe'],
      defaultExe: 'Warframe.x64.exe',
    ),
  ];
}
