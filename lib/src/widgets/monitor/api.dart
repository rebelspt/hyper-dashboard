import '../../services/services.dart';
import 'models.dart';

Future<SiteResult> checkSite(
  Services services, {
  required String title,
  required String url,
  String? icon,
}) async {
  if (url.isEmpty) {
    return SiteResult(
      title: title,
      url: url,
      icon: icon,
      up: false,
      statusCode: 0,
      responseMs: null,
    );
  }

  final uri = Uri.parse(url);
  final stopwatch = Stopwatch()..start();

  try {
    final headResponse = await services.httpClient
        .head(uri)
        .timeout(const Duration(seconds: 10));
    stopwatch.stop();

    if (headResponse.statusCode >= 200 && headResponse.statusCode < 400) {
      return SiteResult(
        title: title,
        url: url,
        icon: icon,
        up: true,
        statusCode: headResponse.statusCode,
        responseMs: stopwatch.elapsedMilliseconds,
      );
    }

    stopwatch.reset();
    stopwatch.start();
    final getResponse =
        await services.httpClient.get(uri).timeout(const Duration(seconds: 10));
    stopwatch.stop();

    final up = getResponse.statusCode >= 200 && getResponse.statusCode < 400;
    return SiteResult(
      title: title,
      url: url,
      icon: icon,
      up: up,
      statusCode: getResponse.statusCode,
      responseMs: stopwatch.elapsedMilliseconds,
    );
  } catch (_) {
    stopwatch.stop();
    return SiteResult(
      title: title,
      url: url,
      icon: icon,
      up: false,
      statusCode: 0,
      responseMs: null,
    );
  }
}
