import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../render_context.dart';
import '../widget.dart';

class IframeWidget extends DashboardWidget {
  IframeWidget(super.config, super.id);

  @override
  String get type => 'iframe';

  @override
  String get defaultTitle => 'Iframe';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final source = config.options['source'] as String? ?? '';
    final height = config.options['height'] as int? ?? 400;

    if (source.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No source URL configured.');
    }

    return div(
      {'cls': 'iframe-wrap'},
      el('iframe', {
        'src': source,
        'height': '${height}px',
        'frameborder': '0',
        'scrolling': 'auto',
        'style': 'width:100%',
      }),
    );
  }
}
