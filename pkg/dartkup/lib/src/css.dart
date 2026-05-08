import 'dart:convert' show HtmlEscape, HtmlEscapeMode;

const _attrEscape = HtmlEscape(HtmlEscapeMode.attribute);

/// Collapses a CSS style map into an inline style attribute value.
///
/// Keys in camelCase (e.g. `fontSize`) are converted to kebab-case (`font-size`).
/// kebab-case keys are passed through as-is.
///
/// Values:
/// - `String`/`num` → rendered and attribute-escaped as-is.
/// - `List` → elements joined with space (correct for shorthand properties
///   like `margin`, `padding`, `border`, `transition`, etc.).
/// - `null` → empty value.
String renderStyle(Map<String, Object?> styles) {
  final buf = StringBuffer();
  for (final MapEntry(:key, :value) in styles.entries) {
    final prop = key.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (m) => '-${m.group(0)!.toLowerCase()}',
    );
    buf.write('$prop:${_renderValue(value)};');
  }
  return buf.toString();
}

String _renderValue(Object? value) {
  if (value == null) return '';
  if (value is List) {
    return value.map((e) => _attrEscape.convert(e?.toString() ?? '')).join(' ');
  }
  return _attrEscape.convert(value.toString());
}
