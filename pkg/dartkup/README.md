# dartkup

A lightweight, type-safe HTML DSL for Dart. Builds HTML trees that render to strings with zero dependencies.

## Usage

```dart
import 'package:dartkup/dartkup.dart';

String card(String title, String body) {
  return div({'cls': 'card'}, [
    h2(null, title),
    p(null, body),
  ]).render();
}

// Full document
final doc = htmlDoc(
  lang: 'en',
  head: [
    meta({'charset': 'utf-8'}),
    title('My Page'),
  ],
  body: [
    div({'cls': 'container'}, [
      h1(null, 'Hello, world!'),
      p(null, 'Built with dartkup'),
    ]),
  ],
).render();
```

## API

### Node types

| Class | Description |
|-------|-------------|
| `TextNode(value)` | Auto-escaped text |
| `RawNode(value)` | Unescaped HTML/JS/CSS |
| `FragmentNode(nodes)` | Flat list, no wrapper |
| `ElementNode(tag, attrs, children)` | HTML element |

All nodes extend `Node` and support `.render()` and `.renderTo(buffer)`.

### Shortcut functions (`h.dart`)

```dart
t(String s)              // Auto-escaped text
raw(String s)            // Unescaped raw content
fragment(List nodes)     // Fragment of nodes
el(tag, attrs?, kids?)   // Any custom element
div(attrs?, kids?)        // <div>
span(attrs?, kids?)       // <span>
p(attrs?, kids?)          // <p>
a(attrs?, kids?)          // <a>
button(attrs?, kids?)     // <button>
img(attrs?)               // <img> (void, no children)
ul(attrs?, kids?)         // <ul>
li(attrs?, kids?)         // <li>
header(attrs?, kids?)     // <header>
nav(attrs?, kids?)        // <nav>
mainEl(attrs?, kids?)     // <main>
script(attrs?, kids?)     // <script> (raw content)
style(attrs?, kids?)      // <style>  (raw content)
meta(attrs?)              // <meta>  (void)
htmlDoc(lang, head, body) // Full <!DOCTYPE html> document
```

### Attributes

- `'cls'` key maps to HTML `class` attribute
- `null` value renders as boolean attribute (`{'defer': null}` → `defer`)
- `'style'` with a `Map` value converts to CSS inline style (camelCase → kebab-case)
- `'style'` with a `String` value is passed through verbatim
- All other keys are passed through verbatim
- Attribute values are HTML-escaped

### CSS Style Maps

```dart
div({
  'style': {
    'fontSize': '14px',           // camelCase → font-size
    'backgroundColor': '#eee',    // → background-color
    'borderRadius': '4px',        // kebab-case passed through
    'border': ['1px', 'solid', '#ccc'],  // arrays → space-joined
    'fontFamily': '"Times New Roman", serif',  // comma-separated as string
  },
}, 'Hello');
```

### Children

Accepts a single `Node`/`String`, a `List`, or any `Iterable`. Strings are auto-escaped.
Void elements ignore children.

### Special handling

- `<script>` and `<style>` write `TextNode` children unescaped (correct for JS/CSS)
- Void elements (img, br, meta, etc.) emit no closing tag
