import 'dart:convert';
import '../models/app_settings.dart';
import '../models/server_config.dart';

class ConfigGenerator {
  static const List<String> _iranianDomainSuffixes = [
    '.ir',
    '.xn--mgba3a4f16a',
    'digikala.com',
    'divar.ir',
    'snapp.ir',
    'torob.com',
    'varzesh3.com',
    'aparat.com',
    'telewebion.com',
    'shaparak.ir',
    'tamin.ir',
    'bale.ai',
    'rubika.ir',
    'eitaa.com',
    'splus.ir',
    'arvancloud.ir',
    'cafebazaar.ir',
    'myket.ir',
    'bmi.ir',
    'bankmellat.ir',
    'bki.ir',
    'rb24.ir',
    'tejaratbank.ir',
  ];

  static final Map<String, String> antiSanctionDnsMap = {
    'radar': '10.202.10.10',
    'electro': '78.157.42.101',
    'shecan': '178.22.122.100',
    'dns4s': '4.2.2.4',
  };

  static Map<String, dynamic> generateSingboxConfig({
    required ServerConfig server,
    required AppSettings settings,
  }) {
    final List<Map<String, dynamic>> inbounds = [];

    // 1. Mixed inbound (SOCKS5 & HTTP)
    inbounds.add({
      'type': 'mixed',
      'tag': 'mixed-in',
      'listen': '127.0.0.1',
      'listen_port': settings.socksPort,
    });

    // 2. High-Performance Gaming TUN (Wintun)
    if (settings.vpnMode == VpnMode.tun || settings.vpnMode == VpnMode.antiSanctionOnly) {
      inbounds.add({
        'type': 'tun',
        'tag': 'tun-in',
        'interface_name': 'CPRay-Wintun',
        'address': [
          '172.19.0.1/30',
        ],
        'mtu': 1400, // Optimal MTU prevents packet fragmentation for max throughput
        'auto_route': true,
        'strict_route': true,
        'stack': 'system', // High speed native OS stack
        'endpoint_independent_nat': true, // Full-Cone NAT for multiplayer games and voice chat
        'udp_timeout': '5m', // Keep matchmaking UDP sessions and game lobbies open
      });
    }

    // 3. Outbounds
    final List<Map<String, dynamic>> outbounds = [];

    // Main Proxy Outbound
    final proxyOutbound = _buildProxyOutbound(server);
    outbounds.add(proxyOutbound);

    // Direct Outbound
    outbounds.add({
      'type': 'direct',
      'tag': 'direct',
    });

    // Block Outbound
    outbounds.add({
      'type': 'block',
      'tag': 'block',
    });

    // 4. Ultra-Fast DNS Configuration (Sing-box 1.14+ Typed DNS + 8K Cache)
    String primaryDns = settings.isAutoDns ? settings.selectedDns : settings.customDns;
    if (settings.antiSanctionMode) {
      primaryDns = antiSanctionDnsMap[settings.antiSanctionProvider] ?? '10.202.10.10';
    }

    final dns = {
      'servers': [
        _buildDnsServer(
          tag: 'remote-doh',
          rawAddress: 'https://1.1.1.1/dns-query',
          detour: 'proxy',
        ),
        _buildDnsServer(
          tag: 'remote-dns',
          rawAddress: primaryDns,
          detour: settings.antiSanctionMode ? 'direct' : 'proxy',
        ),
        _buildDnsServer(
          tag: 'direct-dns',
          rawAddress: '1.1.1.1:53',
        ),
        _buildDnsServer(
          tag: 'direct-dns-backup',
          rawAddress: '8.8.8.8:53',
        ),
        _buildDnsServer(
          tag: 'local-dns',
          rawAddress: 'local',
        ),
      ],
      'rules': [
        if (settings.bypassIranianTraffic) ...[
          {
            'domain_suffix': _iranianDomainSuffixes,
            'server': 'direct-dns',
          }
        ],
      ],
      'final': settings.antiSanctionMode ? 'remote-dns' : 'remote-doh',
      'strategy': 'prefer_ipv4',
      'cache_capacity': 8192, // 8K DNS cache for 0ms repeated lookups
      'reverse_mapping': true,
    };

    // 5. Routing Rules (Sing-box 1.13+ rule-action format)
    final List<Map<String, dynamic>> routeRules = [
      {
        'action': 'sniff',
      },
      {
        'protocol': 'dns',
        'action': 'hijack-dns',
      },
      {
        'ip_is_private': true,
        'outbound': 'direct',
      },
    ];

    // Iranian Domestic Bypass
    if (settings.bypassIranianTraffic) {
      routeRules.add({
        'domain_suffix': _iranianDomainSuffixes,
        'outbound': 'direct',
      });
    }

    // Split Tunneling Rules
    if (settings.splitTunnelMode == SplitTunnelMode.inclusive && settings.splitTunnelApps.isNotEmpty) {
      routeRules.add({
        'process_name': settings.splitTunnelApps,
        'outbound': 'proxy',
      });
    } else if (settings.splitTunnelMode == SplitTunnelMode.exclusive && settings.splitTunnelApps.isNotEmpty) {
      routeRules.add({
        'process_name': settings.splitTunnelApps,
        'outbound': 'direct',
      });
    }

    final String finalOutbound = (settings.splitTunnelMode == SplitTunnelMode.inclusive && settings.splitTunnelApps.isNotEmpty)
        ? 'direct'
        : (settings.vpnMode == VpnMode.antiSanctionOnly ? 'direct' : 'proxy');

    return {
      'log': {
        'level': 'info',
        'timestamp': true,
      },
      'experimental': {
        'clash_api': {
          'external_controller': '127.0.0.1:9090',
          'secret': '',
          'default_mode': 'rule',
        },
      },
      'dns': dns,
      'inbounds': inbounds,
      'outbounds': outbounds,
      'route': {
        'default_domain_resolver': {
          'server': 'direct-dns',
          'strategy': 'prefer_ipv4',
        },
        'find_process': true, // CRITICAL FIX: Enables Windows process name matching for Split Tunneling & Game Optimizer
        'rules': routeRules,
        'final': finalOutbound,
        'auto_detect_interface': true,
      },
    };
  }

