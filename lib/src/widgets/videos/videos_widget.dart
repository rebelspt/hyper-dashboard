import 'dart:convert' show jsonEncode;
import 'package:xml/xml.dart';
import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../components/feed_item.dart';
import '../components/formatters.dart';
import '../render_context.dart';
import '../widget.dart';

class _VideoItem {
  final String title;
  final String url;
  final String thumbnail;
  final String channelName;
  final DateTime published;

  const _VideoItem({
    required this.title,
    required this.url,
    required this.thumbnail,
    required this.channelName,
    required this.published,
  });
}

class VideosWidget extends DashboardWidget {
  VideosWidget(super.config, super.id);

  @override
  String get type => 'videos';

  @override
  String get defaultTitle => 'Videos';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final limit = config.options['limit'] as int? ?? 20;

    final items = await ctx.cache
        .fetch<List<_VideoItem>>('videos', config.cache, () async {
      final channels = _channelList();
      final allVideos = <_VideoItem>[];

      await Future.wait(
        channels.map((id) async {
          try {
            allVideos.addAll(await _fetchChannel(services, id));
          } catch (_) {}
        }),
      );

      allVideos.sort((a, b) => b.published.compareTo(a.published));
      return allVideos;
    });

    if (items.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No videos found.');
    }

    return feedList(
      FeedLayout.card,
      items.take(limit).map((v) {
        final videoId = Uri.parse(v.url).queryParameters['v'] ?? '';
        final payload = jsonEncode({
          'type': 'youtube',
          'id': videoId,
          'title': v.title,
          'thumb': v.thumbnail,
        });
        return FeedItem(
          title: v.title,
          href: v.url,
          thumbnail: v.thumbnail,
          meta: [span({}, t('${v.channelName} · ${relativeAge(v.published)}'))],
          overlay: [
            if (videoId.isNotEmpty)
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
      showLimit: 8,
    );
  }

  List<String> _channelList() {
    final raw = config.options['channels'];
    if (raw is! List) return const [];
    return raw.cast<String>();
  }

  Future<List<_VideoItem>> _fetchChannel(
    Services services,
    String channelId,
  ) async {
    final url =
        'https://www.youtube.com/feeds/videos.xml?channel_id=$channelId';
    final resp = await services.httpClient.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode} for channel $channelId');
    }

    final doc = XmlDocument.parse(resp.body);
    const mediaNamespace = 'http://search.yahoo.com/mrss/';

    return doc.findAllElements('entry').map((entry) {
      final title = entry.findElements('title').firstOrNull?.innerText.trim() ??
          '(no title)';

      final linkEls = entry.findElements('link').toList();
      String videoUrl = '#';
      if (linkEls.isNotEmpty) {
        final el = linkEls.firstWhere(
          (e) => e.getAttribute('rel') == 'alternate',
          orElse: () => linkEls.first,
        );
        videoUrl = el.getAttribute('href') ?? el.innerText.trim();
      }

      final publishedStr =
          entry.findElements('published').firstOrNull?.innerText.trim() ?? '';
      final published = publishedStr.isNotEmpty
          ? DateTime.parse(publishedStr)
          : DateTime.now();

      final thumbnailEl = entry
          .findAllElements('thumbnail', namespace: mediaNamespace)
          .firstOrNull;
      String thumbnail = thumbnailEl?.getAttribute('url') ?? '';
      if (thumbnail.isEmpty) {
        final videoId = Uri.parse(videoUrl).queryParameters['v'];
        if (videoId != null && videoId.isNotEmpty) {
          thumbnail = 'https://i.ytimg.com/vi/$videoId/mqdefault.jpg';
        }
      }

      final channelName = entry
              .findElements('author')
              .firstOrNull
              ?.findElements('name')
              .firstOrNull
              ?.innerText
              .trim() ??
          '';

      return _VideoItem(
        title: title,
        url: videoUrl,
        thumbnail: thumbnail,
        channelName: channelName,
        published: published,
      );
    }).toList();
  }
}
