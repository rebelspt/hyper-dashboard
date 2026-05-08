import 'package:dartkup/dartkup.dart';

class Filter {
  final String id;
  final String label;
  final Node content;

  const Filter({required this.id, required this.label, required this.content});
}

/// Renders a pill-style filter bar backed by Alpine.js client-side state.
///
/// [defaultFilter] must match one of the [filterList] ids.
/// Non-default panels get [x-cloak] to prevent a flash before Alpine hides them.
///
/// Pass [syncParam] to keep state alive across HTMX auto-refreshes: the active
/// filter value is injected into every HTMX request via `htmx:configRequest`
/// so the server re-renders with the correct default on the next refresh cycle.
Node filterBar(
  String defaultFilter,
  List<Filter> filterList, {
  String? syncParam,
}) {
  return div({
    'x-data': "{ filter: '$defaultFilter' }",
    if (syncParam != null) 'data-htmx-sync': syncParam,
  }, [
    div(
      {'cls': 'filter-bar'},
      filterList
          .map(
            (f) => el(
              'button',
              {
                'cls': 'filter-btn',
                '@click': "filter = '${f.id}'",
                ':class': "{ 'filter-btn--active': filter === '${f.id}' }",
              },
              f.label,
            ),
          )
          .toList(),
    ),
    ...filterList.map(
      (f) => div(
        {
          'cls': 'filter-panel',
          'x-show': "filter === '${f.id}'",
          if (f.id != defaultFilter) 'x-cloak': null,
        },
        [f.content],
      ),
    ),
  ]);
}
