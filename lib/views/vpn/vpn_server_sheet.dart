import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/server_provider.dart';
import '../../providers/vpn_provider.dart';
import '../../services/localization_service.dart';

class VpnServerSheet extends StatefulWidget {
  const VpnServerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VpnServerSheet(),
    );
  }

  @override
  State<VpnServerSheet> createState() => _VpnServerSheetState();
}

class _VpnServerSheetState extends State<VpnServerSheet> {
  String _search = '';
  final TextEditingController _subUrlController = TextEditingController();

  @override
  void dispose() {
    _subUrlController.dispose();
    super.dispose();
  }

  void _showAddSubscriptionDialog(BuildContext context) {
    final serverProvider = context.read<ServerProvider>();
    _subUrlController.text = serverProvider.subscriptionUrl ?? '';

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: LocalizationService.direction,
        child: AlertDialog(
          backgroundColor: const Color(0xFF141824),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF00D4FF), width: 1.2),
          ),
          title: Text(
            LocalizationService.tr('add_subscription_title'),
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalizationService.tr('add_subscription_desc'),
                style: const TextStyle(color: Color(0xFF8C9BAE), fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subUrlController,
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
              child: Text(LocalizationService.tr('cancel'), style: const TextStyle(color: Color(0xFF7E8B9E))),
            ),
            ElevatedButton(
              onPressed: () {
                final url = _subUrlController.text.trim();
                if (url.isNotEmpty) {
                  serverProvider.updateSubscription(url);
                }
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
                foregroundColor: const Color(0xFF090A10),
              ),
              child: Text(LocalizationService.tr('save_and_fetch'), style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importFromClipboard(BuildContext context) async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocalizationService.tr('clipboard_empty'))),
        );
      }
      return;
    }

    if (context.mounted) {
      final ok = await context.read<ServerProvider>().addManualConfig(text);
      if (context.mounted) {
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LocalizationService.tr('imported_successfully'))),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LocalizationService.tr('unrecognized_config'))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverProvider = context.watch<ServerProvider>();
    final vpnProvider = context.watch<VpnProvider>();
    final selectedServer = vpnProvider.selectedServer;

    final filtered = serverProvider.servers.where((s) {
      if (_search.trim().isEmpty) return true;
      final q = _search.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.server.toLowerCase().contains(q) ||
          s.protocol.toLowerCase().contains(q);
    }).toList();

    return Directionality(
      textDirection: LocalizationService.direction,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF0E121D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Color(0xFF1E2638), width: 1.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFF28324A),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocalizationService.tr('select_location_node'),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${serverProvider.servers.length} ${LocalizationService.tr('locations_available')}',
                        style: const TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: serverProvider.isLoading ? null : () => serverProvider.testAllPings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF181F30),
                      foregroundColor: const Color(0xFF00FF88),
                      side: const BorderSide(color: Color(0xFF00FF88), width: 1.0),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: serverProvider.isLoading
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00FF88)))
                        : const Icon(Icons.bolt_rounded, size: 16),
                    label: Text(LocalizationService.tr('test_ping'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Search & Quick Import Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _search = val),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: LocalizationService.tr('search_locations'),
                        hintStyle: const TextStyle(color: Color(0xFF5A6678), fontSize: 12),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00D4FF), size: 18),
                        filled: true,
                        fillColor: const Color(0xFF131826),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E2638)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF00D4FF)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _importFromClipboard(context),
                    tooltip: LocalizationService.tr('import_from_clipboard'),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131826),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E2638)),
                      ),
                      child: const Icon(Icons.content_paste_rounded, color: Color(0xFF00D4FF), size: 18),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAddSubscriptionDialog(context),
                    tooltip: LocalizationService.tr('update_subscription'),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131826),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E2638)),
                      ),
                    child: const Icon(Icons.sync_rounded, color: Color(0xFF00FF88), size: 18),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFF1E2638), height: 1),

          // Server List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.dns_rounded, color: Color(0xFF5A6678), size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'No Servers Added',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap + or paste a subscription link to get started',
                          style: TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddSubscriptionDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00D4FF),
                            foregroundColor: const Color(0xFF090A10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.add_link_rounded, size: 18),
                          label: const Text('Add Subscription', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final server = filtered[index];
                      final isSelected = selectedServer?.id == server.id;
                      final ping = server.ping;

                      Color pingColor = const Color(0xFF5A6678);
                      if (ping != null && ping > 0) {
                        if (ping < 80) {
                          pingColor = const Color(0xFF00FF88);
                        } else if (ping < 140) {
                          pingColor = const Color(0xFF00D4FF);
                        } else if (ping < 220) {
                          pingColor = const Color(0xFFFFB300);
                        } else {
                          pingColor = const Color(0xFFFF3366);
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF141D2E) : const Color(0xFF111522),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF00D4FF) : const Color(0xFF1C2335),
                            width: isSelected ? 1.4 : 1.0,
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            vpnProvider.setSelectedServer(server);
                            Navigator.of(context).pop();
                          },
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF181F30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _extractFlag(server.name),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          title: Text(
                            server.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          subtitle: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E2638),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  server.protocol.toUpperCase(),
                                  style: const TextStyle(color: Color(0xFF00D4FF), fontSize: 9, fontWeight: FontWeight.w800),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${server.server}:${server.port}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Color(0xFF5A6678), fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: pingColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: pingColor.withOpacity(0.4)),
                                ),
                                child: Text(
                                  ping != null && ping > 0 ? '$ping ms' : '--',
                                  style: TextStyle(color: pingColor, fontSize: 11, fontWeight: FontWeight.w800),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                color: isSelected ? const Color(0xFF00D4FF) : const Color(0xFF3B4863),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
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