  static Map<String, dynamic> _buildProxyOutbound(ServerConfig server) {
    final protocol = server.protocol.toLowerCase();
    final domainResolver = {
      'server': 'direct-dns',
      'strategy': 'prefer_ipv4',
    };

    if (protocol == 'vless') {
      final map = <String, dynamic>{
        'type': 'vless',
        'tag': 'proxy',
        'server': server.server,
        'server_port': server.port,
        'uuid': server.uuid,
        'domain_resolver': domainResolver,
        'tcp_fast_open': true,
        'packet_encoding': 'xudp', // High-performance UDP gaming with 0 packet loss
      };

      // Flow (xtls-rprx-vision) is ONLY valid on direct/tcp transport
      final isTcp = server.network == null || server.network!.isEmpty || server.network == 'tcp';
      if (isTcp && server.flow != null && server.flow!.isNotEmpty) {
        map['flow'] = server.flow;
      }

      // TLS / Reality
      if (server.security == 'reality') {
        map['tls'] = {
          'enabled': true,
          'server_name': (server.sni != null && server.sni!.isNotEmpty) ? server.sni : (server.host ?? server.server),
          'reality': {
            'enabled': true,
            'public_key': server.pbk ?? '',
            'short_id': server.sid ?? '',
          },
          'utls': {
            'enabled': true,
            'fingerprint': (server.fingerprint != null && server.fingerprint!.isNotEmpty) ? server.fingerprint! : 'chrome',
          },
          if (server.alpn != null && server.alpn!.isNotEmpty)
            'alpn': server.alpn!.split(','),
        };
      } else if (server.security == 'tls') {
        map['tls'] = {
          'enabled': true,
          'server_name': (server.sni != null && server.sni!.isNotEmpty) ? server.sni : (server.host ?? server.server),
          'insecure': server.insecure ?? false,
          'utls': {
            'enabled': true,
            'fingerprint': (server.fingerprint != null && server.fingerprint!.isNotEmpty) ? server.fingerprint! : 'chrome',
          },
          if (server.alpn != null && server.alpn!.isNotEmpty)
            'alpn': server.alpn!.split(','),
        };
      }

      // Transports (WS / gRPC / HTTPUpgrade)
      _applyTransport(map, server);

      return map;
    } else if (protocol == 'vmess') {
      final map = <String, dynamic>{
        'type': 'vmess',
        'tag': 'proxy',
        'server': server.server,
        'server_port': server.port,
        'uuid': server.uuid,
        'security': 'auto',
        'alter_id': 0,
        'domain_resolver': domainResolver,
        'tcp_fast_open': true,
        'packet_encoding': 'xudp', // High-performance UDP gaming
      };

      if (server.security == 'tls') {
        map['tls'] = {
          'enabled': true,
          'server_name': (server.sni != null && server.sni!.isNotEmpty) ? server.sni : (server.host ?? server.server),
          'insecure': server.insecure ?? false,
          'utls': {
            'enabled': true,
            'fingerprint': (server.fingerprint != null && server.fingerprint!.isNotEmpty) ? server.fingerprint! : 'chrome',
          },
          if (server.alpn != null && server.alpn!.isNotEmpty)
            'alpn': server.alpn!.split(','),
        };
      }

      // Transports (Fixes VMess WebSocket / gRPC / HTTPUpgrade)
      _applyTransport(map, server);

      return map;
    } else if (protocol == 'trojan') {
      final map = <String, dynamic>{
        'type': 'trojan',
        'tag': 'proxy',
        'server': server.server,
        'server_port': server.port,
        'password': server.uuid,
        'domain_resolver': domainResolver,
        'tcp_fast_open': true,
        'packet_encoding': 'xudp',
        'tls': {
          'enabled': true,
          'server_name': (server.sni != null && server.sni!.isNotEmpty) ? server.sni : (server.host ?? server.server),
          'insecure': server.insecure ?? false,
          'utls': {
            'enabled': true,
            'fingerprint': (server.fingerprint != null && server.fingerprint!.isNotEmpty) ? server.fingerprint! : 'chrome',
          },
          if (server.alpn != null && server.alpn!.isNotEmpty)
            'alpn': server.alpn!.split(','),
        },
      };

      _applyTransport(map, server);

      return map;
    } else if (protocol == 'hysteria2' || protocol == 'hy2') {
      final map = <String, dynamic>{
        'type': 'hysteria2',
        'tag': 'proxy',
        'server': server.server,
        'server_port': server.port,
        'password': server.uuid,
        'domain_resolver': domainResolver,
        'tcp_fast_open': true,
        'tls': {
          'enabled': true,
          'server_name': (server.sni != null && server.sni!.isNotEmpty) ? server.sni : server.server,
          'insecure': server.insecure ?? false,
          'alpn': [server.alpn ?? 'h3'],
        },
      };

      if (server.obfs != null && server.obfs!.isNotEmpty) {
        map['obfs'] = {
          'type': server.obfs,
          'password': server.obfsPassword ?? '',
        };
      }

      if (server.upMbps != null && server.upMbps! > 0) {
        map['up_mbps'] = server.upMbps;
      }
      if (server.downMbps != null && server.downMbps! > 0) {
        map['down_mbps'] = server.downMbps;
      }

      return map;
    } else if (protocol == 'tuic') {
      return {
        'type': 'tuic',
        'tag': 'proxy',
        'server': server.server,
        'server_port': server.port,
        'uuid': server.uuid,
        'password': server.uuid,
        'congestion_controller': 'bbr',
        'udp_relay_mode': 'native',
        'zero_rtt_handshake': true,
        'domain_resolver': domainResolver,
        'tcp_fast_open': true,
        'tls': {
          'enabled': true,
          'server_name': (server.sni != null && server.sni!.isNotEmpty) ? server.sni : server.server,
          'insecure': server.insecure ?? false,
          'alpn': [server.alpn ?? 'h3'],
        },
      };
    } else if (protocol == 'wireguard') {
      return {
        'type': 'wireguard',
        'tag': 'proxy',
        'server': server.server,
        'server_port': server.port,
        'system_interface': false,
        'interface_name': 'cpray-wg',
        'local_address': [server.localAddress ?? '10.0.0.2/32'],
        'private_key': server.privateKey ?? '',
        'peer_public_key': server.peerPublicKey ?? '',
        if (server.presharedKey != null && server.presharedKey!.isNotEmpty)
          'pre_shared_key': server.presharedKey,
        'mtu': 1400,
        'domain_resolver': domainResolver,
      };
    } else {
      // Shadowsocks
      final method = server.method != null && server.method!.isNotEmpty
          ? server.method!
          : 'chacha20-ietf-poly1305';
      return {
        'type': 'shadowsocks',
        'tag': 'proxy',
        'server': server.server,
        'server_port': server.port,
        'method': method,
        'password': server.uuid ?? 'secret',
        'domain_resolver': domainResolver,
        'tcp_fast_open': true,
        'packet_encoding': 'xudp',
        'udp_over_tcp': true, // Fallback if direct UDP packets are throttled
      };
    }
  }

