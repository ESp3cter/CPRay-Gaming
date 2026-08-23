import 'package:flutter/material.dart';
import '../models/server_config.dart';

class ServerTile extends StatelessWidget {
  final ServerConfig server;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onTestPing;
  final VoidCallback? onDelete;

  const ServerTile({
    super.key,
    required this.server,
    required this.isSelected,
    required this.onSelect,
    required this.onTestPing,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color pingColor = const Color(0xFF7E8B9E);
    String pingText = '-- ms';

    if (server.isTestingPing) {
      pingText = '...';
    } else if (server.ping != null) {
      if (server.ping! > 0) {
        pingText = '${server.ping} ms';
        if (server.ping! < 160) {
          pingColor = const Color(0xFF00FF88);
        } else if (server.ping! < 320) {
          pingColor = const Color(0xFFFFB300);
        } else {
          pingColor = const Color(0xFFFF3366);
        }
      } else {
        pingText = 'Timeout';
        pingColor = const Color(0xFFFF3366);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1B2033) : const Color(0xFF121522),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFF00D4FF) : const Color(0xFF21273D),
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Protocol Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getProtocolColor(server.protocol).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getProtocolColor(server.protocol).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    server.protocol.toUpperCase(),
                    style: TextStyle(
                      color: _getProtocolColor(server.protocol),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Server Name & Host
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFFE0E5FF),
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${server.server}:${server.port}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7A94),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Ping Badge & Test Trigger
                InkWell(
                  onTap: onTestPing,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: pingColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: pingColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          pingText,
                          style: TextStyle(
                            color: pingColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFF6B7A94)),
                    onPressed: onDelete,
                    splashRadius: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getProtocolColor(String proto) {
    switch (proto.toLowerCase()) {
      case 'vless':
        return const Color(0xFF00D4FF);
      case 'hysteria2':
      case 'hy2':
        return const Color(0xFFFF0055);
      case 'tuic':
        return const Color(0xFF9D00FF);
      case 'trojan':
        return const Color(0xFF00FF88);
      case 'wireguard':
        return const Color(0xFFFFB300);
      case 'vmess':
      default:
        return const Color(0xFF0088FF);
    }
  }
}
