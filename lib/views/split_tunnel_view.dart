import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../providers/vpn_provider.dart';
import '../services/game_detector_service.dart';

class SplitTunnelView extends StatefulWidget {
  const SplitTunnelView({super.key});

  @override
  State<SplitTunnelView> createState() => _SplitTunnelViewState();
}

class _SplitTunnelViewState extends State<SplitTunnelView> {
  final TextEditingController _appController = TextEditingController();

  final List<String> _presets = const [
    'steam.exe',
    'discord.exe',
    'cs2.exe',
    'valorant.exe',
    'riotclientservices.exe',
    'epicgameslauncher.exe',
    'chrome.exe',
    'telegram.exe',
  ];

  @override
  void dispose() {
    _appController.dispose();
    super.dispose();
  }

  void _addApp(String appName) {
    final clean = appName.trim();
    if (clean.isEmpty) return;

    final companionList = GameDetectorService.getCompanionProcesses(clean);
    final vpnProvider = context.read<VpnProvider>();
    final list = List<String>.from(vpnProvider.settings.splitTunnelApps);

    int addedCount = 0;
    for (final proc in companionList) {
      final finalName = proc.toLowerCase().endsWith('.exe') ? proc.toLowerCase() : '${proc.toLowerCase()}.exe';
      if (!list.contains(finalName)) {
        list.add(finalName);
        addedCount++;
      }
    }

    if (addedCount > 0) {
      vpnProvider.setSplitTunneling(vpnProvider.settings.splitTunnelMode, list);
      if (companionList.length > 1 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $clean and its companion processes (${companionList.join(", ")})'),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF141726),
          ),
        );
      }
    }
    _appController.clear();
  }

  Future<void> _browseAndAddApp() async {
    final exePath = await GameDetectorService.pickGameExecutable();
    if (exePath != null && mounted) {
      final fileName = exePath.split(Platform.isWindows ? r'\' : '/').last;
      _addApp(fileName);
    }
  }

  void _removeApp(String appName) {
    final vpnProvider = context.read<VpnProvider>();
    final list = List<String>.from(vpnProvider.settings.splitTunnelApps)..remove(appName.toLowerCase());
    vpnProvider.setSplitTunneling(vpnProvider.settings.splitTunnelMode, list);
  }

  void _clearAll() {
    final vpnProvider = context.read<VpnProvider>();
    vpnProvider.setSplitTunneling(vpnProvider.settings.splitTunnelMode, []);
  }

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final settings = vpnProvider.settings;
    final splitMode = settings.splitTunnelMode;
    final appList = settings.splitTunnelApps;

    return Container(
      color: const Color(0xFF090B10),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Split Tunneling & App Routing',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Choose which games or programs route through the VPN tunnel',
                    style: TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Mode Selector Cards (Disabled, Inclusive, Exclusive)
          Row(
            children: [
              Expanded(
                child: _buildModeCard(
                  title: 'Disabled',
                  subtitle: 'All PC programs route through VPN tunnel',
                  icon: Icons.all_inclusive_rounded,
                  isSelected: splitMode == SplitTunnelMode.disabled,
                  accentColor: const Color(0xFF00D4FF),
                  onTap: () => vpnProvider.setSplitTunneling(SplitTunnelMode.disabled, appList),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildModeCard(
                  title: 'Inclusive Mode',
                  subtitle: 'ONLY listed games/apps route through VPN',
                  icon: Icons.check_circle_outline_rounded,
                  isSelected: splitMode == SplitTunnelMode.inclusive,
                  accentColor: const Color(0xFF00FF88),
                  onTap: () => vpnProvider.setSplitTunneling(SplitTunnelMode.inclusive, appList),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildModeCard(
                  title: 'Exclusive Mode',
                  subtitle: 'Route all PC traffic EXCEPT listed apps',
                  icon: Icons.remove_circle_outline_rounded,
                  isSelected: splitMode == SplitTunnelMode.exclusive,
                  accentColor: const Color(0xFFFFB300),
                  onTap: () => vpnProvider.setSplitTunneling(SplitTunnelMode.exclusive, appList),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Dynamic Body
          Expanded(
            child: splitMode != SplitTunnelMode.disabled
                ? _buildActiveSplitContent(context, appList)
                : _buildDisabledContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSplitContent(BuildContext context, List<String> appList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Custom Process Name Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _appController,
                onSubmitted: (val) => _addApp(val),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Enter executable name (e.g. cs2.exe, discord.exe)...',
                  hintStyle: const TextStyle(color: Color(0xFF5A6678)),
                  prefixIcon: const Icon(Icons.add_to_queue_rounded, color: Color(0xFF00D4FF), size: 20),
                  filled: true,
                  fillColor: const Color(0xFF121522),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF22283D)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF00D4FF)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => _addApp(_appController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
                foregroundColor: const Color(0xFF090B10),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add App', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _browseAndAddApp,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00D4FF),
                side: const BorderSide(color: Color(0xFF00D4FF)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.folder_open_rounded, size: 18),
              label: const Text('Browse .exe', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Quick Presets
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presets.map((preset) {
            final isAdded = appList.contains(preset);
            return InkWell(
              onTap: () => isAdded ? _removeApp(preset) : _addApp(preset),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAdded ? const Color(0xFF00D4FF).withOpacity(0.18) : const Color(0xFF141726),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isAdded ? const Color(0xFF00D4FF).withOpacity(0.6) : const Color(0xFF242A42),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAdded ? Icons.check_rounded : Icons.add_rounded,
                      size: 14,
                      color: isAdded ? const Color(0xFF00D4FF) : const Color(0xFF7E8B9E),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      preset,
                      style: TextStyle(
                        color: isAdded ? Colors.white : const Color(0xFF8C9BAE),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // Header with count and Clear All
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ROUTED APPLICATIONS (${appList.length})',
              style: const TextStyle(
                color: Color(0xFF8C9BAE),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            if (appList.isNotEmpty)
              InkWell(
                onTap: _clearAll,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    'Clear All',
                    style: TextStyle(color: Color(0xFFFF3366), fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Configured Apps List
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10131E),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF1E2438)),
            ),
            child: appList.isEmpty
                ? const Center(
                    child: Text(
                      'No apps added yet. Type an executable name, click a preset, or browse .exe file above.',
                      style: TextStyle(color: Color(0xFF5A6678), fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    itemCount: appList.length,
                    itemBuilder: (context, index) {
                      final app = appList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151928),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF242A42)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.sports_esports_rounded, color: Color(0xFF00D4FF), size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                app,
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Color(0xFFFF3366), size: 18),
                              onPressed: () => _removeApp(app),
                              splashRadius: 18,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.all_inclusive_rounded, size: 54, color: Color(0xFF38435E)),
          SizedBox(height: 14),
          Text(
            'Split Tunneling is Disabled',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'All internet traffic from games, browsers, and applications is protected by CPRay.',
            style: TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF141A2C) : const Color(0xFF10131E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFF1E2438),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: isSelected ? accentColor : const Color(0xFF6B7A94), size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF8C9BAE),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF5A6678), fontSize: 11, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}
