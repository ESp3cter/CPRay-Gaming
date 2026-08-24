import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/server_config.dart';

class SubscriptionService {
  static Future<List<ServerConfig>> fetchSubscription(String url) async {
    final response = await http.get(
      Uri.parse(url.trim()),
      headers: {
        'User-Agent': 'CPRay-Gaming/1.0.0 (Windows; Sing-box)',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch configs: HTTP ${response.statusCode}');
    }

    final body = response.body.trim();
    return parseContent(body);
  }

  static ServerConfig? parseSingleConfig(String rawUri) {
    final id = 'manual_${DateTime.now().millisecondsSinceEpoch}';
    return parseUri(rawUri.trim(), id);
  }

  static List<ServerConfig> parseContent(String content) {
    String decoded = content;

    // Try Base64 decode if entire body is base64
    try {
      final normalized = base64.normalize(content.replaceAll('\n', '').replaceAll('\r', '').trim());
      decoded = utf8.decode(base64.decode(normalized));
    } catch (_) {
      // Content might already be plain text lines
    }

    final lines = decoded.split(RegExp(r'[\r\n]+'));
    final List<ServerConfig> servers = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      try {
        final server = parseUri(line, 'node_${i + 1}');
        if (server != null) {
          servers.add(server);
        }
      } catch (_) {}
    }

    return servers;
  }

  static ServerConfig? parseUri(String rawUri, String defaultId) {
    final uri = Uri.tryParse(rawUri);
    if (uri == null) return null;

    final scheme = uri.scheme.toLowerCase();
    final fragment = uri.fragment.isNotEmpty ? Uri.decodeComponent(uri.fragment) : 'Server $defaultId';

    if (scheme == 'vless') {
      final userInfo = uri.userInfo;
      final host = uri.host;
      final port = uri.port > 0 ? uri.port : 443;
      final q = uri.queryParameters;

      return ServerConfig(
        id: defaultId,
        name: fragment,
        protocol: 'vless',
        server: host,
        port: port,
        uuid: userInfo,
        security: q['security'] ?? 'none',
        sni: q['sni'],
        pbk: q['pbk'],
        sid: q['sid'],
        spx: q['spx'],
        flow: q['flow'],
        network: q['type'] ?? 'tcp',
        path: q['path'],
        host: q['host'],
        alpn: q['alpn'],
        fingerprint: q['fp'],
        rawUri: rawUri,
      );
    } else if (scheme == 'trojan') {
      final password = uri.userInfo;
      final host = uri.host;
      final port = uri.port > 0 ? uri.port : 443;
      final q = uri.queryParameters;

      return ServerConfig(
        id: defaultId,
        name: fragment,
        protocol: 'trojan',
        server: host,
        port: port,
        uuid: password,
        security: q['security'] ?? 'tls',
        sni: q['sni'],
        network: q['type'] ?? 'tcp',
        path: q['path'],
        host: q['host'],
        alpn: q['alpn'],
        fingerprint: q['fp'],
        rawUri: rawUri,
      );
    } else if (scheme == 'hysteria2' || scheme == 'hy2') {
      final password = uri.userInfo;
      final host = uri.host;
      final port = uri.port > 0 ? uri.port : 443;
      final q = uri.queryParameters;

      return ServerConfig(
        id: defaultId,
        name: fragment,
        protocol: 'hysteria2',
        server: host,
        port: port,
        uuid: password,
        security: 'tls',
        sni: q['sni'],
        alpn: q['alpn'] ?? 'h3',
        rawUri: rawUri,
      );
    } else if (scheme == 'tuic') {
      final parts = uri.userInfo.split(':');
      final uuid = parts.isNotEmpty ? parts[0] : '';
      final password = parts.length > 1 ? parts[1] : '';
      final host = uri.host;
      final port = uri.port > 0 ? uri.port : 443;
      final q = uri.queryParameters;

      return ServerConfig(
        id: defaultId,
        name: fragment,
        protocol: 'tuic',
        server: host,
        port: port,
        uuid: uuid.isNotEmpty ? uuid : password,
        security: 'tls',
        sni: q['sni'],
        alpn: q['alpn'] ?? 'h3',
        rawUri: rawUri,
      );
    } else if (scheme == 'vmess') {
      final encoded = rawUri.substring('vmess://'.length).trim();
      try {
        final decodedJson = utf8.decode(base64.decode(base64.normalize(encoded)));
        final map = jsonDecode(decodedJson) as Map<String, dynamic>;
        final ps = map['ps'] as String? ?? 'VMess Server';
        final add = map['add'] as String? ?? '';
        final port = int.tryParse(map['port']?.toString() ?? '443') ?? 443;
        final id = map['id'] as String? ?? '';
        final net = map['net'] as String? ?? 'tcp';
        final tls = map['tls'] as String? ?? 'none';
        final sni = map['sni'] as String? ?? map['host'] as String?;

        return ServerConfig(
          id: defaultId,
          name: ps,
          protocol: 'vmess',
          server: add,
          port: port,
          uuid: id,
          security: tls,
          sni: sni,
          network: net,
          path: map['path'] as String?,
          host: map['host'] as String?,
          rawUri: rawUri,
        );
      } catch (_) {}
    } else if (scheme == 'ss') {
      // Shadowsocks
      final host = uri.host;
      final port = uri.port > 0 ? uri.port : 8388;
      return ServerConfig(
        id: defaultId,
        name: fragment,
        protocol: 'shadowsocks',
        server: host,
        port: port,
        uuid: uri.userInfo,
        rawUri: rawUri,
      );
    }

    return null;
  }
}
