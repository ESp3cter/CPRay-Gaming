import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../models/server_config.dart';
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 720;
          if (isMobile) {
            return _buildMobileDashboard(context, vpnProvider, serverProvider, selected, pingValue);
          } else {
            return _buildDesktopDashboard(context, vpnProvider, serverProvider, selected, pingValue);
          }
        },
      ),
    );
  }

  // --- MOBILE ADAPTIVE DASHBOARD ---
  Widget _buildMobileDashboard(
    BuildContext context,
    VpnProvider vpnProvider,
    ServerProvider serverProvider,
    ServerConfig? selected,
    String pingValue,
  ) {
    return Container(
      color: const Color(0xFF090B10),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Server Selector + Refresh Icon Button
            Row(
              children: [
                Expanded(
                  child: _buildServerSelector(context, selected),
                ),
                const SizedBox(width: 8),
                _buildFastUpdateSubButton(context, serverProvider, compact: true),
              ],
            ),
            const SizedBox(height: 12),

            // Mode Switcher (Gaming TUN vs Anti-Sanction)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF121522),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF22283D)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModeButton(
                      label: LocalizationService.tr('gaming_tun'),
                      icon: Icons.sports_esports_rounded,
                      isActive: vpnProvider.settings.vpnMode == VpnMode.tun && !vpnProvider.settings.antiSanctionMode,
                      activeColor: const Color(0xFF00FF88),
                      onTap: () {
                        vpnProvider.setAntiSanctionMode(false);
                        vpnProvider.setVpnMode(VpnMode.tun);
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildModeButton(
                      label: LocalizationService.tr('anti_sanction'),
                      icon: Icons.shield_rounded,
                      isActive: vpnProvider.settings.antiSanctionMode,
                      activeColor: const Color(0xFF9D00FF),
                      onTap: () {
                        vpnProvider.setAntiSanctionMode(!vpnProvider.settings.antiSanctionMode);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Big Glowing Connection Hub
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
              decoration: BoxDecoration(
                color: const Color(0xFF10131E),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF1D2336), width: 1.2),
              ),
              child: Column(
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
                  const SizedBox(height: 18),
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
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF5A6678), fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2x2 Neon Stat Cards
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
                const SizedBox(width: 10),
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
            const SizedBox(height: 10),
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
                const SizedBox(width: 10),
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

            // Real-time Jitter Waveform
            SizedBox(
              height: 190,
              child: JitterGraphWidget(
                pingHistory: vpnProvider.pingHistory,
                currentJitter: vpnProvider.currentJitter,
                packetLoss: vpnProvider.packetLoss,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- DESKTOP WIDESCREEN DASHBOARD ---
  Widget _buildDesktopDashboard(
    BuildContext context,
    VpnProvider vpnProvider,
    ServerProvider serverProvider,
    ServerConfig? selected,
    String pingValue,
  ) {
    return Container(
      color: const Color(0xFF090B10),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Control Header
          Row(
            children: [
              Expanded(
                child: _buildServerSelector(context, selected),
              ),
              const SizedBox(width: 12),
              _buildFastUpdateSubButton(context, serverProvider, compact: false),
              if (Platform.isWindows && onToggleMiniMode != null) ...[
                const SizedBox(width: 12),
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
              ],
              const SizedBox(width: 12),
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
    );
  }

  // --- REUSABLE SUB-WIDGETS ---
  Widget _buildServerSelector(BuildContext context, ServerConfig? selected) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ServerListView()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF121522),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF22283D), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF00D4FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.dns_rounded, color: Color(0xFF00D4FF), size: 18),
            ),
            const SizedBox(width: 10),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    selected != null
                        ? '${selected.protocol.toUpperCase()} • ${selected.server}:${selected.port}'
                        : 'Tap to select gaming node',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF6B7A94), fontSize: 10),
                  ),
                ],
              ),
            ),
            const Icon(Icons.swap_horiz_rounded, color: Color(0xFF00D4FF), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildFastUpdateSubButton(BuildContext context, ServerProvider serverProvider, {required bool compact}) {
    return InkWell(
      onTap: () async {
        if (serverProvider.subscriptionUrl != null && serverProvider.subscriptionUrl!.isNotEmpty) {
          await serverProvider.updateSubscription(serverProvider.subscriptionUrl!);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Subscription nodes updated successfully!')),
            );
          }
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ServerListView()),
          );
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF141726),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF22283D)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sync_rounded,
              color: serverProvider.isLoading ? const Color(0xFFFFB300) : const Color(0xFF00FF88),
              size: 20,
            ),
            if (!compact) ...[
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? activeColor.withOpacity(0.5) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: isActive ? activeColor : const Color(0xFF6B7A94)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF7E8B9E),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
