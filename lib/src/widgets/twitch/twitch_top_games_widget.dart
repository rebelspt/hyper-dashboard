import 'dart:convert' show jsonDecode;
import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../render_context.dart';
import '../widget.dart';
import 'twitch_api.dart';

class TwitchTopGamesWidget extends DashboardWidget {
  TwitchTopGamesWidget(super.config, super.id);

  @override
  String get type => 'twitch-top-games';

  @override
  String get defaultTitle => 'Top Games';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final clientId = config.options['client-id'] as String? ?? '';
    final clientSecret = config.options['client-secret'] as String? ?? '';

    if (clientId.isEmpty || clientSecret.isEmpty) {
      return p(
        {'cls': 'widget-error'},
        'Twitch client-id and client-secret are required.',
      );
    }

    final limit = config.options['limit'] as int? ?? 10;

    final rawExclude = config.options['exclude'];
    final exclude = rawExclude is List
        ? rawExclude
            .cast<Object>()
            .map((e) => e.toString().toLowerCase())
            .toSet()
        : <String>{};

    final games =
        await ctx.cache.fetch<List<_GameInfo>>('games', config.cache, () async {
      final token =
          await fetchTwitchToken(ctx, services, clientId, clientSecret);
      final fetchCount = (limit + exclude.length + 10).clamp(1, 100);

      final resp = await services.httpClient.get(
        Uri.parse('https://api.twitch.tv/helix/games/top?first=$fetchCount'),
        headers: {'Client-Id': clientId, 'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode != 200) {
        throw Exception('Twitch top games API: HTTP ${resp.statusCode}');
      }

      final data =
          (jsonDecode(resp.body) as Map<String, dynamic>)['data'] as List;

      return data
          .cast<Map<String, dynamic>>()
          .where(
            (g) =>
                !exclude.contains((g['name'] as String? ?? '').toLowerCase()),
          )
          .take(limit)
          .map(
            (g) => _GameInfo(
              name: g['name'] as String? ?? '',
              boxArtUrl: (g['box_art_url'] as String? ?? '')
                  .replaceAll('{width}x{height}', '52x72'),
            ),
          )
          .toList();
    });

    if (games.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No games found.');
    }

    return el(
      'ol',
      {'cls': 'tgames-list'},
      games.asMap().entries.map((e) {
        final rank = e.key + 1;
        final game = e.value;
        return li(
          {'cls': 'tgames-item'},
          [
            if (game.boxArtUrl.isNotEmpty)
              img({'src': game.boxArtUrl, 'cls': 'tgames-art', 'alt': ''}),
            span({'cls': 'tgames-name'}, t(game.name)),
            span({'cls': 'tgames-rank'}, t('#$rank')),
          ],
        );
      }).toList(),
    );
  }
}

class _GameInfo {
  final String name;
  final String boxArtUrl;

  const _GameInfo({required this.name, required this.boxArtUrl});
}
