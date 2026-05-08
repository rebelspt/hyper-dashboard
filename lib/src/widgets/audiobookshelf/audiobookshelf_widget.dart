import 'dart:convert' show jsonEncode;
import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../components/feed_item.dart';
import '../render_context.dart';
import '../widget.dart';
import 'api/fetch.dart';
import 'models.dart';

class AudiobookshelfWidget extends DashboardWidget {
  AudiobookshelfWidget(super.config, super.id);

  @override
  String get type => 'audiobookshelf';

  @override
  String get defaultTitle => 'Audiobookshelf';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final rawUrl = config.options['url'] as String? ?? '';
    final baseUrl =
        rawUrl.endsWith('/') ? rawUrl.substring(0, rawUrl.length - 1) : rawUrl;
    final apiKey = config.options['api-key'] as String? ?? '';
    final mode = AbsMode.from(config.options['mode'] as String?);
    final limit = config.options['limit'] as int? ?? 10;
    final libraryName = config.options['library'] as String? ?? '';

    if (baseUrl.isEmpty || apiKey.isEmpty) {
      return p(
        {'cls': 'widget-error'},
        'Audiobookshelf url and api-key are required.',
      );
    }

    if (mode.usesPersonalizedEndpoint && libraryName.isEmpty) {
      return p(
        {
          'cls': 'widget-error',
        },
        'Audiobookshelf mode "${config.options['mode']}" requires a library option.',
      );
    }

    final headers = {'Authorization': 'Bearer $apiKey'};

    final items = await ctx.cache.fetch<List<AbsItem>>(
      'items',
      config.cache,
      () => switch (mode) {
        AbsMode.continueListening =>
          fetchInProgress(services, baseUrl, apiKey, headers, limit),
        AbsMode.continueSeries ||
        AbsMode.listenAgain ||
        AbsMode.newestEpisodes ||
        AbsMode.recentlyAdded =>
          fetchPersonalized(
            services,
            baseUrl,
            apiKey,
            headers,
            libraryName,
            mode,
            limit,
          ),
        AbsMode.newest =>
          fetchNewest(services, baseUrl, apiKey, headers, limit),
      },
    );

    if (items.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No items found.');
    }

    return feedList(
      FeedLayout.media,
      items.map((item) {
        final payload = item.streamUrl.isNotEmpty
            ? jsonEncode({
                'type': 'audio',
                'url': item.streamUrl,
                'title': item.title,
                'thumb': item.coverUrl,
              })
            : null;
        return FeedItem(
          title: item.title,
          href: item.itemUrl,
          thumbnail: item.coverUrl,
          subtitle: item.subtitle,
          progress: item.progress,
          overlay: [
            if (payload != null)
              el(
                'button',
                {
                  'cls': 'yt-add-btn',
                  'onclick':
                      'event.preventDefault();event.stopPropagation();MediaPlayer.queue($payload)',
                  'title': 'Add to queue',
                },
                raw('&#9654;'),
              ),
          ],
        );
      }).toList(),
      showLimit: 5,
    );
  }
}
