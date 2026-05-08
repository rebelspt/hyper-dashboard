export 'parsers.dart';

import 'dart:io';

import 'package:yaml/yaml.dart';

import 'models.dart';
import 'parsers.dart';

class ConfigParser {
  /// Parses a dashboard configuration from a YAML file at [path].
  static DashboardConfig parse(String path) {
    final content = File(path).readAsStringSync();
    final yaml = loadYaml(content) as YamlMap;
    return _parseConfig(yaml);
  }

  /// Parses a dashboard configuration from a YAML string.
  /// Useful for testing without file I/O.
  static DashboardConfig parseString(String content) {
    final yaml = loadYaml(content) as YamlMap;
    return _parseConfig(yaml);
  }

  static DashboardConfig _parseConfig(YamlMap yaml) {
    final themeMap = yaml['theme'] as YamlMap?;
    final pagesList = yaml['pages'] as YamlList?;

    return DashboardConfig(
      theme: parseTheme(themeMap),
      pages: pagesList?.cast<YamlMap>().map(parsePage).toList() ?? const [],
    );
  }
}
