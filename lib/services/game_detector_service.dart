import 'dart:io';
import 'package:path/path.dart' as p;

class DetectableGame {
  final String id;
  final String name;
  final String category;
  final String icon;
  final List<String> processNames;
  final String defaultExe;
  final String? installedPath;

  const DetectableGame({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.processNames,
    required this.defaultExe,
    this.installedPath,
  });

  DetectableGame copyWithPath(String path) {
    return DetectableGame(
      id: id,
      name: name,
      category: category,
      icon: icon,
      processNames: processNames,
      defaultExe: defaultExe,
      installedPath: path,
    );
  }
}

class GameDetectorService {
  static List<DetectableGame> get defaultGames => knownCatalog;

  static final List<DetectableGame> knownCatalog = [
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

  /// Scans Windows filesystem and registry paths to ONLY return games actually installed on this PC
  static Future<List<DetectableGame>> scanInstalledGames() async {
    if (!Platform.isWindows) {
      return [];
    }

    final List<DetectableGame> detected = [];
    final List<String> driveRoots = ['C:', 'D:', 'E:', 'F:', 'G:'];
    final localAppData = Platform.environment['LOCALAPPDATA'] ?? r'C:\Users\Default\AppData\Local';
    final programFiles = Platform.environment['ProgramFiles'] ?? r'C:\Program Files';
    final programFilesX86 = Platform.environment['ProgramFiles(x86)'] ?? r'C:\Program Files (x86)';

    // 1. Scan Steam Libraries
    final List<String> steamSearchDirs = [
      p.join(programFilesX86, 'Steam'),
      p.join(programFiles, 'Steam'),
      r'C:\Steam',
      r'D:\Steam',
      r'E:\Steam',
      r'D:\SteamLibrary',
      r'E:\SteamLibrary',
      r'F:\SteamLibrary',
    ];

    // Check Steam Client itself
    for (final dir in steamSearchDirs) {
      final exe = File(p.join(dir, 'steam.exe'));
      if (exe.existsSync()) {
        detected.add(knownCatalog.firstWhere((g) => g.id == 'steam').copyWithPath(exe.path));
        break;
      }
    }

    // Check Discord
    final discordDir = Directory(p.join(localAppData, 'Discord'));
    if (discordDir.existsSync()) {
      try {
        final entries = discordDir.listSync();
        for (final entry in entries) {
          if (entry is Directory && entry.path.contains('app-')) {
            final exe = File(p.join(entry.path, 'Discord.exe'));
            if (exe.existsSync()) {
              detected.add(knownCatalog.firstWhere((g) => g.id == 'discord').copyWithPath(exe.path));
              break;
            }
          }
        }
      } catch (_) {}
    }

    // Check Riot Games
    for (final drive in driveRoots) {
      final riotClient = File(p.join(drive, 'Riot Games', 'Riot Client', 'RiotClientServices.exe'));
      if (riotClient.existsSync()) {
        detected.add(knownCatalog.firstWhere((g) => g.id == 'riot_client').copyWithPath(riotClient.path));
      }
      final valorant = File(p.join(drive, 'Riot Games', 'VALORANT', 'live', 'VALORANT.exe'));
      if (valorant.existsSync()) {
        detected.add(knownCatalog.firstWhere((g) => g.id == 'valorant').copyWithPath(valorant.path));
      }
      final lol = File(p.join(drive, 'Riot Games', 'League of Legends', 'LeagueClient.exe'));
      if (lol.existsSync()) {
        detected.add(knownCatalog.firstWhere((g) => g.id == 'lol').copyWithPath(lol.path));
      }
    }

    // Check Epic Games
    final epicExe = File(p.join(programFilesX86, 'Epic Games', 'Launcher', 'Portal', 'Binaries', 'Win64', 'EpicGamesLauncher.exe'));
    final epicExeAlt = File(p.join(programFiles, 'Epic Games', 'Launcher', 'Portal', 'Binaries', 'Win64', 'EpicGamesLauncher.exe'));
    if (epicExe.existsSync()) {
      detected.add(knownCatalog.firstWhere((g) => g.id == 'epic').copyWithPath(epicExe.path));
    } else if (epicExeAlt.existsSync()) {
      detected.add(knownCatalog.firstWhere((g) => g.id == 'epic').copyWithPath(epicExeAlt.path));
    }

    // Check EA App
    final eaExe = File(p.join(programFiles, 'Electronic Arts', 'EA Desktop', 'EA Desktop', 'EADesktop.exe'));
    if (eaExe.existsSync()) {
      detected.add(knownCatalog.firstWhere((g) => g.id == 'ea_app').copyWithPath(eaExe.path));
    }

    // Check Battle.net
    final bnetExe = File(p.join(programFilesX86, 'Battle.net', 'Battle.net.exe'));
    if (bnetExe.existsSync()) {
      detected.add(knownCatalog.firstWhere((g) => g.id == 'bnet').copyWithPath(bnetExe.path));
    }

    // Check Ubisoft
    final ubiExe = File(p.join(programFilesX86, 'Ubisoft', 'Ubisoft Game Launcher', 'upc.exe'));
    if (ubiExe.existsSync()) {
      detected.add(knownCatalog.firstWhere((g) => g.id == 'ubisoft').copyWithPath(ubiExe.path));
    }

    // Check Common Steam Games across library folders
    for (final base in steamSearchDirs) {
      final common = Directory(p.join(base, 'steamapps', 'common'));
      if (common.existsSync()) {
        try {
          final gameFolders = common.listSync();
          for (final folder in gameFolders) {
            if (folder is Directory) {
              final folderName = p.basename(folder.path).toLowerCase();
              
              // CS2
              if (folderName.contains('counter-strike') || folderName.contains('csgo')) {
                final cs2Exe = File(p.join(folder.path, 'game', 'bin', 'win64', 'cs2.exe'));
                if (cs2Exe.existsSync()) {
                  detected.add(knownCatalog.firstWhere((g) => g.id == 'cs2').copyWithPath(cs2Exe.path));
                }
              }
              // Dota 2
              if (folderName.contains('dota 2')) {
                final dotaExe = File(p.join(folder.path, 'game', 'bin', 'win64', 'dota2.exe'));
                if (dotaExe.existsSync()) {
                  detected.add(knownCatalog.firstWhere((g) => g.id == 'dota2').copyWithPath(dotaExe.path));
                }
              }
              // Rust
              if (folderName.contains('rust')) {
                final rustExe = File(p.join(folder.path, 'RustClient.exe'));
                if (rustExe.existsSync()) {
                  detected.add(knownCatalog.firstWhere((g) => g.id == 'rust').copyWithPath(rustExe.path));
                }
              }
              // Apex Legends
              if (folderName.contains('apex')) {
                final apexExe = File(p.join(folder.path, 'r5apex.exe'));
                if (apexExe.existsSync()) {
                  detected.add(knownCatalog.firstWhere((g) => g.id == 'apex').copyWithPath(apexExe.path));
                }
              }
              // PUBG
              if (folderName.contains('pubg')) {
                final pubgExe = File(p.join(folder.path, 'TslGame', 'Binaries', 'Win64', 'TslGame.exe'));
                if (pubgExe.existsSync()) {
                  detected.add(knownCatalog.firstWhere((g) => g.id == 'pubg').copyWithPath(pubgExe.path));
                }
              }
              // GTA V
              if (folderName.contains('grand theft auto v') || folderName.contains('gta v')) {
                final gtaExe = File(p.join(folder.path, 'GTA5.exe'));
                if (gtaExe.existsSync()) {
                  detected.add(knownCatalog.firstWhere((g) => g.id == 'gta5').copyWithPath(gtaExe.path));
                }
              }
              // Rainbow Six
              if (folderName.contains('rainbow six') || folderName.contains('rainbowsix')) {
                final r6Exe = File(p.join(folder.path, 'RainbowSix.exe'));
                if (r6Exe.existsSync()) {
                  detected.add(knownCatalog.firstWhere((g) => g.id == 'r6').copyWithPath(r6Exe.path));
                }
              }
            }
          }
        } catch (_) {}
      }
    }

    // De-duplicate by ID
    final Map<String, DetectableGame> unique = {};
    for (final item in detected) {
      unique[item.id] = item;
    }

    return unique.values.toList();
  }

  /// Opens native Windows file dialog to let user select any .exe game file
  static Future<String?> pickGameExecutable() async {
    if (!Platform.isWindows) return null;
    try {
      final script = r'''
Add-Type -AssemblyName System.Windows.Forms
$f = New-Object System.Windows.Forms.OpenFileDialog
$f.Title = "Select Game or Application Executable (.exe)"
$f.Filter = "Executables (*.exe)|*.exe|All Files (*.*)|*.*"
$f.InitialDirectory = [System.Environment]::GetFolderPath("ProgramFiles")
if ($f.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    Write-Output $f.FileName
}
''';
      final result = await Process.run('powershell', ['-NoProfile', '-Command', script]);
      final out = (result.stdout as String).trim();
      if (out.isNotEmpty && out.endsWith('.exe')) {
        return out;
      }
    } catch (_) {}
    return null;
  }
}
