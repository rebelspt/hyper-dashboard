import 'dart:convert' show jsonDecode;
import '../../services/services.dart';
import '../render_context.dart';

Future<String> fetchTwitchToken(
  RenderContext ctx,
  Services services,
  String clientId,
  String clientSecret,
) =>
    ctx.cache.fetch<String>('token', const Duration(hours: 1), () async {
      final resp = await services.httpClient.post(
        Uri.parse(
          'https://id.twitch.tv/oauth2/token'
          '?client_id=$clientId'
          '&client_secret=$clientSecret'
          '&grant_type=client_credentials',
        ),
      );
      if (resp.statusCode != 200) {
        throw Exception('Twitch OAuth: HTTP ${resp.statusCode}');
      }
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      return body['access_token'] as String;
    });
