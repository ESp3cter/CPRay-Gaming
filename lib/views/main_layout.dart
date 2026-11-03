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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 720;
          if (isMobile) {
            return _buildMobileLayout(context, vpnProvider, isConnected, pages);
          } else {
            return _buildDesktopLayout(context, vpnProvider, isConnected, pages);
          }
        },
      ),
    );
  }

  // --- MOBILE ADAPTIVE LAYOUT ---
  Widget _buildMobileLayout(
    BuildContext context,
    VpnProvider vpnProvider,
    bool isConnected,
    List<Widget> pages,
  ) {
    final titles = [
      LocalizationService.tr('dashboard'),
      LocalizationService.tr('game_optimizer'),
      LocalizationService.tr('game_ping_tester'),
      LocalizationService.tr('servers'),
      LocalizationService.tr('split_tunneling'),
      LocalizationService.tr('settings'),
      LocalizationService.tr('engine_logs'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF090B10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E111A),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF00D4FF), size: 24),
            tooltip: 'Navigation Menu',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF9D00FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.sports_esports_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocalizationService.tr('app_title'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  titles[_selectedIndex],
                  style: const TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Quick Status indicator badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isConnected ? const Color(0xFF00FF88).withOpacity(0.15) : const Color(0xFFFF3366).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isConnected ? const Color(0xFF00FF88).withOpacity(0.5) : const Color(0xFFFF3366).withOpacity(0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isConnected ? const Color(0xFF00FF88) : const Color(0xFFFF3366),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isConnected ? 'ON' : 'OFF',
                  style: TextStyle(
                    color: isConnected ? const Color(0xFF00FF88) : const Color(0xFFFF3366),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Language Switch
          InkWell(
            onTap: () {
              final nextLang = LocalizationService.isPersian ? 'en' : 'fa';
              vpnProvider.setLanguage(nextLang);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          const SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFF1B2133), height: 1.0),
        ),
      ),
      drawer: _buildDrawer(context, vpnProvider, isConnected),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- MOBILE BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNav() {
    int currentNav = 0;
    if (_selectedIndex == 0) currentNav = 0;
    else if (_selectedIndex == 1) currentNav = 1;
    else if (_selectedIndex == 3) currentNav = 2;
    else if (_selectedIndex == 2) currentNav = 3;
    else if (_selectedIndex == 5) currentNav = 4;
    else currentNav = 0;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E111A),
        border: Border(top: BorderSide(color: Color(0xFF1B2133), width: 1.2)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentNav,
        onTap: (navIdx) {
          setState(() {
            switch (navIdx) {
              case 0: _selectedIndex = 0; break;
              case 1: _selectedIndex = 1; break;
              case 2: _selectedIndex = 3; break;
              case 3: _selectedIndex = 2; break;
              case 4: _selectedIndex = 5; break;
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0E111A),
        selectedItemColor: const Color(0xFF00D4FF),
        unselectedItemColor: const Color(0xFF6B7A94),
        selectedFontSize: 11,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.speed_rounded),
            label: LocalizationService.tr('dashboard'),
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_rounded),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.dns_rounded),
            label: LocalizationService.tr('servers'),
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.network_check_rounded),
            label: 'Ping',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.tune_rounded),
            label: LocalizationService.tr('settings'),
          ),
        ],
      ),
    );
  }

  // --- MOBILE SLIDE-OUT DRAWER ---
  Widget _buildDrawer(BuildContext context, VpnProvider vpnProvider, bool isConnected) {
    return Drawer(
      backgroundColor: const Color(0xFF0E111A),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
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
                ],
              ),
            ),
            const Divider(color: Color(0xFF1B2133), height: 1),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildDrawerNavItem(context, 0, LocalizationService.tr('dashboard'), Icons.speed_rounded),
                  _buildDrawerNavItem(context, 1, LocalizationService.tr('game_optimizer'), Icons.sports_esports_rounded),
                  _buildDrawerNavItem(context, 2, LocalizationService.tr('game_ping_tester'), Icons.network_check_rounded),
                  _buildDrawerNavItem(context, 3, LocalizationService.tr('servers'), Icons.dns_rounded),
                  _buildDrawerNavItem(context, 4, LocalizationService.tr('split_tunneling'), Icons.alt_route_rounded),
                  _buildDrawerNavItem(context, 5, LocalizationService.tr('settings'), Icons.tune_rounded),
                  _buildDrawerNavItem(context, 6, LocalizationService.tr('engine_logs'), Icons.terminal_rounded),
                ],
              ),
            ),
            _buildStatusPill(vpnProvider, isConnected),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerNavItem(BuildContext context, int index, String title, IconData icon) {
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
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // --- DESKTOP WIDESCREEN LAYOUT ---
  Widget _buildDesktopLayout(
    BuildContext context,
    VpnProvider vpnProvider,
    bool isConnected,
    List<Widget> pages,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFF090B10),
      body: Row(
        children: [
          // Desktop Left Sidebar
          Container(
            width: 236,
            decoration: BoxDecoration(
              color: const Color(0xFF0E111A),
              border: BorderDirectional(
                end: const BorderSide(color: Color(0xFF1B2133), width: 1.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(LocalizationService.isPersian ? -4 : 4, 0),
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
                      _buildDesktopNavItem(0, LocalizationService.tr('dashboard'), Icons.speed_rounded),
                      _buildDesktopNavItem(1, LocalizationService.tr('game_optimizer'), Icons.sports_esports_rounded),
                      _buildDesktopNavItem(2, LocalizationService.tr('game_ping_tester'), Icons.network_check_rounded),
                      _buildDesktopNavItem(3, LocalizationService.tr('servers'), Icons.dns_rounded),
                      _buildDesktopNavItem(4, LocalizationService.tr('split_tunneling'), Icons.alt_route_rounded),
                      _buildDesktopNavItem(5, LocalizationService.tr('settings'), Icons.tune_rounded),
                      _buildDesktopNavItem(6, LocalizationService.tr('engine_logs'), Icons.terminal_rounded),
                    ],
                  ),
                ),

                // Bottom Status Pill
                _buildStatusPill(vpnProvider, isConnected),
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
    );
  }

  Widget _buildDesktopNavItem(int index, String title, IconData icon) {
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

  Widget _buildStatusPill(VpnProvider vpnProvider, bool isConnected) {
    return Container(
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
    );
  }
}
