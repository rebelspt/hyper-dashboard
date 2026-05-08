import 'dart:convert' show jsonDecode;
import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../components/feed_item.dart';
import '../components/nodes.dart';
import '../render_context.dart';
import '../widget.dart';

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

    final limit = config.options['limit'] as int? ?? 15;
    final sortBy = config.options['sort-by'] as String? ?? 'hot';
    final showThumbnails = config.options['show-thumbnails'] as bool? ?? true;

    final items = await ctx.cache
        .fetch<List<Map<String, dynamic>>>('posts', config.cache, () async {
      final url =
          'https://www.reddit.com/r/$subreddit/$sortBy.json?limit=$limit&raw_json=1';

      final resp = await services.httpClient.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode} fetching r/$subreddit');
      }

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final children =
          (body['data']['children'] as List).cast<Map<String, dynamic>>();
      return children
          .map((child) => child['data'] as Map<String, dynamic>)
          .toList();
    });

    if (items.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No items found.');
    }

    return feedList(
      FeedLayout.feed,
      items.map((post) {
        final title = post['title'] as String? ?? '(no title)';
        final postUrl = post['url'] as String? ?? '#';
        final permalink = post['permalink'] as String? ?? '';
        final author = post['author'] as String? ?? '';
        final score = post['score'] as int? ?? 0;
        final numComments = post['num_comments'] as int? ?? 0;
        final isSelf = post['is_self'] as bool? ?? false;
        final thumbSrc = showThumbnails && !isSelf ? _previewImage(post) : '';
        final commentsUrl = 'https://www.reddit.com$permalink';

        return FeedItem(
          title: title,
          href: postUrl,
          thumbnail: thumbSrc,
          meta: [
            span({}, t('↑$score')),
            extLink(
              commentsUrl,
              t('$numComments comments'),
              cls: 'feed-meta-link',
            ),
            span({}, t('by u/$author')),
          ],
        );
      }).toList(),
      showLimit: 5,
    );
  }

  String _previewImage(Map<String, dynamic> post) {
    try {
      final images = ((post['preview'] as Map?)?['images'] as List?)
          ?.cast<Map<String, dynamic>>();
      if (images != null && images.isNotEmpty) {
        final resolutions =
            (images[0]['resolutions'] as List?)?.cast<Map<String, dynamic>>();
        if (resolutions != null && resolutions.isNotEmpty) {
          final r = resolutions.lastWhere(
            (r) => (r['width'] as int? ?? 0) <= 320,
            orElse: () => resolutions.first,
          );
          final url = (r['url'] as String? ?? '').replaceAll('&amp;', '&');
          if (url.isNotEmpty) return url;
        }
      }
    } catch (_) {}

    final thumb = post['thumbnail'] as String? ?? '';
    return thumb.startsWith('https://') ? thumb : '';
  }
}
