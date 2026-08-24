import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vpn_provider.dart';
import '../services/updater_service.dart';
import '../services/vpn_service.dart';
import '../widgets/update_dialog.dart';
import 'dashboard_view.dart';
import 'logs_view.dart';
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

  final List<Widget> _pages = const [
    DashboardView(),
    ServerListView(),
    SplitTunnelView(),
    SettingsView(),
    LogsView(),
  ];

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
        barrierDismissible: false, // Force update non-dismissible
        builder: (context) => UpdateDialog(updateInfo: update),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final isConnected = vpnProvider.isConnected;

    return Scaffold(
      backgroundColor: const Color(0xFF090B10),
      body: Row(
        children: [
          // Desktop Left Sidebar
          Container(
            width: 230,
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
                // Brand Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'CPRay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            'GAMING DESKTOP',
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
                ),

                const Divider(color: Color(0xFF1B2133), height: 1),
                const SizedBox(height: 12),

                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _buildNavItem(0, 'Dashboard', Icons.speed_rounded),
                      _buildNavItem(1, 'Servers & Nodes', Icons.dns_rounded),
                      _buildNavItem(2, 'Split Tunneling', Icons.alt_route_rounded),
                      _buildNavItem(3, 'Settings & Routing', Icons.tune_rounded),
                      _buildNavItem(4, 'Engine Logs', Icons.terminal_rounded),
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
                              isConnected ? 'TUNNEL ACTIVE' : 'DISCONNECTED',
                              style: TextStyle(
                                color: isConnected ? const Color(0xFF00FF88) : const Color(0xFF8C9BAE),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              vpnProvider.settings.vpnMode == VpnMode.tun ? 'Gaming (TUN)' : 'System Proxy',
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
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
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
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF8C9BAE),
            fontSize: 13,
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
