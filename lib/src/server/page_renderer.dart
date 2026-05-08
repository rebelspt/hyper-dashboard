import '../config/models.dart';
import 'package:dartkup/dartkup.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import '../widgets/widget.dart';
import 'player.dart';

class PageRenderer {
  final DashboardConfig config;

  /// Maps each WidgetConfig instance to its widget (by object identity).
  final Map<WidgetConfig, DashboardWidget> widgetsByConfig;

  final Services services;

  PageRenderer(this.config, this.widgetsByConfig, this.services);

  Future<Node> renderPage(int pageIndex) async {
    final idx = pageIndex.clamp(0, config.pages.length - 1);
    final page = config.pages[idx];

    final columns = await Future.wait(page.columns.map(_renderColumn));

    return htmlDoc(
      lang: 'en',
      head: [
        meta({'charset': 'UTF-8'}),
        meta({
          'name': 'viewport',
          'content': 'width=device-width, initial-scale=1.0',
        }),
        meta({'name': 'referrer', 'content': 'no-referrer'}),
        el('title', {}, t('Dashboard — ${page.name}')),
        script({'src': 'https://unpkg.com/htmx.org@1.9.12', 'defer': null}),
        script({'src': '/assets/playlist.js', 'defer': null}),
        script({'src': '/assets/clock.js', 'defer': null}),
        script({'src': '/assets/api-widget.js', 'defer': null}),
        script({'src': '/assets/htmx-alpine-sync.js', 'defer': null}),
        script({
          'src': 'https://cdn.jsdelivr.net/npm/alpinejs@3/dist/cdn.min.js',
          'defer': null,
        }),
        style({}, t(ThemeRenderer.toCss(config.theme))),
      ],
      body: [
        header(
          {'cls': 'header'},
          div(
            {'cls': 'header-inner'},
            [
              span({'cls': 'header-logo'}, 'Dashboard'),
              _nav(idx),
            ],
          ),
        ),
        mainEl({'cls': 'main'}, div({'cls': 'columns'}, columns)),
        playerNode(),
        minibarNode(),
      ],
    );
  }

  /// Returns a partial fragment for HTMX navigation requests.
  Future<Node> renderPartial(int pageIndex) async {
    final idx = pageIndex.clamp(0, config.pages.length - 1);
    final page = config.pages[idx];

    final columns = await Future.wait(page.columns.map(_renderColumn));

    return fragment([
      div({'cls': 'columns'}, columns),
      if (config.pages.length > 1)
        div(
          {'id': 'main-nav', 'cls': 'nav-tabs', 'hx-swap-oob': 'true'},
          _navLinks(idx),
        ),
    ]);
  }

  Node _nav(int activeIdx) {
    if (config.pages.length <= 1) return fragment(const []);
    return div({'id': 'main-nav', 'cls': 'nav-tabs'}, _navLinks(activeIdx));
  }

  List<Node> _navLinks(int activeIdx) =>
      config.pages.indexed.map<Node>((entry) {
        final (i, page) = entry;
        return a(
          {
            'href': '/?page=$i',
            'cls': i == activeIdx ? 'nav-tab nav-tab--active' : 'nav-tab',
            'hx-get': '/?page=$i',
            'hx-target': 'main',
            'hx-swap': 'innerHTML',
            'hx-push-url': 'true',
          },
          t(page.name),
        );
      }).toList();

  Future<Node> _renderColumn(ColumnConfig col) async {
    final parts = await Future.wait<Node>(
      col.widgets.map((wc) async {
        final widget = widgetsByConfig[wc];
        if (widget == null) return FragmentNode(const []);
        if (wc.asyncPolicy == 'always') return widget.renderPlaceholder();
        if (wc.asyncPolicy == 'stale') {
          if (!widget.hasCachedData) return widget.renderPlaceholder();
          if (widget.hasStaleData) return widget.render(services, stale: true);
          return widget.render(services);
        }
        return widget.render(services);
      }),
    );
    return div({'cls': 'column column--${col.size}'}, parts);
  }
}
