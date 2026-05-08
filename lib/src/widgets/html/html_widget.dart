import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../render_context.dart';
import '../widget.dart';

class HtmlWidget extends DashboardWidget {
  HtmlWidget(super.config, super.id);

  @override
  String get type => 'html';

  @override
  String get defaultTitle => 'HTML';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final source = config.options['source'] as String? ?? '';

    return div({'cls': 'html-content'}, raw(source));
  }
}
