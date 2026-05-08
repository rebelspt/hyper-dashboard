import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../components/filters.dart';
import '../components/tabs.dart';
import '../render_context.dart';
import '../widget.dart';
import 'api.dart';
import 'models.dart';

class DockerWidget extends DashboardWidget {
  DockerWidget(super.config, super.id);

  @override
  String get type => 'docker';

  @override
  String get defaultTitle => 'Docker';

  @override
  QueryParams persistentParams(QueryParams incoming) {
    return Map<String, String>.from(incoming)
      ..remove('action')
      ..remove('container');
  }

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final socketUrl =
        config.options['socket'] as String? ?? 'unix:///var/run/docker.sock';
    final limit = config.options['limit'] as int? ?? 20;
    final client = DockerClient(socketUrl, services);

    final action = ctx.queryParameters['action'];
    final containerId = ctx.queryParameters['container'];
    final viewId = ctx.queryParameters['view'];

    if (action != null && containerId != null) {
      try {
        await client.performAction(containerId, action);
      } catch (_) {}
      ctx.cache.invalidate('containers-all');
    }

    if (viewId != null) {
      return _renderDetailView(client, viewId, ctx);
    }

    final containers = await ctx.cache.fetch<List<DockerContainer>>(
      'containers-all',
      config.cache,
      () => client.listContainers(true),
    );

    final items = containers.take(limit).toList();
    final running = items.where((c) => c.status.canStop).toList();

    if (items.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No containers found.');
    }

    final defaultFilter = ctx.queryParameters['filter'] ?? 'all';

