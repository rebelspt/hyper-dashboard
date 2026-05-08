import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../css/scope_css.dart';
import 'package:dartkup/dartkup.dart';
import 'package:begod/begod.dart';
import '../../services/services.dart';
import '../render_context.dart';
import '../widget.dart';

/// Parses a Mustache-style path pattern like `users/<id>` or `items/<id|\d+>`.
class _PathPattern {
  static final _parser = RegExp(r'([^<]*)(?:<([^>|]+)(?:\|([^>]*))?>)?');

  final String pattern;
  final RegExp _regex;
  final List<String> _params;

  _PathPattern(this.pattern)
      : _regex = _buildRegex(pattern),
        _params = _extractParams(pattern);

  static RegExp _buildRegex(String pattern) {
    var regex = '';
    for (final m in _parser.allMatches(pattern)) {
      regex += RegExp.escape(m[1]!);
      if (m[2] != null) {
        regex += '(${m[3] ?? r'[^/]+'})';
      }
    }
    return RegExp('^$regex\$');
  }

  static List<String> _extractParams(String pattern) {
    final params = <String>[];
    for (final m in _parser.allMatches(pattern)) {
      if (m[2] != null) {
        params.add(m[2]!);
      }
    }
    return params;
  }

  Map<String, String>? match(String path) {
    final m = _regex.firstMatch(path);
    if (m == null) return null;
    return {
      for (var i = 0; i < _params.length; i++) _params[i]: m[i + 1]!,
    };
  }
}

/// A single route configured inside an [ApiWidget].
class _ApiRoute {
  final String path;
  final String? url;
  final String method;
  final Map<String, String> headers;
  final Map<String, dynamic>? body;
  final String? template;
  final _PathPattern _matcher;

  _ApiRoute({
    required this.path,
    this.url,
    required this.method,
    required this.headers,
    this.body,
    this.template,
  }) : _matcher = _PathPattern(path);
}

class ApiWidget extends DashboardWidget {
  final List<_ApiRoute> _routes;

  ApiWidget(super.config, super.id)
      : _routes = _parseRoutes(config.options['routes']);

  @override
  String get type => 'api';

  @override
  String get defaultTitle => 'API';

