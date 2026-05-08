import '../cache/widget_cache.dart';

typedef QueryParams = Map<String, String>;

extension QueryParamsX on QueryParams {
  int intOr(String key, int fallback) =>
      int.tryParse(this[key] ?? '') ?? fallback;
  int? intOrNull(String key) => int.tryParse(this[key] ?? '');
  double doubleOr(String key, double fallback) =>
      double.tryParse(this[key] ?? '') ?? fallback;
  double? doubleOrNull(String key) => double.tryParse(this[key] ?? '');
}

/// Passed to every [renderBody] call carrying the cache store to use.
/// The core injects a [StaleCacheStore] when serving a stale-then-refresh
/// response, so individual widgets never need to reason about staleness.
///
/// [stale] is retained solely so container widgets (group, split-column) can
/// propagate the same rendering mode to their children.
///
/// [widgetId] and [queryParameters] are set when the widget is rendered via an
/// HTTP request, allowing widgets to build self-referential URLs that preserve
/// the original query string.
class RenderContext {
  final CacheStore cache;
  final bool stale;
  final String widgetId;
  final QueryParams queryParameters;

  /// Sub-path when the widget is rendered via a routed URL
  /// (e.g. `/widget/<id>/pokemon/pikachu` => `pokemon/pikachu`).
  final String routePath;

  RenderContext(
    this.cache,
    this.widgetId, {
    this.stale = false,
    this.queryParameters = const {},
    this.routePath = '',
  });

  /// Returns the URL path for this widget with [query] as the query string,
  /// ignoring any [queryParameters] that were present on the incoming request.
  String url([QueryParams query = const {}]) {
    final base = routePath.isNotEmpty
        ? '/widget/$widgetId/$routePath'
        : '/widget/$widgetId';
    if (query.isEmpty) return base;
    return Uri.parse(base).replace(queryParameters: query).toString();
  }
}
