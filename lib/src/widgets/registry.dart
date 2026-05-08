import '../config/models.dart';
import 'widget.dart';
import 'api/api_widget.dart';
import 'audiobookshelf/audiobookshelf_widget.dart';
import 'docker/docker_widget.dart';
import 'bookmarks/bookmarks_widget.dart';
import 'calendar/calendar_widget.dart';
import 'clock/clock_widget.dart';
import 'group/group_widget.dart';
import 'hacker_news/hacker_news_widget.dart';
import 'html/html_widget.dart';
import 'iframe/iframe_widget.dart';
import 'lobsters/lobsters_widget.dart';
import 'markets/markets_widget.dart';
import 'monitor/monitor_widget.dart';
import 'reddit/reddit_widget.dart';
import 'releases/releases_widget.dart';
import 'repository/repository_widget.dart';
import 'rss/rss_widget.dart';
import 'search/search_widget.dart';
import 'split_column/split_column_widget.dart';
import 'twitch/twitch_channels_widget.dart';
import 'twitch/twitch_top_games_widget.dart';
import 'videos/videos_widget.dart';
import 'weather/weather_widget.dart';

typedef WidgetFactory = DashboardWidget Function(
  WidgetConfig config,
  String id,
);

class WidgetRegistry {
  static final Map<String, WidgetFactory> _factories = {
    'api': (c, id) => ApiWidget(c, id),
    'audiobookshelf': (c, id) => AudiobookshelfWidget(c, id),
    'bookmarks': (c, id) => BookmarksWidget(c, id),
    'calendar': (c, id) => CalendarWidget(c, id),
    'clock': (c, id) => ClockWidget(c, id),
    'group': (c, id) => GroupWidget(c, id, create),
    'docker': (c, id) => DockerWidget(c, id),
    'hacker-news': (c, id) => HackerNewsWidget(c, id),
    'html': (c, id) => HtmlWidget(c, id),
    'iframe': (c, id) => IframeWidget(c, id),
    'lobsters': (c, id) => LobstersWidget(c, id),
    'markets': (c, id) => MarketsWidget(c, id),
    'monitor': (c, id) => MonitorWidget(c, id),
    'reddit': (c, id) => RedditWidget(c, id),
    'releases': (c, id) => ReleasesWidget(c, id),
    'repository': (c, id) => RepositoryWidget(c, id),
    'rss': (c, id) => RssWidget(c, id),
    'search': (c, id) => SearchWidget(c, id),
    'split-column': (c, id) => SplitColumnWidget(c, id, create),
    'twitch-channels': (c, id) => TwitchChannelsWidget(c, id),
    'twitch-top-games': (c, id) => TwitchTopGamesWidget(c, id),
    'videos': (c, id) => VideosWidget(c, id),
    'weather': (c, id) => WeatherWidget(c, id),
  };

  static DashboardWidget? create(WidgetConfig config, String id) =>
      _factories[config.type]?.call(config, id);

  /// Register a custom widget type at runtime.
  static void register(String type, WidgetFactory factory) =>
      _factories[type] = factory;
}
