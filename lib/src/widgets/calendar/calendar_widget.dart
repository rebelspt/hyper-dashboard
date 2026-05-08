import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../render_context.dart';
import '../widget.dart';

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

enum WeekStart {
  monday,
  sunday;

  static WeekStart from(String? value) =>
      value?.toLowerCase() == 'sunday' ? WeekStart.sunday : WeekStart.monday;

  List<String> get dayNames => switch (this) {
        WeekStart.sunday => ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
        WeekStart.monday => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      };

  int leadingCount(int firstWeekday) => switch (this) {
        WeekStart.sunday => firstWeekday % 7,
        WeekStart.monday => firstWeekday - 1,
      };
}

class CalendarWidget extends DashboardWidget {
  CalendarWidget(super.config, super.id);

  @override
  String get type => 'calendar';

  @override
  String get defaultTitle => 'Calendar';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final weekStart =
        WeekStart.from(config.options['first-day-of-week'] as String?);

    final today = DateTime.now();
    final year = ctx.queryParameters.intOr('year', today.year);
    final month = ctx.queryParameters.intOr('month', today.month);

    final prevDate = DateTime(year, month - 1, 1);
    final nextDate = DateTime(year, month + 1, 1);
    final target = '#widget-${ctx.widgetId}';

    final nav = div(
      {'cls': 'cal-nav'},
      [
        button(
          {
            'cls': 'cal-nav-btn',
            'hx-get': ctx.url(
              {'year': '${prevDate.year}', 'month': '${prevDate.month}'},
            ),
            'hx-target': target,
            'hx-swap': 'outerHTML',
          },
          '‹',
        ),
        span({'cls': 'cal-nav-title'}, t('${_monthNames[month - 1]} $year')),
        button(
          {
            'cls': 'cal-nav-btn',
            'hx-get': ctx.url(
              {'year': '${nextDate.year}', 'month': '${nextDate.month}'},
            ),
            'hx-target': target,
            'hx-swap': 'outerHTML',
          },
          '›',
        ),
      ],
    );

    final headerCells = weekStart.dayNames
        .map<Node>((d) => div({'cls': 'cal-day-name'}, t(d)))
        .toList();

    final firstOfMonth = DateTime(year, month, 1);
    final lastOfMonth = DateTime(year, month + 1, 0);
    final leading = weekStart.leadingCount(firstOfMonth.weekday);

    final cells = <Node>[];

    final prevMonthLastDay = DateTime(year, month, 0).day;
    for (int i = leading - 1; i >= 0; i--) {
      final day = prevMonthLastDay - i;
      cells.add(div({'cls': 'cal-day cal-other-month'}, t('$day')));
    }

    for (int day = 1; day <= lastOfMonth.day; day++) {
      final isToday =
          day == today.day && month == today.month && year == today.year;
      final cls = isToday ? 'cal-day cal-today' : 'cal-day';
      cells.add(div({'cls': cls}, t('$day')));
    }

    final remainder = cells.length % 7;
    final trailingCount = remainder == 0 ? 0 : 7 - remainder;
    for (int day = 1; day <= trailingCount; day++) {
      cells.add(div({'cls': 'cal-day cal-other-month'}, t('$day')));
    }

    return fragment([
      nav,
      div({'cls': 'cal-grid'}, [...headerCells, ...cells]),
    ]);
  }
}
