import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vpn_provider.dart';
import '../services/updater_service.dart';
import '../widgets/update_dialog.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final List<String> _dnsOptions = [
    '1.1.1.1',
    '8.8.8.8',
    '9.9.9.9',
    '77.88.8.8',
  ];

  bool _isCheckingUpdate = false;

  Future<void> _manualCheckUpdate() async {
    setState(() => _isCheckingUpdate = true);
    final update = await UpdaterService.checkForUpdates();
    setState(() => _isCheckingUpdate = false);

    if (mounted) {
      if (update != null && update.hasUpdate) {
        showDialog(
          context: context,
          builder: (context) => UpdateDialog(updateInfo: update),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are using the latest version of CPRay Gaming!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final settings = vpnProvider.settings;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0D14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings & Routing',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _buildSectionHeader('GAMING & TUNNEL ENGINE'),
          _buildSwitchTile(
            title: 'Gaming TUN Mode (Wintun)',
            subtitle: 'Routes 100% of PC and Game UDP/TCP traffic through low-latency virtual adapter',
            value: settings.isGamingTunMode,
            icon: Icons.sports_esports_rounded,
            activeColor: const Color(0xFF00FF88),
            onChanged: (val) {
              vpnProvider.toggleGamingTunMode(val);
            },
          ),
          _buildSwitchTile(
            title: 'Bypass Domestic Traffic',
            subtitle: 'Directly routes local banking and domestic websites for maximum speed',
            value: settings.bypassDomesticIps,
            icon: Icons.alt_route_rounded,
            activeColor: const Color(0xFF00D4FF),
            onChanged: (val) {
              vpnProvider.updateSettings(settings.copyWith(bypassDomesticIps: val));
            },
          ),

          const SizedBox(height: 20),
          _buildSectionHeader('DNS & RESOLUTION'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF141726),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF242A42)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.dns_rounded, color: Color(0xFF9D00FF), size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Gaming DNS Server',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: settings.selectedDns,
                  dropdownColor: const Color(0xFF141726),
                  underline: const SizedBox(),
                  style: const TextStyle(color: Color(0xFF00D4FF), fontWeight: FontWeight.w700),
                  items: _dnsOptions.map((dns) {
                    return DropdownMenuItem(
                      value: dns,
                      child: Text(dns),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      vpnProvider.updateSettings(settings.copyWith(selectedDns: val));
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _buildSectionHeader('APPLICATION & UPDATES'),
          _buildSwitchTile(
            title: 'Auto-Start on Windows Boot',
            subtitle: 'Launch CPRay Gaming automatically when you start your PC',
            value: settings.autoStartOnBoot,
            icon: Icons.power_rounded,
            activeColor: const Color(0xFFFFB300),
            onChanged: (val) {
              vpnProvider.updateSettings(settings.copyWith(autoStartOnBoot: val));
            },
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141726),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF242A42)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'CPRay-Gaming Client',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Version 0.0.2 (Sing-box Core)',
                      style: TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _isCheckingUpdate ? null : _manualCheckUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4FF),
                    foregroundColor: const Color(0xFF0D0F18),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _isCheckingUpdate
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D0F18)),
                        )
                      : const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Check Update', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF6B7A94),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141726),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF242A42)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: activeColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF6B7A94), fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            activeTrackColor: activeColor.withOpacity(0.3),
            inactiveThumbColor: const Color(0xFF6B7A94),
            inactiveTrackColor: const Color(0xFF1C2237),
          ),
        ],
      ),
    );
  }
}
