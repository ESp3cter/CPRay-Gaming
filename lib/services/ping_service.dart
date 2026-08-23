import 'dart:async';
import 'dart:io';
import '../models/server_config.dart';

class PingService {
  static Future<int> testTcpPing(String host, int port, {Duration timeout = const Duration(milliseconds: 2500)}) async {
    final stopwatch = Stopwatch()..start();
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      stopwatch.stop();
      await socket.close();
      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      return -1; // Timed out or unreachable
    }
  }

  static Future<void> testServerPing(ServerConfig server) async {
    server.isTestingPing = true;
    final ping = await testTcpPing(server.server, server.port);
    server.ping = ping;
    server.isTestingPing = false;
  }

  static Future<void> testAllServers(List<ServerConfig> servers, {Function()? onProgress}) async {
    for (final server in servers) {
      server.isTestingPing = true;
      if (onProgress != null) onProgress();
    }

    // Run batch pings concurrently in chunks of 5
    const chunkSize = 5;
    for (var i = 0; i < servers.length; i += chunkSize) {
      final end = (i + chunkSize < servers.length) ? i + chunkSize : servers.length;
      final chunk = servers.sublist(i, end);

      await Future.wait(chunk.map((s) async {
        final ping = await testTcpPing(s.server, s.port);
        s.ping = ping;
        s.isTestingPing = false;
        if (onProgress != null) onProgress();
      }));
    }
  }
}
