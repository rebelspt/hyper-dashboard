import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../components/nodes.dart';
import '../components/filters.dart';
import '../render_context.dart';
import '../widget.dart';
import 'api.dart';
import 'models.dart';

enum MonitorStyle {
  normal,
  compact;

  static MonitorStyle from(String? value) => switch (value) {
        'compact' => MonitorStyle.compact,
        _ => MonitorStyle.normal,
      };

  bool get showIcons => this == MonitorStyle.normal;
}

class MonitorWidget extends DashboardWidget {
  MonitorWidget(super.config, super.id);

  @override
  String get type => 'monitor';

  @override
  String get defaultTitle => 'Monitor';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final monitorStyle = MonitorStyle.from(config.options['style'] as String?);
    final sitesRaw = (config.options['sites'] as List? ?? []).cast<Map>();

    final sites = await ctx.cache.fetch<List<SiteResult>>(
      'sites',
      config.cache,
      () => Future.wait(
        sitesRaw.map(
          (s) => checkSite(
            services,
            title: s['title'] as String? ?? '',
            url: s['url'] as String? ?? '',
            icon: s['icon'] as String?,
          ),
        ),
      ),
    );

    if (sites.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No sites configured.');
    }

    final up = sites.where((s) => s.up).toList();
    final failing = sites.where((s) => !s.up).toList();

    final defaultFilter = ctx.queryParameters['filter'] ?? 'all';

    return filterBar(
      defaultFilter,
      [
        Filter(
          id: 'all',
          label: 'All (${sites.length})',
          content: _buildList(sites, monitorStyle),
        ),
        Filter(
          id: 'up',
          label: 'Up (${up.length})',
          content: _buildList(up, monitorStyle),
        ),
        Filter(
          id: 'failing',
          label: 'Failing (${failing.length})',
          content: _buildList(failing, monitorStyle),
        ),
      ],
      syncParam: 'filter',
    );
  }

  Node _buildList(List<SiteResult> sites, MonitorStyle style) {
    if (sites.isEmpty) {
      return p({'cls': 'widget-empty'}, 'All clear.');
    }
    return ul(
      {'cls': 'monitor-list'},
      sites.map<Node>((site) => _buildRow(site, style)).toList(),
    );
  }

  Node _buildRow(SiteResult site, MonitorStyle style) {
    final dotCls = site.up
        ? 'monitor-dot monitor-dot--up'
        : 'monitor-dot monitor-dot--down';

    final timeLabel =
        site.responseMs != null ? '${site.responseMs}ms' : 'timeout';
    final statusLabel = site.statusCode > 0 ? '${site.statusCode}' : '—';

    return li(
      {'cls': 'monitor-site'},
      [
        span({'cls': dotCls}),
        extLink(
          site.url,
          [
            if (site.icon != null && style.showIcons)
              simpleIcon(site.icon!, cls: 'monitor-icon'),
            t(site.title.isNotEmpty ? site.title : site.url),
          ],
          cls: 'monitor-name',
        ),
        span({'cls': 'monitor-status'}, t(statusLabel)),
        span({'cls': 'monitor-time'}, t(timeLabel)),
      ],
    );
  }
}
