import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_target.dart';
import '../providers/server_provider.dart';
import '../providers/vpn_provider.dart';
import '../services/localization_service.dart';

class GamePingTesterView extends StatefulWidget {
  const GamePingTesterView({super.key});

  @override
  State<GamePingTesterView> createState() => _GamePingTesterViewState();
}

class _GamePingTesterViewState extends State<GamePingTesterView> {
  String _selectedCategory = 'All';
  String _search = '';

  final List<String> _categories = [
    'All',
    'Tactical Shooter',
    'Battle Royale',
    'MOBA & Strategy',
    'MMO & RPG',
    'Action & Co-Op',
    'Sports & Racing',
    'Voice & Platforms',
  ];

  @override
  Widget build(BuildContext context) {
    final serverProvider = context.watch<ServerProvider>();
    final vpnProvider = context.watch<VpnProvider>();
    final targets = serverProvider.gameTargets;

    final filtered = targets.where((t) {
      if (_selectedCategory != 'All' && t.category != _selectedCategory) {
        return false;
      }
      if (_search.trim().isNotEmpty) {
        final q = _search.toLowerCase();
        return t.gameName.toLowerCase().contains(q) ||
            t.region.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q);
      }
      return true;
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
                    LocalizationService.tr('game_ping_tester'),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Direct ping latency measurements to 100+ global competitive game clusters & voice gateways',
                    style: const TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => serverProvider.testAllGameTargets(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4FF),
                  foregroundColor: const Color(0xFF090B10),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.bolt_rounded, size: 18),
                label: const Text('Test All 100 Games', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Active Tunnel Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF10131E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: vpnProvider.isConnected ? const Color(0xFF00FF88).withOpacity(0.4) : const Color(0xFF22283D),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  vpnProvider.isConnected ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  color: vpnProvider.isConnected ? const Color(0xFF00FF88) : const Color(0xFF00D4FF),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    vpnProvider.isConnected
                        ? 'Tunnel Active: Measuring routing latency through ${vpnProvider.selectedServer?.name ?? "Selected Node"}'
                        : 'Tunnel Disconnected: Showing direct ISP ping. Connect to CPRay tunnel to test optimized game routing.',
                    style: TextStyle(
                      color: vpnProvider.isConnected ? const Color(0xFFCBD5E1) : const Color(0xFF8C9BAE),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Search & Filter Category Chips
          Row(
            children: [
              Expanded(
                flex: 4,
                child: TextField(
                  onChanged: (val) => setState(() => _search = val),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search 100+ games (e.g. Tarkov, CS2, Valorant, Warzone, EA FC)...',
                    hintStyle: const TextStyle(color: Color(0xFF5A6678)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00D4FF), size: 18),
                    filled: true,
                    fillColor: const Color(0xFF10131E),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E2438)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00D4FF)),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Category Chips Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF090B10) : const Color(0xFF8C9BAE),
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF00FF88),
                    backgroundColor: const Color(0xFF10131E),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF00FF88) : const Color(0xFF1E2438),
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // Grid of 100 Game Targets
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final target = filtered[index];
                final ping = target.ping;

                Color pingColor = const Color(0xFF5A6678);
                if (ping != null && ping > 0) {
                  if (ping < 65) {
                    pingColor = const Color(0xFF00FF88);
                  } else if (ping < 100) {
                    pingColor = const Color(0xFF00D4FF);
                  } else if (ping < 140) {
                    pingColor = const Color(0xFFFFB300);
                  } else {
                    pingColor = const Color(0xFFFF3366);
                  }
                }

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10131E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1D2336)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151928),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(target.icon, style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              target.gameName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              target.region,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Color(0xFF6B7A94), fontSize: 10),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              target.category,
                              style: const TextStyle(color: Color(0xFF00D4FF), fontSize: 9, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          target.isTesting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00D4FF)),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: pingColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: pingColor.withOpacity(0.4)),
                                  ),
                                  child: Text(
                                    (ping != null && ping > 0) ? '$ping ms' : '-- ms',
                                    style: TextStyle(
                                      color: pingColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => serverProvider.testGameTargetPing(target),
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Text(
                                'Re-test',
                                style: TextStyle(color: Color(0xFF00D4FF), fontSize: 9, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
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
