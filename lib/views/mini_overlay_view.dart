import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/vpn_provider.dart';
import '../services/vpn_service.dart';

class MiniOverlayView extends StatelessWidget {
  final VoidCallback onExpand;

  const MiniOverlayView({super.key, required this.onExpand});

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final isConnected = vpnProvider.isConnected;
    final selected = vpnProvider.selectedServer;
    final ping = selected?.ping != null && selected!.ping! > 0 ? '${selected.ping} ms' : '-- ms';

    return Scaffold(
      backgroundColor: const Color(0xFF090B10),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D101A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isConnected ? const Color(0xFF00FF88).withOpacity(0.6) : const Color(0xFF22283D),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isConnected ? const Color(0xFF00FF88).withOpacity(0.15) : Colors.black54,
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Bar
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isConnected ? const Color(0xFF00FF88) : const Color(0xFFFF3366),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selected?.name ?? 'CPRay Gaming',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen_rounded, color: Color(0xFF00D4FF), size: 20),
                  tooltip: 'Expand Window',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onExpand,
                ),
              ],
            ),

            // Metrics Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHUDCard('PING', ping, const Color(0xFF00FF88)),
                _buildHUDCard('DOWN', '${vpnProvider.downloadSpeed.toStringAsFixed(0)} KB/s', const Color(0xFF00D4FF)),
                _buildHUDCard('TIME', VpnService.formatDuration(vpnProvider.connectedSeconds), const Color(0xFFFFB300)),
                IconButton(
                  onPressed: () => vpnProvider.toggleConnection(),
                  icon: Icon(
                    isConnected ? Icons.power_settings_new_rounded : Icons.play_arrow_rounded,
                    color: isConnected ? const Color(0xFFFF3366) : const Color(0xFF00FF88),
                    size: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHUDCard(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF5A6678), fontSize: 9, fontWeight: FontWeight.w800)),
        Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
