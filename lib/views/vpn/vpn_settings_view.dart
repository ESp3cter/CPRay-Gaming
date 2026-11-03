import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_settings.dart';
import '../../providers/vpn_provider.dart';
import '../../services/localization_service.dart';
import '../../services/updater_service.dart';
import '../../widgets/update_dialog.dart';

class VpnSettingsView extends StatefulWidget {
  const VpnSettingsView({super.key});

  @override
  State<VpnSettingsView> createState() => _VpnSettingsViewState();
}

class _VpnSettingsViewState extends State<VpnSettingsView> {
  bool _isCheckingUpdate = false;

  final Map<String, String> _antiSanctionNames = {
    'radar': 'Radar.game (10.202.10.10)',
    'electro': 'Electro DNS (78.157.42.101)',
    'shecan': 'Shecan (178.22.122.100)',
    'dns4s': 'DNS4S (4.2.2.4)',
  };

  Future<void> _checkUpdate() async {
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
          const SnackBar(content: Text('You are using the latest version of CPRay VPN!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final settings = vpnProvider.settings;

    return Scaffold(
      backgroundColor: const Color(0xFF090C14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E121D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF00D4FF)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFF1E2638), height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        children: [
          _buildSectionHeader('ROUTING & PRIVACY'),
          _buildSwitchCard(
            title: 'Domestic Traffic Bypass',
            subtitle: 'Direct unthrottled access to local banking & .ir websites',
            value: settings.bypassIran,
            icon: Icons.alt_route_rounded,
            activeColor: const Color(0xFF00FF88),
            onChanged: (val) => vpnProvider.setBypassIran(val),
          ),
          const SizedBox(height: 10),
          _buildSwitchCard(
            title: 'Anti-Sanction DNS Mode',
            subtitle: 'Bypass game & dev developer sanctions with low latency DNS',
            value: settings.antiSanctionMode,
            icon: Icons.shield_rounded,
            activeColor: const Color(0xFF9D00FF),
            onChanged: (val) => vpnProvider.setAntiSanctionMode(val),
          ),
          if (settings.antiSanctionMode) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF111624),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E2638)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Resolver', style: TextStyle(color: Color(0xFF8C9BAE), fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _antiSanctionNames.entries.map((e) {
                      final isSelected = settings.antiSanctionProvider == e.key;
                      return ChoiceChip(
                        label: Text(e.value),
                        selected: isSelected,
                        onSelected: (_) => vpnProvider.setAntiSanctionProvider(e.key),
                        selectedColor: const Color(0xFF9D00FF).withOpacity(0.25),
                        backgroundColor: const Color(0xFF161C2C),
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFF9D00FF) : const Color(0xFF8C9BAE),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF9D00FF) : const Color(0xFF222B3F),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 22),
          _buildSectionHeader('PREFERENCES & LANGUAGE'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF111624),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E2638)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4FF).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.language_rounded, color: Color(0xFF00D4FF), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('App Language', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
                InkWell(
                  onTap: () {
                    final nextLang = LocalizationService.isPersian ? 'en' : 'fa';
                    vpnProvider.setLanguage(nextLang);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF182030),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2B3650)),
                    ),
                    child: Text(
                      LocalizationService.isPersian ? '🇮🇷 فارسی' : '🇺🇸 English',
                      style: const TextStyle(color: Color(0xFF00D4FF), fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildSwitchCard(
            title: 'Auto-Connect on Launch',
            subtitle: 'Automatically connect to the fastest node when opened',
            value: settings.autoConnect,
            icon: Icons.flash_on_rounded,
            activeColor: const Color(0xFFFFB300),
            onChanged: (val) => vpnProvider.setAutoConnect(val),
          ),

          const SizedBox(height: 22),
          _buildSectionHeader('APPLICATION & UPDATES'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111624),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E2638)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4FF).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_rounded, color: Color(0xFF00D4FF), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'CPRay VPN Suite',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Version 0.3.6 (Sing-box Core 1.14+)',
                        style: TextStyle(color: Color(0xFF6B7A94), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isCheckingUpdate ? null : _checkUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4FF),
                    foregroundColor: const Color(0xFF090A10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _isCheckingUpdate
                      ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF090A10)))
                      : const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Update', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
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
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111624),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2638)),
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
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Color(0xFF6B7A94), fontSize: 11)),
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
