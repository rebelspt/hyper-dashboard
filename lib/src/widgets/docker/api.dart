import 'dart:convert' show jsonDecode, utf8;
import 'dart:io' as io;
import 'dart:typed_data' show BytesBuilder, Uint8List;

import '../../services/services.dart';
import 'models.dart';

class DockerClient {
  final bool _isUnix;
  final String _socketPath;
  final String _tcpBase;
  final Services _services;

  DockerClient(String url, this._services)
      : _isUnix = url.startsWith('unix://'),
        _socketPath =
            url.startsWith('unix://') ? url.replaceFirst('unix://', '') : '',
        _tcpBase = url.startsWith('unix://') ? '' : url;

  Future<List<DockerContainer>> listContainers(bool all) async {
    final q = all ? {'all': '1'} : <String, String>{};
    final body = await _get('/containers/json', q);
    final list = (jsonDecode(body) as List).cast<Map<String, dynamic>>();
    return list.map(DockerContainer.fromJson).toList();
  }

  Future<Map<String, dynamic>> inspectContainer(String id) async {
    final body = await _get('/containers/$id/json', {});
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<List<String>> fetchLogs(String id, int lines) async {
    final bytes = await _getBytes(
      '/containers/$id/logs',
      {'stdout': '1', 'stderr': '1', 'tail': '$lines'},
    );
    return _parseDockerLogs(bytes);
  }

  Future<void> performAction(String id, String action) async {
    final path = switch (action) {
      'start' => '/containers/$id/start',
      'stop' => '/containers/$id/stop',
      'restart' => '/containers/$id/restart',
      _ => throw ArgumentError('Unknown action: $action'),
    };
    await _post(path);
  }

  // ── HTTP helpers ────────────────────────────────────────────────────────────

  Future<String> _get(String path, Map<String, String> query) async {
    if (_isUnix) return _unixGet(path, query);
    final uri = Uri.parse(_tcpBase + path)
        .replace(queryParameters: query.isEmpty ? null : query);
    final resp = await _services.httpClient.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Docker $path → ${resp.statusCode}');
    }
    return resp.body;
  }

  Future<Uint8List> _getBytes(String path, Map<String, String> query) async {
    if (_isUnix) return _unixGetBytes(path, query);
    final uri = Uri.parse(_tcpBase + path)
        .replace(queryParameters: query.isEmpty ? null : query);
    final resp = await _services.httpClient.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Docker $path → ${resp.statusCode}');
    }
    return resp.bodyBytes;
  }

  Future<void> _post(String path) async {
    if (_isUnix) return _unixPost(path);
    final uri = Uri.parse(_tcpBase + path);
    final resp = await _services.httpClient.post(uri, body: '');
    if (resp.statusCode >= 400) {
      throw Exception('Docker $path → ${resp.statusCode}');
    }
  }

  // ── Unix socket transport ────────────────────────────────────────────────────

  io.HttpClient _unixClient() {
    final c = io.HttpClient();
    final socketPath = _socketPath;
    c.connectionFactory = (uri, _, __) async {
      final s = await io.Socket.connect(
        io.InternetAddress(socketPath, type: io.InternetAddressType.unix),
        0,
      );
      return io.ConnectionTask.fromSocket(Future.value(s), s.destroy);
    };
    return c;
  }

  Future<String> _unixGet(String path, Map<String, String> query) async {
    final c = _unixClient();
    try {
      final uri = Uri.http('localhost', path, query.isEmpty ? null : query);
      final req = await c.getUrl(uri);
      final resp = await req.close();
      if (resp.statusCode != 200) {
        throw Exception('Docker $path → ${resp.statusCode}');
      }
      return await utf8.decodeStream(resp);
    } finally {
      c.close(force: true);
    }
  }

  Future<Uint8List> _unixGetBytes(
    String path,
    Map<String, String> query,
  ) async {
    final c = _unixClient();
    try {
      final uri = Uri.http('localhost', path, query.isEmpty ? null : query);
      final req = await c.getUrl(uri);
      final resp = await req.close();
      if (resp.statusCode != 200) {
        throw Exception('Docker $path → ${resp.statusCode}');
      }
      final builder = BytesBuilder();
      await for (final chunk in resp) {
        builder.add(chunk);
      }
      return builder.takeBytes();
    } finally {
      c.close(force: true);
    }
  }

  Future<void> _unixPost(String path) async {
    final c = _unixClient();
    try {
      final uri = Uri.http('localhost', path);
      final req = await c.postUrl(uri);
      req.headers.set('Content-Length', '0');
      final resp = await req.close();
      await resp.drain<void>();
      if (resp.statusCode >= 400) {
        throw Exception('Docker $path → ${resp.statusCode}');
      }
    } finally {
      c.close(force: true);
    }
  }

  // ── Docker multiplexed log format parser ─────────────────────────────────────

  static List<String> _parseDockerLogs(Uint8List bytes) {
    if (bytes.isEmpty) return [];

    // Detect multiplexed format: stream byte (1 or 2) then 3 zero padding bytes.
    // TTY containers emit raw bytes with no frame headers.
    final isMultiplexed = bytes.length >= 8 &&
        (bytes[0] == 1 || bytes[0] == 2) &&
        bytes[1] == 0 &&
        bytes[2] == 0 &&
        bytes[3] == 0;

    if (!isMultiplexed) {
      return utf8
          .decode(bytes, allowMalformed: true)
          .split('\n')
          .where((l) => l.isNotEmpty)
          .toList();
    }

    final buf = StringBuffer();
    var i = 0;
    while (i + 8 <= bytes.length) {
      // bytes [i+4..i+7] are big-endian uint32 payload size
      final size = (bytes[i + 4] << 24) |
          (bytes[i + 5] << 16) |
          (bytes[i + 6] << 8) |
          bytes[i + 7];
      i += 8;
      if (i + size > bytes.length) break;
      buf.write(utf8.decode(bytes.sublist(i, i + size), allowMalformed: true));
      i += size;
    }

    return buf.toString().split('\n').where((l) => l.isNotEmpty).toList();
  }
}