  static List<_ApiRoute> _parseRoutes(dynamic raw) {
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map)
          _ApiRoute(
            path: item['path']?.toString() ?? '',
            url: item['url']?.toString(),
            method: item['method']?.toString() ?? 'GET',
            headers: _parseHeadersMap(item['headers']),
            body: item['body'] is Map
                ? Map<String, dynamic>.from(item['body'] as Map)
                : null,
            template: item['template']?.toString(),
          ),
    ];
  }

  static Map<String, String> _parseHeadersMap(dynamic raw) {
    if (raw is! Map) return const {};
    return {
      for (final e in raw.entries) e.key.toString(): e.value?.toString() ?? '',
    };
  }

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    if (_routes.isEmpty) {
      throw ArgumentError(
        'API widget requires at least one route in the "routes" option.',
      );
    }

    if (ctx.routePath.isNotEmpty) {
      return _renderRoute(services, ctx);
    }

    return _renderDefaultRoute(services, ctx);
  }

  Future<Node> _renderDefaultRoute(Services services, RenderContext ctx) async {
    final route = _routes.first;

    final rawUrl = route.url;
    if (rawUrl == null || rawUrl.isEmpty) {
      throw ArgumentError(
        'The default route (first route) requires a "url" option.',
      );
    }
    final url = _interpolate(rawUrl, ctx.queryParameters);

    final method = _parseMethod(route.method);
    final headers = _parseHeaders(route.headers);

    Map<String, dynamic>? bodyMap;
    if (route.body != null) {
      bodyMap = _interpolateValue(route.body!, ctx.queryParameters)
          as Map<String, dynamic>;
    }

    final templateStr = route.template;
    if (templateStr == null || templateStr.isEmpty) {
      throw ArgumentError(
        'The default route (first route) requires a "template" option.',
      );
    }
    final template = MustacheTemplate(templateStr);

    final data = await ctx.cache.fetch<Map<String, dynamic>>(
      'response',
      config.cache,
      () => _fetchData(services, url, method, headers, bodyMap, template),
    );

    final html = template.render(data);
    return _wrapOutput(html);
  }

  Future<Node> _renderRoute(Services services, RenderContext ctx) async {
    final routePath = ctx.routePath;

    // Find the first matching route.
    _ApiRoute? matchedRoute;
    Map<String, String> pathVars = {};
    for (final route in _routes) {
      final vars = route._matcher.match(routePath);
      if (vars != null) {
        matchedRoute = route;
        pathVars = vars;
        break;
      }
    }

    if (matchedRoute == null) {
      throw ArgumentError('No route matches path: $routePath');
    }

    // Build the interpolation context: path variables + query parameters.
    final allParams = <String, String>{}
      ..addAll(pathVars)
      ..addAll(ctx.queryParameters);

    final rawUrl = matchedRoute.url;
    if (rawUrl == null || rawUrl.isEmpty) {
      throw ArgumentError('Route "$routePath" requires a "url" option.');
    }
    final url = _interpolate(rawUrl, allParams);

    final method = _parseMethod(matchedRoute.method);
    final headers = _parseHeaders(matchedRoute.headers);

    // Interpolate body map.
    Map<String, dynamic>? bodyMap;
    if (matchedRoute.body != null) {
      bodyMap = _interpolateValue(matchedRoute.body!, allParams)
          as Map<String, dynamic>;
    }

    final templateStr = matchedRoute.template;
    if (templateStr == null || templateStr.isEmpty) {
      throw ArgumentError('Route "$routePath" requires a "template" option.');
    }
    final template = MustacheTemplate(templateStr);

    // Cache key must be unique per route + interpolated params.
    final cacheKey = 'route:$routePath:'
        '${allParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key))}';

    final data = await ctx.cache.fetch<Map<String, dynamic>>(
      cacheKey,
      config.cache,
      () => _fetchData(services, url, method, headers, bodyMap, template),
    );

    final html = template.render(data);
    return _wrapOutput(html);
  }

  /// Wraps rendered HTML with the scoped style tag and hx-base container.
  Node _wrapOutput(String html) {
    final scopeClass = 'aw-$id';
    final css = config.options['style'] as String?;
    final scopedCss =
        css != null && css.isNotEmpty ? scopeCss(css, '.$scopeClass') : null;

    return div(
      {'data-hx-base': '/widget/$id/', 'cls': scopeClass},
      [
        if (scopedCss != null) style({}, raw(scopedCss)),
        raw(html),
      ],
    );
  }

  Future<Map<String, dynamic>> _fetchData(
    Services services,
    String url,
    String method,
    Map<String, String> headers,
    Map? bodyMap,
    MustacheTemplate template,
  ) async {
    final uri = Uri.parse(url);
    late final http.Response response;

    switch (method) {
      case 'GET':
        response = await services.httpClient.get(uri, headers: headers);
      case 'POST':
        response = await services.httpClient.post(
          uri,
          headers: _headersWithContentType(headers, bodyMap),
          body: _encodeBody(bodyMap),
        );
      case 'PUT':
        response = await services.httpClient.put(
          uri,
          headers: _headersWithContentType(headers, bodyMap),
          body: _encodeBody(bodyMap),
        );
      case 'PATCH':
        response = await services.httpClient.patch(
          uri,
          headers: _headersWithContentType(headers, bodyMap),
          body: _encodeBody(bodyMap),
        );
      case 'DELETE':
        response = await services.httpClient.delete(uri, headers: headers);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }

    dynamic jsonData;
    try {
      jsonData = jsonDecode(response.body);
    } catch (_) {
      throw FormatException(
        'API response is not valid JSON (status ${response.statusCode})',
      );
    }

    final Map<String, dynamic> data;
    if (jsonData is Map) {
      data = Map<String, dynamic>.from(jsonData);
    } else {
      data = {'_raw': jsonData};
    }

    if (response.statusCode >= 400) {
      data['error'] = {
        'status': response.statusCode,
        'message': response.body,
      };

      if (!template.hasReference('error')) {
        throw Exception(
          'API request failed with status ${response.statusCode}: ${response.body}',
        );
      }
    }

    return data;
  }

  String _parseMethod(String? raw) {
    final m = (raw ?? 'GET').toUpperCase();
    const valid = {'GET', 'POST', 'PUT', 'PATCH', 'DELETE'};
    if (valid.contains(m)) return m;
    return 'GET';
  }

  Map<String, String> _parseHeaders(dynamic raw) {
    if (raw is! Map) return const {};
    return {
      for (final e in raw.entries) e.key.toString(): e.value?.toString() ?? '',
    };
  }

  Map<String, String> _headersWithContentType(
    Map<String, String> headers,
    Map? body,
  ) {
    if (body == null) return headers;
    final result = Map<String, String>.from(headers);
    result.putIfAbsent('Content-Type', () => 'application/json');
    return result;
  }

  String? _encodeBody(Map? body) {
    if (body == null) return null;
    return jsonEncode(body);
  }

  /// Replace `{key}` occurrences in [template] with values from [params].
  static String _interpolate(String template, Map<String, String> params) {
    return template.replaceAllMapped(
      RegExp(r'\{(\w+)\}'),
      (m) => params[m.group(1)] ?? m.group(0)!,
    );
  }

  /// Deep-interpolate `{key}` inside Maps, Lists and Strings.
  static dynamic _interpolateValue(dynamic value, Map<String, String> params) {
    if (value is String) {
      return _interpolate(value, params);
    }
    if (value is Map) {
      return {
        for (final e in value.entries)
          e.key.toString(): _interpolateValue(e.value, params),
      };
    }
    if (value is List) {
      return value.map((v) => _interpolateValue(v, params)).toList();
    }
    return value;
  }
}
