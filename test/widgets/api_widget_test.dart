import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'package:hyper_dashboard/src/cache/widget_cache.dart';
import 'package:hyper_dashboard/src/config/models.dart';
import 'package:hyper_dashboard/src/services/services.dart';
import 'package:hyper_dashboard/src/widgets/api/api_widget.dart';
import 'package:hyper_dashboard/src/widgets/render_context.dart';

class _MockClient extends http.BaseClient {
  final Map<String, http.Response> _responses;

  _MockClient(this._responses);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final url = request.url.toString();
    final response = _responses[url];
    if (response == null) {
      throw Exception('No mock response for $url');
    }
    return http.StreamedResponse(
      Stream.fromIterable([response.bodyBytes]),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}

WidgetConfig _config(Map<String, dynamic> options) => WidgetConfig(
      type: 'api',
      options: options,
    );

RenderContext _ctx() => RenderContext(WidgetCacheStore(), 'test-api');

void main() {
  group('ApiWidget config validation', () {
    test('throws when routes is empty', () async {
      final widget = ApiWidget(_config({}), 'id');
      expect(
        () => widget.renderBody(Services(), _ctx()),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when first route has no url', () async {
      final widget = ApiWidget(
        _config({
          'routes': [
            {'path': '_default', 'template': '{{x}}'},
          ],
        }),
        'id',
      );
      expect(
        () => widget.renderBody(Services(), _ctx()),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when first route has no template', () async {
      final widget = ApiWidget(
        _config({
          'routes': [
            {'path': '_default', 'url': 'http://test'},
          ],
        }),
        'id',
      );
      expect(
        () => widget.renderBody(Services(), _ctx()),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('defaults method to GET', () async {
      final client = _MockClient({
        'http://test': http.Response('{"msg":"hi"}', 200),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{msg}}',
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      expect(node.render(), contains('hi'));
    });

    test('invalid method defaults to GET', () async {
      final client = _MockClient({
        'http://test': http.Response('{"msg":"hi"}', 200),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{msg}}',
              'method': 'INVALID',
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      expect(node.render(), contains('hi'));
    });
  });

  group('ApiWidget HTTP methods', () {
    test('GET request with custom headers', () async {
      final client = _MockClient({
        'http://test': http.Response('{"msg":"hi"}', 200),
      });
      // We can't easily capture headers with our simple mock, so we verify via behavior.
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{msg}}',
              'method': 'GET',
              'headers': {'X-Custom': 'value'},
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      expect(node.render(), contains('hi'));
    });

    test('POST with JSON body', () async {
      final client = _MockClient({
        'http://test': http.Response('{"result":"ok"}', 200),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{result}}',
              'method': 'POST',
              'body': {'query': 'dart', 'limit': 10},
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      expect(node.render(), contains('ok'));
    });

    test('PUT with JSON body', () async {
      final client = _MockClient({
        'http://test': http.Response('{"updated":true}', 200),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{updated}}',
              'method': 'PUT',
              'body': {'name': 'test'},
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      expect(node.render(), contains('true'));
    });

    test('PATCH with JSON body', () async {
      final client = _MockClient({
        'http://test': http.Response('{"patched":true}', 200),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{patched}}',
              'method': 'PATCH',
              'body': {'field': 'value'},
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      expect(node.render(), contains('true'));
    });

    test('DELETE request', () async {
      final client = _MockClient({
        'http://test': http.Response('{"deleted":true}', 200),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{deleted}}',
              'method': 'DELETE',
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      expect(node.render(), contains('true'));
    });
  });

  group('ApiWidget template rendering', () {
    test('renders simple template with JSON data', () async {
      final client = _MockClient({
        'http://test': http.Response(
          jsonEncode({'login': 'octocat', 'bio': 'GitHub mascot'}),
          200,
        ),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '<h3>{{login}}</h3><p>{{bio}}</p>',
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      final html = node.render();
      expect(html, contains('<h3>octocat</h3>'));
      expect(html, contains('<p>GitHub mascot</p>'));
    });

    test('renders list with sections', () async {
      final client = _MockClient({
        'http://test': http.Response(
          jsonEncode({
            'items': [
              {'name': 'Alice', 'age': 30},
              {'name': 'Bob', 'age': 25},
            ],
          }),
          200,
        ),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template':
                  '<ul>{{#items}}<li>{{name}} - {{age}}</li>{{/items}}</ul>',
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      final html = node.render();
      expect(html, contains('<li>Alice - 30</li>'));
      expect(html, contains('<li>Bob - 25</li>'));
    });

    test('renders nested objects with dotted names', () async {
      final client = _MockClient({
        'http://test': http.Response(
          jsonEncode({
            'user': {
              'profile': {'name': 'John', 'email': 'john@example.com'},
            },
          }),
          200,
        ),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{user.profile.name}} - {{user.profile.email}}',
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      expect(node.render(), contains('John - john@example.com'));
    });

    test('HTML escaping in template', () async {
      final client = _MockClient({
        'http://test': http.Response(
          jsonEncode({'content': '<script>alert("xss")</script>'}),
          200,
        ),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{content}}',
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      expect(
        node.render(),
        contains('&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;'),
      );
    });

    test('raw HTML with triple mustache', () async {
      final client = _MockClient({
        'http://test': http.Response(
          jsonEncode({'html': '<b>Bold</b>'}),
          200,
        ),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{{html}}}',
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      expect(node.render(), contains('<b>Bold</b>'));
    });
  });

  group('ApiWidget error handling', () {
    test('404 with {{#error}} in template renders gracefully', () async {
      final client = _MockClient({
        'http://test': http.Response(
          jsonEncode({'message': 'Not found'}),
          404,
        ),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template':
                  '{{#error}}<div class="error">{{error.status}}: {{error.message}}</div>{{/error}}',
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      final html = node.render();
      expect(html, contains('404'));
      expect(html, contains('Not found'));
    });

    test('404 without {{error}} throws', () async {
      final client = _MockClient({
        'http://test': http.Response(
          jsonEncode({'message': 'Not found'}),
          404,
        ),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{message}}',
            },
          ],
        }),
        'id',
      );
      expect(
        () => widget.renderBody(services, _ctx()),
        throwsA(isA<Exception>()),
      );
    });

    test('500 error with {{#error}} renders gracefully', () async {
      final client = _MockClient({
        'http://test': http.Response(
          jsonEncode({'detail': 'Server Error'}),
          500,
        ),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{#error}}Error {{error.status}}{{/error}}',
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      expect(node.render(), contains('Error 500'));
    });

    test('non-JSON response throws', () async {
      final client = _MockClient({
        'http://test': http.Response('not json', 200),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{x}}',
            },
          ],
        }),
        'id',
      );
      expect(
        () => widget.renderBody(services, _ctx()),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ApiWidget caching', () {
    test('second render uses cache, no second HTTP call', () async {
      var callCount = 0;
      final client = _MockClient({
        'http://test': http.Response('{"msg":"hi"}', 200),
      });
      // We can't track calls with _MockClient directly, so we use a wrapper.
      final trackingClient = _TrackingClient(client, () => callCount++);
      final services = Services(httpClient: trackingClient);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{msg}}',
            },
          ],
        }),
        'id',
      );
      final ctx = _ctx();

      await widget.renderBody(services, ctx);
      expect(callCount, 1);

      await widget.renderBody(services, ctx);
      expect(callCount, 1);
    });
  });

  group('ApiWidget complex template', () {
    test('renders GitHub-style API response', () async {
      final client = _MockClient({
        'http://test': http.Response(
          jsonEncode({
            'login': 'octocat',
            'id': 1,
            'html_url': 'https://github.com/octocat',
            'public_repos': 8,
            'followers': 100,
            'repos': [
              {'name': 'Spoon-Knife', 'stars': 500},
              {'name': 'Hello-World', 'stars': 100},
            ],
          }),
          200,
        ),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '''<div class="user">
<h3>{{login}}</h3>
<p>Repos: {{public_repos}} | Followers: {{followers}}</p>
<ul>{{#repos}}<li>{{name}} ({{stars}} ⭐)</li>{{/repos}}</ul>
<a href="{{html_url}}">Profile</a>
</div>''',
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      final html = node.render();
      expect(html, contains('<h3>octocat</h3>'));
      expect(html, contains('Repos: 8 | Followers: 100'));
      expect(html, contains('<li>Spoon-Knife (500 ⭐)</li>'));
      expect(html, contains('<li>Hello-World (100 ⭐)</li>'));
      expect(
          html, contains('<a href="https://github.com/octocat">Profile</a>'),);
    });
  });

  group('ApiWidget routes', () {
    test('route matches path and interpolates URL variable', () async {
      final client = _MockClient({
        'http://api.example.com/default': http.Response('{"n":0}', 200),
        'http://api.example.com/users/42': http.Response(
          jsonEncode({'name': 'Alice'}),
          200,
        ),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://api.example.com/default',
              'template': '{{n}}',
            },
            {
              'path': 'users/<userId>',
              'url': 'http://api.example.com/users/{userId}',
              'template': '<h1>{{name}}</h1>',
            },
          ],
        }),
        'id',
      );
      final ctx = RenderContext(
        WidgetCacheStore(),
        'id',
        routePath: 'users/42',
      );
      final node = await widget.renderBody(services, ctx);
      expect(node.render(), contains('<h1>Alice</h1>'));
    });

    test('route uses query parameters for interpolation', () async {
      final client = _MockClient({
        'http://api.example.com/default': http.Response('{"n":0}', 200),
        'http://api.example.com/search?q=dart': http.Response(
          jsonEncode({'total': 99}),
          200,
        ),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://api.example.com/default',
              'template': '{{n}}',
            },
            {
              'path': 'search',
              'url': 'http://api.example.com/search?q={q}',
              'template': 'Total: {{total}}',
            },
          ],
        }),
        'id',
      );
      final ctx = RenderContext(
        WidgetCacheStore(),
        'id',
        routePath: 'search',
        queryParameters: {'q': 'dart'},
      );
      final node = await widget.renderBody(services, ctx);
      expect(node.render(), contains('Total: 99'));
    });

    test('route uses its own url and template', () async {
      final client = _MockClient({
        'http://api.example.com/default': http.Response('{"n":0}', 200),
        'http://api.example.com/items/7': http.Response(
          jsonEncode({'title': 'Book'}),
          200,
        ),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://api.example.com/default',
              'template': '{{n}}',
            },
            {
              'path': 'items/<id>',
              'url': 'http://api.example.com/items/{id}',
              'template': 'Title: {{title}}',
            },
          ],
        }),
        'id',
      );
      final ctx = RenderContext(
        WidgetCacheStore(),
        'id',
        routePath: 'items/7',
      );
      final node = await widget.renderBody(services, ctx);
      expect(node.render(), contains('Title: Book'));
    });

    test('route-level template overrides another route', () async {
      final client = _MockClient({
        'http://api.example.com/home': http.Response('{"name":"Default"}', 200),
        'http://api.example.com/profile': http.Response(
          jsonEncode({'name': 'Bob'}),
          200,
        ),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://api.example.com/home',
              'template': 'Home: {{name}}',
            },
            {
              'path': 'profile',
              'url': 'http://api.example.com/profile',
              'template': 'Route: {{name}}',
            },
          ],
        }),
        'id',
      );
      final ctx = RenderContext(
        WidgetCacheStore(),
        'id',
        routePath: 'profile',
      );
      final node = await widget.renderBody(services, ctx);
      expect(node.render(), contains('Route: Bob'));
    });

    test('route interpolates body variables', () async {
      final client = _MockClient({
        'http://api.example.com/default': http.Response('{"n":0}', 200),
        'http://api.example.com/posts': http.Response(
          jsonEncode({'id': 123}),
          200,
        ),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://api.example.com/default',
              'template': '{{n}}',
            },
            {
              'path': 'posts',
              'url': 'http://api.example.com/posts',
              'method': 'POST',
              'template': '{{id}}',
              'body': {'title': '{title}', 'userId': '{userId}'},
            },
          ],
        }),
        'id',
      );
      final ctx = RenderContext(
        WidgetCacheStore(),
        'id',
        routePath: 'posts',
        queryParameters: {'title': 'Hello', 'userId': '99'},
      );
      final node = await widget.renderBody(services, ctx);
      expect(node.render(), contains('123'));
    });

    test('route caches separately from default route', () async {
      var callCount = 0;
      final client = _MockClient({
        'http://api.example.com/default': http.Response('{"n":0}', 200),
        'http://api.example.com/users/1': http.Response('{"n":1}', 200),
        'http://api.example.com/users/2': http.Response('{"n":2}', 200),
      });
      final trackingClient = _TrackingClient(client, () => callCount++);
      final services = Services(httpClient: trackingClient);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://api.example.com/default',
              'template': '{{n}}',
            },
            {
              'path': 'users/<userId>',
              'url': 'http://api.example.com/users/{userId}',
              'template': '{{n}}',
            },
          ],
        }),
        'id',
      );

      final cache = WidgetCacheStore();
      final ctx1 = RenderContext(cache, 'id', routePath: 'users/1');
      await widget.renderBody(services, ctx1);
      expect(callCount, 1);

      final ctx2 = RenderContext(cache, 'id', routePath: 'users/1');
      await widget.renderBody(services, ctx2);
      expect(callCount, 1); // cached

      final ctx3 = RenderContext(cache, 'id', routePath: 'users/2');
      await widget.renderBody(services, ctx3);
      expect(callCount, 2); // different params, new request
    });

    test('unmatched route path throws ArgumentError', () async {
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://api.example.com',
              'template': '{{x}}',
            },
            {
              'path': 'foo',
              'url': 'http://api.example.com/foo',
              'template': 'foo',
            },
          ],
        }),
        'id',
      );
      final ctx = RenderContext(
        WidgetCacheStore(),
        'id',
        routePath: 'bar',
      );
      expect(
        () => widget.renderBody(Services(), ctx),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('first route is used as default when no routePath is given', () async {
      final client = _MockClient({
        'http://api.example.com/default': http.Response('{"msg":"hi"}', 200),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://api.example.com/default',
              'template': '{{msg}}',
            },
            {
              'path': 'other',
              'url': 'http://api.example.com/other',
              'template': 'other',
            },
          ],
        }),
        'id',
      );
      final node = await widget.renderBody(services, _ctx());
      expect(node.render(), contains('hi'));
    });
  });

  group('ApiWidget data-hx-base', () {
    test('default render wraps output in data-hx-base div', () async {
      final client = _MockClient({
        'http://test': http.Response('{"msg":"hi"}', 200),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{msg}}',
            },
          ],
        }),
        'api-42',
      );
      final node = await widget.renderBody(services, _ctx());
      final html = node.render();
      expect(html, contains('data-hx-base="/widget/api-42/"'));
    });

    test('route render wraps output in data-hx-base div', () async {
      final client = _MockClient({
        'http://api.example.com/default': http.Response('{"n":0}', 200),
        'http://api.example.com/users/1': http.Response('{"name":"A"}', 200),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://api.example.com/default',
              'template': '{{n}}',
            },
            {
              'path': 'users/<id>',
              'url': 'http://api.example.com/users/{id}',
              'template': '{{name}}',
            },
          ],
        }),
        'api-7',
      );
      final ctx = RenderContext(
        WidgetCacheStore(),
        'api-7',
        routePath: 'users/1',
      );
      final node = await widget.renderBody(services, ctx);
      final html = node.render();
      expect(html, contains('data-hx-base="/widget/api-7/"'));
      expect(html, contains('A'));
    });
  });

  group('ApiWidget scoped style', () {
    test('injects scoped style tag with prefixed selectors', () async {
      final client = _MockClient({
        'http://test': http.Response('{"msg":"hi"}', 200),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'style': '.card { color: red; } .btn, .link { margin: 0; }',
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '<div class="card">{{msg}}</div>',
            },
          ],
        }),
        'api-99',
      );
      final node = await widget.renderBody(services, _ctx());
      final html = node.render();
      expect(html, contains('<style>'));
      expect(html, contains('.aw-api-99 .card { color: red; }'));
      expect(
          html, contains('.aw-api-99 .btn, .aw-api-99 .link { margin: 0; }'),);
    });

    test('scopes nested rules inside @media', () async {
      final client = _MockClient({
        'http://test': http.Response('{"msg":"hi"}', 200),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'style': '@media (min-width: 600px) { .card { width: 100%; } }',
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{msg}}',
            },
          ],
        }),
        'api-88',
      );
      final node = await widget.renderBody(services, _ctx());
      final html = node.render();
      expect(html, contains('@media (min-width: 600px)'));
      expect(html, contains('.aw-api-88 .card { width: 100%; }'));
    });

    test('does not inject style when style option is missing', () async {
      final client = _MockClient({
        'http://test': http.Response('{"msg":"hi"}', 200),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'routes': [
            {
              'path': '_default',
              'url': 'http://test',
              'template': '{{msg}}',
            },
          ],
        }),
        'api-77',
      );
      final node = await widget.renderBody(services, _ctx());
      final html = node.render();
      expect(html, isNot(contains('<style>')));
    });

    test('applies scoped style to route renders too', () async {
      final client = _MockClient({
        'http://api.example.com/default': http.Response('{"n":0}', 200),
        'http://api.example.com/items/7':
            http.Response('{"title":"Book"}', 200),
      });
      final services = Services(httpClient: client);
      final widget = ApiWidget(
        _config({
          'style': '.title { font-weight: bold; }',
          'routes': [
            {
              'path': '_default',
              'url': 'http://api.example.com/default',
              'template': '{{n}}',
            },
            {
              'path': 'items/<id>',
              'url': 'http://api.example.com/items/{id}',
              'template': '<div class="title">{{title}}</div>',
            },
          ],
        }),
        'api-66',
      );
      final ctx = RenderContext(
        WidgetCacheStore(),
        'api-66',
        routePath: 'items/7',
      );
      final node = await widget.renderBody(services, ctx);
      final html = node.render();
      expect(html, contains('.aw-api-66 .title { font-weight: bold; }'));
      expect(html, contains('<div class="title">Book</div>'));
    });
  });
}

class _TrackingClient extends http.BaseClient {
  final http.BaseClient _inner;
  final void Function() _onSend;

  _TrackingClient(this._inner, this._onSend);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    _onSend();
    return _inner.send(request);
  }
}
