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
          'Engine Live Logs',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _autoScroll ? Icons.vertical_align_bottom_rounded : Icons.pause_rounded,
              color: _autoScroll ? const Color(0xFF00FF88) : const Color(0xFF6B7A94),
            ),
            tooltip: _autoScroll ? 'Auto-scroll ON' : 'Auto-scroll PAUSED',
            onPressed: () {
              setState(() => _autoScroll = !_autoScroll);
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: Color(0xFF00D4FF)),
            tooltip: 'Copy Logs',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: logs.join('\n')));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logs copied to clipboard!')),
              );
            },
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF07080C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E2336)),
        ),
        child: logs.isEmpty
            ? const Center(
                child: Text(
                  'No log entries yet. Connect to a server to see live traffic routing.',
                  style: TextStyle(color: Color(0xFF5A6678), fontSize: 12),
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final line = logs[index];
                  Color textColor = const Color(0xFFCBD5E1);

                  if (line.contains('[ERROR]') || line.contains('fatal') || line.contains('failed')) {
                    textColor = const Color(0xFFFF3366);
                  } else if (line.contains('TUN') || line.contains('connected') || line.contains('started')) {
                    textColor = const Color(0xFF00FF88);
                  } else if (line.contains('warn')) {
                    textColor = const Color(0xFFFFB300);
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      line,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: textColor,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
