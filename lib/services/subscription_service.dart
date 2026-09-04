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
    final trimmed = rawUri.trim();
    // In case the user pasted multiple lines or base64 into the single input box
    final list = parseContent(trimmed);
    if (list.isNotEmpty) return list.first;

    final id = 'manual_${DateTime.now().millisecondsSinceEpoch}';
    return parseUri(trimmed, id);
  }

  static String _safeBase64Decode(String input) {
    String str = input.replaceAll('\r', '').replaceAll('\n', '').trim();
    // Normalize URL-safe characters
    str = str.replaceAll('-', '+').replaceAll('_', '/');
    // Normalize padding
    final remainder = str.length % 4;
    if (remainder > 0) {
      str += '=' * (4 - remainder);
    }
    return utf8.decode(base64.decode(str));
  }

  static List<ServerConfig> parseContent(String content) {
    String decoded = content.trim();

    // 1. Try safe Base64 decode if entire body is base64 encoded
    try {
      if (!decoded.contains('://') || decoded.length > 50 && !decoded.contains('\n')) {
        decoded = _safeBase64Decode(decoded);
      }
    } catch (_) {
      // Content is already plain text lines
    }

    final lines = decoded.split(RegExp(r'[\r\n]+'));
    final List<ServerConfig> servers = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      // Check if this single line is base64 encoded without scheme
      if (!line.contains('://') && line.length > 20) {
        try {
          line = _safeBase64Decode(line);
        } catch (_) {}
      }

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
    final trimmed = rawUri.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;

    final scheme = uri.scheme.toLowerCase();
    final fragment = uri.fragment.isNotEmpty
        ? Uri.decodeComponent(uri.fragment).trim()
        : 'Server $defaultId';

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
        sni: q['sni'] ?? q['host'],
        pbk: q['pbk'],
        sid: q['sid'],
        spx: q['spx'],
        flow: q['flow'],
        network: q['type'] ?? 'tcp',
        path: q['path'],
        host: q['host'],
        alpn: q['alpn'],
        fingerprint: q['fp'],
        insecure: q['insecure'] == '1' || q['allowInsecure'] == '1',
        rawUri: trimmed,
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
        sni: q['sni'] ?? q['host'],
        network: q['type'] ?? 'tcp',
        path: q['path'],
        host: q['host'],
        alpn: q['alpn'],
        fingerprint: q['fp'],
        insecure: q['insecure'] == '1' || q['allowInsecure'] == '1',
        rawUri: trimmed,
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
        sni: q['sni'] ?? host,
        alpn: q['alpn'] ?? 'h3',
        obfs: q['obfs'],
        obfsPassword: q['obfs-password'] ?? q['obfs_password'],
        insecure: q['insecure'] == '1' || q['allowInsecure'] == '1',
        upMbps: int.tryParse(q['up'] ?? q['upmbps'] ?? ''),
        downMbps: int.tryParse(q['down'] ?? q['downmbps'] ?? ''),
        rawUri: trimmed,
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
        sni: q['sni'] ?? host,
        alpn: q['alpn'] ?? 'h3',
        insecure: q['insecure'] == '1' || q['allowInsecure'] == '1',
        rawUri: trimmed,
      );
    } else if (scheme == 'vmess') {
      final encoded = trimmed.substring('vmess://'.length).trim();
      try {
        final decodedJson = _safeBase64Decode(encoded);
        final map = jsonDecode(decodedJson) as Map<String, dynamic>;
        final ps = (map['ps'] as String? ?? 'VMess Server').trim();
        final add = (map['add'] as String? ?? '').trim();
        final port = int.tryParse(map['port']?.toString() ?? '443') ?? 443;
        final id = (map['id'] as String? ?? '').trim();
        final net = (map['net'] as String? ?? 'tcp').trim();
        final tls = (map['tls'] as String? ?? 'none').trim();
        final sni = (map['sni'] as String? ?? map['host'] as String?)?.trim();

        return ServerConfig(
          id: defaultId,
          name: ps.isNotEmpty ? ps : 'VMess $defaultId',
          protocol: 'vmess',
          server: add,
          port: port,
          uuid: id,
          security: tls,
          sni: sni,
          network: net,
          path: map['path'] as String?,
          host: map['host'] as String?,
          alpn: map['alpn'] as String?,
          fingerprint: map['fp'] as String?,
          rawUri: trimmed,
        );
      } catch (_) {}
    } else if (scheme == 'ss') {
      // Shadowsocks (SIP002 standard & legacy formats)
      // Format 1: ss://BASE64(method:password)@server:port#tag
      // Format 2: ss://BASE64(method:password@server:port)#tag
      // Format 3: ss://method:password@server:port#tag
      try {
        String mainPart = trimmed.substring('ss://'.length);
        String name = fragment;
        if (mainPart.contains('#')) {
          final hashIdx = mainPart.indexOf('#');
          name = Uri.decodeComponent(mainPart.substring(hashIdx + 1)).trim();
          mainPart = mainPart.substring(0, hashIdx);
        }

        String method = 'chacha20-ietf-poly1305';
        String password = '';
        String server = '';
        int port = 8388;

        if (mainPart.contains('@')) {
          // Format 1 or 3
          final atIdx = mainPart.indexOf('@');
          final userPart = mainPart.substring(0, atIdx);
          final hostPortPart = mainPart.substring(atIdx + 1);

          // Check if userPart is base64 encoded
          String decodedUser = userPart;
          try {
            decodedUser = _safeBase64Decode(userPart);
          } catch (_) {}

          if (decodedUser.contains(':')) {
            final colIdx = decodedUser.indexOf(':');
            method = decodedUser.substring(0, colIdx);
            password = decodedUser.substring(colIdx + 1);
          } else {
            password = decodedUser;
          }

          final hpClean = hostPortPart.split('?').first;
          final lastCol = hpClean.lastIndexOf(':');
          if (lastCol != -1) {
            server = hpClean.substring(0, lastCol);
            port = int.tryParse(hpClean.substring(lastCol + 1)) ?? 8388;
          } else {
            server = hpClean;
          }
        } else {
          // Format 2: entire mainPart is base64 encoded
          try {
            final decodedAll = _safeBase64Decode(mainPart);
            final atIdx = decodedAll.indexOf('@');
            if (atIdx != -1) {
              final userPart = decodedAll.substring(0, atIdx);
              final hpPart = decodedAll.substring(atIdx + 1).split('?').first;

              if (userPart.contains(':')) {
                final colIdx = userPart.indexOf(':');
                method = userPart.substring(0, colIdx);
                password = userPart.substring(colIdx + 1);
              }

              final lastCol = hpPart.lastIndexOf(':');
              if (lastCol != -1) {
                server = hpPart.substring(0, lastCol);
                port = int.tryParse(hpPart.substring(lastCol + 1)) ?? 8388;
              } else {
                server = hpPart;
              }
            }
          } catch (_) {}
        }

        if (server.isNotEmpty) {
          return ServerConfig(
            id: defaultId,
            name: name.isNotEmpty ? name : 'Shadowsocks $defaultId',
            protocol: 'shadowsocks',
            server: server,
            port: port,
            uuid: password,
            method: method,
            rawUri: trimmed,
          );
        }
      } catch (_) {}
    } else if (scheme == 'wireguard' || scheme == 'wg') {
      final host = uri.host;
      final port = uri.port > 0 ? uri.port : 51820;
      final q = uri.queryParameters;

      return ServerConfig(
        id: defaultId,
        name: fragment,
        protocol: 'wireguard',
        server: host,
        port: port,
        privateKey: uri.userInfo.isNotEmpty ? uri.userInfo : q['private_key'],
        peerPublicKey: q['public_key'] ?? q['peer_public_key'],
        localAddress: q['address'] ?? q['ip'] ?? '10.0.0.2/32',
        presharedKey: q['preshared_key'] ?? q['psk'],
        rawUri: trimmed,
      );
    }

    return null;
  }
}
