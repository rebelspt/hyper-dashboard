import 'dart:io' show File;

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../config/models.dart';
import '../services/services.dart';
import '../widgets/api/api_widget.dart';
import '../widgets/registry.dart';
import '../widgets/widget.dart';
import 'page_renderer.dart';

class DashboardServer {
  final DashboardConfig config;
  final String assetsDir;
  final bool useLocalAssets;
  final _services = Services();

  /// Lookup by widget ID for the /widget/<id> refresh endpoint.
  final Map<String, DashboardWidget> _byId = {};

  /// Lookup by WidgetConfig object identity for page rendering.
  final Map<WidgetConfig, DashboardWidget> _byConfig = {};

  DashboardServer(this.config, {this.assetsDir = 'assets', this.useLocalAssets = false}) {
    _buildIndex();
  }

  void _buildIndex() {
    var counter = 0;
    for (final page in config.pages) {
      for (final col in page.columns) {
        for (final wc in col.widgets) {
          final id = '${wc.type}-$counter';
          final widget = WidgetRegistry.create(wc, id);
          if (widget != null) {
            _byId[id] = widget;
            _byConfig[wc] = widget;
          }
          counter++;
        }
      }
    }
  }

  Handler buildHandler() {
    final router = Router();

    router.get('/', (Request req) async {
      final pageStr = req.url.queryParameters['page'] ?? '0';
      final pageIdx = int.tryParse(pageStr) ?? 0;
      final renderer = PageRenderer(config, _byConfig, _services, useLocalAssets: useLocalAssets);
      final isHtmx = req.headers['hx-request'] == 'true';
      final node = isHtmx
          ? await renderer.renderPartial(pageIdx)
          : await renderer.renderPage(pageIdx);
      return Response.ok(node.render(), headers: _html);
    });

    router.get('/widget/<id>', (Request req, String id) async {
      final widget = _byId[id];
      if (widget == null) return Response.notFound('Widget "$id" not found');
      final node = await widget.render(
        _services,
        queryParameters: req.url.queryParameters,
      );
      return Response.ok(node.render(), headers: _html);
    });

    // Catch-all for API-widget sub-routes: /widget/<id>/<path>
    router.all('/widget/<id>/<path|[^]*>',
        (Request req, String id, String path) async {
      final widget = _byId[id];
      if (widget == null) return Response.notFound('Widget "$id" not found');
      if (widget is! ApiWidget) return Router.routeNotFound;
      final node = await widget.renderRoute(
        _services,
        path,
        req.url.queryParameters,
      );
      return Response.ok(node.render(), headers: _html);
    });

    router.get(r'/assets/<path|[^/]+\.[^/]+>', (Request req, String path) async {
      if (path.contains('..')) return Response.forbidden('');
      final file = File('$assetsDir/$path');
      if (!file.existsSync()) {
        return Response.notFound('Asset not found: $path');
      }
      return Response.ok(
        file.readAsStringSync(),
        headers: {'content-type': _mimeType(path), 'cache-control': 'no-cache'},
      );
    });

    router.all('/<_|.*>', (Request req) => Response.found('/'));

    return router.call;
  }

  static String _mimeType(String path) {
    if (path.endsWith('.js')) return 'application/javascript; charset=utf-8';
    if (path.endsWith('.css')) return 'text/css; charset=utf-8';
    if (path.endsWith('.svg')) return 'image/svg+xml';
    return 'text/plain; charset=utf-8';
  }

  static const _html = {'content-type': 'text/html; charset=utf-8'};
}
