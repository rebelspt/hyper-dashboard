import '../../config/models.dart';
import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../render_context.dart';
import '../widget.dart';

typedef ChildWidgetFactory = DashboardWidget? Function(
  WidgetConfig config,
  String id,
);

class GroupWidget extends DashboardWidget {
  final ChildWidgetFactory _factory;
  late final List<DashboardWidget> _children;

  GroupWidget(super.config, super.id, this._factory) {
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
  String get type => 'group';

  @override
  String get defaultTitle => 'Group';

  @override
  bool get hasCachedData => _children.any((c) => c.hasCachedData);

  @override
  bool get hasStaleData => _children.any((c) => c.hasStaleData);

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    if (_children.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No widgets configured.');
    }

    final panels = await Future.wait(
      _children.asMap().entries.map((e) async {
        final child = e.value;
        try {
          return await child.renderBody(
            services,
            child.contextFor(
              stale: ctx.stale,
              queryParameters: ctx.queryParameters,
            ),
          );
        } catch (err) {
          return p({'cls': 'widget-error'}, 'Error: $err');
        }
      }),
    );

    final tabs = _children.asMap().entries.map((e) {
      final index = e.key;
      final child = e.value;
      final label = child.config.title ?? child.defaultTitle;
      return button(
        {
          'cls': index == 0 ? 'group-tab group-tab--active' : 'group-tab',
          'data-tab': '$index',
        },
        t(label),
      );
    }).toList();

    final panelDivs = panels.asMap().entries.map((e) {
      final index = e.key;
      final body = e.value;
      return div(
        index == 0
            ? {'cls': 'group-panel'}
            : {'cls': 'group-panel', 'style': 'display:none'},
        body,
      );
    }).toList();

    final js = '''
(function(){
  var tabs = document.querySelectorAll('#group-$id .group-tab');
  var panels = document.querySelectorAll('#group-$id .group-panel');
  tabs.forEach(function(tab, i){
    tab.addEventListener('click', function(){
      tabs.forEach(function(t){ t.classList.remove('group-tab--active'); });
      panels.forEach(function(p){ p.style.display='none'; });
      tab.classList.add('group-tab--active');
      panels[i].style.display='';
    });
  });
}());''';

    return fragment([
      div(
        {'id': 'group-$id'},
        [
          div({'cls': 'group-tabs'}, tabs),
          div({'cls': 'group-panels'}, panelDivs),
        ],
      ),
      script({}, raw(js)),
    ]);
  }
}
