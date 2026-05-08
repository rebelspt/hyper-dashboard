/// HTML DSL surface.
///
/// Contract:
///   - First positional arg = attrs map (optional, default {})
///       • 'cls' key maps to the HTML 'class' attribute
///       • null value → boolean attribute (e.g. {'defer': null})
///       • 'style' key with a Map value → CSS inline style (camelCase → kebab-case)
///       • all other keys are passed through verbatim
///   - Second positional arg = children (optional)
///       • accepts a single Node/String, a List, or any Iterable
///       • omit entirely for void / attribute-only elements
///   - t()   → auto-escaped text node
///   - raw()  → unescaped HTML/JS/CSS fragment
library;

import 'node.dart';
export 'node.dart';

// ── Primitives ───────────────────────────────────────────────────────────────

/// Auto-escaped text content.
TextNode t(String s) => TextNode(s);

/// Unescaped raw HTML / JS / CSS fragment.
RawNode raw(String s) => RawNode(s);

/// Groups nodes without a wrapping element. String items are auto-escaped.
FragmentNode fragment(List<Object> nodes) => FragmentNode(nodes);

// ── Internal helpers ─────────────────────────────────────────────────────────

Map<String, Object?> _attrs(Map<String, dynamic> m) => {
      for (final e in m.entries) (e.key == 'cls' ? 'class' : e.key): e.value,
    };

List<Object> _kids(Object? c) {
  if (c == null) return const [];
  if (c is List<Object>) return c;
  if (c is Iterable<Object>) return c.toList();
  return [c];
}

// ── Generic builder ──────────────────────────────────────────────────────────

/// Build any element by tag name.
ElementNode el(
  String tag, [
  Map<String, dynamic> attrs = const {},
  Object? children,
]) =>
    ElementNode(tag: tag, attrs: _attrs(attrs), children: _kids(children));

// ── Block / structural elements ──────────────────────────────────────────────

ElementNode div([Map<String, dynamic> attrs = const {}, Object? children]) =>
    el('div', attrs, children);

ElementNode span([Map<String, dynamic> attrs = const {}, Object? children]) =>
    el('span', attrs, children);

ElementNode p([Map<String, dynamic> attrs = const {}, Object? children]) =>
    el('p', attrs, children);

ElementNode header([Map<String, dynamic> attrs = const {}, Object? children]) =>
    el('header', attrs, children);

ElementNode nav([Map<String, dynamic> attrs = const {}, Object? children]) =>
    el('nav', attrs, children);

/// Renders as `<main>`. Named `mainEl` to avoid shadowing Dart's `main`.
ElementNode mainEl([Map<String, dynamic> attrs = const {}, Object? children]) =>
    el('main', attrs, children);

// ── List elements ────────────────────────────────────────────────────────────

ElementNode ul([Map<String, dynamic> attrs = const {}, Object? children]) =>
    el('ul', attrs, children);

ElementNode li([Map<String, dynamic> attrs = const {}, Object? children]) =>
    el('li', attrs, children);

// ── Interactive elements ─────────────────────────────────────────────────────

ElementNode a([Map<String, dynamic> attrs = const {}, Object? children]) =>
    el('a', attrs, children);

ElementNode button([Map<String, dynamic> attrs = const {}, Object? children]) =>
    el('button', attrs, children);

// ── Void / self-closing elements ─────────────────────────────────────────────

/// Self-closing `<img>` — no children.
ElementNode img([Map<String, dynamic> attrs = const {}]) =>
    ElementNode(tag: 'img', attrs: _attrs(attrs));

/// Self-closing `<meta>` — no children.
ElementNode meta([Map<String, dynamic> attrs = const {}]) =>
    ElementNode(tag: 'meta', attrs: _attrs(attrs));

// ── Script & style ───────────────────────────────────────────────────────────

ElementNode script([Map<String, dynamic> attrs = const {}, Object? children]) =>
    el('script', attrs, children);

ElementNode style([Map<String, dynamic> attrs = const {}, Object? children]) =>
    el('style', attrs, children);

// ── Full document ─────────────────────────────────────────────────────────────

/// Renders a complete HTML document (prepends `<!DOCTYPE html>`).
Node htmlDoc({
  required String lang,
  required List<Object> head,
  required List<Object> body,
}) {
  final buf = StringBuffer('<!DOCTYPE html>');
  ElementNode(
    tag: 'html',
    attrs: {'lang': lang},
    children: [
      ElementNode(tag: 'head', children: head),
      ElementNode(tag: 'body', children: body),
    ],
  ).renderTo(buf);
  return RawNode(buf.toString());
}
