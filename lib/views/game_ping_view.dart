import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/server_provider.dart';
import '../providers/vpn_provider.dart';
import '../services/localization_service.dart';

class GamePingView extends StatelessWidget {
  const GamePingView({super.key});

  @override
  Widget build(BuildContext context) {
    final serverProvider = context.watch<ServerProvider>();
    final vpnProvider = context.watch<VpnProvider>();
    final targets = serverProvider.gameTargets;

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
                    'Direct ping latency measurements to actual European game servers & voice gateways',
                    style: TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
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
                icon: const Icon(Icons.speed_rounded, size: 18),
                label: const Text('Test All Game Pings', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Active Tunnel Banner
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
                        ? 'Tunnel Active: Measuring routing latency through ${vpnProvider.selectedServer?.name ?? "Selected Server"}'
                        : 'Tunnel Disconnected: Showing direct ISP latency to game servers. Connect to measure optimized route.',
                    style: TextStyle(
                      color: vpnProvider.isConnected ? const Color(0xFFCBD5E1) : const Color(0xFF8C9BAE),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Grid of Game Server Targets
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 2.3,
              ),
              itemCount: targets.length,
              itemBuilder: (context, index) {
                final target = targets[index];
                final ping = target.ping;

                Color pingColor = const Color(0xFF5A6678);
                if (ping != null) {
                  if (ping < 70) {
                    pingColor = const Color(0xFF00FF88);
                  } else if (ping < 110) {
                    pingColor = const Color(0xFF00D4FF);
                  } else if (ping < 150) {
                    pingColor = const Color(0xFFFFB300);
                  } else {
                    pingColor = const Color(0xFFFF3366);
                  }
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10131E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1D2336)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151928),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(target.icon, style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              target.gameName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              target.region,
                              style: const TextStyle(color: Color(0xFF6B7A94), fontSize: 11),
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
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00D4FF)),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: pingColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: pingColor.withOpacity(0.4)),
                                  ),
                                  child: Text(
                                    ping != null ? '$ping ms' : '-- ms',
                                    style: TextStyle(
                                      color: pingColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => serverProvider.testGameTargetPing(target),
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Text(
                                'Re-test',
                                style: TextStyle(color: Color(0xFF00D4FF), fontSize: 10, fontWeight: FontWeight.w600),
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
