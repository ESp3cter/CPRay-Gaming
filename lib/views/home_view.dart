import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/server_provider.dart';
import '../providers/vpn_provider.dart';
import '../services/updater_service.dart';
import '../services/vpn_service.dart';
import '../widgets/connect_button.dart';
import '../widgets/stat_card.dart';
import '../widgets/update_dialog.dart';
import 'logs_view.dart';
import 'server_list_view.dart';
import 'settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdates();
    });
  }

  Future<void> _checkUpdates() async {
    final update = await UpdaterService.checkForUpdates();
    if (update != null && update.hasUpdate && mounted) {
      showDialog(
        context: context,
        builder: (context) => UpdateDialog(updateInfo: update),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final serverProvider = context.watch<ServerProvider>();

    // Auto-select first server if none selected
    if (vpnProvider.selectedServer == null && serverProvider.servers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vpnProvider.setSelectedServer(serverProvider.servers.first);
      });
    }

    final selected = vpnProvider.selectedServer;
    final pingValue = (selected?.ping != null && selected!.ping! > 0) ? '${selected.ping}' : '--';

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Top App Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D4FF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.4)),
                        ),
                        child: const Icon(
                          Icons.sports_esports_rounded,
                          color: Color(0xFF00D4FF),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'CPRay Gaming',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'LOW LATENCY TUNNEL',
                            style: TextStyle(
                              color: Color(0xFF00D4FF),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Gaming TUN Switch
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141724),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: vpnProvider.settings.isGamingTunMode
                                ? const Color(0xFF00FF88).withOpacity(0.5)
                                : const Color(0xFF242A42),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              size: 16,
                              color: vpnProvider.settings.isGamingTunMode
                                  ? const Color(0xFF00FF88)
                                  : const Color(0xFF6B7A94),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'TUN MODE',
                              style: TextStyle(
                                color: vpnProvider.settings.isGamingTunMode
                                    ? const Color(0xFF00FF88)
                                    : const Color(0xFF6B7A94),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Switch(
                              value: vpnProvider.settings.isGamingTunMode,
                              onChanged: (val) => vpnProvider.toggleGamingTunMode(val),
                              activeColor: const Color(0xFF00FF88),
                              activeTrackColor: const Color(0xFF00FF88).withOpacity(0.3),
                              inactiveThumbColor: const Color(0xFF6B7A94),
                              inactiveTrackColor: const Color(0xFF1C2237),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Logs Button
                      IconButton(
                        icon: const Icon(Icons.terminal_rounded, color: Color(0xFF8C9BAE), size: 22),
                        tooltip: 'Live Logs',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const LogsView()),
                          );
                        },
                      ),
                      // Settings Button
                      IconButton(
                        icon: const Icon(Icons.settings_rounded, color: Color(0xFF8C9BAE), size: 22),
                        tooltip: 'Settings',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const SettingsView()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(flex: 1),

              // Server Selection Pill
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ServerListView()),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141726),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF242A42), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D4FF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.dns_rounded, color: Color(0xFF00D4FF), size: 18),
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
                                  ? '${selected.protocol.toUpperCase()} • ${selected.server}'
                                  : 'Click to import or select server',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6B7A94),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF6B7A94)),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Connect Glowing Trigger
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

              const Spacer(flex: 2),

              // 4 Stat Cards (Ping, Download, Upload, Session Duration)
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Latency',
                      value: pingValue,
                      unit: 'ms',
                      icon: Icons.speed_rounded,
                      accentColor: const Color(0xFF00FF88),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Duration',
                      value: VpnService.formatDuration(vpnProvider.connectedSeconds),
                      unit: '',
                      icon: Icons.timer_rounded,
                      accentColor: const Color(0xFF00D4FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Download',
                      value: vpnProvider.downloadSpeed.toStringAsFixed(1),
                      unit: 'KB/s',
                      icon: Icons.arrow_downward_rounded,
                      accentColor: const Color(0xFF9D00FF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Upload',
                      value: vpnProvider.uploadSpeed.toStringAsFixed(1),
                      unit: 'KB/s',
                      icon: Icons.arrow_upward_rounded,
                      accentColor: const Color(0xFFFFB300),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
