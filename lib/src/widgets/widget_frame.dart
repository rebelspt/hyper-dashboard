import 'package:dartkup/dartkup.dart';

/// Shared HTML frame rendered around every widget.
///
/// All methods return Node — callers never build raw HTML strings.
class WidgetFrame {
  static Node wrap({
    required String id,
    required String widgetPath,
    required String title,
    required int refreshSeconds,
    required Node body,
    bool showHeader = true,
    bool refreshOnLoad = false,
  }) =>
      div(
        {
          'cls': 'widget',
          'id': 'widget-$id',
          if (refreshOnLoad) ...{
            'hx-get': widgetPath,
            'hx-trigger': 'load',
            'hx-swap': 'outerHTML',
          } else if (refreshSeconds > 0) ...{
            'hx-get': widgetPath,
            'hx-trigger': 'every ${refreshSeconds}s',
            'hx-swap': 'outerHTML',
          },
        },
        [
          if (showHeader) _header(title, id, widgetPath),
          div({'cls': 'widget-body'}, body),
        ],
      );

  static Node error({
    required String id,
    required String widgetPath,
    required String title,
    required String message,
    required int refreshSeconds,
  }) =>
      wrap(
        id: id,
        widgetPath: widgetPath,
        title: title,
        refreshSeconds: refreshSeconds,
        body: p({'cls': 'widget-error'}, '⚠ $message'),
      );

  static Node loading({
    required String id,
    required String widgetPath,
    required String title,
  }) =>
      div(
        {
          'cls': 'widget widget--loading',
          'id': 'widget-$id',
          'hx-get': widgetPath,
          'hx-trigger': 'load',
          'hx-swap': 'outerHTML',
        },
        [
          _header(title, id, widgetPath),
          div({
            'cls': 'widget-body',
          }, [
            div({'cls': 'widget-skeleton'}),
            div({'cls': 'widget-skeleton', 'style': 'width:75%'}),
            div({'cls': 'widget-skeleton', 'style': 'width:55%'}),
          ]),
        ],
      );

  static Node _header(String title, String id, String widgetPath) => div(
        {'cls': 'widget-header'},
        [
          span({'cls': 'widget-title'}, t(title)),
          button(
            {
              'cls': 'widget-refresh',
              'hx-get': widgetPath,
              'hx-target': '#widget-$id',
              'hx-swap': 'outerHTML',
              'title': 'Refresh',
            },
            '↻',
          ),
        ],
      );
}