    return filterBar(
      defaultFilter,
      [
        Filter(
          id: 'all',
          label: 'All (${items.length})',
          content: _buildContainerList(items, ctx),
        ),
        Filter(
          id: 'running',
          label: 'Running (${running.length})',
          content: _buildContainerList(running, ctx),
        ),
      ],
      syncParam: 'filter',
    );
  }

  // ── List view ─────────────────────────────────────────────────────��──────────

  Node _buildContainerList(
    List<DockerContainer> containers,
    RenderContext ctx,
  ) {
    if (containers.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No containers.');
    }
    return ul(
      {'cls': 'docker-list'},
      containers.map((c) => _renderContainer(c, ctx)).toList(),
    );
  }

  Node _renderContainer(DockerContainer c, RenderContext ctx) {
    return li({
      'cls': 'docker-item',
    }, [
      el(
        'button',
        {
          'cls': 'docker-item-btn',
          'hx-get': ctx.url({'view': c.id}),
          'hx-target': '#widget-$id',
          'hx-swap': 'outerHTML',
        },
        [
          span({'cls': 'docker-status docker-status--${c.status.cssMod}'}),
          div({
            'cls': 'docker-info',
          }, [
            span({'cls': 'docker-name'}, c.name),
            span({'cls': 'docker-image'}, c.image),
            if (c.statusText.isNotEmpty)
              span({'cls': 'docker-uptime'}, c.statusText),
          ]),
        ],
      ),
      div({
        'cls': 'docker-actions',
      }, [
        if (c.status.canStart)
          _actionBtn('Start', ctx.url({'action': 'start', 'container': c.id})),
        if (c.status.canStop) ...[
          _actionBtn('Stop', ctx.url({'action': 'stop', 'container': c.id})),
          _actionBtn(
            'Restart',
            ctx.url({'action': 'restart', 'container': c.id}),
          ),
        ],
      ]),
    ]);
  }

  Node _actionBtn(String label, String url) {
    return el(
      'button',
      {
        'cls': 'docker-action-btn',
        'hx-get': url,
        'hx-target': '#widget-$id',
        'hx-swap': 'outerHTML',
      },
      label,
    );
  }

  // ── Detail view ─────────────────────────────────────────────────────────────

  Future<Node> _renderDetailView(
    DockerClient client,
    String viewId,
    RenderContext ctx,
  ) async {
    final allContainers = await ctx.cache.fetch<List<DockerContainer>>(
      'containers-all',
      config.cache,
      () => client.listContainers(true),
    );

    DockerContainer? container;
    for (final c in allContainers) {
      if (c.id == viewId) {
        container = c;
        break;
      }
    }
    if (container == null) {
      return p({'cls': 'widget-error'}, 'Container not found.');
    }

    final logsFuture = client.fetchLogs(viewId, 200);
    final inspectFuture = client.inspectContainer(viewId);
    final logs = await logsFuture;
    final inspect = await inspectFuture;

    final defaultTab = ctx.queryParameters['tab'] ?? 'logs';

    return div({
      'cls': 'docker-detail',
    }, [
      _renderDetailHeader(container, ctx),
      tabPanel(
        defaultTab,
        [
          Tab(id: 'logs', label: 'Logs', content: _buildLogContent(logs)),
          Tab(
            id: 'info',
            label: 'Info',
            content: _buildInfoContent(container, inspect),
          ),
        ],
        syncParam: 'tab',
      ),
    ]);
  }

  Node _renderDetailHeader(DockerContainer c, RenderContext ctx) {
    return div({
      'cls': 'docker-detail-header',
    }, [
      el(
        'button',
        {
          'cls': 'docker-back-btn',
          'hx-get': ctx.url(),
          'hx-target': '#widget-$id',
          'hx-swap': 'outerHTML',
        },
        '← Back',
      ),
      div({
        'cls': 'docker-detail-title',
      }, [
        span({'cls': 'docker-status docker-status--${c.status.cssMod}'}),
        t(c.name),
      ]),
    ]);
  }

  Node _buildLogContent(List<String> logs) {
    return div({
      'cls': 'docker-log-view',
      'x-init': r'$nextTick(() => { $el.scrollTop = $el.scrollHeight })',
    }, [
      el(
        'pre',
        {'cls': 'docker-log-output'},
        logs.isEmpty
            ? [t('No logs available.')]
            : logs.map((l) => fragment([t(l), raw('\n')])).toList(),
      ),
    ]);
  }

  Node _buildInfoContent(DockerContainer c, Map<String, dynamic> inspect) {
    final state = (inspect['State'] as Map<String, dynamic>?) ?? {};
    final network = (inspect['NetworkSettings'] as Map<String, dynamic>?) ?? {};
    final ports = (network['Ports'] as Map<String, dynamic>?) ?? {};
    final mounts =
        (inspect['Mounts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final created = inspect['Created'] as String? ?? '';
    final startedAt = state['StartedAt'] as String? ?? '';
    final isRunning = state['Running'] as bool? ?? false;

    final rows = <Node>[];

    void row(String label, String value) {
      if (value.isEmpty) return;
      rows.add(
        div(
          {'cls': 'docker-info-row'},
          [
            span({'cls': 'docker-info-label'}, label),
            span({'cls': 'docker-info-value'}, value),
          ],
        ),
      );
    }

    row('ID', c.shortId);
    row('Image', c.image);
    row('Status', c.statusText.isNotEmpty ? c.statusText : c.status.label);
    if (created.isNotEmpty) row('Created', _formatIso(created));
    if (isRunning && startedAt.isNotEmpty) {
      row('Started', _formatIso(startedAt));
    }

    final portLines = <String>[];
    for (final entry in ports.entries) {
      final bindings =
          (entry.value as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final b in bindings) {
        final hostPort = b['HostPort'] as String? ?? '';
        if (hostPort.isNotEmpty) portLines.add('$hostPort → ${entry.key}');
      }
    }
    if (portLines.isNotEmpty) row('Ports', portLines.join(', '));

    if (mounts.isNotEmpty) {
      final mountLines = mounts.map((m) {
        final src = m['Source'] as String? ?? '';
        final dst = m['Destination'] as String? ?? '';
        return '$src:$dst';
      }).join('\n');
      row('Mounts', mountLines);
    }

    return div({
      'cls': 'docker-info-view',
    }, [
      div({'cls': 'docker-info-table'}, rows),
    ]);
  }

  static String _formatIso(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final y = dt.year;
      final mo = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      final h = dt.hour.toString().padLeft(2, '0');
      final mi = dt.minute.toString().padLeft(2, '0');
      return '$y-$mo-$d $h:$mi';
    } catch (_) {
      return iso;
    }
  }
}
