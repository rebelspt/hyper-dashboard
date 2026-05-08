import 'package:test/test.dart';
import 'package:begod/src/ast.dart';
import 'package:begod/src/renderer.dart';
import 'package:begod/src/helpers/helpers.dart';

MustacheRenderer _renderer() {
  return MustacheRenderer(helperRegistry: HelperRegistry.defaults());
}

void main() {
  group('LetHelper', () {
    final renderer = _renderer();

    test('binds a constant string', () {
      final nodes =
          MustacheAST('{{#let name "Alice"}}Hello {{name}}{{/let}}').parse();
      expect(renderer.render(nodes, {}), 'Hello Alice');
    });

    test('binds a constant number', () {
      final nodes =
          MustacheAST('{{#let count 5}}count is {{count}}{{/let}}').parse();
      expect(renderer.render(nodes, {}), 'count is 5');
    });

    test('binds a constant boolean', () {
      final nodes = MustacheAST(
        '{{#let flag true}}{{#if flag}}yes{{/if}}{{/let}}',
      ).parse();
      expect(renderer.render(nodes, {}), 'yes');
    });

    test('renames a variable from context', () {
      final nodes = MustacheAST(
        '{{#let name firstName}}Hello {{name}}{{/let}}',
      ).parse();
      expect(renderer.render(nodes, {'firstName': 'Bob'}), 'Hello Bob');
    });

    test('shadows an existing variable', () {
      final nodes = MustacheAST(
        '{{#let name "inner"}}inner={{name}}{{/let}} outer={{name}}',
      ).parse();
      expect(
          renderer.render(nodes, {'name': 'outer'}), 'inner=inner outer=outer');
    });

    test('nested let bindings', () {
      final nodes = MustacheAST(
        '{{#let a "A"}}{{a}}-{{#let b "B"}}{{a}}{{b}}{{/let}}-{{a}}{{/let}}',
      ).parse();
      expect(renderer.render(nodes, {}), 'A-AB-A');
    });

    test('does not leak outside scope', () {
      final nodes =
          MustacheAST('{{#let x "inside"}}{{x}}{{/let}}{{x}}').parse();
      expect(renderer.render(nodes, {'x': 'global'}), 'insideglobal');
    });

    test('binds from a dotted path', () {
      final nodes = MustacheAST(
        '{{#let name user.firstName}}Hello {{name}}{{/let}}',
      ).parse();
      expect(
        renderer.render(nodes, {
          'user': {'firstName': 'Ada'}
        }),
        'Hello Ada',
      );
    });

    test('binds inside each loop', () {
      final nodes = MustacheAST(
        '{{#each items}}{{#let name item}}{{name}},{{/let}}{{/each}}',
      ).parse();
      expect(
        renderer.render(nodes, {
          'items': [
            {'item': 'Alice'},
            {'item': 'Bob'},
          ],
        }),
        'Alice,Bob,',
      );
    });

    test('let with each loop vars', () {
      final nodes = MustacheAST(
        '{{#each items}}{{#let pos @index}}{{pos}}:{{.}}{{/let}};{{/each}}',
      ).parse();
      expect(
          renderer.render(nodes, {
            'items': ['a', 'b']
          }),
          '0:a;1:b;');
    });
  });

  group('LetHelper expressions', () {
    final renderer = _renderer();

    test('arithmetic addition', () {
      final nodes =
          MustacheAST('{{#let total a + b}}{{total}}{{/let}}').parse();
      expect(renderer.render(nodes, {'a': 3, 'b': 4}), '7');
    });

    test('arithmetic subtraction', () {
      final nodes =
          MustacheAST('{{#let result a - b}}{{result}}{{/let}}').parse();
      expect(renderer.render(nodes, {'a': 10, 'b': 3}), '7');
    });

    test('arithmetic multiplication', () {
      final nodes =
          MustacheAST('{{#let result a * b}}{{result}}{{/let}}').parse();
      expect(renderer.render(nodes, {'a': 3, 'b': 4}), '12');
    });

    test('arithmetic division', () {
      final nodes =
          MustacheAST('{{#let result a / b}}{{result}}{{/let}}').parse();
      expect(renderer.render(nodes, {'a': 10, 'b': 2}), '5.0');
    });

    test('operator precedence: multiplication before addition', () {
      final nodes = MustacheAST(
        '{{#let result 2 + 3 * 4}}{{result}}{{/let}}',
      ).parse();
      expect(renderer.render(nodes, {}), '14');
    });

    test('parentheses override precedence', () {
      final nodes = MustacheAST(
        '{{#let result (2 + 3) * 4}}{{result}}{{/let}}',
      ).parse();
      expect(renderer.render(nodes, {}), '20');
    });

    test('string concatenation with +', () {
      final nodes = MustacheAST(
        '{{#let greeting "Hello, " + name}}{{greeting}}{{/let}}',
      ).parse();
      expect(renderer.render(nodes, {'name': 'World'}), 'Hello, World');
    });

    test('string concatenation with numbers', () {
      final nodes = MustacheAST(
        '{{#let label "count: " + count}}{{label}}{{/let}}',
      ).parse();
      expect(renderer.render(nodes, {'count': 5}), 'count: 5');
    });

    test('AND operator true', () {
      final nodes = MustacheAST(
        '{{#let result a && b}}{{#if result}}yes{{/if}}{{/let}}',
      ).parse();
      expect(renderer.render(nodes, {'a': true, 'b': true}), 'yes');
    });

    test('AND operator false', () {
      final nodes = MustacheAST(
        '{{#let result a && b}}{{#if result}}yes{{/if}}{{/let}}',
      ).parse();
      expect(renderer.render(nodes, {'a': true, 'b': false}), '');
    });

    test('OR operator true', () {
      final nodes = MustacheAST(
        '{{#let result a || b}}{{#if result}}yes{{/if}}{{/let}}',
      ).parse();
      expect(renderer.render(nodes, {'a': false, 'b': true}), 'yes');
    });

    test('OR operator false', () {
      final nodes = MustacheAST(
        '{{#let result a || b}}{{#if result}}yes{{/if}}{{/let}}',
      ).parse();
      expect(renderer.render(nodes, {'a': false, 'b': false}), '');
    });

    test('unary minus on variable', () {
      final nodes = MustacheAST('{{#let result -x}}{{result}}{{/let}}').parse();
      expect(renderer.render(nodes, {'x': 5}), '-5');
    });

    test('unary minus on literal', () {
      final nodes = MustacheAST('{{#let result -5}}{{result}}{{/let}}').parse();
      expect(renderer.render(nodes, {}), '-5');
    });

    test('complex expression with multiple operators', () {
      final nodes = MustacheAST(
        '{{#let total (price + tax) * (1 + rate)}}{{total}}{{/let}}',
      ).parse();
      final result =
          renderer.render(nodes, {'price': 100, 'tax': 10, 'rate': 0.1});
      expect(double.parse(result), closeTo(121.0, 0.001));
    });
  });

  group('LetHelper comparison operators', () {
    final renderer = _renderer();

    test('== equal numbers', () {
      final nodes =
          MustacheAST('{{#let ok a == b}}{{#if ok}}yes{{/if}}{{/let}}').parse();
      expect(renderer.render(nodes, {'a': 5, 'b': 5}), 'yes');
      expect(renderer.render(nodes, {'a': 5, 'b': 3}), '');
    });

    test('!= not equal', () {
      final nodes =
          MustacheAST('{{#let ok a != b}}{{#if ok}}yes{{/if}}{{/let}}').parse();
      expect(renderer.render(nodes, {'a': 5, 'b': 3}), 'yes');
      expect(renderer.render(nodes, {'a': 5, 'b': 5}), '');
    });

    test('< less than', () {
      final nodes =
          MustacheAST('{{#let ok score < 50}}{{#if ok}}low{{/if}}{{/let}}')
              .parse();
      expect(renderer.render(nodes, {'score': 30}), 'low');
      expect(renderer.render(nodes, {'score': 60}), '');
    });

    test('> greater than', () {
      final nodes =
          MustacheAST('{{#let ok score > 50}}{{#if ok}}high{{/if}}{{/let}}')
              .parse();
      expect(renderer.render(nodes, {'score': 75}), 'high');
      expect(renderer.render(nodes, {'score': 30}), '');
    });

    test('<= less than or equal', () {
      final nodes =
          MustacheAST('{{#let ok score <= 50}}{{#if ok}}pass{{/if}}{{/let}}')
              .parse();
      expect(renderer.render(nodes, {'score': 50}), 'pass');
      expect(renderer.render(nodes, {'score': 51}), '');
    });

    test('>= greater than or equal', () {
      final nodes =
          MustacheAST('{{#let ok score >= 50}}{{#if ok}}pass{{/if}}{{/let}}')
              .parse();
      expect(renderer.render(nodes, {'score': 50}), 'pass');
      expect(renderer.render(nodes, {'score': 49}), '');
    });

    test('comparison with compound expressions', () {
      final nodes = MustacheAST(
        '{{#let ok a + b > c}}{{#if ok}}yes{{/if}}{{/let}}',
      ).parse();
      expect(renderer.render(nodes, {'a': 3, 'b': 4, 'c': 5}), 'yes');
      expect(renderer.render(nodes, {'a': 1, 'b': 2, 'c': 5}), '');
    });

    test('comparison precedence: arithmetic before comparison', () {
      final nodes = MustacheAST(
        '{{#let ok a + b == c * d}}{{#if ok}}yes{{/if}}{{/let}}',
      ).parse();
      expect(renderer.render(nodes, {'a': 1, 'b': 2, 'c': 1, 'd': 3}), 'yes');
    });

    test('comparison with boolean operators', () {
      final nodes = MustacheAST(
        '{{#let ok score > 0 && score < 100}}{{#if ok}}range{{/if}}{{/let}}',
      ).parse();
      expect(renderer.render(nodes, {'score': 50}), 'range');
      expect(renderer.render(nodes, {'score': 150}), '');
      expect(renderer.render(nodes, {'score': -10}), '');
    });
  });
}
