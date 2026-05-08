import 'dart:convert' show HtmlEscape, HtmlEscapeMode;

import 'css.dart';

// Module-private escaping — the only place in the codebase where HTML escaping lives.
const _textEscape = HtmlEscape(HtmlEscapeMode.element);
const _attrEscape = HtmlEscape(HtmlEscapeMode.attribute);

String _escapeText(String s) => _textEscape.convert(s);
String _escapeAttr(String s) => _attrEscape.convert(s);

// Elements that must not emit a closing tag.
const _voidElements = <String>{
  'area',
  'base',
  'br',
  'col',
  'embed',
  'hr',
  'img',
  'input',
  'link',
  'meta',
  'param',
  'source',
  'track',
  'wbr',
};

// Elements whose text content must never be HTML-escaped (JS, CSS).
const _rawContentElements = <String>{'script', 'style'};

sealed class Node {
  const Node();

  /// Renders the node tree to a String. Allocates a StringBuffer internally.
  String render() {
    final buf = StringBuffer();
    renderTo(buf);
    return buf.toString();
  }

  /// Low-allocation render path — appends to a caller-supplied buffer.
  void renderTo(StringBuffer buf);
}

/// Auto-escaped text content node.
final class TextNode extends Node {
  final String value;
  const TextNode(this.value);

  @override
  void renderTo(StringBuffer buf) => buf.write(_escapeText(value));
}

/// Unescaped raw content — use for pre-rendered HTML fragments, JS, or CSS.
final class RawNode extends Node {
  final String value;
  const RawNode(this.value);

  @override
  void renderTo(StringBuffer buf) => buf.write(value);
}

/// A flat list of nodes with no wrapping element.
/// String entries in children are auto-converted to escaped text.
final class FragmentNode extends Node {
  final List<Object> children;
  FragmentNode(this.children);

  @override
  void renderTo(StringBuffer buf) {
    for (final child in children) {
      if (child is Node) {
        child.renderTo(buf);
      } else if (child is String) {
        buf.write(_escapeText(child));
      }
    }
  }
}

/// An HTML element: `<tag attrs...>children</tag>`.
///
/// - attrs: null value → boolean attribute (e.g. `{'defer': null}` → `defer`).
/// - attrs: `'style'` with a `Map` value → CSS inline style (keys convert camelCase
///   to kebab-case, e.g. `fontSize` → `font-size`).
/// - children: String entries are auto-escaped; Node entries render normally.
/// - Void elements (_voidElements) emit no closing tag and ignore children.
/// - Raw-content elements (_rawContentElements) write TextNode children and
///   String children without HTML-escaping (correct for `<script>` and `<style>`).
final class ElementNode extends Node {
  final String tag;
  final Map<String, Object?> attrs;
  final List<Object> children;

  const ElementNode({
    required this.tag,
    this.attrs = const {},
    this.children = const [],
  });

  @override
  void renderTo(StringBuffer buf) {
    buf.write('<$tag');
    for (final MapEntry(:key, :value) in attrs.entries) {
      if (value == null) {
        buf.write(' $key');
      } else {
        final rendered = key == 'style' && value is Map
            ? renderStyle(value as Map<String, Object?>)
            : _escapeAttr(value.toString());
        buf.write(' $key="$rendered"');
      }
    }

    if (_voidElements.contains(tag)) {
      buf.write('>');
      return;
    }

    buf.write('>');

    final isRaw = _rawContentElements.contains(tag);
    for (final child in children) {
      if (isRaw && child is TextNode) {
        buf.write(child.value);
      } else if (isRaw && child is String) {
        buf.write(child);
      } else if (child is Node) {
        child.renderTo(buf);
      } else if (child is String) {
        buf.write(_escapeText(child));
      }
    }

    buf.write('</$tag>');
  }
}
