import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'package:hyper_dashboard/src/cache/widget_cache.dart';
import 'package:hyper_dashboard/src/config/models.dart';
import 'package:hyper_dashboard/src/services/services.dart';
import 'package:hyper_dashboard/src/widgets/reddit/reddit_widget.dart';
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
      type: 'reddit',
      options: options,
    );

RenderContext _ctx() => RenderContext(WidgetCacheStore(), 'test-reddit');

const _rssBody = '''<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
 <title>reddit: the front page of the internet</title>
 <link href="https://www.reddit.com/r/PS3/" rel="alternate" type="text/html"/>
 <entry>
   <author>
     <name>testuser1</name>
   </author>
   <content type="html">&lt;table&gt;&lt;tr&gt;&lt;td&gt;&lt;a href="https://example.com"&gt;&lt;img src="https://preview.redd.it/img1.jpg" alt="" /&gt;&lt;/a&gt;&lt;/td&gt;&lt;/tr&gt;&lt;/table&gt;</content>
   <id>t3_abc1</id>
   <link href="https://www.reddit.com/r/PS3/comments/abc1/post_one/" rel="alternate" type="text/html"/>
   <published>2024-01-15T09:00:00+00:00</published>
   <title>Post One</title>
   <updated>2024-01-15T09:00:00+00:00</updated>
 </entry>
 <entry>
   <author>
     <name>testuser2</name>
   </author>
   <content type="html">&lt;!-- SC_OFF --&gt;&lt;div class="md"&gt;&lt;p&gt;self post text&lt;/p&gt;&lt;/div&gt;&lt;!-- SC_ON --&gt;</content>
   <id>t3_abc2</id>
   <link href="https://www.reddit.com/r/PS3/comments/abc2/post_two/" rel="alternate" type="text/html"/>
   <published>2024-01-14T15:00:00+00:00</published>
   <title>Post Two</title>
   <updated>2024-01-14T15:00:00+00:00</updated>
 </entry>
</feed>''';

void main() {
  group('RedditWidget config validation', () {
    test('shows empty message when subreddit is missing', () async {
      final widget = RedditWidget(_config({}), 'id');
      final node = await widget.renderBody(Services(), _ctx());
      expect(node.render(), contains('No subreddit configured.'));
    });

    test('shows empty message when subreddit is empty string', () async {
      final widget = RedditWidget(_config({'subreddit': ''}), 'id');
      final node = await widget.renderBody(Services(), _ctx());
      expect(node.render(), contains('No subreddit configured.'));
    });
  });

  group('RedditWidget HTTP errors', () {
    test('throws on non-200 status', () async {
      final client = _MockClient({
        'https://www.reddit.com/r/PS3.rss':
            http.Response('Not Found', 404),
      });
      final services = Services(httpClient: client);
      final widget = RedditWidget(_config({'subreddit': 'PS3'}), 'id');

      expect(
        () => widget.renderBody(services, _ctx()),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('RedditWidget rendering', () {
    test('renders items with title, author, and link', () async {
      final client = _MockClient({
        'https://www.reddit.com/r/PS3.rss': http.Response(_rssBody, 200),
      });
      final services = Services(httpClient: client);
      final widget = RedditWidget(_config({'subreddit': 'PS3'}), 'id');
      final node = await widget.renderBody(services, _ctx());
      final html = node.render();

      expect(html, contains('Post One'));
      expect(html, contains('Post Two'));
      expect(html, contains('by u/testuser1'));
      expect(html, contains('by u/testuser2'));
      expect(html, contains('https://www.reddit.com/r/PS3/comments/abc1/post_one/'));
      expect(html, contains('https://www.reddit.com/r/PS3/comments/abc2/post_two/'));
    });

    test('extracts thumbnail from content when present', () async {
      final client = _MockClient({
        'https://www.reddit.com/r/PS3.rss': http.Response(_rssBody, 200),
      });
      final services = Services(httpClient: client);
      final widget = RedditWidget(_config({'subreddit': 'PS3'}), 'id');
      final node = await widget.renderBody(services, _ctx());
      final html = node.render();

      expect(html, contains('https://preview.redd.it/img1.jpg'));
    });

    test('uses empty thumbnail for items with no image in content', () async {
      final client = _MockClient({
        'https://www.reddit.com/r/PS3.rss': http.Response(_rssBody, 200),
      });
      final services = Services(httpClient: client);
      final widget = RedditWidget(_config({'subreddit': 'PS3'}), 'id');
      final node = await widget.renderBody(services, _ctx());
      final html = node.render();

      expect(RegExp(r'<img ').allMatches(html).length, equals(1));
    });

    test('shows empty message when feed has no entries', () async {
      final emptyFeed = '''<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
 <title>reddit: the front page of the internet</title>
 <link href="https://www.reddit.com/r/empty/" rel="alternate" type="text/html"/>
</feed>''';
      final client = _MockClient({
        'https://www.reddit.com/r/empty.rss': http.Response(emptyFeed, 200),
      });
      final services = Services(httpClient: client);
      final widget = RedditWidget(_config({'subreddit': 'empty'}), 'id');
      final node = await widget.renderBody(services, _ctx());
      final html = node.render();

      expect(html, contains('No items found.'));
    });
  });

  group('RedditWidget caching', () {
    test('uses cache for repeated renders', () async {
      var callCount = 0;
      final client = _TrackingClient(
        _MockClient({
          'https://www.reddit.com/r/PS3.rss': http.Response(_rssBody, 200),
        }),
        () => callCount++,
      );
      final services = Services(httpClient: client);
      final widget = RedditWidget(_config({'subreddit': 'PS3'}), 'id');
      final ctx = _ctx();

      await widget.renderBody(services, ctx);
      await widget.renderBody(services, ctx);

      expect(callCount, equals(1));
    });
  });

  group('RedditWidget useChannelImage', () {
    test('does not fall back to channel logo when item has no image', () async {
      final feedWithLogo = '''<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
 <title>reddit: the front page of the internet</title>
 <link href="https://www.reddit.com/r/PS3/" rel="alternate" type="text/html"/>
 <logo>https://www.redditstatic.com/icon.png</logo>
 <entry>
   <author><name>testuser</name></author>
   <content type="html">&lt;p&gt;no image here&lt;/p&gt;</content>
   <id>t3_abc</id>
   <link href="https://www.reddit.com/r/PS3/comments/abc/post/" rel="alternate" type="text/html"/>
   <published>2024-01-15T09:00:00+00:00</published>
   <title>A Post</title>
   <updated>2024-01-15T09:00:00+00:00</updated>
 </entry>
</feed>''';
      final client = _MockClient({
        'https://www.reddit.com/r/PS3.rss': http.Response(feedWithLogo, 200),
      });
      final services = Services(httpClient: client);
      final widget = RedditWidget(_config({'subreddit': 'PS3'}), 'id');
      final node = await widget.renderBody(services, _ctx());
      final html = node.render();

      expect(html, contains('A Post'));
      expect(html, isNot(contains('redditstatic.com')));
    });
  });
}

class _TrackingClient extends http.BaseClient {
  final http.BaseClient _inner;
  final void Function() _onSend;

  _TrackingClient(this._inner, this._onSend);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    _onSend();
    return _inner.send(request);
  }
}
