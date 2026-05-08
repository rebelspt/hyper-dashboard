import '../../config/models.dart';
import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../render_context.dart';
import '../widget.dart';

typedef ChildWidgetFactory = DashboardWidget? Function(
  WidgetConfig config,
  String id,
);

class SplitColumnWidget extends DashboardWidget {
  final ChildWidgetFactory _factory;
  late final List<DashboardWidget> _children;

  SplitColumnWidget(super.config, super.id, this._factory) {
    final rawList = (config.options['widgets'] as List? ?? []).cast<Map>();
    _children = rawList
        .asMap()
        .entries
        .map((e) {
          final m = Map<String, dynamic>.from(e.value.cast<String, dynamic>());
          final childConfig = WidgetConfig(
            type: m['type'] as String? ?? 'unknown',
            title: m['title'] as String?,
            hideHeader: m['hide-header'] as bool? ?? false,
            cache: config.cache,
            refresh: config.refresh,
            options: m,
          );
          return _factory(childConfig, '${id}_c${e.key}');
        })
        .whereType<DashboardWidget>()
        .toList();
  }

  @override
  String get type => 'split-column';

  @override
  String get defaultTitle => 'Split Column';

  @override
  bool get hasCachedData => _children.any((c) => c.hasCachedData);

  @override
  bool get hasStaleData => _children.any((c) => c.hasStaleData);

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    if (_children.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No widgets configured.');
    }

    final maxCols = config.options['max-columns'] as int? ?? 2;

    final rendered = await Future.wait(
      _children.map(
        (child) => child.render(
          services,
          stale: ctx.stale,
          queryParameters: ctx.queryParameters,
        ),
      ),
    );

    return div(
      {'cls': 'split-col', 'style': '--split-cols: $maxCols'},
      rendered.map((node) => div({'cls': 'split-col-item'}, node)).toList(),
    );
  }
}
