# begod

A Mustache template engine for Dart with expression support, built-in helpers, and filters. Powered by ANTLR4.

## Usage

```dart
import 'package:begod/begod.dart';

void main() {
  final template = MustacheTemplate('Hello, {{name}}!');
  print(template.render({'name': 'World'})); // Hello, World!
}
```

## Features

### Variables
```mustache
{{name}}                          HTML-escaped
{{{html}}}                        Raw (unescaped)
{{&html}}                         Raw (ampersand style)
```

### Sections
```mustache
{{#items}}...{{/items}}           Loop / truthy block
{{^empty}}...{{/empty}}           Inverted (falsy) block
```

### Helpers
```mustache
{{#if active}}...{{/if}}           Truthy check
{{#if score > 50}}...{{/if}}       Expression conditions
{{#unless loading}}...{{/unless}}  Falsy check
{{#each items}}...{{/each}}        List iteration
{{#let name value}}...{{/let}}     Local variable binding
```

### Expressions (in let and if)
Operators: `+`, `-`, `*`, `/`, `==`, `!=`, `<`, `>`, `<=`, `>=`, `&&`, `||`, `()` grouping.

```mustache
{{#let total (price + tax) * quantity}}{{total}}{{/let}}
{{#if score > 0 && score < 100}}range{{/if}}
{{#let greeting "Hello, " + name}}{{greeting}}{{/let}}
```

### Filters
```mustache
{{name | uppercase}}              {{name | truncate(50)}}
{{name | capitalize}}             {{name | default("N/A")}}
{{items | split(",") | join(" ")}}  {{value | round(2)}}
```

#### String Filters
`uppercase`, `lowercase`, `capitalize`, `trim`, `truncate`, `default`, `replace`, `slice`, `strip_html`, `url_encode`

#### Number Filters
`round`, `number`, `filesize`, `abs`

#### List Filters
`split`, `join`, `size`, `first`, `last`, `at`, `take`

### Custom Helpers
```dart
class GreetHelper extends MustacheHelper {
  @override
  String get name => 'greet';

  @override
  String render(
    List<Node> children,
    List<Arg> args,
    bool inverted,
    Object? context,
    dynamic renderer,
  ) {
    final r = renderer as HelperDelegate;
    final name = r.resolve('name', context);
    return 'Hello, ${r.stringify(name)}!';
  }
}

final registry = HelperRegistry()..register(GreetHelper());
final template = MustacheTemplate('{{#greet}}{{/greet}}',
    helperRegistry: registry);
```

### Custom Filters
```dart
class ExclaimFilter extends MustacheFilter {
  @override
  String get name => 'exclaim';

  @override
  Object? apply(Object? input, List<Object?> args) {
    return '${input ?? ''}!';
  }
}

final registry = FilterRegistry()..register(ExclaimFilter());
final template = MustacheTemplate('{{name | exclaim}}',
    filterRegistry: registry);
```

## API

### MustacheTemplate
```dart
factory MustacheTemplate(
  String template, {
  HelperRegistry? helperRegistry,
  FilterRegistry? filterRegistry,
})

String render(Object? data, {Map<String, String> partials = const {}})
bool hasReference(String name)
```

### MustacheRenderer
```dart
MustacheRenderer({
  PartialResolver? partialResolver,
  HelperRegistry? helperRegistry,
  FilterRegistry? filterRegistry,
})

String render(List<Node> nodes, Object? context)
String renderNodes(List<Node> nodes, Object? context)
```

### MustacheAST
```dart
MustacheAST(String template)
List<Node> parse()
```
