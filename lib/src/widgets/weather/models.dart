enum WeatherUnits {
  metric,
  imperial;

  static WeatherUnits from(String? value) => switch (value) {
        'imperial' => WeatherUnits.imperial,
        _ => WeatherUnits.metric,
      };

  String get tempUnit => switch (this) {
        WeatherUnits.imperial => 'F',
        WeatherUnits.metric => 'C',
      };

  String get windUnit => switch (this) {
        WeatherUnits.imperial => 'mph',
        WeatherUnits.metric => 'km/h',
      };

  String get apiTempParam => switch (this) {
        WeatherUnits.imperial => 'fahrenheit',
        WeatherUnits.metric => 'celsius',
      };

  String get apiWindParam => switch (this) {
        WeatherUnits.imperial => 'mph',
        WeatherUnits.metric => 'kmh',
      };
}

enum WeatherView {
  daily,
  hourly;

  static WeatherView from(String? value) => switch (value) {
        'hourly' => WeatherView.hourly,
        _ => WeatherView.daily,
      };

  String cacheKey(String date) => switch (this) {
        WeatherView.hourly => 'weather-hourly-$date',
        WeatherView.daily => 'weather-daily',
      };
}

class GeoResult {
  final double latitude;
  final double longitude;
  final String name;
  final String country;

  const GeoResult({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.country,
  });
}

class WeatherData {
  final double temperature;
  final int weatherCode;
  final int humidity;
  final double windSpeed;
  final List<String> dailyTimes;
  final List<double> dailyMax;
  final List<double> dailyMin;
  final List<int> dailyCodes;
  final List<String> hourlyTimes;
  final List<double> hourlyTemps;
  final List<int> hourlyCodes;
  final List<int> hourlyPrecip;

  const WeatherData({
    required this.temperature,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeed,
    required this.dailyTimes,
    required this.dailyMax,
    required this.dailyMin,
    required this.dailyCodes,
    required this.hourlyTimes,
    required this.hourlyTemps,
    required this.hourlyCodes,
    required this.hourlyPrecip,
  });
}
