class DashboardConfig {
  final ThemeConfig theme;
  final List<PageConfig> pages;

  const DashboardConfig({required this.theme, required this.pages});
}

class ThemeConfig {
  final String background;
  final String surface;
  final String border;
  final String text;
  final String textMuted;
  final String accent;
  final String font;
  final String radius;

  const ThemeConfig({
    this.background = '#1a1b26',
    this.surface = '#24283b',
    this.border = '#414868',
    this.text = '#c0caf5',
    this.textMuted = '#565f89',
    this.accent = '#7aa2f7',
    this.font = 'Inter, system-ui, sans-serif',
    this.radius = '8px',
  });
}

class PageConfig {
  final String name;
  final List<ColumnConfig> columns;

  const PageConfig({required this.name, required this.columns});
}

class ColumnConfig {
  final String size; // 'small' | 'full'
  final List<WidgetConfig> widgets;

  const ColumnConfig({required this.size, required this.widgets});
}

class WidgetConfig {
  final String type;
  final String? title;
  final bool hideHeader;
  final Duration cache;
  final Duration? refresh;
  final String asyncPolicy; // 'never' | 'always' | 'stale'
  final Map<String, dynamic> options;

  const WidgetConfig({
    required this.type,
    this.title,
    this.hideHeader = false,
    this.cache = const Duration(minutes: 15),
    this.refresh,
    this.asyncPolicy = 'never',
    required this.options,
  });
}
