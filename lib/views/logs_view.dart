import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/vpn_provider.dart';

class LogsView extends StatefulWidget {
  const LogsView({super.key});

  @override
  State<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends State<LogsView> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final logs = vpnProvider.logs;

    if (_autoScroll && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }

    return Container(
      color: const Color(0xFF090B10),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Toolbar
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sing-box Core Live Terminal',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${logs.length} entries recorded • Real-time stdout & diagnostics',
                    style: const TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              // Auto Scroll Toggle
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _autoScroll = !_autoScroll);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF141A2C),
                  foregroundColor: _autoScroll ? const Color(0xFF00FF88) : const Color(0xFF7E8B9E),
                  side: BorderSide(
                    color: _autoScroll ? const Color(0xFF00FF88) : const Color(0xFF242A42),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: Icon(
                  _autoScroll ? Icons.vertical_align_bottom_rounded : Icons.pause_rounded,
                  size: 16,
                ),
                label: Text(_autoScroll ? 'Auto-Scroll ON' : 'Auto-Scroll PAUSED', style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 10),
              // Clear / Reset Logs Button
              ElevatedButton.icon(
                onPressed: () {
                  vpnProvider.clearLogs();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Console logs cleared!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1424),
                  foregroundColor: const Color(0xFFFF3366),
                  side: const BorderSide(color: Color(0xFFFF3366), width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                label: const Text('Reset Logs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 10),
              // Copy Logs Button
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: logs.join('\n')));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logs copied to clipboard!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4FF),
                  foregroundColor: const Color(0xFF090B10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Terminal Window Box
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF06070B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1B2133)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: logs.isEmpty
                  ? const Center(
                      child: Text(
                        'Terminal initialized. Connect to a server node to view live traffic routing stdout.',
                        style: TextStyle(color: Color(0xFF4A5568), fontSize: 13, fontFamily: 'monospace'),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final line = logs[index];
                        Color textColor = const Color(0xFFCBD5E1);

                        if (line.contains('[ERROR]') || line.contains('fatal') || line.contains('FATAL') || line.contains('failed')) {
                          textColor = const Color(0xFFFF3366);
                        } else if (line.contains('TUN') || line.contains('connected') || line.contains('started')) {
                          textColor = const Color(0xFF00FF88);
                        } else if (line.contains('warn') || line.contains('WARN')) {
                          textColor = const Color(0xFFFFB300);
                        } else if (line.contains('CLEARED')) {
                          textColor = const Color(0xFF00D4FF);
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.5),
                          child: Text(
                            line,
                            style: TextStyle(
                              fontFamily: 'Consolas, monospace',
                              color: textColor,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
