import 'dart:convert';

import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../render_context.dart';
import '../widget.dart';

class ClockWidget extends DashboardWidget {
  ClockWidget(super.config, super.id);

  @override
  String get type => 'clock';

  @override
  String get defaultTitle => 'Time';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final tzList = (config.options['timezones'] as List?)?.cast<Map>();
    final hourFormat = config.options['hour_format'] as String? ?? '24';
    if (tzList != null && tzList.isNotEmpty) {
      return _renderMulti(tzList, hourFormat);
    }
    final tz = config.options['timezone'] as String? ?? 'UTC';
    return _renderSingle(tz, hourFormat);
  }

  // ── Single clock ────────────────────────────────────────────────────────────

  Node _renderSingle(String tz, String hourFormat) {
    return el(
      'hyper-dashboard-clock',
      {
        'timezone': tz,
        'hour-format': hourFormat,
      },
      [],
    );
  }

  // ── Multi-timezone list ─────────────────────────────────────────────────────

  Node _renderMulti(List<Map> tzList, String hourFormat) {
    final timezones = tzList.map((tz) {
      final timezone = tz['timezone'] as String? ?? 'UTC';
      final label = tz['label'] as String? ?? timezone;
      return {'timezone': timezone, 'label': label};
    }).toList();

    return el(
      'hyper-dashboard-clock',
      {
        'timezones': jsonEncode(timezones),
        'hour-format': hourFormat,
      },
      [],
    );
  }
}
