import 'package:http/http.dart' as http;

class Services {
  final http.Client httpClient;

  Services({http.Client? httpClient})
      : httpClient = _UserAgentClient(httpClient ?? http.Client());

  void dispose() => httpClient.close();
}

class _UserAgentClient extends http.BaseClient {
  static const _defaultUserAgent = 'hyper-dashboard/1.0';

  final http.Client _inner;

  _UserAgentClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.putIfAbsent('User-Agent', () => _defaultUserAgent);
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
