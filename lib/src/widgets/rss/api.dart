import 'dart:io' show HttpDate;

import 'package:xml/xml.dart';

import '../../services/services.dart';
import 'models.dart';

const _mediaNs = 'http://search.yahoo.com/mrss/';
const _webfeedsNs = 'http://webfeeds.org/rss/1.0';
final _imgSrcRe = RegExp(r'''<img[^>]+src=["']([^"']+)["']''');

Future<List<RssItem>> fetchRss(
  Services services,
  String url,
  String feedName, {
  bool useChannelImage = true,
}) async {
  final response = await services.httpClient.get(Uri.parse(url));
  if (response.statusCode != 200) {
    throw Exception('HTTP ${response.statusCode}');
  }

  final doc = XmlDocument.parse(response.body);

  if (doc.findAllElements('feed').isNotEmpty) {
    return _parseAtom(doc, feedName, useChannelImage: useChannelImage);
  }
  return _parseRss(doc, feedName, useChannelImage: useChannelImage);
}

String _extractImage(XmlElement el) {
  final mediaThumbnail = el
      .findAllElements('thumbnail', namespace: _mediaNs)
      .firstOrNull
      ?.getAttribute('url');
  if (mediaThumbnail != null && mediaThumbnail.isNotEmpty) {
    return mediaThumbnail;
  }

  final mediaContent = el
      .findAllElements('content', namespace: _mediaNs)
      .where(
        (e) =>
            (e.getAttribute('medium') == 'image' ||
                (e.getAttribute('type') ?? '').startsWith('image')) &&
            e.getAttribute('url') != null,
      )
      .firstOrNull
      ?.getAttribute('url');
  if (mediaContent != null && mediaContent.isNotEmpty) return mediaContent;

  final enclosure = el.findElements('enclosure').firstOrNull;
  if (enclosure != null &&
      (enclosure.getAttribute('type') ?? '').startsWith('image')) {
    final url = enclosure.getAttribute('url') ?? '';
    if (url.isNotEmpty) return url;
  }

  final featured = el
      .findAllElements('featuredImage', namespace: _webfeedsNs)
      .firstOrNull
      ?.innerText
      .trim();
  if (featured != null && featured.isNotEmpty) return featured;

  final description =
      el.findElements('description').firstOrNull?.innerText ?? '';
  if (description.isNotEmpty) {
    final match = _imgSrcRe.firstMatch(description);
    if (match != null) return match.group(1)!;
  }

  final content =
      el.findElements('content').firstOrNull?.innerText ?? '';
  if (content.isNotEmpty) {
    final match = _imgSrcRe.firstMatch(content);
    if (match != null) return match.group(1)!;
  }

  return '';
}

String _extractChannelImage(XmlElement channelOrFeed) {
  final rssImage = channelOrFeed
      .findElements('image')
      .firstOrNull
      ?.findElements('url')
      .firstOrNull
      ?.innerText
      .trim();
  if (rssImage != null && rssImage.isNotEmpty) return rssImage;

  final logo = channelOrFeed.findElements('logo').firstOrNull?.innerText.trim();
  if (logo != null && logo.isNotEmpty) return logo;

  final icon = channelOrFeed.findElements('icon').firstOrNull?.innerText.trim();
  if (icon != null && icon.isNotEmpty) return icon;

  final cover = channelOrFeed
      .findAllElements('cover', namespace: _webfeedsNs)
      .firstOrNull
      ?.getAttribute('image');
  if (cover != null && cover.isNotEmpty) return cover;

  final mediaThumb = channelOrFeed
      .findAllElements('thumbnail', namespace: _mediaNs)
      .firstOrNull
      ?.getAttribute('url');
  if (mediaThumb != null && mediaThumb.isNotEmpty) return mediaThumb;

  return '';
}

List<RssItem> _parseRss(XmlDocument doc, String feedName, {bool useChannelImage = true}) {
  final channel = doc.findAllElements('channel').firstOrNull;
  final channelTitle =
      channel?.findElements('title').firstOrNull?.innerText.trim() ?? feedName;
  final source = feedName.isNotEmpty ? feedName : channelTitle;
  final channelImage = useChannelImage && channel != null ? _extractChannelImage(channel) : '';

  return doc.findAllElements('item').map((item) {
    final title = item.findElements('title').firstOrNull?.innerText.trim() ??
        '(no title)';
    final link = item.findElements('link').firstOrNull?.innerText.trim() ?? '#';
    final pubDateStr =
        item.findElements('pubDate').firstOrNull?.innerText.trim() ?? '';
    final imageUrl = _extractImage(item);

    return RssItem(
      title: title,
      link: link,
      pubDate: _parseDate(pubDateStr) ?? DateTime.now(),
      source: source,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : channelImage,
    );
  }).toList();
}

List<RssItem> _parseAtom(XmlDocument doc, String feedName, {bool useChannelImage = true}) {
  final feed = doc.findAllElements('feed').firstOrNull;
  final feedTitle =
      feed?.findElements('title').firstOrNull?.innerText.trim() ?? feedName;
  final source = feedName.isNotEmpty ? feedName : feedTitle;
  final channelImage = useChannelImage && feed != null ? _extractChannelImage(feed) : '';

  return doc.findAllElements('entry').map((entry) {
    final title = entry.findElements('title').firstOrNull?.innerText.trim() ??
        '(no title)';

    final linkEls = entry.findElements('link').toList();
    String link = '#';
    if (linkEls.isNotEmpty) {
      final el = linkEls.firstWhere(
        (e) => e.getAttribute('rel') == 'alternate',
        orElse: () => linkEls.first,
      );
      link = el.getAttribute('href') ?? el.innerText.trim();
    }

    final dateStr =
        entry.findElements('published').firstOrNull?.innerText.trim() ??
            entry.findElements('updated').firstOrNull?.innerText.trim() ??
            '';
    final imageUrl = _extractImage(entry);

    final author = entry
            .findElements('author')
            .firstOrNull
            ?.findElements('name')
            .firstOrNull
            ?.innerText
            .trim() ??
        '';

    return RssItem(
      title: title,
      link: link,
      pubDate: _parseDate(dateStr) ?? DateTime.now(),
      source: source,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : channelImage,
      author: author,
    );
  }).toList();
}

DateTime? _parseDate(String s) {
  if (s.isEmpty) return null;
  try {
    return DateTime.parse(s);
  } catch (_) {}
  try {
    final normalized = s.replaceAll(RegExp(r'[+-]\d{4}\s*$'), 'GMT');
    return HttpDate.parse(normalized);
  } catch (_) {}
  return null;
}
