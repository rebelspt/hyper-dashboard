import 'dart:convert' show jsonDecode;
import '../../services/services.dart';
import 'models.dart';

Future<GeoResult> geocode(Services services, String location) async {
  final encoded = Uri.encodeComponent(location);
  final url =
      'https://geocoding-api.open-meteo.com/v1/search?name=$encoded&count=1&language=en&format=json';
  final resp = await services.httpClient.get(Uri.parse(url));
  if (resp.statusCode != 200) {
    throw Exception('Geocoding HTTP ${resp.statusCode}');
  }
  final body = jsonDecode(resp.body) as Map<String, dynamic>;
  final results = body['results'] as List?;
  if (results == null || results.isEmpty) {
    throw Exception('Location not found: $location');
  }
  final r = results.first as Map<String, dynamic>;
  return GeoResult(
    latitude: (r['latitude'] as num).toDouble(),
    longitude: (r['longitude'] as num).toDouble(),
    name: r['name'] as String? ?? location,
    country: r['country'] as String? ?? '',
  );
}

Future<WeatherData> fetchForecast(
  Services services,
  GeoResult geo,
  WeatherUnits units,
) async {
  final url = 'https://api.open-meteo.com/v1/forecast'
      '?latitude=${geo.latitude}'
      '&longitude=${geo.longitude}'
      '&current=temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m'
      '&daily=temperature_2m_max,temperature_2m_min,weather_code'
      '&hourly=temperature_2m,weather_code,precipitation_probability'
      '&timezone=auto'
      '&forecast_days=7'
      '&wind_speed_unit=${units.apiWindParam}'
      '&temperature_unit=${units.apiTempParam}';

  final resp = await services.httpClient.get(Uri.parse(url));
  if (resp.statusCode != 200) {
    throw Exception('Forecast HTTP ${resp.statusCode}');
  }
  final body = jsonDecode(resp.body) as Map<String, dynamic>;
  final current = body['current'] as Map<String, dynamic>;
  final daily = body['daily'] as Map<String, dynamic>;
  final hourly = body['hourly'] as Map<String, dynamic>;

  return WeatherData(
    temperature: (current['temperature_2m'] as num).toDouble(),
    weatherCode: current['weather_code'] as int,
    humidity: current['relative_humidity_2m'] as int,
    windSpeed: (current['wind_speed_10m'] as num).toDouble(),
    dailyTimes: (daily['time'] as List).cast<String>(),
    dailyMax: (daily['temperature_2m_max'] as List)
        .map((e) => (e as num).toDouble())
        .toList(),
    dailyMin: (daily['temperature_2m_min'] as List)
        .map((e) => (e as num).toDouble())
        .toList(),
    dailyCodes: (daily['weather_code'] as List).cast<int>(),
    hourlyTimes: (hourly['time'] as List).cast<String>(),
    hourlyTemps: (hourly['temperature_2m'] as List)
        .map((e) => (e as num).toDouble())
        .toList(),
    hourlyCodes: (hourly['weather_code'] as List).cast<int>(),
    hourlyPrecip: (hourly['precipitation_probability'] as List)
        .map((e) => (e as num? ?? 0).toInt())
        .toList(),
  );
}
