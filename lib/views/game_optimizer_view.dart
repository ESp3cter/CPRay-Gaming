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

  @override
  void dispose() {
    _customExeController.dispose();
    super.dispose();
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
            'Add Custom Game Executable',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the Windows executable process name for your game (e.g. game.exe, overwatch.exe):',
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

    final allGames = GameDetectorService.defaultGames;
    final filteredGames = allGames.where((g) {
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
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationService.tr('game_optimizer'),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Per-App Gaming Accelerator: Route only your active games (up to 5) while your PC stays direct',
                    style: TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddCustomGameDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF141A2C),
                  foregroundColor: const Color(0xFF00FF88),
                  side: const BorderSide(color: Color(0xFF00FF88), width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Custom Game (.exe)', style: TextStyle(fontWeight: FontWeight.w800)),
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
                          ? 'Click "Boost Game" on any online game or launcher to route it through the low-ping tunnel.'
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
              hintText: 'Search games, launchers, or executable (e.g. Steam, CS2, Tarkov, Valorant)...',
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

          // Grid of Games & Launchers
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 2.4,
              ),
              itemCount: filteredGames.length,
              itemBuilder: (context, index) {
                final game = filteredGames[index];
                final isBoosted = vpnProvider.isGameBoosted(game.id);

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
                            Text(
                              game.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${game.category} • ${game.defaultExe}',
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
                                isBoosted ? '⚡ BOOST ACTIVE (VPN)' : 'DIRECT ROUTE (ISP)',
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
