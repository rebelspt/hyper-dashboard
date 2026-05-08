import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../render_context.dart';
import '../widget.dart';
import 'api.dart';
import 'models.dart';

class WeatherWidget extends DashboardWidget {
  WeatherWidget(super.config, super.id);

  @override
  String get type => 'weather';

  @override
  String get defaultTitle => 'Weather';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final location = config.options['location'] as String? ?? 'London';
    final units = WeatherUnits.from(config.options['units'] as String?);
    final view = WeatherView.from(ctx.queryParameters['view']);
    final date = ctx.queryParameters['date'] ?? '';

    final geo = await ctx.cache.fetch<GeoResult>(
      'geo',
      const Duration(days: 7),
      () => geocode(services, location),
    );

    final data = await ctx.cache.fetch<WeatherData>(
      view.cacheKey(date),
      config.cache,
      () => fetchForecast(services, geo, units),
    );

    if (view == WeatherView.hourly && date.isNotEmpty) {
      return _renderHourly(ctx, data, date, units.tempUnit);
    }
    return _renderDaily(ctx, data, units.tempUnit, units.windUnit);
  }

  // ── Daily view ────────────────────────────────────────────────────────────

  Node _renderDaily(
    RenderContext ctx,
    WeatherData data,
    String tempUnit,
    String windUnit,
  ) {
    final emoji = _weatherEmoji(data.weatherCode);
    final desc = _weatherDesc(data.weatherCode);
    final temp = data.temperature.round();
    final target = '#widget-${ctx.widgetId}';
    final today = DateTime.now();

    final forecastDays = <Node>[];
    for (var i = 0; i < data.dailyTimes.length; i++) {
      final dt = DateTime.parse(data.dailyTimes[i]);
      final isToday = dt.year == today.year &&
          dt.month == today.month &&
          dt.day == today.day;
      final dayName = isToday ? 'Today' : _shortDay(dt.weekday);
      final dayEmoji = _weatherEmoji(data.dailyCodes[i]);
      final lo = data.dailyMin[i].round();
      final hi = data.dailyMax[i].round();

      forecastDays.add(
        div(
          {
            'cls': 'weather-day weather-day--link',
            'hx-get': ctx.url({'view': 'hourly', 'date': data.dailyTimes[i]}),
            'hx-target': target,
            'hx-swap': 'outerHTML',
          },
          [
            span({'cls': 'weather-day-name'}, t(dayName)),
            span({'cls': 'weather-day-icon'}, t(dayEmoji)),
            span({'cls': 'weather-day-range'}, t('$lo–$hi°')),
            span({'cls': 'weather-day-arrow'}, t('›')),
          ],
        ),
      );
    }

    return div(
      {'cls': 'weather'},
      [
        div(
          {'cls': 'weather-current'},
          [
            span({'cls': 'weather-icon'}, t(emoji)),
            span({'cls': 'weather-temp'}, t('$temp°$tempUnit')),
            div(
              {'cls': 'weather-details'},
              [
                span({}, t(desc)),
                span({}, t('💧${data.humidity}%')),
                span({}, t('💨${data.windSpeed.round()} $windUnit')),
              ],
            ),
          ],
        ),
        div({'cls': 'weather-forecast'}, forecastDays),
      ],
    );
  }

  // ── Hourly view ───────────────────────────────────────────────────────────

  Node _renderHourly(
    RenderContext ctx,
    WeatherData data,
    String date,
    String tempUnit,
  ) {
    final target = '#widget-${ctx.widgetId}';

    final dayIndex = data.dailyTimes.indexOf(date);
    final hiLo = dayIndex >= 0
        ? '${data.dailyMin[dayIndex].round()}–${data.dailyMax[dayIndex].round()}°$tempUnit'
        : '';

    final dt = DateTime.tryParse(date);
    final today = DateTime.now();
    final isToday = dt != null &&
        dt.year == today.year &&
        dt.month == today.month &&
        dt.day == today.day;
    final dayLabel = dt == null
        ? date
        : (isToday ? 'Today' : '${_longDay(dt.weekday)}, ${_monthDay(dt)}');

    final rows = <Node>[];
    for (var i = 0; i < data.hourlyTimes.length; i++) {
      final time = data.hourlyTimes[i];
      if (!time.startsWith(date)) continue;
      final hour = int.tryParse(time.substring(11, 13)) ?? 0;
      if (hour % 3 != 0) continue;

      final timeLabel = time.substring(11, 16);
      rows.add(
        div(
          {'cls': 'weather-hour'},
          [
            span({'cls': 'weather-hour-time'}, t(timeLabel)),
            span(
              {'cls': 'weather-hour-icon'},
              t(_weatherEmoji(data.hourlyCodes[i])),
            ),
            span(
              {'cls': 'weather-hour-temp'},
              t('${data.hourlyTemps[i].round()}°'),
            ),
            span(
              {'cls': 'weather-hour-precip'},
              t('💧${data.hourlyPrecip[i]}%'),
            ),
          ],
        ),
      );
    }

    return div(
      {'cls': 'weather'},
      [
        div(
          {'cls': 'weather-nav'},
          [
            button(
              {
                'cls': 'weather-nav-btn',
                'hx-get': ctx.url(),
                'hx-target': target,
                'hx-swap': 'outerHTML',
              },
              '‹',
            ),
            div(
              {'cls': 'weather-nav-title'},
              [
                span({}, t(dayLabel)),
                if (hiLo.isNotEmpty)
                  span({'cls': 'weather-nav-subtitle'}, t(hiLo)),
              ],
            ),
          ],
        ),
        div({'cls': 'weather-hours'}, rows),
      ],
    );
  }

  // ── Render helpers ────────────────────────────────────────────────────────

  String _weatherEmoji(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '🌤️';
    if (code == 45 || code == 48) return '🌫️';
    if (code == 51 ||
        code == 53 ||
        code == 55 ||
        code == 61 ||
        code == 63 ||
        code == 65) {
      return '🌧️';
    }
    if (code == 71 || code == 73 || code == 75 || code == 77) return '❄️';
    if (code == 80 || code == 81 || code == 82) return '🌦️';
    if (code == 85 || code == 86) return '🌨️';
    if (code == 95 || code == 96 || code == 99) return '⛈️';
    return '🌡️';
  }

  String _weatherDesc(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code == 45 || code == 48) return 'Foggy';
    if (code == 51 ||
        code == 53 ||
        code == 55 ||
        code == 61 ||
        code == 63 ||
        code == 65) {
      return 'Rain';
    }
    if (code == 71 || code == 73 || code == 75 || code == 77) return 'Snow';
    if (code == 80 || code == 81 || code == 82) return 'Showers';
    if (code == 85 || code == 86) return 'Snow showers';
    if (code == 95 || code == 96 || code == 99) return 'Thunderstorm';
    return 'Unknown';
  }

  String _shortDay(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1) % 7];
  }

  String _longDay(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[(weekday - 1) % 7];
  }

  String _monthDay(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}
