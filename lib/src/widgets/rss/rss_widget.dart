import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../components/feed_item.dart';
import '../components/formatters.dart';
import '../render_context.dart';
import '../widget.dart';
import 'api.dart';
import 'models.dart';

class RssWidget extends DashboardWidget {
  RssWidget(super.config, super.id);

  @override
  String get type => 'rss';

  @override
  String get defaultTitle => 'RSS';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final limit = config.options['limit'] as int? ?? 15;

    final items =
        await ctx.cache.fetch<List<RssItem>>('items', config.cache, () async {
      final feeds = _feedList();
      final result = <RssItem>[];

      await Future.wait(
        feeds.map((f) async {
          try {
            result.addAll(await fetchRss(services, f['url']!, f['name']!));
          } catch (_) {}
        }),
      );

      result.sort((a, b) => b.pubDate.compareTo(a.pubDate));
      return result;
    });

    if (items.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No items found.');
    }

    return feedList(
      FeedLayout.feed,
      items
          .take(limit)
          .map(
            (item) => FeedItem(
              title: item.title,
              href: item.link,
              thumbnail: item.imageUrl,
              meta: [
                if (item.source.isNotEmpty) span({}, t(item.source)),
                span({}, t(relativeAge(item.pubDate))),
              ],
            ),
          )
          .toList(),
      showLimit: 5,
    );
  }

  List<Map<String, String>> _feedList() {
    final raw = config.options['feeds'];
    if (raw is! List) return const [];
    return raw
        .cast<Map>()
        .map(
          (f) => {
            'url': (f['url'] as String?) ?? '',
            'name': (f['name'] as String?) ?? '',
          },
        )
        .toList();
  }
}
