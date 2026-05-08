import '../cache/widget_cache.dart';
import '../config/models.dart';
import 'package:dartkup/dartkup.dart';
import '../services/services.dart';
import 'render_context.dart';
import 'widget_frame.dart';

abstract class DashboardWidget {
  final WidgetConfig config;
  final String id;
  final _cacheStore = WidgetCacheStore();

  DashboardWidget(this.config, this.id);

  String get type;
  String get defaultTitle;

  /// True when any cached data exists (fresh or expired).
  /// Container widgets override this to delegate to their children.
  bool get hasCachedData => _cacheStore.hasData;

  /// True when cached data exists but at least one entry has expired,
  /// meaning the stale strategy should serve the old data and schedule a refresh.
  /// Container widgets override this to delegate to their children.
  bool get hasStaleData => _cacheStore.hasExpiredData;

  Future<Node> renderBody(Services services, RenderContext ctx);

  /// Returns the query params that should survive in the auto-refresh URL.
  /// Override to strip transient action params (e.g. action, container).
  QueryParams persistentParams(QueryParams incoming) => incoming;

  /// Builds a [RenderContext] backed by this widget's own cache store.
  /// Container widgets call this on each child to ensure each child uses its
  /// own isolated cache rather than the container's.
  RenderContext contextFor({
    bool stale = false,
    QueryParams queryParameters = const {},
    String routePath = '',
  }) {
    if (stale) {
      return RenderContext(
        StaleCacheStore(_cacheStore),
        id,
        stale: true,
        queryParameters: queryParameters,
        routePath: routePath,
      );
    }
    return RenderContext(
      _cacheStore,
      id,
      queryParameters: queryParameters,
      routePath: routePath,
    );
  }

  /// Renders the widget for a sub-route.
  ///
  /// [routePath] is the path appended after `/widget/<id>/`.
  /// The base implementation simply passes [routePath] through to
  /// [RenderContext] and calls [renderBody].
  Future<Node> renderRoute(
    Services services,
    String routePath,
    QueryParams queryParameters, {
    bool stale = false,
  }) async {
    final ctx = contextFor(
      stale: stale,
      queryParameters: queryParameters,
      routePath: routePath,
    );
    final refreshParams = persistentParams(queryParameters);
    try {
      final body = await renderBody(services, ctx);
      return WidgetFrame.wrap(
        id: id,
        widgetPath: ctx.url(refreshParams),
        title: config.title ?? defaultTitle,
        refreshSeconds: _refreshSeconds,
        showHeader: !config.hideHeader,
        refreshOnLoad: stale,
        body: body,
      );
    } catch (e) {
      return WidgetFrame.error(
        id: id,
        widgetPath: ctx.url(refreshParams),
        title: config.title ?? defaultTitle,
        message: e.toString(),
        refreshSeconds: _refreshSeconds,
      );
    }
  }

  Node renderPlaceholder() => WidgetFrame.loading(
        id: id,
        widgetPath: '/widget/$id',
        title: config.title ?? defaultTitle,
      );

  /// Returns the refresh interval in seconds.
  /// Uses [config.refresh] if set
  /// A value of 0 disables auto-refresh.
  int get _refreshSeconds {
    if (config.refresh != null) {
      return config.refresh!.inSeconds;
    }
    return 0;
  }

  Future<Node> render(
    Services services, {
    bool stale = false,
    QueryParams queryParameters = const {},
  }) async {
    final ctx = contextFor(stale: stale, queryParameters: queryParameters);
    final refreshParams = persistentParams(queryParameters);
    try {
      final body = await renderBody(services, ctx);
      return WidgetFrame.wrap(
        id: id,
        widgetPath: ctx.url(refreshParams),
        title: config.title ?? defaultTitle,
        refreshSeconds: _refreshSeconds,
        showHeader: !config.hideHeader,
        refreshOnLoad: stale,
        body: body,
      );
    } catch (e) {
      return WidgetFrame.error(
        id: id,
        widgetPath: ctx.url(refreshParams),
        title: config.title ?? defaultTitle,
        message: e.toString(),
        refreshSeconds: _refreshSeconds,
      );
    }
  }
}
