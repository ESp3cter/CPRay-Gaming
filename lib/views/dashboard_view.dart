import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../models/app_settings.dart';
import '../providers/server_provider.dart';
import '../providers/vpn_provider.dart';
import '../services/localization_service.dart';
import '../services/vpn_service.dart';
import '../widgets/connect_button.dart';
import '../widgets/jitter_graph.dart';
import '../widgets/stat_card.dart';
import 'server_list_view.dart';

class DashboardView extends StatelessWidget {
  final VoidCallback? onToggleMiniMode;

  const DashboardView({super.key, this.onToggleMiniMode});

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final serverProvider = context.watch<ServerProvider>();

    if (vpnProvider.selectedServer == null && serverProvider.servers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vpnProvider.setSelectedServer(serverProvider.servers.first);
      });
    }

    final selected = vpnProvider.selectedServer;
    final pingValue = (selected?.ping != null && selected!.ping! > 0) ? '${selected.ping}' : '--';

    return Directionality(
      textDirection: LocalizationService.direction,
      child: Container(
        color: const Color(0xFF090B10),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Control Header
            Row(
              children: [
                // Selected Server Card (Clickable)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ServerListView()),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121522),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF22283D), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D4FF).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.dns_rounded, color: Color(0xFF00D4FF), size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selected != null ? selected.name : 'No Server Selected',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  selected != null
                                      ? '${selected.protocol.toUpperCase()} • ${selected.server}:${selected.port}'
                                      : 'Click to select or import nodes',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Color(0xFF6B7A94), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.swap_horiz_rounded, color: Color(0xFF00D4FF), size: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Fast Update Subscription Button
                InkWell(
                  onTap: () async {
                    if (serverProvider.subscriptionUrl != null && serverProvider.subscriptionUrl!.isNotEmpty) {
                      await serverProvider.updateSubscription(serverProvider.subscriptionUrl!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Subscription nodes updated successfully!')),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ServerListView()),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141726),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF22283D)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sync_rounded,
                          color: serverProvider.isLoading ? const Color(0xFFFFB300) : const Color(0xFF00FF88),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          serverProvider.isLoading ? 'UPDATING...' : LocalizationService.tr('update_sub'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Mini HUD Overlay Launcher Button
                if (onToggleMiniMode != null)
                  IconButton(
                    onPressed: onToggleMiniMode,
                    tooltip: LocalizationService.tr('mini_hud'),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141726),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.4)),
                      ),
                      child: const Icon(Icons.picture_in_picture_alt_rounded, color: Color(0xFF00D4FF), size: 20),
                    ),
                  ),

                const SizedBox(width: 12),

                // Mode Switcher (Gaming TUN vs System Proxy vs Anti-Sanction)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121522),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF22283D)),
                  ),
                  child: Row(
                    children: [
                      _buildModeButton(
                        label: LocalizationService.tr('gaming_tun'),
                        icon: Icons.sports_esports_rounded,
                        isActive: vpnProvider.settings.vpnMode == VpnMode.tun && !vpnProvider.settings.antiSanctionMode,
                        activeColor: const Color(0xFF00FF88),
                        onTap: () {
                          vpnProvider.setAntiSanctionMode(false);
                          vpnProvider.setVpnMode(VpnMode.tun);
                        },
                      ),
                      _buildModeButton(
                        label: LocalizationService.tr('anti_sanction'),
                        icon: Icons.shield_rounded,
                        isActive: vpnProvider.settings.antiSanctionMode,
                        activeColor: const Color(0xFF9D00FF),
                        onTap: () {
                          vpnProvider.setAntiSanctionMode(!vpnProvider.settings.antiSanctionMode);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Main Widescreen Dashboard Content (2 Columns)
            Expanded(
              child: Row(
                children: [
                  // Left Column: Big Glowing Connection Hub
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10131E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF1D2336), width: 1.2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ConnectButton(
                            status: vpnProvider.status,
                            onTap: () {
                              if (selected == null && serverProvider.servers.isEmpty) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const ServerListView()),
                                );
                              } else {
                                vpnProvider.toggleConnection();
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            vpnProvider.isConnected
                                ? LocalizationService.tr('connected_secure')
                                : vpnProvider.isConnecting
                                    ? LocalizationService.tr('connecting')
                                    : LocalizationService.tr('ready_to_connect'),
                            style: TextStyle(
                              color: vpnProvider.isConnected
                                  ? const Color(0xFF00FF88)
                                  : vpnProvider.isConnecting
                                      ? const Color(0xFFFFB300)
                                      : const Color(0xFF7E8B9E),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            vpnProvider.settings.antiSanctionMode
                                ? 'Anti-Sanction DNS Active (${vpnProvider.settings.antiSanctionProvider.toUpperCase()})'
                                : (vpnProvider.settings.vpnMode == VpnMode.tun
                                    ? 'TUN Mode: All Game UDP/TCP Traffic Routed'
                                    : 'Proxy Mode: Web & System Traffic Routed'),
                            style: const TextStyle(color: Color(0xFF5A6678), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Right Column: Neon Stat Cards & Jitter Waveform Graph
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: LocalizationService.tr('ping_latency'),
                                value: pingValue,
                                unit: 'ms',
                                icon: Icons.speed_rounded,
                                accentColor: const Color(0xFF00FF88),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: StatCard(
                                title: LocalizationService.tr('duration'),
                                value: VpnService.formatDuration(vpnProvider.connectedSeconds),
                                unit: '',
                                icon: Icons.timer_rounded,
                                accentColor: const Color(0xFF00D4FF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: LocalizationService.tr('download_speed'),
                                value: vpnProvider.downloadSpeed.toStringAsFixed(1),
                                unit: 'KB/s',
                                icon: Icons.arrow_downward_rounded,
                                accentColor: const Color(0xFF9D00FF),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: StatCard(
                                title: LocalizationService.tr('upload_speed'),
                                value: vpnProvider.uploadSpeed.toStringAsFixed(1),
                                unit: 'KB/s',
                                icon: Icons.arrow_upward_rounded,
                                accentColor: const Color(0xFFFFB300),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Live Jitter & Packet Loss Waveform Graph
                        Expanded(
                          child: JitterGraphWidget(
                            pingHistory: vpnProvider.pingHistory,
                            currentJitter: vpnProvider.currentJitter,
                            packetLoss: vpnProvider.packetLoss,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? activeColor.withOpacity(0.5) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? activeColor : const Color(0xFF6B7A94)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF7E8B9E),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
