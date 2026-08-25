import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../models/app_settings.dart';
import '../providers/vpn_provider.dart';
import '../services/localization_service.dart';
import '../services/updater_service.dart';
import '../services/vpn_service.dart';
import '../widgets/update_dialog.dart';
import 'dashboard_view.dart';
import 'game_optimizer_view.dart';
import 'game_ping_tester_view.dart';
import 'logs_view.dart';
import 'mini_overlay_view.dart';
import 'server_list_view.dart';
import 'settings_view.dart';
import 'split_tunnel_view.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool _isMiniMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForceUpdate();
    });
  }

  Future<void> _checkForceUpdate() async {
    final update = await UpdaterService.checkForUpdates();
    if (update != null && update.hasUpdate && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => UpdateDialog(updateInfo: update),
      );
    }
  }

  Future<void> _toggleMiniMode() async {
    if (!Platform.isWindows) return;
    setState(() => _isMiniMode = !_isMiniMode);

    if (_isMiniMode) {
      await windowManager.setSize(const Size(340, 130));
      await windowManager.setAlwaysOnTop(true);
    } else {
      await windowManager.setSize(const Size(1020, 680));
      await windowManager.setAlwaysOnTop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isMiniMode) {
      return MiniOverlayView(onExpand: _toggleMiniMode);
    }

    final vpnProvider = context.watch<VpnProvider>();
    final isConnected = vpnProvider.isConnected;

    final List<Widget> pages = [
      DashboardView(onToggleMiniMode: _toggleMiniMode),
      const GameOptimizerView(),
      const GamePingTesterView(),
      const ServerListView(),
      const SplitTunnelView(),
      const SettingsView(),
      const LogsView(),
    ];

    return Directionality(
      textDirection: LocalizationService.direction,
      child: Scaffold(
        backgroundColor: const Color(0xFF090B10),
        body: Row(
          children: [
            // Desktop Left Sidebar
            Container(
              width: 236,
              decoration: BoxDecoration(
                color: const Color(0xFF0E111A),
                border: const Border(
                  right: BorderSide(color: Color(0xFF1B2133), width: 1.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Header & Language Switch
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00D4FF), Color(0xFF9D00FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00D4FF).withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.sports_esports_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocalizationService.tr('app_title'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                LocalizationService.tr('app_subtitle'),
                                style: const TextStyle(
                                  color: Color(0xFF00D4FF),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Language Switch Button
                        InkWell(
                          onTap: () {
                            final nextLang = LocalizationService.isPersian ? 'en' : 'fa';
                            vpnProvider.setLanguage(nextLang);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF181C2C),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF28314B)),
                            ),
                            child: Text(
                              LocalizationService.isPersian ? '🇺🇸 EN' : '🇮🇷 فا',
                              style: const TextStyle(color: Color(0xFF00D4FF), fontSize: 10, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Color(0xFF1B2133), height: 1),
                  const SizedBox(height: 10),

                  // Navigation Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _buildNavItem(0, LocalizationService.tr('dashboard'), Icons.speed_rounded),
                        _buildNavItem(1, LocalizationService.tr('game_optimizer'), Icons.sports_esports_rounded),
                        _buildNavItem(2, LocalizationService.tr('game_ping_tester'), Icons.network_check_rounded),
                        _buildNavItem(3, LocalizationService.tr('servers'), Icons.dns_rounded),
                        _buildNavItem(4, LocalizationService.tr('split_tunneling'), Icons.alt_route_rounded),
                        _buildNavItem(5, LocalizationService.tr('settings'), Icons.tune_rounded),
                        _buildNavItem(6, LocalizationService.tr('engine_logs'), Icons.terminal_rounded),
                      ],
                    ),
                  ),

                  // Bottom Status Pill
                  Container(
                    margin: const EdgeInsets.all(14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141724),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isConnected
                            ? const Color(0xFF00FF88).withOpacity(0.4)
                            : const Color(0xFF242A42),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: isConnected ? const Color(0xFF00FF88) : const Color(0xFFFF3366),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: isConnected
                                    ? const Color(0xFF00FF88).withOpacity(0.6)
                                    : const Color(0xFFFF3366).withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isConnected
                                    ? LocalizationService.tr('tunnel_active')
                                    : LocalizationService.tr('disconnected'),
                                style: TextStyle(
                                  color: isConnected ? const Color(0xFF00FF88) : const Color(0xFF8C9BAE),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                vpnProvider.settings.antiSanctionMode
                                    ? 'Anti-Sanction DNS'
                                    : (vpnProvider.boostedGameIds.isNotEmpty && vpnProvider.settings.splitTunnelMode == SplitTunnelMode.inclusive
                                        ? 'Per-App (${vpnProvider.boostedGameIds.length} Games)'
                                        : (vpnProvider.settings.vpnMode == VpnMode.tun
                                            ? 'Gaming (TUN)'
                                            : 'System Proxy')),
                                style: const TextStyle(
                                  color: Color(0xFF5A6678),
                                  fontSize: 9,
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

            // Right Content View
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: pages,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00D4FF).withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF00D4FF).withOpacity(0.4) : Colors.transparent,
          width: 1.0,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF00D4FF) : const Color(0xFF7E8B9E),
          size: 19,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF8C9BAE),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
