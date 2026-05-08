import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import 'package:hyper_dashboard/src/config/parser.dart';

void main() {
  group('parseDuration', () {
    const defaultDuration = Duration(minutes: 15);

    group('valid inputs', () {
      test('parses seconds', () {
        expect(parseDuration('10s'), equals(const Duration(seconds: 10)));
        expect(parseDuration('0s'), equals(const Duration(seconds: 0)));
        expect(parseDuration('3600s'), equals(const Duration(seconds: 3600)));
      });

      test('parses minutes', () {
        expect(parseDuration('5m'), equals(const Duration(minutes: 5)));
        expect(parseDuration('0m'), equals(const Duration(minutes: 0)));
        expect(parseDuration('60m'), equals(const Duration(minutes: 60)));
      });

      test('parses hours', () {
        expect(parseDuration('2h'), equals(const Duration(hours: 2)));
        expect(parseDuration('0h'), equals(const Duration(hours: 0)));
        expect(parseDuration('24h'), equals(const Duration(hours: 24)));
      });

      test('parses days', () {
        expect(parseDuration('1d'), equals(const Duration(days: 1)));
        expect(parseDuration('0d'), equals(const Duration(days: 0)));
        expect(parseDuration('7d'), equals(const Duration(days: 7)));
      });
    });

    group('whitespace handling', () {
      test('trims leading whitespace', () {
        expect(parseDuration('  10s'), equals(const Duration(seconds: 10)));
        expect(parseDuration('\t5m'), equals(const Duration(minutes: 5)));
      });

      test('trims trailing whitespace', () {
        expect(parseDuration('10s  '), equals(const Duration(seconds: 10)));
        expect(parseDuration('5m\t'), equals(const Duration(minutes: 5)));
      });

      test('trims both leading and trailing whitespace', () {
        expect(parseDuration('  10s  '), equals(const Duration(seconds: 10)));
        expect(parseDuration('\t 5m \t'), equals(const Duration(minutes: 5)));
      });
    });

    group('invalid inputs', () {
      test('returns default for null', () {
        expect(parseDuration(null), equals(defaultDuration));
      });

      test('returns default for empty string', () {
        expect(parseDuration(''), equals(defaultDuration));
      });

      test('returns default for whitespace-only string', () {
        expect(parseDuration('   '), equals(defaultDuration));
        expect(parseDuration('\t\n'), equals(defaultDuration));
      });

      test('returns default for missing unit', () {
        expect(parseDuration('10'), equals(defaultDuration));
        expect(parseDuration('5 '), equals(defaultDuration));
      });

      test('returns default for invalid unit', () {
        expect(parseDuration('10x'), equals(defaultDuration));
        expect(parseDuration('5y'), equals(defaultDuration));
        expect(parseDuration('1w'), equals(defaultDuration));
      });

      test('returns default for missing number', () {
        expect(parseDuration('s'), equals(defaultDuration));
        expect(parseDuration('m'), equals(defaultDuration));
      });

      test('returns default for non-numeric prefix', () {
        expect(parseDuration('abs'), equals(defaultDuration));
        expect(parseDuration('tenm'), equals(defaultDuration));
      });

      test('returns default for negative numbers', () {
        expect(parseDuration('-10s'), equals(defaultDuration));
        expect(parseDuration('-5m'), equals(defaultDuration));
      });

      test('returns default for decimal numbers', () {
        expect(parseDuration('1.5h'), equals(defaultDuration));
        expect(parseDuration('2.5m'), equals(defaultDuration));
      });

      test('returns default for extra characters', () {
        expect(parseDuration('10sm'), equals(defaultDuration));
        expect(parseDuration('5m extra'), equals(defaultDuration));
        expect(parseDuration('extra 5m'), equals(defaultDuration));
      });
    });

    group('custom default values', () {
      const customDefault = Duration(hours: 1);

      test('uses custom default for null', () {
        expect(
          parseDuration(null, defaultValue: customDefault),
          equals(customDefault),
        );
      });

      test('uses custom default for invalid input', () {
        expect(
          parseDuration('invalid', defaultValue: customDefault),
          equals(customDefault),
        );
      });
    });

    group('boundary values', () {
      test('handles very large values', () {
        expect(
            parseDuration('999999s'), equals(const Duration(seconds: 999999)),);
        expect(parseDuration('99999m'), equals(const Duration(minutes: 99999)));
      });

      test('handles max int values safely', () {
        // Should not crash on large numbers
        final result = parseDuration('999999999s');
        expect(result, isA<Duration>());
      });
    });
  });

  group('parseTheme', () {
    test('returns default theme for null', () {
      final theme = parseTheme(null);
      expect(theme.background, equals('#1a1b26'));
      expect(theme.surface, equals('#24283b'));
      expect(theme.border, equals('#414868'));
      expect(theme.text, equals('#c0caf5'));
      expect(theme.textMuted, equals('#565f89'));
      expect(theme.accent, equals('#7aa2f7'));
      expect(theme.font, equals('Inter, system-ui, sans-serif'));
      expect(theme.radius, equals('8px'));
    });

    test('parses complete theme', () {
      final yaml = loadYaml('''
background: '#000000'
surface: '#111111'
border: '#222222'
text: '#333333'
text-muted: '#444444'
accent: '#555555'
font: 'Custom Font'
radius: '16px'
''') as YamlMap;

      final theme = parseTheme(yaml);
      expect(theme.background, equals('#000000'));
      expect(theme.surface, equals('#111111'));
      expect(theme.border, equals('#222222'));
      expect(theme.text, equals('#333333'));
      expect(theme.textMuted, equals('#444444'));
      expect(theme.accent, equals('#555555'));
      expect(theme.font, equals('Custom Font'));
      expect(theme.radius, equals('16px'));
    });

    test('partial theme uses defaults for missing values', () {
      final yaml = loadYaml('''
background: '#custom'
accent: '#custom-accent'
''') as YamlMap;

      final theme = parseTheme(yaml);
      expect(theme.background, equals('#custom'));
      expect(theme.accent, equals('#custom-accent'));
      // Defaults
      expect(theme.surface, equals('#24283b'));
      expect(theme.text, equals('#c0caf5'));
    });

    test('handles empty theme map', () {
      final yaml = loadYaml('{}') as YamlMap;
      final theme = parseTheme(yaml);
      expect(theme.background, equals('#1a1b26'));
    });

    test('handles non-string values gracefully', () {
      final yaml = loadYaml('''
background: "123"
radius: "16"
''') as YamlMap;

      final theme = parseTheme(yaml);
      expect(theme.background, equals('123'));
      expect(theme.radius, equals('16'));
    });
  });

  group('parseWidget', () {
    test('parses minimal widget', () {
      final yaml = loadYaml('''
type: weather
''') as YamlMap;

      final widget = parseWidget(yaml);
      expect(widget.type, equals('weather'));
      expect(widget.title, isNull);
      expect(widget.hideHeader, isFalse);
      expect(widget.cache, equals(const Duration(minutes: 15)));
      expect(widget.refresh, isNull);
      expect(widget.asyncPolicy, equals('stale'));
    });

    test('parses complete widget', () {
      final yaml = loadYaml('''
type: weather
title: London Weather
hide-header: true
cache: 30m
refresh: 5m
async-policy: always
location: London
units: metric
''') as YamlMap;

      final widget = parseWidget(yaml);
      expect(widget.type, equals('weather'));
      expect(widget.title, equals('London Weather'));
      expect(widget.hideHeader, isTrue);
      expect(widget.cache, equals(const Duration(minutes: 30)));
      expect(widget.refresh, equals(const Duration(minutes: 5)));
      expect(widget.asyncPolicy, equals('always'));
      expect(widget.options['location'], equals('London'));
      expect(widget.options['units'], equals('metric'));
    });

    test('uses unknown type when type is missing', () {
      final yaml = loadYaml('''
title: Some Widget
''') as YamlMap;

      final widget = parseWidget(yaml);
      expect(widget.type, equals('unknown'));
    });

    test('refresh is null when not specified', () {
      final yaml = loadYaml('''
type: test
cache: 10m
''') as YamlMap;

      final widget = parseWidget(yaml);
      expect(widget.refresh, isNull);
      expect(widget.cache, equals(const Duration(minutes: 10)));
    });

    test('refresh: 0s results in zero duration', () {
      final yaml = loadYaml('''
type: test
refresh: 0s
''') as YamlMap;

      final widget = parseWidget(yaml);
      expect(widget.refresh, equals(const Duration(seconds: 0)));
    });

    test('preserves all options in options map', () {
      final yaml = loadYaml('''
type: custom
title: My Widget
foo: bar
nested:
  key: value
list:
  - item1
  - item2
''') as YamlMap;

      final widget = parseWidget(yaml);
      expect(widget.options['foo'], equals('bar'));
      expect(widget.options['nested'], isA<Map<String, dynamic>>());
      expect(widget.options['list'], isA<List>());
    });

    test('handles various async-policy values', () {
      for (final policy in ['never', 'always', 'stale']) {
        final yaml = loadYaml('''
type: test
async-policy: $policy
''') as YamlMap;

        final widget = parseWidget(yaml);
        expect(widget.asyncPolicy, equals(policy));
      }
    });

    test('handles invalid cache duration gracefully', () {
      final yaml = loadYaml('''
type: test
cache: invalid
''') as YamlMap;

      final widget = parseWidget(yaml);
      // Falls back to default
      expect(widget.cache, equals(const Duration(minutes: 15)));
    });

    test('handles invalid refresh duration gracefully', () {
      final yaml = loadYaml('''
type: test
refresh: invalid
''') as YamlMap;

      final widget = parseWidget(yaml);
      // Falls back to default (15m)
      expect(widget.refresh, equals(const Duration(minutes: 15)));
    });

    test('handles empty options', () {
      final yaml = loadYaml('{}') as YamlMap;
      final widget = parseWidget(yaml);
      expect(widget.type, equals('unknown'));
      // Empty YAML map produces empty Dart map
      expect(widget.options, isA<Map<String, dynamic>>());
    });

    test('handles deeply nested options', () {
      final yaml = loadYaml('''
type: test
level1:
  level2:
    level3:
      value: deep
''') as YamlMap;

      final widget = parseWidget(yaml);
      final nested = widget.options['level1'] as Map;
      final level2 = nested['level2'] as Map;
      final level3 = level2['level3'] as Map;
      expect(level3['value'], equals('deep'));
    });
  });

  group('parseColumn', () {
    test('parses column with default size', () {
      final yaml = loadYaml('''
widgets: []
''') as YamlMap;

      final column = parseColumn(yaml);
      expect(column.size, equals('full'));
      expect(column.widgets, isEmpty);
    });

    test('parses column with custom size', () {
      final yaml = loadYaml('''
size: small
widgets: []
''') as YamlMap;

      final column = parseColumn(yaml);
      expect(column.size, equals('small'));
    });

    test('parses column with widgets', () {
      final yaml = loadYaml('''
size: full
widgets:
  - type: weather
    title: Weather
  - type: clock
''') as YamlMap;

      final column = parseColumn(yaml);
      expect(column.size, equals('full'));
      expect(column.widgets, hasLength(2));
      expect(column.widgets[0].type, equals('weather'));
      expect(column.widgets[1].type, equals('clock'));
    });

    test('handles missing widgets', () {
      final yaml = loadYaml('''
size: small
''') as YamlMap;

      final column = parseColumn(yaml);
      expect(column.widgets, isEmpty);
    });

    test('handles empty widgets list', () {
      final yaml = loadYaml('''
widgets: []
''') as YamlMap;

      final column = parseColumn(yaml);
      expect(column.widgets, isEmpty);
    });
  });

  group('parsePage', () {
    test('parses page with default name', () {
      final yaml = loadYaml('''
columns: []
''') as YamlMap;

      final page = parsePage(yaml);
      expect(page.name, equals('Page'));
      expect(page.columns, isEmpty);
    });

    test('parses page with custom name', () {
      final yaml = loadYaml('''
name: Dashboard
columns: []
''') as YamlMap;

      final page = parsePage(yaml);
      expect(page.name, equals('Dashboard'));
    });

    test('parses page with columns', () {
      final yaml = loadYaml('''
name: Home
columns:
  - size: small
    widgets:
      - type: clock
  - size: full
    widgets:
      - type: weather
''') as YamlMap;

      final page = parsePage(yaml);
      expect(page.name, equals('Home'));
      expect(page.columns, hasLength(2));
      expect(page.columns[0].size, equals('small'));
      expect(page.columns[1].size, equals('full'));
    });

    test('handles missing columns', () {
      final yaml = loadYaml('''
name: Empty
''') as YamlMap;

      final page = parsePage(yaml);
      expect(page.columns, isEmpty);
    });
  });

  group('deepConvert', () {
    test('converts simple YamlMap', () {
      final yaml = loadYaml('''
key: value
number: 42
''') as YamlMap;

      final result = deepConvert(yaml) as Map<String, dynamic>;
      expect(result['key'], equals('value'));
      expect(result['number'], equals(42));
    });

    test('converts nested YamlMap', () {
      final yaml = loadYaml('''
outer:
  inner:
    deep: value
''') as YamlMap;

      final result = deepConvert(yaml) as Map<String, dynamic>;
      final outer = result['outer'] as Map;
      final inner = outer['inner'] as Map;
      expect(inner['deep'], equals('value'));
    });

    test('converts YamlList', () {
      final yaml = loadYaml('''
- item1
- item2
- item3
''') as YamlList;

      final result = deepConvert(yaml) as List;
      expect(result, equals(['item1', 'item2', 'item3']));
    });

    test('converts mixed structures', () {
      final yaml = loadYaml('''
list:
  - name: item1
    value: 10
  - name: item2
    value: 20
map:
  key:
    - a
    - b
''') as YamlMap;

      final result = deepConvert(yaml) as Map<String, dynamic>;
      final list = result['list'] as List;
      expect(list[0]['name'], equals('item1'));
      expect(list[1]['value'], equals(20));

      final map = result['map'] as Map;
      expect((map['key'] as List)[0], equals('a'));
    });

    test('passes through primitive values', () {
      expect(deepConvert('string'), equals('string'));
      expect(deepConvert(42), equals(42));
      expect(deepConvert(true), equals(true));
      expect(deepConvert(null), isNull);
    });

    test('handles empty YamlMap', () {
      final yaml = loadYaml('{}') as YamlMap;
      final result = deepConvert(yaml) as Map;
      expect(result, isEmpty);
    });

    test('handles empty YamlList', () {
      final yaml = loadYaml('[]') as YamlList;
      final result = deepConvert(yaml) as List;
      expect(result, isEmpty);
    });

    test('handles deeply nested structures', () {
      final yaml = loadYaml('''
level1:
  level2:
    level3:
      level4:
        level5: deep-value
''') as YamlMap;

      final result = deepConvert(yaml);
      expect(
        result['level1']['level2']['level3']['level4']['level5'],
        equals('deep-value'),
      );
    });

    test('handles lists within lists', () {
      final yaml = loadYaml('''
- - a
  - b
- - c
  - d
''') as YamlList;

      final result = deepConvert(yaml) as List;
      expect(result[0], equals(['a', 'b']));
      expect(result[1], equals(['c', 'd']));
    });
  });

  group('ConfigParser.parseString (integration)', () {
    test('parses complete config', () {
      final yaml = '''
theme:
  background: '#000000'
  accent: '#ff0000'
pages:
  - name: Home
    columns:
      - size: small
        widgets:
          - type: clock
            title: Time
      - size: full
        widgets:
          - type: weather
            cache: 30m
            refresh: 5m
            async-policy: stale
''';

      final config = ConfigParser.parseString(yaml);

      // Theme
      expect(config.theme.background, equals('#000000'));
      expect(config.theme.accent, equals('#ff0000'));

      // Pages
      expect(config.pages, hasLength(1));
      expect(config.pages[0].name, equals('Home'));

      // Columns
      expect(config.pages[0].columns, hasLength(2));
      expect(config.pages[0].columns[0].size, equals('small'));
      expect(config.pages[0].columns[1].size, equals('full'));

      // Widgets
      final smallWidgets = config.pages[0].columns[0].widgets;
      expect(smallWidgets[0].type, equals('clock'));
      expect(smallWidgets[0].title, equals('Time'));

      final fullWidgets = config.pages[0].columns[1].widgets;
      expect(fullWidgets[0].type, equals('weather'));
      expect(fullWidgets[0].cache, equals(const Duration(minutes: 30)));
      expect(fullWidgets[0].refresh, equals(const Duration(minutes: 5)));
    });

    test('parses minimal config', () {
      final yaml = '''
pages: []
''';

      final config = ConfigParser.parseString(yaml);
      expect(config.pages, isEmpty);
      // Default theme
      expect(config.theme.background, equals('#1a1b26'));
    });

    test('parses config without theme', () {
      final yaml = '''
pages:
  - name: Page1
    columns: []
''';

      final config = ConfigParser.parseString(yaml);
      expect(config.theme.background, equals('#1a1b26'));
      expect(config.pages[0].name, equals('Page1'));
    });

    test('handles special characters in strings', () {
      final yaml = '''
pages:
  - name: "Page with: special chars"
    columns:
      - widgets:
          - type: html
            title: 'Widget with "quotes"'
            source: "<div>HTML content</div>"
''';

      final config = ConfigParser.parseString(yaml);
      expect(config.pages[0].name, equals('Page with: special chars'));
      expect(
        config.pages[0].columns[0].widgets[0].title,
        equals('Widget with "quotes"'),
      );
    });

    test('handles unicode characters', () {
      final yaml = '''
pages:
  - name: '🏠 Home'
    columns:
      - widgets:
          - type: clock
            title: 'Österreich Zeit'
''';

      final config = ConfigParser.parseString(yaml);
      expect(config.pages[0].name, equals('🏠 Home'));
      expect(
        config.pages[0].columns[0].widgets[0].title,
        equals('Österreich Zeit'),
      );
    });
  });

  group('edge cases and robustness', () {
    test('handles widget with all option types', () {
      final yaml = loadYaml('''
type: complex
string: hello
integer: 42
float: 3.14
boolean: true
null_value: ~
list:
  - a
  - b
  - c
nested:
  key: value
''') as YamlMap;

      final widget = parseWidget(yaml);
      expect(widget.options['string'], equals('hello'));
      expect(widget.options['integer'], equals(42));
      expect(widget.options['float'], equals(3.14));
      expect(widget.options['boolean'], equals(true));
      expect(widget.options['null_value'], isNull);
      expect(widget.options['list'], equals(['a', 'b', 'c']));
      expect((widget.options['nested'] as Map)['key'], equals('value'));
    });

    test('handles boolean-like strings', () {
      final yaml = loadYaml('''
type: test
bool-string: "true"
false-string: "false"
''') as YamlMap;

      final widget = parseWidget(yaml);
      // They remain as strings, not converted to bool
      expect(widget.options['bool-string'], equals('true'));
      expect(widget.options['false-string'], equals('false'));
    });

    test('handles numeric strings', () {
      final yaml = loadYaml('''
type: test
num-string: "123"
float-string: "3.14"
''') as YamlMap;

      final widget = parseWidget(yaml);
      // They remain as strings
      expect(widget.options['num-string'], equals('123'));
      expect(widget.options['float-string'], equals('3.14'));
    });

    test('handles very long strings', () {
      final longString = 'x' * 10000;
      final yaml = loadYaml('''
type: test
long: "$longString"
''') as YamlMap;

      final widget = parseWidget(yaml);
      expect(widget.options['long'], equals(longString));
    });

    test(
      'handles many widgets in a column',
      () {
        final widgets = List.generate(
          100,
          (i) => '''
  - type: widget$i
    title: "Widget $i"
''',
        ).join();

        final yaml = loadYaml(
          '''
size: full
widgets:
$widgets
''',
        ) as YamlMap;

        final column = parseColumn(yaml);
        expect(column.widgets, hasLength(100));
        expect(column.widgets[0].type, equals('widget0'));
        expect(column.widgets[99].type, equals('widget99'));
      },
    );

    test(
      'handles many columns in a page',
      () {
        final columns = List.generate(
          20,
          (i) => '''
  - size: ${i % 2 == 0 ? 'small' : 'full'}
    widgets: []
''',
        ).join();

        final yaml = loadYaml(
          '''
name: Many Columns
columns:
$columns
''',
        ) as YamlMap;

        final page = parsePage(yaml);
        expect(page.columns, hasLength(20));
      },
    );

    test(
      'handles many pages',
      () {
        final pages = List.generate(
          50,
          (i) => '''
  - name: Page $i
    columns: []
''',
        ).join();

        final yaml = '''
pages:
$pages
''';

        final config = ConfigParser.parseString(yaml);
        expect(config.pages, hasLength(50));
      },
    );
  });
}
