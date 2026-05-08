import 'package:dartkup/dartkup.dart';
import 'nodes.dart';

enum FeedLayout {
  /// Text-only list: title link + meta row. No thumbnail. (HackerNews, Lobsters)
  article,

  /// List with optional left thumbnail: title link + meta row. (RSS, Reddit)
  feed,

  /// Responsive grid: entire card is a link, 16:9 thumbnail on top. (Videos)
  card,

  /// Compact list with portrait thumbnail: title + subtitle + progress bar. (Audiobookshelf)
  media,
}

class FeedItem {
  final String title;
  final String href;

  /// Image URL. Empty string means no thumbnail.
  final String thumbnail;

  /// Secondary text line below the title. Empty string means none.
  final String subtitle;

  /// Nodes rendered inside the `.feed-meta` row.
  /// Each element is typically a `span` or `extLink(…, cls: 'feed-meta-link')`.
  final List<Node> meta;

  /// Progress 0.0–1.0. Negative means no progress bar.
  final double progress;

  /// Absolutely-positioned nodes rendered inside the card (card layout only).
  final List<Node> overlay;

  const FeedItem({
    required this.title,
    required this.href,
    this.thumbnail = '',
    this.subtitle = '',
    this.meta = const [],
    this.progress = -1,
    this.overlay = const [],
  });
}

/// Renders a list or grid of [items] using [layout].
///
/// If [showLimit] is set, only that many items are visible initially.
/// The remaining items are hidden and revealed by a "N more" button.
Node feedList(FeedLayout layout, List<FeedItem> items, {int? showLimit}) {
  final rendered = [
    for (var i = 0; i < items.length; i++)
      _buildItem(
        layout,
        items[i],
        overflow: showLimit != null && i >= showLimit,
      ),
  ];

  final overflowCount =
      showLimit != null ? (items.length - showLimit).clamp(0, items.length) : 0;

  final list = layout == FeedLayout.card
      ? div({'cls': 'feed-grid'}, rendered)
      : ul({'cls': 'feed-list'}, rendered);

  if (overflowCount <= 0) return list;

  final btn = el(
    'button',
    {
      'cls': 'feed-more-btn',
      'x-show': '!open',
      '@click': 'open = true',
    },
    t('$overflowCount more'),
  );

  return div({'cls': 'feed-wrapper', 'x-data': '{ open: false }'}, [list, btn]);
}

// ── Private builders ────────────────────────────────────────────────────────

Map<String, dynamic> _overflowAttrs(bool overflow) =>
    overflow ? {'x-show': 'open', 'x-cloak': null} : const {};

Node _buildItem(FeedLayout layout, FeedItem item, {bool overflow = false}) =>
    switch (layout) {
      FeedLayout.article => _article(item, overflow: overflow),
      FeedLayout.feed => _feed(item, overflow: overflow),
      FeedLayout.card => _card(item, overflow: overflow),
      FeedLayout.media => _media(item, overflow: overflow),
    };

Node _article(FeedItem item, {bool overflow = false}) => li(
      {'cls': 'feed-item feed-item--article', ..._overflowAttrs(overflow)},
      [
        extLink(item.href, t(item.title), cls: 'feed-title'),
        if (item.meta.isNotEmpty) div({'cls': 'feed-meta'}, item.meta),
      ],
    );

Node _thumb(String src, String cls, {String alt = ''}) {
  if (src.isNotEmpty) {
    return img({
      'src': src,
      'cls': cls,
      'alt': alt,
      'loading': 'lazy',
      'onerror': 'var d=document.createElement(\'div\');'
          "d.className=this.className+' feed-thumb--empty';"
          'this.parentNode.replaceChild(d,this)',
    });
  }
  return div({'cls': '$cls feed-thumb--empty'});
}

Node _feed(FeedItem item, {bool overflow = false}) => li(
      {'cls': 'feed-item feed-item--feed', ..._overflowAttrs(overflow)},
      [
        _thumb(item.thumbnail, 'feed-thumb'),
        div(
          {'cls': 'feed-content'},
          [
            extLink(item.href, t(item.title), cls: 'feed-title'),
            if (item.meta.isNotEmpty) div({'cls': 'feed-meta'}, item.meta),
          ],
        ),
      ],
    );

Node _card(FeedItem item, {bool overflow = false}) => extLink(
      item.href,
      [
        _thumb(item.thumbnail, 'feed-card-thumb', alt: item.title),
        div(
          {'cls': 'feed-card-info'},
          [
            div({'cls': 'feed-title'}, t(item.title)),
            if (item.meta.isNotEmpty) div({'cls': 'feed-meta'}, item.meta),
          ],
        ),
        ...item.overlay,
      ],
      cls: 'feed-item feed-item--card',
      extra: _overflowAttrs(overflow),
    );

Node _media(FeedItem item, {bool overflow = false}) {
  final hasProg = item.progress >= 0;
  final pct = hasProg ? (item.progress * 100).clamp(0, 100).round() : 0;

  return li(
    {'cls': 'feed-item feed-item--media', ..._overflowAttrs(overflow)},
    [
      _thumb(item.thumbnail, 'feed-media-thumb'),
      div(
        {'cls': 'feed-content'},
        [
          extLink(item.href, t(item.title), cls: 'feed-title'),
          if (item.subtitle.isNotEmpty)
            div({'cls': 'feed-subtitle'}, t(item.subtitle)),
          if (hasProg)
            div(
              {'cls': 'feed-progress'},
              div({'cls': 'feed-progress-bar', 'style': 'width:$pct%'}),
            ),
        ],
      ),
      ...item.overlay,
    ],
  );
}
