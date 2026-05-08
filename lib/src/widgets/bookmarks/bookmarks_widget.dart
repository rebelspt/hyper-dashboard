import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../components/nodes.dart';
import '../render_context.dart';
import '../widget.dart';

class BookmarksWidget extends DashboardWidget {
  BookmarksWidget(super.config, super.id);

  @override
  String get type => 'bookmarks';

  @override
  String get defaultTitle => 'Bookmarks';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final groups = (config.options['groups'] as List? ?? []).cast<Map>();

    if (groups.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No bookmarks configured.');
    }

    return fragment(groups.map<Node>(_renderGroup).toList());
  }

  Node _renderGroup(Map group) {
    final name = group['name'] as String? ?? '';
    final links = (group['links'] as List? ?? []).cast<Map>();

    return div(
      {'cls': 'bookmark-group'},
      [
        if (name.isNotEmpty) p({'cls': 'bookmark-group-name'}, t(name)),
        ul(
          {'cls': 'bookmark-list'},
          links.map<Node>((link) {
            final label = link['name'] as String? ?? '';
            final url = link['url'] as String? ?? '#';
            final icon = link['icon'] as String?;

            return li(
              {'cls': 'bookmark-item'},
              extLink(url, [
                if (icon != null) simpleIcon(icon, cls: 'bookmark-icon'),
                t(label),
              ]),
            );
          }).toList(),
        ),
      ],
    );
  }
}
