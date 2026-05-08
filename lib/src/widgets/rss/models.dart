class RssItem {
  final String title;
  final String link;
  final DateTime pubDate;
  final String source;
  final String imageUrl;

  const RssItem({
    required this.title,
    required this.link,
    required this.pubDate,
    required this.source,
    this.imageUrl = '',
  });
}
