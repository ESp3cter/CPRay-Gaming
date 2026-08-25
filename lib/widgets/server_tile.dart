import 'package:flutter/material.dart';
import '../models/server_config.dart';

class ServerTile extends StatelessWidget {
  final ServerConfig server;
  final bool isSelected;
  final bool isBestGamingNode;
  final VoidCallback onSelect;
  final VoidCallback onTestPing;
  final VoidCallback? onDelete;

  const ServerTile({
    super.key,
    required this.server,
    required this.isSelected,
    this.isBestGamingNode = false,
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
        if (server.ping! < 70) {
          pingColor = const Color(0xFF00FF88);
        } else if (server.ping! < 120) {
          pingColor = const Color(0xFF00D4FF);
        } else if (server.ping! < 180) {
          pingColor = const Color(0xFFFFB300);
        } else {
          pingColor = const Color(0xFFFF3366);
        }
      } else {
        pingText = 'Timeout';
        pingColor = const Color(0xFFFF3366);
      }
    }

    final grade = server.gamingGrade;
    Color gradeColor = const Color(0xFF5A6678);
    if (grade == 'S+') {
      gradeColor = const Color(0xFF00FF88);
    } else if (grade == 'A') {
      gradeColor = const Color(0xFF00D4FF);
    } else if (grade == 'B') {
      gradeColor = const Color(0xFFFFB300);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1B2033) : const Color(0xFF121522),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF00D4FF)
              : (isBestGamingNode ? const Color(0xFF00FF88).withOpacity(0.6) : const Color(0xFF21273D)),
          width: (isSelected || isBestGamingNode) ? 1.5 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : (isBestGamingNode
                ? [
                    BoxShadow(
                      color: const Color(0xFF00FF88).withOpacity(0.08),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : []),
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

                // Server Name & Info & Gaming Intelligence Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              server.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFFE0E5FF),
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isBestGamingNode) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00FF88).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.4)),
                              ),
                              child: const Text(
                                '👑 BEST FOR GAMING',
                                style: TextStyle(
                                  color: Color(0xFF00FF88),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            '${server.server}:${server.port}',
                            style: const TextStyle(
                              color: Color(0xFF6B7A94),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: (server.isUdpCapable ? const Color(0xFF00D4FF) : const Color(0xFF5A6678)).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              server.isUdpCapable ? '⚡ UDP READY' : '🌐 TCP',
                              style: TextStyle(
                                color: server.isUdpCapable ? const Color(0xFF00D4FF) : const Color(0xFF6B7A94),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (server.gamingScore > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Gaming Grade: $grade (${server.gamingScore}/100)',
                              style: TextStyle(color: gradeColor, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Ping Badge & Test Trigger
                InkWell(
                  onTap: onTestPing,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: pingColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: pingColor.withOpacity(0.3)),
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
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (onDelete != null) ...[
                  const SizedBox(width: 6),
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
