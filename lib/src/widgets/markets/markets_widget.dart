import 'dart:math' as math;
import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../render_context.dart';
import '../widget.dart';
import 'api.dart';
import 'models.dart';

class MarketsWidget extends DashboardWidget {
  MarketsWidget(super.config, super.id);

  @override
  String get type => 'markets';

  @override
  String get defaultTitle => 'Markets';

  String _formatPrice(MarketItem item) {
    final code = item.currency.isEmpty ? '' : '${item.currency} ';
    return '$code${item.price.toStringAsFixed(2)}';
  }

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final sortBy = MarketsSortBy.from(config.options['sort-by'] as String?);

    final items = await ctx.cache
        .fetch<List<MarketItem>>('quotes', config.cache, () async {
      final marketDefs = _marketList();
      final results = <MarketItem>[];

      await Future.wait(
        marketDefs.map((m) async {
          try {
            final item = await fetchSymbol(services, m['symbol']!, m['name']!);
            if (item != null) results.add(item);
          } catch (_) {}
        }),
      );

      switch (sortBy) {
        case MarketsSortBy.name:
          results.sort((a, b) => a.name.compareTo(b.name));
        case MarketsSortBy.change:
          results.sort((a, b) => b.changePct.compareTo(a.changePct));
        case MarketsSortBy.absoluteChange:
          results.sort((a, b) => b.change.abs().compareTo(a.change.abs()));
        case MarketsSortBy.none:
          break;
      }

      return results;
    });

    if (items.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No market data available.');
    }

    return ul(
      {'cls': 'markets-list'},
      items.map((item) {
        final isPos = item.change >= 0;
        final sign = isPos ? '+' : '';
        final changeCls = isPos
            ? 'markets-change markets-change--pos'
            : 'markets-change markets-change--neg';

        return li(
          {'cls': 'markets-item'},
          [
            span({'cls': 'markets-name'}, t(item.name)),
            span({'cls': 'markets-spark'}, _buildSparkline(item.chart, isPos)),
            span({'cls': 'markets-price'}, t(_formatPrice(item))),
            span(
              {'cls': changeCls},
              t('$sign${item.changePct.toStringAsFixed(2)}%'),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<Map<String, String>> _marketList() {
    final raw = config.options['markets'];
    if (raw is! List) return const [];
    return raw
        .cast<Map>()
        .map(
          (m) => {
            'symbol': (m['symbol'] as String?) ?? '',
            'name': (m['name'] as String?) ?? (m['symbol'] as String?) ?? '',
          },
        )
        .toList();
  }

  Node _buildSparkline(List<double> data, bool positive) {
    const w = 80.0;
    const h = 32.0;
    const pad = 2.0;
    final color = positive ? '#4ade80' : '#f87171';

    if (data.length < 2) {
      return raw(
        '<svg class="markets-spark-svg" viewBox="0 0 80 32" preserveAspectRatio="none"></svg>',
      );
    }

    final minV = data.reduce(math.min);
    final maxV = data.reduce(math.max);
    final range = (maxV - minV).abs();

    double xOf(int i) => pad + (i / (data.length - 1)) * (w - 2 * pad);
    double yOf(double v) =>
        range == 0 ? h / 2 : pad + (1.0 - (v - minV) / range) * (h - 2 * pad);

    final pts = List.generate(
      data.length,
      (i) => '${xOf(i).toStringAsFixed(1)},${yOf(data[i]).toStringAsFixed(1)}',
    );

    final polyPts = pts.join(' ');
    final fillPath = [
      'M ${pts.first}',
      ...pts.skip(1).map((p) => 'L $p'),
      'L ${xOf(data.length - 1).toStringAsFixed(1)},${(h - pad).toStringAsFixed(1)}',
      'L ${xOf(0).toStringAsFixed(1)},${(h - pad).toStringAsFixed(1)}',
      'Z',
    ].join(' ');

    return raw(
      '<svg class="markets-spark-svg" viewBox="0 0 80 32" preserveAspectRatio="none">'
      '<path d="$fillPath" fill="$color" fill-opacity="0.15"/>'
      '<polyline points="$polyPts" fill="none" stroke="$color" stroke-width="1.5"'
      ' stroke-linecap="round" stroke-linejoin="round"/>'
      '</svg>',
    );
  }
}
