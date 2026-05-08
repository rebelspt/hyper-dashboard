import '../filter.dart';

class UppercaseFilter extends MustacheFilter {
  @override
  String get name => 'uppercase';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is! String) return '';
    return (input).toUpperCase();
  }
}

class LowercaseFilter extends MustacheFilter {
  @override
  String get name => 'lowercase';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is! String) return '';
    return (input).toLowerCase();
  }
}

class CapitalizeFilter extends MustacheFilter {
  @override
  String get name => 'capitalize';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is! String || input.isEmpty) return '';
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}

class TruncateFilter extends MustacheFilter {
  @override
  String get name => 'truncate';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is! String) return '';
    final length =
        args.isNotEmpty && args[0] is num ? (args[0] as num).toInt() : 20;
    if (length <= 0) return '';
    if (input.length <= length) return input;
    return input.substring(0, length);
  }
}

class DefaultFilter extends MustacheFilter {
  @override
  String get name => 'default';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input == null || (input is String && input.isEmpty)) {
      if (args.isNotEmpty && args[0] is String) return args[0];
      return args.isNotEmpty ? args[0].toString() : '';
    }
    return input;
  }
}

class ReplaceFilter extends MustacheFilter {
  @override
  String get name => 'replace';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is! String || args.length < 2) return input ?? '';
    final search = args[0]?.toString() ?? '';
    final replacement = args[1]?.toString() ?? '';
    return (input).replaceAll(search, replacement);
  }
}

class SliceFilter extends MustacheFilter {
  @override
  String get name => 'slice';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is! String) return '';
    final start =
        args.isNotEmpty && args[0] is num ? (args[0] as num).toInt() : 0;
    final end =
        args.length > 1 && args[1] is num ? (args[1] as num).toInt() : null;
    final len = input.length;
    final s = start < 0 ? (len + start).clamp(0, len) : start.clamp(0, len);
    if (end == null) return input.substring(s);
    final e = end < 0 ? (len + end).clamp(0, len) : end.clamp(0, len);
    if (e <= s) return '';
    return input.substring(s, e);
  }
}

class StripHtmlFilter extends MustacheFilter {
  @override
  String get name => 'strip_html';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is! String) return '';
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }
}

class UrlEncodeFilter extends MustacheFilter {
  @override
  String get name => 'url_encode';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is! String) return '';
    return Uri.encodeComponent(input);
  }
}

class TrimFilter extends MustacheFilter {
  @override
  String get name => 'trim';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is! String) return '';
    return (input).trim();
  }
}
