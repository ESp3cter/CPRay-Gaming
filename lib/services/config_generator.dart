import 'dart:convert';
import '../models/app_settings.dart';
import '../models/server_config.dart';

class ConfigGenerator {
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
      'sniff': true,
      'sniff_override_destination': false,
    });

    // 2. Gaming TUN Mode (Wintun)
    if (settings.isGamingTunMode) {
      inbounds.add({
        'type': 'tun',
        'tag': 'tun-in',
        'interface_name': 'CPRay-Wintun',
        'inet4_address': '172.19.0.1/30',
        'auto_route': true,
        'strict_route': true,
        'stack': 'mixed',
        'sniff': true,
        'sniff_override_destination': false,
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

    // DNS Outbound
    outbounds.add({
      'type': 'dns',
      'tag': 'dns-out',
    });

    // 4. DNS Configuration for Low Gaming Latency (Sing-box 1.12+ modern format)
    final dns = {
      'servers': [
        {
          'tag': 'remote-dns',
          'type': 'udp',
          'server': settings.selectedDns,
          'server_port': 53,
          'detour': 'proxy',
        },
        {
          'tag': 'direct-dns',
          'type': 'local',
          'detour': 'direct',
        }
      ],
      'rules': [
        if (settings.bypassDomesticIps) ...[
          {
            'geoip': ['ir', 'private'],
            'server': 'direct-dns',
          },
          {
            'geosite': ['ir'],
            'server': 'direct-dns',
          }
        ],
      ],
      'final': 'remote-dns',
      'strategy': 'prefer_ipv4',
    };

    // 5. Routing Rules
    final List<Map<String, dynamic>> routeRules = [
      {
        'protocol': 'dns',
        'outbound': 'dns-out',
      },
      {
        'ip_is_private': true,
        'outbound': 'direct',
      },
    ];

    if (settings.bypassDomesticIps) {
      routeRules.add({
        'geoip': ['ir', 'private'],
        'outbound': 'direct',
      });
      routeRules.add({
        'geosite': ['ir'],
        'outbound': 'direct',
      });
    }

    // Route everything else through proxy
    routeRules.add({
      'outbound': 'proxy',
    });

    return {
      'log': {
        'level': 'info',
        'timestamp': true,
      },
      'dns': dns,
      'inbounds': inbounds,
      'outbounds': outbounds,
      'route': {
        'rules': routeRules,
        'auto_detect_interface': true,
      },
    };
  }

  static Map<String, dynamic> _buildProxyOutbound(ServerConfig server) {
    final protocol = server.protocol.toLowerCase();

    if (protocol == 'vless') {
      final map = <String, dynamic>{
        'type': 'vless',
        'tag': 'proxy',
        'server': server.server,
        'server_port': server.port,
        'uuid': server.uuid,
      };

      if (server.flow != null && server.flow!.isNotEmpty) {
        map['flow'] = server.flow;
      }

      if (server.security == 'reality') {
        map['tls'] = {
          'enabled': true,
          'server_name': server.sni,
          'reality': {
            'enabled': true,
            'public_key': server.pbk,
            'short_id': server.sid ?? '',
          },
          'utls': {
            'enabled': true,
            'fingerprint': server.fingerprint ?? 'chrome',
          }
        };
      } else if (server.security == 'tls') {
        map['tls'] = {
          'enabled': true,
          'server_name': server.sni,
          'utls': {
            'enabled': true,
            'fingerprint': server.fingerprint ?? 'chrome',
          }
        };
      }

      if (server.network == 'ws') {
        map['transport'] = {
          'type': 'ws',
          'path': server.path ?? '/',
          'headers': server.host != null ? {'Host': server.host!} : null,
        };
      } else if (server.network == 'grpc') {
        map['transport'] = {
          'type': 'grpc',
          'service_name': server.path ?? '',
        };
      }

      return map;
    } else if (protocol == 'hysteria2' || protocol == 'hy2') {
      return {
        'type': 'hysteria2',
        'tag': 'proxy',
        'server': server.server,
        'server_port': server.port,
        'password': server.uuid,
        'tls': {
          'enabled': true,
          'server_name': server.sni,
          'alpn': [server.alpn ?? 'h3'],
        }
      };
    } else if (protocol == 'trojan') {
      return {
        'type': 'trojan',
        'tag': 'proxy',
        'server': server.server,
        'server_port': server.port,
        'password': server.uuid,
        'tls': {
          'enabled': true,
          'server_name': server.sni,
        }
      };
    } else if (protocol == 'tuic') {
      return {
        'type': 'tuic',
        'tag': 'proxy',
        'server': server.server,
        'server_port': server.port,
        'uuid': server.uuid,
        'password': server.uuid,
        'congestion_controller': 'bbr',
        'tls': {
          'enabled': true,
          'server_name': server.sni,
          'alpn': [server.alpn ?? 'h3'],
        }
      };
    } else if (protocol == 'vmess') {
      return {
        'type': 'vmess',
        'tag': 'proxy',
        'server': server.server,
        'server_port': server.port,
        'uuid': server.uuid,
        'security': 'auto',
        'alter_id': 0,
        'tls': server.security == 'tls'
            ? {
                'enabled': true,
                'server_name': server.sni,
              }
            : null,
      };
    } else {
      // Shadowsocks fallback
      return {
        'type': 'shadowsocks',
        'tag': 'proxy',
        'server': server.server,
        'server_port': server.port,
        'method': 'chacha20-ietf-poly1305',
        'password': server.uuid ?? 'secret',
      };
    }
  }

  static String generateJsonString({
    required ServerConfig server,
    required AppSettings settings,
  }) {
    final map = generateSingboxConfig(server: server, settings: settings);
    return const JsonEncoder.withIndent('  ').convert(map);
  }
}
