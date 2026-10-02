import 'dart:async';
import 'dart:io';
import '../models/server_config.dart';

class PingService {
  static Future<int> testTcpPing(String host, int port, {Duration timeout = const Duration(milliseconds: 2500)}) async {
    final stopwatch = Stopwatch()..start();
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      stopwatch.stop();
      socket.destroy(); // Use destroy() instead of close() to avoid TIME_WAIT
      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      return -1; // Timed out or unreachable
    }
  }

  /// For UDP protocols (Hysteria2, TUIC, WireGuard), fall back to ICMP-style ping
  /// via raw process since Dart doesn't support raw UDP probes easily
  static Future<int> testIcmpPing(String host, {Duration timeout = const Duration(milliseconds: 2500)}) async {
    try {
      final result = await Process.run(
        'ping',
        Platform.isWindows
            ? ['-n', '1', '-w', '${timeout.inMilliseconds}', host]
            : ['-c', '1', '-W', '${timeout.inSeconds > 0 ? timeout.inSeconds : 1}', host],
      ).timeout(timeout + const Duration(seconds: 1));

      if (result.exitCode == 0) {
        final output = result.stdout as String;
        // Extract ping time from output
        final regex = RegExp(r'time[=<]\s*(\d+\.?\d*)\s*ms', caseSensitive: false);
        final match = regex.firstMatch(output);
        if (match != null) {
          return double.parse(match.group(1)!).round();
        }
        return 1; // Ping succeeded but couldn't parse time
      }
      return -1;
    } catch (_) {
      return -1;
    }
  }

  /// Protocol-aware ping: uses TCP for TCP protocols, ICMP for UDP protocols
  static Future<int> testServerPingSmart(ServerConfig server) async {
    final protocol = server.protocol.toLowerCase();
    final isUdpOnly = protocol == 'hysteria2' || protocol == 'hy2' || 
                      protocol == 'tuic' || protocol == 'wireguard';
    
    if (isUdpOnly) {
      // Try ICMP ping for UDP-only protocols, with TCP fallback if ICMP is blocked
      final icmp = await testIcmpPing(server.server);
      if (icmp > 0) return icmp;
      return testTcpPing(server.server, server.port);
    } else {
      // Use TCP connect for TCP-based protocols
      return testTcpPing(server.server, server.port);
    }
  }

  static Future<void> testServerPing(ServerConfig server) async {
    server.isTestingPing = true;
    final ping = await testServerPingSmart(server);
    server.ping = ping;
    server.isTestingPing = false;
  }

  static Future<void> testAllServers(List<ServerConfig> servers, {Function()? onProgress}) async {
    for (final server in servers) {
      server.isTestingPing = true;
      if (onProgress != null) onProgress();
    }

    // Run batch pings concurrently in chunks of 10 (increased from 5)
    const chunkSize = 10;
    for (var i = 0; i < servers.length; i += chunkSize) {
      final end = (i + chunkSize < servers.length) ? i + chunkSize : servers.length;
      final chunk = servers.sublist(i, end);

      await Future.wait(chunk.map((s) async {
        final ping = await testServerPingSmart(s);
        s.ping = ping;
        s.isTestingPing = false;
        if (onProgress != null) onProgress();
      }));
    }
  }
}
