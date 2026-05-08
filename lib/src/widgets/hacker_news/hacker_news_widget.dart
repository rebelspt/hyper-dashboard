import 'dart:convert' show jsonDecode;
import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../components/feed_item.dart';
import '../components/formatters.dart';
import '../components/nodes.dart';
import '../render_context.dart';
import '../widget.dart';

class HackerNewsWidget extends DashboardWidget {
  HackerNewsWidget(super.config, super.id);

  @override
  String get type => 'hacker-news';

  @override
  String get defaultTitle => 'Hacker News';

  static const _feeds = {
    'top': 'topstories',
    'new': 'newstories',
    'best': 'beststories',
    'ask': 'askstories',
    'show': 'showstories',
    'jobs': 'jobstories',
  };

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final limit = config.options['limit'] as int? ?? 10;
    final commentsTemplate = config.options['comments-url-template'] as String?;
    final modeKey = config.options['mode'] as String? ?? 'top';
    final feed = _feeds[modeKey] ?? 'topstories';

    final items = await ctx.cache.fetch<List<Map<String, dynamic>>>(
        'items-$feed', config.cache, () async {
      final idsResp = await services.httpClient.get(
        Uri.parse('https://hacker-news.firebaseio.com/v0/$feed.json'),
      );
      if (idsResp.statusCode != 200) {
        throw Exception('HTTP ${idsResp.statusCode} fetching $feed');
      }

      final ids = (jsonDecode(idsResp.body) as List).cast<int>();
      final topIds = ids.take(limit).toList();

      return Future.wait(
        topIds.map((id) async {
          final resp = await services.httpClient.get(
            Uri.parse('https://hacker-news.firebaseio.com/v0/item/$id.json'),
          );
          if (resp.statusCode != 200) {
            throw Exception('HTTP ${resp.statusCode} fetching item $id');
          }
          return jsonDecode(resp.body) as Map<String, dynamic>;
        }),
      );
    });

    if (items.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No items found.');
    }

    return feedList(
      FeedLayout.article,
      items.map((item) {
        final id = item['id'] as int? ?? 0;
        final title = item['title'] as String? ?? '(no title)';
        final score = item['score'] as int? ?? 0;
        final descendants = item['descendants'] as int? ?? 0;
        final timeEpoch = item['time'] as int? ?? 0;
        final url = (item['url'] as String?) ??
            'https://news.ycombinator.com/item?id=$id';

        final hnItemUrl = 'https://news.ycombinator.com/item?id=$id';
        final commentsUrl = commentsTemplate != null
            ? commentsTemplate.replaceAll('{POST-ID}', '$id')
            : hnItemUrl;

        final age =
            relativeAge(DateTime.fromMillisecondsSinceEpoch(timeEpoch * 1000));

        return FeedItem(
          title: title,
          href: url,
          meta: [
            span({}, t('$score points')),
            extLink(
              commentsUrl,
              t('$descendants comments'),
              cls: 'feed-meta-link',
            ),
            span({}, t(age)),
          ],
        );
      }).toList(),
      showLimit: 5,
    );
  }
}
