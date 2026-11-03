import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/server_config.dart';
import '../../providers/server_provider.dart';
import '../../providers/vpn_provider.dart';
import '../../services/localization_service.dart';
import '../../services/updater_service.dart';
import '../../services/vpn_service.dart';
import '../../widgets/update_dialog.dart';
import 'vpn_server_sheet.dart';
import 'vpn_settings_view.dart';

class VpnMainLayout extends StatefulWidget {
  const VpnMainLayout({super.key});

  @override
  State<VpnMainLayout> createState() => _VpnMainLayoutState();
}

class _VpnMainLayoutState extends State<VpnMainLayout> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForceUpdate();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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

  void _showAddSubscriptionDialog(BuildContext context) {
    final controller = TextEditingController(
      text: context.read<ServerProvider>().subscriptionUrl ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF00D4FF), width: 1.2),
        ),
        title: const Text(
          'Add Subscription URL',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste your Pasarguard, Marzban, or V2Ray link:',
              style: TextStyle(color: Color(0xFF8C9BAE), fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'https://panel.example.com/sub/...',
                hintStyle: const TextStyle(color: Color(0xFF5A6678)),
                filled: true,
                fillColor: const Color(0xFF0C0E16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF22283D)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00D4FF)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF7E8B9E))),
          ),
          ElevatedButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                context.read<ServerProvider>().updateSubscription(url);
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4FF),
              foregroundColor: const Color(0xFF090A10),
            ),
            child: const Text('Save & Fetch', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromClipboard(BuildContext context) async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clipboard is empty!')),
        );
      }
      return;
    }

    if (context.mounted) {
      final ok = await context.read<ServerProvider>().addManualConfig(text);
      if (context.mounted) {
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imported node successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unrecognized config format in clipboard.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final serverProvider = context.watch<ServerProvider>();

    if (vpnProvider.selectedServer == null && serverProvider.servers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vpnProvider.setSelectedServer(serverProvider.servers.first);
      });
    }

    final isConnected = vpnProvider.isConnected;
    final isConnecting = vpnProvider.isConnecting;
    final selectedServer = vpnProvider.selectedServer;

    if (isConnected || isConnecting) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.value = 0.0;
      }
    }

    return Directionality(
      textDirection: LocalizationService.direction,
      child: Scaffold(
        backgroundColor: const Color(0xFF090C14),
        body: SafeArea(
          child: Column(
            children: [
              // --- CLOUDFLARE WARP TOP BAR ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Settings Button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131724),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E2638)),
                        ),
                        child: const Icon(Icons.tune_rounded, color: Color(0xFF8C9BAE), size: 20),
                      ),
                      tooltip: 'Settings',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const VpnSettingsView()),
                        );
                      },
                    ),

                    // App Title
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00D4FF), Color(0xFF00FF88)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shield_rounded, color: Color(0xFF090C14), size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'CPRay VPN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),

                    // Add (+) Menu Button
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131724),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E2638)),
                        ),
                        child: const Icon(Icons.add_rounded, color: Color(0xFF00D4FF), size: 20),
                      ),
                      color: const Color(0xFF141824),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFF1E2638)),
                      ),
                      onSelected: (val) {
                        if (val == 'clipboard') {
                          _importFromClipboard(context);
                        } else if (val == 'sub_add') {
                          _showAddSubscriptionDialog(context);
                        } else if (val == 'sub_refresh') {
                          if (serverProvider.subscriptionUrl != null && serverProvider.subscriptionUrl!.isNotEmpty) {
                            serverProvider.updateSubscription(serverProvider.subscriptionUrl!);
                          } else {
                            _showAddSubscriptionDialog(context);
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'clipboard',
                          child: Row(
                            children: [
                              Icon(Icons.content_paste_rounded, color: Color(0xFF00D4FF), size: 18),
                              SizedBox(width: 10),
                              Text('Import from Clipboard', style: TextStyle(color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'sub_refresh',
                          child: Row(
                            children: [
                              Icon(Icons.sync_rounded, color: Color(0xFF00FF88), size: 18),
                              SizedBox(width: 10),
                              Text('Update Subscription', style: TextStyle(color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'sub_add',
                          child: Row(
                            children: [
                              Icon(Icons.add_link_rounded, color: Color(0xFFFFB300), size: 18),
                              SizedBox(width: 10),
                              Text('Edit Subscription URL', style: TextStyle(color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- CENTER HERO POWER TOGGLE ---
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // WARP Large Toggle Button
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          final scale = (isConnected || isConnecting) ? _pulseAnimation.value : 1.0;
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: InkWell(
                          onTap: () {
                            if (selectedServer == null && serverProvider.servers.isEmpty) {
                              VpnServerSheet.show(context);
                            } else {
                              vpnProvider.toggleConnection();
                            }
                          },
                          borderRadius: BorderRadius.circular(100),
                          splashColor: isConnected
                              ? const Color(0xFF00FF88).withOpacity(0.3)
                              : const Color(0xFF00D4FF).withOpacity(0.3),
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: isConnected
                                    ? [
                                        const Color(0xFF00FF88).withOpacity(0.25),
                                        const Color(0xFF101924),
                                        const Color(0xFF0B0E17),
                                      ]
                                    : isConnecting
                                        ? [
                                            const Color(0xFFFFB300).withOpacity(0.25),
                                            const Color(0xFF191715),
                                            const Color(0xFF0B0E17),
                                          ]
                                        : [
                                            const Color(0xFF14192A),
                                            const Color(0xFF0E121E),
                                            const Color(0xFF090B12),
                                          ],
                              ),
                              border: Border.all(
                                color: isConnected
                                    ? const Color(0xFF00FF88)
                                    : isConnecting
                                        ? const Color(0xFFFFB300)
                                        : const Color(0xFF22293D),
                                width: isConnected ? 3.5 : 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isConnected
                                      ? const Color(0xFF00FF88).withOpacity(0.35)
                                      : isConnecting
                                          ? const Color(0xFFFFB300).withOpacity(0.3)
                                          : Colors.black.withOpacity(0.4),
                                  blurRadius: isConnected ? 32 : 16,
                                  spreadRadius: isConnected ? 2 : 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                isConnected
                                    ? Icons.power_settings_new_rounded
                                    : isConnecting
                                        ? Icons.sync_rounded
                                        : Icons.power_settings_new_rounded,
                                size: 68,
                                color: isConnected
                                    ? const Color(0xFF00FF88)
                                    : isConnecting
                                        ? const Color(0xFFFFB300)
                                        : const Color(0xFF5A6678),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Status Headline
                      Text(
                        isConnected
                            ? 'CONNECTED'
                            : isConnecting
                                ? 'CONNECTING...'
                                : 'DISCONNECTED',
                        style: TextStyle(
                          color: isConnected
                              ? const Color(0xFF00FF88)
                              : isConnecting
                                  ? const Color(0xFFFFB300)
                                  : const Color(0xFF8C9BAE),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isConnected
                            ? 'Your traffic is encrypted, secure & accelerated'
                            : isConnecting
                                ? 'Establishing secure Sing-box tunnel...'
                                : 'Your internet is direct & unprotected',
                        style: const TextStyle(
                          color: Color(0xFF6B7A94),
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Telemetry Badges (Visible when connected)
                      if (isConnected) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatChip(
                              icon: Icons.speed_rounded,
                              label: (selectedServer?.ping != null && selectedServer!.ping! > 0)
                                  ? '${selectedServer.ping} ms'
                                  : 'Active',
                              color: const Color(0xFF00FF88),
                            ),
                            const SizedBox(width: 8),
                            _buildStatChip(
                              icon: Icons.arrow_downward_rounded,
                              label: '${vpnProvider.downloadSpeed.toStringAsFixed(1)} KB/s',
                              color: const Color(0xFF00D4FF),
                            ),
                            const SizedBox(width: 8),
                            _buildStatChip(
                              icon: Icons.timer_rounded,
                              label: VpnService.formatDuration(vpnProvider.connectedSeconds),
                              color: const Color(0xFF9D00FF),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // --- BOTTOM FLOATING SERVER CARD ---
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: InkWell(
                  onTap: () => VpnServerSheet.show(context),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111522),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF1E2638), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: const Color(0xFF181F30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            selectedServer != null ? _extractFlag(selectedServer.name) : '🌐',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedServer != null ? selectedServer.name : 'Select a Server Node',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedServer != null
                                    ? '${selectedServer.protocol.toUpperCase()} • Tap to change location'
                                    : 'Tap to choose or import servers',
                                style: const TextStyle(color: Color(0xFF6B7A94), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF182030),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF2B3650)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                (selectedServer?.ping != null && selectedServer!.ping! > 0)
                                    ? '${selectedServer.ping} ms'
                                    : 'Switch',
                                style: const TextStyle(color: Color(0xFF00D4FF), fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFF00D4FF), size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111522),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  String _extractFlag(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('de') || lower.contains('germany') || lower.contains('آلمان')) return '🇩🇪';
    if (lower.contains('nl') || lower.contains('netherland') || lower.contains('هلند')) return '🇳🇱';
    if (lower.contains('fr') || lower.contains('france') || lower.contains('فرانسه')) return '🇫🇷';
    if (lower.contains('gb') || lower.contains('uk') || lower.contains('england') || lower.contains('انگلیس')) return '🇬🇧';
    if (lower.contains('us') || lower.contains('united states') || lower.contains('آمریکا')) return '🇺🇸';
    if (lower.contains('tr') || lower.contains('turkey') || lower.contains('ترکیه')) return '🇹🇷';
    if (lower.contains('ae') || lower.contains('uae') || lower.contains('dubai') || lower.contains('دبی')) return '🇦🇪';
    if (lower.contains('fi') || lower.contains('finland') || lower.contains('فنلاند')) return '🇫🇮';
    if (lower.contains('ir') || lower.contains('iran') || lower.contains('ایران')) return '🇮🇷';
    return '🌐';
  }
}
