import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../render_context.dart';
import '../widget.dart';

class _EngineConfig {
  final String name;
  final String url;

  _EngineConfig({
    required this.name,
    required this.url,
  });

  bool get isTemplate => url.contains('{QUERY}');
}

class SearchWidget extends DashboardWidget {
  SearchWidget(super.config, super.id);

  @override
  String get type => 'search';

  @override
  String get defaultTitle => 'Search';

  @override
  QueryParams persistentParams(QueryParams incoming) {
    final engine = incoming['engine'];
    if (engine != null) return {'engine': engine};
    return const {};
  }

  List<_EngineConfig> _parseEngines() {
    final enginesList = config.options['engines'] as List?;
    if (enginesList != null && enginesList.isNotEmpty) {
      return enginesList.cast<Map>().map((e) {
        return _EngineConfig(
          name: e['name'] as String? ?? 'Search',
          url: e['url'] as String? ?? '',
        );
      }).where((e) => e.url.isNotEmpty).toList();
    }

    final searchEngine = config.options['search-engine'] as String?;
    if (searchEngine != null && searchEngine.isNotEmpty) {
      return [_EngineConfig(name: 'Search', url: searchEngine)];
    }

    return const [];
  }

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final engines = _parseEngines();
    if (engines.isEmpty) {
      return div({'cls': 'widget-empty'}, t('No search engines configured'));
    }

    final autofocus = config.options['autofocus'] as bool? ?? false;
    final placeholder = config.options['placeholder'] as String? ?? 'Search…';
    final bangsRaw = (config.options['bangs'] as List? ?? []).cast<Map>();

    final inputId = 'search-input-$id';
    final formId = 'search-form-$id';

    // Active engine: query param takes priority, then default-engine config,
    // then the first engine in the list.
    final activeEngineName = ctx.queryParameters['engine'] ??
        config.options['default-engine'] as String?;
    final activeEngine = engines.firstWhere(
      (e) => e.name == activeEngineName,
      orElse: () => engines.first,
    );

    // Preserved query from HTMX engine switch
    final preservedQuery = ctx.queryParameters['q'] ?? '';

    final bangs = bangsRaw
        .map(
          (b) => (
            title: b['title'] as String? ?? '',
            shortcut: b['shortcut'] as String? ?? '',
            url: b['url'] as String? ?? '',
          ),
        )
        .where((b) => b.shortcut.isNotEmpty && b.url.isNotEmpty)
        .toList();

    final bangsJson = _bangsJson(bangs);
    final engineUrl = _jsStr(activeEngine.url);

    final xData = '{'
        'bangs: $bangsJson,'
        'engineUrl: $engineUrl,'
        'handleSubmit(e) {'
        '  var input = this.\$refs.q;'
        '  var val = input.value.trim();'
        '  for (var i = 0; i < this.bangs.length; i++) {'
        '    var b = this.bangs[i];'
        '    var prefix = b.shortcut + " ";'
        '    if (val === b.shortcut || val.indexOf(prefix) === 0) {'
        '      e.preventDefault();'
        '      var query = val === b.shortcut ? "" : val.slice(prefix.length);'
        '      var url = b.url.replace("{QUERY}", encodeURIComponent(query));'
        '      window.open(url, "_blank");'
        '      input.value = "";'
        '      return;'
        '    }'
        '  }'
        '  if (this.engineUrl.indexOf("{QUERY}") !== -1) {'
        '    e.preventDefault();'
        '    var url = this.engineUrl.replace("{QUERY}", encodeURIComponent(val));'
        '    window.open(url, "_blank");'
        '    input.value = "";'
        '  }'
        '}'
        '}';

    // Engine toggle buttons (HTMX-driven server round-trip)
    // Placed OUTSIDE the form so they never submit it.
    Node? engineButtons;
    if (engines.length > 1) {
      engineButtons = div(
        {'cls': 'search-engines'},
        engines.map((e) {
          final isActive = e.name == activeEngine.name;
          return el(
            'button',
            {
              'type': 'button',
              'cls':
                  'search-engine-btn${isActive ? ' search-engine-btn--active' : ''}',
              'hx-get': ctx.url({'engine': e.name}),
              'hx-target': 'closest .widget',
              'hx-swap': 'outerHTML',
              'hx-include': '#$inputId',
            },
            [t(e.name)],
          );
        }).toList(),
      );
    }

    // Wrap form + buttons in .search-widget so everything is
    // spaced consistently with gap: 0.75rem, and engine buttons live
    // outside the form so they can never trigger submission.
    return fragment([
      div({'cls': 'search-widget'}, [
        el('form', {
          'cls': 'search-form',
          'action': activeEngine.isTemplate ? '#' : activeEngine.url,
          'method': 'get',
          'target': '_blank',
          'id': formId,
          'x-data': xData,
          '@submit': 'handleSubmit(\$event)',
        }, [
          el('input', {
            'x-ref': 'q',
            'cls': 'search-input',
            'type': 'text',
            'name': 'q',
            'id': inputId,
            'placeholder': placeholder,
            if (preservedQuery.isNotEmpty) 'value': preservedQuery,
            if (autofocus) 'autofocus': null,
            'autocomplete': 'off',
            'autocorrect': 'off',
            'autocapitalize': 'off',
            'spellcheck': 'false',
          }),
        ]),
        if (engineButtons != null) engineButtons,
      ]),
    ]);
  }

  String _bangsJson(List<({String title, String shortcut, String url})> bangs) {
    final entries = bangs.map((b) {
      return '{"shortcut":${_jsStr(b.shortcut)},"url":${_jsStr(b.url)}}';
    }).join(',');
    return '[$entries]';
  }

  String _jsStr(String s) {
    return '"${s.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';
  }
}
