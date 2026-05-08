import 'dart:convert' show jsonDecode;
import '../../services/services.dart';
import 'models.dart';

Future<MarketItem?> fetchSymbol(
  Services services,
  String symbol,
  String name,
) async {
  final url =
      'https://query2.finance.yahoo.com/v8/finance/chart/$symbol?range=1d&interval=5m&includePrePost=false';
  final resp = await services.httpClient.get(
    Uri.parse(url),
    headers: {'User-Agent': 'Mozilla/5.0 (compatible; hyper-dashboard/1.0)'},
  );
  if (resp.statusCode != 200) {
    throw Exception('HTTP ${resp.statusCode} for $symbol');
  }

  final body = jsonDecode(resp.body) as Map<String, dynamic>;
  final chart = body['chart'] as Map<String, dynamic>?;
  final resultList = chart?['result'] as List?;
  if (resultList == null || resultList.isEmpty) return null;

  final result = resultList.first as Map<String, dynamic>;
  final meta = result['meta'] as Map<String, dynamic>?;
  if (meta == null) return null;

  final price = (meta['regularMarketPrice'] as num?)?.toDouble() ?? 0.0;
  final prevClose = (meta['chartPreviousClose'] as num?)?.toDouble() ?? 0.0;
  final change = price - prevClose;
  final changePct = prevClose != 0 ? change / prevClose * 100 : 0.0;
  final currency = (meta['currency'] as String?) ?? '';

  final indicators = result['indicators'] as Map<String, dynamic>?;
  final quoteList = indicators?['quote'] as List?;
  final closes = (quoteList?.first as Map<String, dynamic>?)?['close'] as List?;
  final chartData =
      closes?.whereType<num>().map((v) => v.toDouble()).toList() ?? [];

  return MarketItem(
    symbol: symbol,
    name: name,
    currency: currency,
    price: price,
    change: change,
    changePct: changePct,
    chart: chartData,
  );
}
