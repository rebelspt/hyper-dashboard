import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../components/feed_item.dart';
import '../components/formatters.dart';
import '../render_context.dart';
import '../widget.dart';
import '../rss/api.dart';
import '../rss/models.dart';

class RedditWidget extends DashboardWidget {
  RedditWidget(super.config, super.id);

  @override
  String get type => 'reddit';

  @override
  String get defaultTitle => 'Reddit';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final subreddit = config.options['subreddit'] as String? ?? '';
    if (subreddit.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No subreddit configured.');
    }

    final url = 'https://www.reddit.com/r/$subreddit.rss';

    final items =
        await ctx.cache.fetch<List<RssItem>>('posts', config.cache, () async {
      return fetchRss(services, url, subreddit, useChannelImage: false);
    });

    if (items.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No items found.');
    }

    return feedList(
      FeedLayout.feed,
      items
          .map((item) => FeedItem(
                title: item.title,
                href: item.link,
                thumbnail: item.imageUrl,
                meta: [
                  if (item.author.isNotEmpty)
                    span({}, t('by u/${item.author}')),
                  span({}, t(relativeAge(item.pubDate))),
                ],
              ))
          .toList(),
      showLimit: 5,
    );
  }
}
