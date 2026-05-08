import 'package:dartkup/dartkup.dart';

class Tab {
  final String id;
  final String label;
  final Node content;

  const Tab({required this.id, required this.label, required this.content});
}

/// Renders a client-side tabbed panel backed by Alpine.js.
///
/// [defaultTab] must match one of the [tabList] ids.
/// Non-default panels get [x-cloak] to prevent a flash before Alpine hides them.
///
/// Pass [syncParam] to keep state alive across HTMX auto-refreshes: the active
/// tab value is injected into every HTMX request via `htmx:configRequest`
/// so the server re-renders with the correct default on the next refresh cycle.
Node tabPanel(String defaultTab, List<Tab> tabList, {String? syncParam}) {
  return div({
    'cls': 'tabs',
    'x-data': "{ tab: '$defaultTab' }",
    if (syncParam != null) 'data-htmx-sync': syncParam,
  }, [
    div(
      {'cls': 'tabs-bar'},
      tabList
          .map(
            (t) => el(
              'button',
              {
                'cls': 'tab-btn',
                '@click': "tab = '${t.id}'",
                ':class': "{ 'tab-btn--active': tab === '${t.id}' }",
              },
              t.label,
            ),
          )
          .toList(),
    ),
    ...tabList.map(
      (t) => div(
        {
          'cls': 'tab-panel',
          'x-show': "tab === '${t.id}'",
          if (t.id != defaultTab) 'x-cloak': null,
        },
        [t.content],
      ),
    ),
  ]);
}
