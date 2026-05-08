import 'dart:convert' show jsonDecode;
import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../components/feed_item.dart';
import '../components/nodes.dart';
import '../render_context.dart';
import '../widget.dart';

enum LobstersSortBy {
  hot,
  newest;

  static LobstersSortBy from(String? value) => switch (value) {
        'new' || 'newest' => LobstersSortBy.newest,
        _ => LobstersSortBy.hot,
      };

  String get endpoint => switch (this) {
        LobstersSortBy.newest => 'https://lobste.rs/newest.json',
        LobstersSortBy.hot => 'https://lobste.rs/hottest.json',
      };
}

class LobstersWidget extends DashboardWidget {
  LobstersWidget(super.config, super.id);

  @override
  String get type => 'lobsters';

  @override
  String get defaultTitle => 'Lobsters';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final limit = config.options['limit'] as int? ?? 25;
    final sortBy = LobstersSortBy.from(config.options['sort-by'] as String?);

    final items = await ctx.cache
        .fetch<List<Map<String, dynamic>>>('items', config.cache, () async {
      final resp = await services.httpClient.get(Uri.parse(sortBy.endpoint));
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode} fetching Lobsters feed');
      }

      return (jsonDecode(resp.body) as List).cast<Map<String, dynamic>>();
    });

    if (items.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No items found.');
    }

    return feedList(
      FeedLayout.article,
      items.take(limit).map((item) {
        final title = item['title'] as String? ?? '(no title)';
        final rawUrl = item['url'] as String? ?? '';
        final shortIdUrl = item['short_id_url'] as String? ?? '#';
        final score = item['score'] as int? ?? 0;
        final commentCount = item['comment_count'] as int? ?? 0;
        final tags =
            (item['tags'] as List?)?.cast<String>() ?? const <String>[];

        final url = rawUrl.isNotEmpty ? rawUrl : shortIdUrl;
        final commentsUrl = '$shortIdUrl/comments';
        final tagsText = tags.join(', ');

        return FeedItem(
          title: title,
          href: url,
          meta: [
            span({}, t('$score pts')),
            extLink(
              commentsUrl,
              t('$commentCount comments'),
              cls: 'feed-meta-link',
            ),
            if (tagsText.isNotEmpty)
              span({'style': 'opacity:0.6'}, t(tagsText)),
          ],
        );
      }).toList(),
      showLimit: 5,
    );
  }
}
