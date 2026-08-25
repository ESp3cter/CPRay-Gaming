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

    // 2. Gaming TUN Mode (Wintun)
    if (settings.vpnMode == VpnMode.tun || settings.vpnMode == VpnMode.antiSanctionOnly) {
      inbounds.add({
        'type': 'tun',
        'tag': 'tun-in',
        'interface_name': 'CPRay-Wintun',
        'address': [
          '172.19.0.1/30',
        ],
        'auto_route': true,
        'strict_route': true,
        'stack': 'mixed',
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

    // 4. DNS Configuration
    String primaryDns = settings.isAutoDns ? settings.selectedDns : settings.customDns;
    if (settings.antiSanctionMode) {
      primaryDns = antiSanctionDnsMap[settings.antiSanctionProvider] ?? '10.202.10.10';
    }

    final dns = {
      'servers': [
        {
          'tag': 'remote-dns',
          'address': primaryDns,
          'detour': settings.antiSanctionMode ? 'direct' : 'proxy',
        },
        {
          'tag': 'direct-dns',
          'address': '8.8.8.8',
          'detour': 'direct',
        },
        {
          'tag': 'local-dns',
          'address': 'local',
        }
      ],
      'rules': [
        if (settings.bypassIranianTraffic) ...[
          {
            'domain_suffix': _iranianDomainSuffixes,
            'server': 'direct-dns',
          }
        ],
      ],
      'final': 'remote-dns',
      'strategy': 'prefer_ipv4',
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
      'dns': dns,
      'inbounds': inbounds,
      'outbounds': outbounds,
      'route': {
        'default_domain_resolver': {
          'server': 'direct-dns',
          'strategy': 'prefer_ipv4',
        },
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
        'domain_resolver': domainResolver,
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
        'domain_resolver': domainResolver,
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
        'domain_resolver': domainResolver,
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
        'domain_resolver': domainResolver,
        'tls': server.security == 'tls'
            ? {
                'enabled': true,
                'server_name': server.sni,
              }
            : null,
      };
    } else {
      return {
        'type': 'shadowsocks',
        'tag': 'proxy',
        'server': server.server,
        'server_port': server.port,
        'method': 'chacha20-ietf-poly1305',
        'password': server.uuid ?? 'secret',
        'domain_resolver': domainResolver,
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
