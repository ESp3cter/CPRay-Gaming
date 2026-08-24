import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/server_config.dart';
import '../providers/server_provider.dart';
import '../providers/vpn_provider.dart';
import '../widgets/server_tile.dart';

class ServerListView extends StatefulWidget {
  const ServerListView({super.key});

  @override
  State<ServerListView> createState() => _ServerListViewState();
}

class _ServerListViewState extends State<ServerListView> {
  final TextEditingController _subUrlController = TextEditingController();
  final TextEditingController _manualConfigController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final serverProvider = context.read<ServerProvider>();
    if (serverProvider.subscriptionUrl != null) {
      _subUrlController.text = serverProvider.subscriptionUrl!;
    }
  }

  @override
  void dispose() {
    _subUrlController.dispose();
    _manualConfigController.dispose();
    super.dispose();
  }

  void _showAddSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141726),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF00D4FF), width: 1.2),
          ),
          title: const Text(
            'Import Pasarguard / V2Ray Subscription',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Paste your subscription URL from Pasarguard, Marzban, or any panel:',
                style: TextStyle(color: Color(0xFF8C9BAE), fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _subUrlController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'https://your-panel.com/sub/...',
                  hintStyle: const TextStyle(color: Color(0xFF5A6678)),
                  filled: true,
                  fillColor: const Color(0xFF0D0F18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF242A42)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF00D4FF)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF7E8B9E))),
            ),
            ElevatedButton(
              onPressed: () {
                final url = _subUrlController.text.trim();
                if (url.isNotEmpty) {
                  context.read<ServerProvider>().updateSubscription(url);
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
                foregroundColor: const Color(0xFF0D0F18),
              ),
              child: const Text('Fetch Configs', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  void _showManualAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141726),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF00FF88), width: 1.2),
          ),
          title: const Text(
            'Import Manual Node',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Paste a single vless://, vmess://, trojan://, hy2:// or tuic:// link:',
                style: TextStyle(color: Color(0xFF8C9BAE), fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _manualConfigController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'vless://uuid@server:port?security=reality...',
                  hintStyle: const TextStyle(color: Color(0xFF5A6678)),
                  filled: true,
                  fillColor: const Color(0xFF0D0F18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF242A42)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF00FF88)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF7E8B9E))),
            ),
            ElevatedButton(
              onPressed: () async {
                final link = _manualConfigController.text.trim();
                if (link.isNotEmpty) {
                  final ok = await context.read<ServerProvider>().addManualConfig(link);
                  if (mounted) {
                    if (ok) {
                      _manualConfigController.clear();
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid config link format')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF88),
                foregroundColor: const Color(0xFF0D0F18),
              ),
              child: const Text('Add Node', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final serverProvider = context.watch<ServerProvider>();
    final vpnProvider = context.watch<VpnProvider>();
    final servers = serverProvider.filteredServers;

    return Container(
      color: const Color(0xFF090B10),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Action Bar
          Row(
            children: [
              if (Navigator.canPop(context)) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF00D4FF), size: 24),
                  tooltip: 'Back to Dashboard',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Servers & Gaming Nodes',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${serverProvider.servers.length} nodes loaded • Select a node to connect',
                    style: const TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              // Ping Test All Button
              ElevatedButton.icon(
                onPressed: () => serverProvider.testAllPings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF141A2C),
                  foregroundColor: const Color(0xFF00FF88),
                  side: const BorderSide(color: Color(0xFF00FF88), width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.bolt_rounded, size: 18),
                label: const Text('Test All Pings', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 10),
              // Fast Refresh Sub Button
              ElevatedButton.icon(
                onPressed: () {
                  if (serverProvider.subscriptionUrl != null && serverProvider.subscriptionUrl!.isNotEmpty) {
                    serverProvider.updateSubscription(serverProvider.subscriptionUrl!);
                  } else {
                    _showAddSubscriptionDialog(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4FF),
                  foregroundColor: const Color(0xFF090B10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(
                  Icons.sync_rounded,
                  size: 18,
                  color: serverProvider.isLoading ? const Color(0xFFFFB300) : const Color(0xFF090B10),
                ),
                label: Text(
                  serverProvider.isLoading ? 'Updating...' : 'Update Subscription',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              // Add Node Button
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF9D00FF), size: 28),
                tooltip: 'Add Single Config',
                onPressed: () => _showManualAddDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search Bar
          TextField(
            onChanged: (val) => serverProvider.setSearchQuery(val),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search by node name, server address, or protocol...',
              hintStyle: const TextStyle(color: Color(0xFF5A6678)),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6B7A94)),
              filled: true,
              fillColor: const Color(0xFF10131E),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF1E2438)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF1E2438)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF00D4FF)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (serverProvider.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3366).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF3366).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFFF3366), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      serverProvider.errorMessage!,
                      style: const TextStyle(color: Color(0xFFFF3366), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Server Grid / List
          Expanded(
            child: servers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 54, color: Color(0xFF38435E)),
                        const SizedBox(height: 14),
                        const Text(
                          'No servers loaded',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Import your Pasarguard subscription link or paste nodes to get started.',
                          style: TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddSubscriptionDialog(context),
                          icon: const Icon(Icons.add_link_rounded, size: 18),
                          label: const Text('Add Pasarguard / V2Ray Subscription'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00D4FF),
                            foregroundColor: const Color(0xFF090B10),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: servers.length,
                    itemBuilder: (context, index) {
                      final server = servers[index];
                      final isSelected = vpnProvider.selectedServer?.id == server.id;

                      return ServerTile(
                        server: server,
                        isSelected: isSelected,
                        onSelect: () {
                          vpnProvider.setSelectedServer(server);
                          if (vpnProvider.isConnected) {
                            vpnProvider.connect();
                          }
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                        },
                        onTestPing: () => serverProvider.testSinglePing(server),
                        onDelete: () => serverProvider.deleteServer(server.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
