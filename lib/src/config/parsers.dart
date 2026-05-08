import 'package:yaml/yaml.dart';

import 'models.dart';

/// Parses a duration string into a [Duration].
/// Supported formats: `10s`, `5m`, `2h`, `1d`
/// Returns the default duration if the string is invalid or empty.
Duration parseDuration(
  String? s, {
  Duration defaultValue = const Duration(minutes: 15),
}) {
  if (s == null || s.trim().isEmpty) {
    return defaultValue;
  }

  final match = RegExp(r'^(\d+)(s|m|h|d)$').firstMatch(s.trim());
  if (match == null) return defaultValue;

  final n = int.tryParse(match.group(1)!);
  if (n == null || n < 0) return defaultValue;

  return switch (match.group(2)!) {
    's' => Duration(seconds: n),
    'm' => Duration(minutes: n),
    'h' => Duration(hours: n),
    'd' => Duration(days: n),
    _ => defaultValue,
  };
}

/// Parses a theme configuration from a YAML map.
ThemeConfig parseTheme(YamlMap? m) {
  if (m == null) return const ThemeConfig();

  return ThemeConfig(
    background: m['background'] as String? ?? '#1a1b26',
    surface: m['surface'] as String? ?? '#24283b',
    border: m['border'] as String? ?? '#414868',
    text: m['text'] as String? ?? '#c0caf5',
    textMuted: m['text-muted'] as String? ?? '#565f89',
    accent: m['accent'] as String? ?? '#7aa2f7',
    font: m['font'] as String? ?? 'Inter, system-ui, sans-serif',
    radius: m['radius'] as String? ?? '8px',
  );
}

/// Parses a page configuration from a YAML map.
PageConfig parsePage(YamlMap m) => PageConfig(
      name: m['name'] as String? ?? 'Page',
      columns: (m['columns'] as YamlList?)
              ?.cast<YamlMap>()
              .map(parseColumn)
              .toList() ??
          const [],
    );

/// Parses a column configuration from a YAML map.
ColumnConfig parseColumn(YamlMap m) => ColumnConfig(
      size: m['size'] as String? ?? 'full',
      widgets: (m['widgets'] as YamlList?)
              ?.cast<YamlMap>()
              .map(parseWidget)
              .toList() ??
          const [],
    );

/// Parses a widget configuration from a YAML map.
WidgetConfig parseWidget(YamlMap m) {
  final cacheStr = m['cache'] as String?;
  final refreshStr = m['refresh'] as String?;
  // Convert the full YamlMap to a plain Dart map for widget-specific options.
  final options = deepConvert(m) as Map<String, dynamic>;

  return WidgetConfig(
    type: m['type'] as String? ?? 'unknown',
    title: m['title'] as String?,
    hideHeader: m['hide-header'] as bool? ?? false,
    cache: parseDuration(cacheStr),
    refresh: refreshStr != null ? parseDuration(refreshStr) : null,
    asyncPolicy: m['async-policy'] as String? ?? 'stale',
    options: options,
  );
}

/// Recursively converts YAML structures to plain Dart objects.
dynamic deepConvert(dynamic value) {
  if (value is YamlMap) {
    return Map<String, dynamic>.fromEntries(
      value.entries.map(
        (e) => MapEntry(e.key.toString(), deepConvert(e.value)),
      ),
    );
  }
  if (value is YamlList) {
    return value.map(deepConvert).toList();
  }
  return value;
}
