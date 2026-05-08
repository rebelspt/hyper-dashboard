import 'package:test/test.dart';
import 'package:begod/src/ast.dart';
import 'package:begod/src/renderer.dart';
import 'package:begod/src/filters/filters.dart';

void main() {
  final renderer = MustacheRenderer(filterRegistry: FilterRegistry.defaults());

  group('FilterRegistry', () {
    test('contains all built-in filters', () {
      final registry = FilterRegistry.defaults();
      expect(registry.get('uppercase'), isNotNull);
      expect(registry.get('lowercase'), isNotNull);
      expect(registry.get('capitalize'), isNotNull);
      expect(registry.get('truncate'), isNotNull);
      expect(registry.get('default'), isNotNull);
      expect(registry.get('replace'), isNotNull);
      expect(registry.get('slice'), isNotNull);
      expect(registry.get('strip_html'), isNotNull);
      expect(registry.get('url_encode'), isNotNull);
      expect(registry.get('trim'), isNotNull);
      expect(registry.get('round'), isNotNull);
      expect(registry.get('number'), isNotNull);
      expect(registry.get('filesize'), isNotNull);
      expect(registry.get('abs'), isNotNull);
      expect(registry.get('split'), isNotNull);
      expect(registry.get('join'), isNotNull);
      expect(registry.get('size'), isNotNull);
      expect(registry.get('first'), isNotNull);
      expect(registry.get('last'), isNotNull);
      expect(registry.get('at'), isNotNull);
      expect(registry.get('take'), isNotNull);
    });

    test('unknown filter is passthrough', () {
      final nodes = MustacheAST('{{name | nosuchfilter}}').parse();
      expect(renderer.render(nodes, {'name': 'hello'}), 'hello');
    });
  });

  group('string filters', () {
    test('uppercase', () {
      final nodes = MustacheAST('{{name | uppercase}}').parse();
      expect(renderer.render(nodes, {'name': 'hello'}), 'HELLO');
    });

    test('lowercase', () {
      final nodes = MustacheAST('{{name | lowercase}}').parse();
      expect(renderer.render(nodes, {'name': 'HELLO'}), 'hello');
    });

    test('capitalize', () {
      final nodes = MustacheAST('{{name | capitalize}}').parse();
      expect(renderer.render(nodes, {'name': 'hELLO'}), 'Hello');
    });

    test('truncate default length', () {
      final nodes = MustacheAST('{{name | truncate}}').parse();
      expect(renderer.render(nodes, {'name': 'hello world this is long'}),
          'hello world this is ');
    });

    test('truncate with custom length', () {
      final nodes = MustacheAST('{{name | truncate(5)}}').parse();
      expect(renderer.render(nodes, {'name': 'hello world'}), 'hello');
    });

    test('default replaces empty', () {
      final nodes = MustacheAST('{{name | default("N/A")}}').parse();
      expect(renderer.render(nodes, {'name': ''}), 'N/A');
    });

    test('default keeps value', () {
      final nodes = MustacheAST('{{name | default("N/A")}}').parse();
      expect(renderer.render(nodes, {'name': 'Bob'}), 'Bob');
    });

    test('default with null', () {
      final nodes = MustacheAST('{{name | default("unknown")}}').parse();
      expect(renderer.render(nodes, {}), 'unknown');
    });

    test('replace', () {
      final nodes = MustacheAST('{{name | replace("-", " ")}}').parse();
      expect(renderer.render(nodes, {'name': 'hello-world'}), 'hello world');
    });

    test('slice', () {
      final nodes = MustacheAST('{{name | slice(1, 4)}}').parse();
      expect(renderer.render(nodes, {'name': 'hello'}), 'ell');
    });

    test('slice', () {
      final nodes = MustacheAST('{{name | slice(1, 4)}}').parse();
      expect(renderer.render(nodes, {'name': 'hello'}), 'ell');
    });

    test('strip_html', () {
      final nodes = MustacheAST('{{html | strip_html}}').parse();
      expect(renderer.render(nodes, {'html': '<b>bold</b> &amp; text'}),
          'bold &amp; text');
    });

    test('url_encode', () {
      final nodes = MustacheAST('{{path | url_encode}}').parse();
      expect(renderer.render(nodes, {'path': 'hello world'}), 'hello%20world');
    });

    test('trim', () {
      final nodes = MustacheAST('{{name | trim}}').parse();
      expect(renderer.render(nodes, {'name': '  hello  '}), 'hello');
    });
  });

  group('number filters', () {
    test('round defaults to integer', () {
      final nodes = MustacheAST('{{value | round}}').parse();
      expect(renderer.render(nodes, {'value': 3.14159}), '3');
    });

    test('round to decimals', () {
      final nodes = MustacheAST('{{value | round(2)}}').parse();
      expect(renderer.render(nodes, {'value': 3.14159}), '3.14');
    });

    test('number format', () {
      final nodes = MustacheAST('{{value | number}}').parse();
      expect(renderer.render(nodes, {'value': 1234567}), '1,234,567');
    });

    test('filesize', () {
      final nodes = MustacheAST('{{size | filesize}}').parse();
      expect(renderer.render(nodes, {'size': 1024}), '1.0 KB');
    });

    test('abs', () {
      final nodes = MustacheAST('{{value | abs}}').parse();
      expect(renderer.render(nodes, {'value': -42}), '42');
    });
  });

  group('list filters', () {
    test('split', () {
      final nodes = MustacheAST('{{items | split(",")}}').parse();
      expect(renderer.render(nodes, {'items': 'a,b,c'}), '[a, b, c]');
    });

    test('join', () {
      final nodes = MustacheAST('{{items | join(" | ")}}').parse();
      expect(
          renderer.render(nodes, {
            'items': ['a', 'b', 'c']
          }),
          'a | b | c');
    });

    test('size of list', () {
      final nodes = MustacheAST('{{items | size}}').parse();
      expect(
          renderer.render(nodes, {
            'items': ['a', 'b', 'c']
          }),
          '3');
    });

    test('size of string', () {
      final nodes = MustacheAST('{{name | size}}').parse();
      expect(renderer.render(nodes, {'name': 'hello'}), '5');
    });

    test('first of list', () {
      final nodes = MustacheAST('{{items | first}}').parse();
      expect(
          renderer.render(nodes, {
            'items': ['a', 'b', 'c']
          }),
          'a');
    });

    test('last of list', () {
      final nodes = MustacheAST('{{items | last}}').parse();
      expect(
          renderer.render(nodes, {
            'items': ['a', 'b', 'c']
          }),
          'c');
    });

    test('at index', () {
      final nodes = MustacheAST('{{items | at(1)}}').parse();
      expect(
          renderer.render(nodes, {
            'items': ['a', 'b', 'c']
          }),
          'b');
    });

    test('at negative index', () {
      final nodes = MustacheAST('{{items | at(-1)}}').parse();
      expect(
          renderer.render(nodes, {
            'items': ['a', 'b', 'c']
          }),
          'c');
    });

    test('take', () {
      final nodes = MustacheAST('{{items | take(2)}}').parse();
      expect(
          renderer.render(nodes, {
            'items': ['a', 'b', 'c']
          }),
          '[a, b]');
    });
  });

  group('filter chaining', () {
    test('chain two filters', () {
      final nodes = MustacheAST('{{name | trim | uppercase}}').parse();
      expect(renderer.render(nodes, {'name': '  hello  '}), 'HELLO');
    });

    test('chain three filters', () {
      final nodes =
          MustacheAST('{{name | trim | lowercase | capitalize}}').parse();
      expect(renderer.render(nodes, {'name': '  HELLO  '}), 'Hello');
    });

    test('split then join', () {
      final nodes = MustacheAST('{{items | split(",") | join(" | ")}}').parse();
      expect(renderer.render(nodes, {'items': 'a,b,c'}), 'a | b | c');
    });

    test('split then take then join', () {
      final nodes =
          MustacheAST('{{items | split(",") | take(2) | join("+")}}').parse();
      expect(renderer.render(nodes, {'items': 'a,b,c'}), 'a+b');
    });
  });

  group('filters in expressions', () {
    test('filter before comparison', () {
      final nodes = MustacheAST(
        '{{#if name | uppercase == "HELLO"}}yes{{/if}}',
      ).parse();
      expect(renderer.render(nodes, {'name': 'hello'}), 'yes');
    });

    test('filter inside let', () {
      final nodes = MustacheAST(
        '{{#let greeting "hello" | uppercase}}{{greeting}}{{/let}}',
      ).parse();
      expect(renderer.render(nodes, {}), 'HELLO');
    });

    test('filter on each item', () {
      final nodes = MustacheAST(
        '{{#each items}}{{. | uppercase}},{{/each}}',
      ).parse();
      expect(
          renderer.render(nodes, {
            'items': ['a', 'b']
          }),
          'A,B,');
    });
  });
}
