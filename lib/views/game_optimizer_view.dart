import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vpn_provider.dart';
import '../services/game_detector_service.dart';
import '../services/localization_service.dart';

class GameOptimizerView extends StatefulWidget {
  const GameOptimizerView({super.key});

  @override
  State<GameOptimizerView> createState() => _GameOptimizerViewState();
}

class _GameOptimizerViewState extends State<GameOptimizerView> {
  String _search = '';
  final TextEditingController _customExeController = TextEditingController();
  List<DetectableGame> _detectedGames = [];
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _scanGames();
  }

  @override
  void dispose() {
    _customExeController.dispose();
    super.dispose();
  }

  Future<void> _scanGames() async {
    setState(() => _isScanning = true);
    final results = await GameDetectorService.scanInstalledGames();
    if (mounted) {
      setState(() {
        _detectedGames = results;
        _isScanning = false;
      });
    }
  }

  Future<void> _browseAndAddGame() async {
    final exePath = await GameDetectorService.pickGameExecutable();
    if (exePath != null && mounted) {
      final fileName = exePath.split(Platform.isWindows ? r'\' : '/').last;
      context.read<VpnProvider>().addCustomGame(fileName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added custom game: $fileName')),
      );
    }
  }

  void _showAddCustomGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141726),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF00FF88), width: 1.2),
          ),
          title: const Text(
            'Add Game or App Executable',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the Windows executable process name (e.g. game.exe, overwatch.exe):',
                style: TextStyle(color: Color(0xFF8C9BAE), fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _customExeController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'mygame.exe',
                  hintStyle: const TextStyle(color: Color(0xFF5A6678)),
                  filled: true,
                  fillColor: const Color(0xFF0D0F18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF242A42)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF00FF88)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _browseAndAddGame();
                  },
                  icon: const Icon(Icons.folder_open_rounded, color: Color(0xFF00D4FF), size: 18),
                  label: const Text('Or Browse .exe File Directly', style: TextStyle(color: Color(0xFF00D4FF), fontSize: 12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF7E8B9E))),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _customExeController.text.trim();
                if (name.isNotEmpty) {
                  context.read<VpnProvider>().addCustomGame(name);
                  _customExeController.clear();
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF88),
                foregroundColor: const Color(0xFF0D0F18),
              ),
              child: const Text('Add Game', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final boostedCount = vpnProvider.boostedGameIds.length;

    // Combine detected games with custom user-added games
    final List<DetectableGame> allVisibleGames = List.from(_detectedGames);
    for (final custom in vpnProvider.customGameExes) {
      if (!allVisibleGames.any((g) => g.defaultExe.toLowerCase() == custom.toLowerCase())) {
        allVisibleGames.add(
          DetectableGame(
            id: custom,
            name: custom.replaceAll('.exe', '').toUpperCase(),
            category: 'Custom Added App',
            icon: '🎯',
            processNames: [custom],
            defaultExe: custom,
          ),
        );
      }
    }

    final filteredGames = allVisibleGames.where((g) {
      if (_search.trim().isEmpty) return true;
      final q = _search.toLowerCase();
      return g.name.toLowerCase().contains(q) ||
          g.category.toLowerCase().contains(q) ||
          g.defaultExe.toLowerCase().contains(q);
    }).toList();

    return Container(
      color: const Color(0xFF090B10),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocalizationService.tr('game_optimizer'),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Per-App Selective Routing: Only boosted games use the VPN tunnel while your PC stays direct.',
                    style: TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isScanning ? null : _scanGames,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF141A2C),
                      foregroundColor: const Color(0xFF00D4FF),
                      side: const BorderSide(color: Color(0xFF00D4FF), width: 1.2),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isScanning
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00D4FF)))
                        : const Icon(Icons.refresh_rounded, size: 16),
                    label: Text(_isScanning ? 'Scanning PC...' : 'Rescan Games', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                  ElevatedButton.icon(
                    onPressed: _browseAndAddGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF141A2C),
                      foregroundColor: const Color(0xFF00FF88),
                      side: const BorderSide(color: Color(0xFF00FF88), width: 1.2),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.folder_open_rounded, size: 16),
                    label: const Text('Browse .exe', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCustomGameDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF88),
                      foregroundColor: const Color(0xFF090B10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add by Name', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Boost Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF10131E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: boostedCount > 0 ? const Color(0xFF00D4FF).withOpacity(0.5) : const Color(0xFF1E2438),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (boostedCount > 0 ? const Color(0xFF00D4FF) : const Color(0xFF5A6678)).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    color: boostedCount > 0 ? const Color(0xFF00D4FF) : const Color(0xFF6B7A94),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎮 $boostedCount / 5 Games Boosted Simultaneously',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        boostedCount == 0
                          ? 'No games are currently boosted. Click "Boost Game" to route only that game through CPRay tunnel.'
                          : 'Only boosted games bypass censorship & lag. Other apps, browsers, and Windows use direct ISP internet.',
                        style: const TextStyle(color: Color(0xFF8C9BAE), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (boostedCount >= 5)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.4)),
                    ),
                    child: const Text(
                      'MAX LIMIT (5/5)',
                      style: TextStyle(color: Color(0xFFFFB300), fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search Bar
          TextField(
            onChanged: (val) => setState(() => _search = val),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search installed games, launchers, or executable (e.g. Steam, CS2, Tarkov, Valorant)...',
              hintStyle: const TextStyle(color: Color(0xFF5A6678)),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00D4FF), size: 20),
              filled: true,
              fillColor: const Color(0xFF10131E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF1E2438)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF00D4FF)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Content Area
          Expanded(
            child: _isScanning
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF00D4FF)),
                        SizedBox(height: 16),
                        Text(
                          'Scanning Windows PC for installed games & launchers...',
                          style: TextStyle(color: Color(0xFF8C9BAE), fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : filteredGames.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.videogame_asset_off_rounded, color: Color(0xFF5A6678), size: 54),
                            const SizedBox(height: 16),
                            const Text(
                              'No Installed Games Detected Automatically',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Click "Browse .exe" or "Add by Name" to add your games and launchers to the accelerator list.',
                              style: TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 12,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _browseAndAddGame,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00FF88),
                                    foregroundColor: const Color(0xFF090B10),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.folder_open_rounded, size: 18),
                                  label: const Text('Browse Game (.exe)', style: TextStyle(fontWeight: FontWeight.w800)),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _scanGames,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF141A2C),
                                    foregroundColor: const Color(0xFF00D4FF),
                                    side: const BorderSide(color: Color(0xFF00D4FF), width: 1.2),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.refresh_rounded, size: 18),
                                  label: const Text('Rescan PC', style: TextStyle(fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 2.3,
                        ),
                        itemCount: filteredGames.length,
                        itemBuilder: (context, index) {
                          final game = filteredGames[index];
                          final isBoosted = vpnProvider.isGameBoosted(game.id);
                          final isCustom = vpnProvider.customGameExes.contains(game.defaultExe);

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isBoosted ? const Color(0xFF14192A) : const Color(0xFF10131E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isBoosted ? const Color(0xFF00FF88) : const Color(0xFF1E2438),
                                width: isBoosted ? 1.6 : 1.0,
                              ),
                              boxShadow: isBoosted
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF00FF88).withOpacity(0.12),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF151928),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(game.icon, style: const TextStyle(fontSize: 24)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              game.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                          if (isCustom)
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF5252), size: 18),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              tooltip: 'Remove Custom App',
                                              onPressed: () => vpnProvider.removeCustomGame(game.defaultExe),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        game.installedPath != null
                                            ? game.installedPath!
                                            : '${game.category} • ${game.defaultExe}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Color(0xFF6B7A94), fontSize: 10),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (isBoosted ? const Color(0xFF00FF88) : const Color(0xFF5A6678)).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isBoosted ? '⚡ BOOST ACTIVE (VPN ONLY)' : 'DIRECT (ISP)',
                                          style: TextStyle(
                                            color: isBoosted ? const Color(0xFF00FF88) : const Color(0xFF6B7A94),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () async {
                                    final ok = await vpnProvider.toggleGameBoost(game);
                                    if (!ok && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Maximum 5 games can be boosted at the same time.')),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isBoosted ? const Color(0xFFFF3366).withOpacity(0.15) : const Color(0xFF00D4FF),
                                    foregroundColor: isBoosted ? const Color(0xFFFF3366) : const Color(0xFF090B10),
                                    side: isBoosted
                                        ? const BorderSide(color: Color(0xFFFF3366), width: 1.2)
                                        : BorderSide.none,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: Text(
                                    isBoosted ? 'Disconnect' : 'Boost Game',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
