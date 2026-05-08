class SiteResult {
  final String title;
  final String url;
  final String? icon;
  final bool up;
  final int statusCode;
  final int? responseMs;

  const SiteResult({
    required this.title,
    required this.url,
    this.icon,
    required this.up,
    required this.statusCode,
    required this.responseMs,
  });
}