  static void _applyTransport(Map<String, dynamic> map, ServerConfig server) {
    final net = (server.network ?? '').toLowerCase();
    if (net == 'ws') {
      map['transport'] = {
        'type': 'ws',
        'path': (server.path != null && server.path!.isNotEmpty) ? server.path! : '/',
        if (server.host != null && server.host!.isNotEmpty)
          'headers': {'Host': server.host!},
      };
    } else if (net == 'grpc') {
      map['transport'] = {
        'type': 'grpc',
        'service_name': server.path ?? '',
      };
    } else if (net == 'httpupgrade') {
      map['transport'] = {
        'type': 'httpupgrade',
        if (server.host != null && server.host!.isNotEmpty)
          'host': server.host,
        'path': (server.path != null && server.path!.isNotEmpty) ? server.path! : '/',
      };
    }
  }

  static Map<String, dynamic> _buildDnsServer({
    required String tag,
    required String rawAddress,
    String? detour,
  }) {
    final clean = rawAddress.trim();
    if (clean == 'local') {
      return {
        'tag': tag,
        'type': 'local',
        if (detour != null) 'detour': detour,
      };
    }

    if (clean.startsWith('https://') || clean.startsWith('http://')) {
      final uri = Uri.parse(clean);
      return {
        'tag': tag,
        'type': 'https',
        'server': uri.host,
        'server_port': uri.port > 0 ? uri.port : 443,
        'path': uri.path.isNotEmpty ? uri.path : '/dns-query',
        if (detour != null) 'detour': detour,
      };
    }

    if (clean.startsWith('tls://')) {
      final uri = Uri.parse(clean);
      return {
        'tag': tag,
        'type': 'tls',
        'server': uri.host,
        'server_port': uri.port > 0 ? uri.port : 853,
        if (detour != null) 'detour': detour,
      };
    }

    // Default UDP / Plain DNS
    String host = clean;
    int port = 53;
    if (host.startsWith('udp://')) {
      host = host.substring('udp://'.length);
    }
    if (host.contains(':')) {
      final parts = host.split(':');
      host = parts[0];
      port = int.tryParse(parts[1]) ?? 53;
    }

    return {
      'tag': tag,
      'type': 'udp',
      'server': host,
      'server_port': port,
      if (detour != null) 'detour': detour,
    };
  }

  static String generateJsonString({
    required ServerConfig server,
    required AppSettings settings,
  }) {
    final map = generateSingboxConfig(server: server, settings: settings);
    return const JsonEncoder.withIndent('  ').convert(map);
  }
}
