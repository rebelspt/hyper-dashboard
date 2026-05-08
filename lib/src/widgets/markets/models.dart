enum MarketsSortBy {
  none,
  name,
  change,
  absoluteChange;

  static MarketsSortBy from(String? value) => switch (value) {
        'name' => MarketsSortBy.name,
        'change' => MarketsSortBy.change,
        'absolute-change' => MarketsSortBy.absoluteChange,
        _ => MarketsSortBy.none,
      };
}

class MarketItem {
  final String symbol;
  final String name;
  final String currency;
  final double price;
  final double change;
  final double changePct;
  final List<double> chart;

  const MarketItem({
    required this.symbol,
    required this.name,
    required this.currency,
    required this.price,
    required this.change,
    required this.changePct,
    this.chart = const [],
  });
}
