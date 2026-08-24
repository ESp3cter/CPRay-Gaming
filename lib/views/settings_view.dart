import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../providers/vpn_provider.dart';
import '../services/updater_service.dart';
import '../widgets/update_dialog.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController _customDnsController = TextEditingController();
  bool _isCheckingUpdate = false;

  final List<String> _autoDnsPresets = [
    '1.1.1.1',
    '8.8.8.8',
    '9.9.9.9',
    '77.88.8.8',
  ];

  @override
  void initState() {
    super.initState();
    final vpnProvider = context.read<VpnProvider>();
    _customDnsController.text = vpnProvider.settings.customDns;
  }

  @override
  void dispose() {
    _customDnsController.dispose();
    super.dispose();
  }

  Future<void> _manualCheckUpdate() async {
    setState(() => _isCheckingUpdate = true);
    final update = await UpdaterService.checkForUpdates();
    setState(() => _isCheckingUpdate = false);

    if (mounted) {
      if (update != null && update.hasUpdate) {
        showDialog(
          context: context,
          barrierDismissible: false,
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

    return Container(
      color: const Color(0xFF090B10),
      padding: const EdgeInsets.all(28),
      child: ListView(
        children: [
          const Text(
            'Settings & Routing',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Fine-tune your tunnel, domestic bypass, and DNS servers',
            style: TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('TUNNEL & OPERATION MODE'),
          Row(
            children: [
              Expanded(
                child: _buildSelectCard(
                  title: 'Gaming TUN Mode (Wintun)',
                  subtitle: 'Direct virtual adapter. 100% of game UDP packets & system apps.',
                  icon: Icons.sports_esports_rounded,
                  isSelected: settings.vpnMode == VpnMode.tun,
                  accentColor: const Color(0xFF00FF88),
                  onTap: () => vpnProvider.setVpnMode(VpnMode.tun),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildSelectCard(
                  title: 'System Proxy Mode',
                  subtitle: 'Lightweight web proxy. Routes browsers & system HTTP without adapter.',
                  icon: Icons.public_rounded,
                  isSelected: settings.vpnMode == VpnMode.systemProxy,
                  accentColor: const Color(0xFF00D4FF),
                  onTap: () => vpnProvider.setVpnMode(VpnMode.systemProxy),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('DOMESTIC ROUTING & BYPASS'),
          _buildSwitchTile(
            title: 'Bypass Iranian Websites & IPs',
            subtitle: 'Directly routes local banking, Snapp, Varzesh3, and all .ir domains outside VPN',
            value: settings.bypassIranianTraffic,
            icon: Icons.alt_route_rounded,
            activeColor: const Color(0xFF00D4FF),
            onChanged: (val) => vpnProvider.setBypassIranianTraffic(val),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('DNS RESOLUTION ENGINE'),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF10131E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E2438)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.dns_rounded, color: Color(0xFF9D00FF), size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Automatic Gaming DNS',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Switch(
                      value: settings.isAutoDns,
                      onChanged: (val) {
                        vpnProvider.setDnsSettings(
                          isAuto: val,
                          customDns: _customDnsController.text,
                        );
                      },
                      activeColor: const Color(0xFF9D00FF),
                      activeTrackColor: const Color(0xFF9D00FF).withOpacity(0.3),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (settings.isAutoDns) ...[
                  Row(
                    children: [
                      const Text(
                        'Preset DNS Server:',
                        style: TextStyle(color: Color(0xFF7E8B9E), fontSize: 12),
                      ),
                      const SizedBox(width: 14),
                      DropdownButton<String>(
                        value: settings.selectedDns,
                        dropdownColor: const Color(0xFF141726),
                        underline: const SizedBox(),
                        style: const TextStyle(color: Color(0xFF00D4FF), fontWeight: FontWeight.w700),
                        items: _autoDnsPresets.map((dns) {
                          return DropdownMenuItem(value: dns, child: Text(dns));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            vpnProvider.setDnsSettings(
                              isAuto: true,
                              customDns: _customDnsController.text,
                              selectedDns: val,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ] else ...[
                  const Text(
                    'Manual Custom DNS Server:',
                    style: TextStyle(color: Color(0xFF7E8B9E), fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customDnsController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'e.g. 77.88.8.8 or 9.9.9.9',
                            hintStyle: const TextStyle(color: Color(0xFF5A6678)),
                            filled: true,
                            fillColor: const Color(0xFF161A29),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF242A42)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          vpnProvider.setDnsSettings(
                            isAuto: false,
                            customDns: _customDnsController.text.trim(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Custom DNS saved successfully!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9D00FF),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save DNS'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('APPLICATION PREFERENCES'),
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
          const SizedBox(height: 10),
          _buildSwitchTile(
            title: 'Auto-Connect on Launch',
            subtitle: 'Automatically connect to the last selected server when app starts',
            value: settings.autoConnectOnLaunch,
            icon: Icons.flash_on_rounded,
            activeColor: const Color(0xFF00FF88),
            onChanged: (val) {
              vpnProvider.updateSettings(settings.copyWith(autoConnectOnLaunch: val));
            },
          ),

          const SizedBox(height: 20),

          // About & Force Update Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF10131E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E2438)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'CPRay-Gaming Desktop',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Version 0.0.7 (Sing-box Core 1.13+)',
                      style: TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _isCheckingUpdate ? null : _manualCheckUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4FF),
                    foregroundColor: const Color(0xFF090B10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _isCheckingUpdate
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF090B10)),
                        )
                      : const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Check Update', style: TextStyle(fontWeight: FontWeight.w800)),
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
      padding: const EdgeInsets.only(left: 4, bottom: 10),
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

  Widget _buildSelectCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF141A2C) : const Color(0xFF10131E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFF1E2438),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF8C9BAE),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF5A6678), fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF10131E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2438)),
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
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
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
