import 'package:test/test.dart';
import 'package:begod/src/ast.dart';
import 'package:begod/src/renderer.dart';
import 'package:begod/src/helpers/helpers.dart';

MustacheRenderer _renderer() {
  return MustacheRenderer(helperRegistry: HelperRegistry.defaults());
}

void main() {
  group('IfHelper', () {
    final renderer = _renderer();

    test('renders when truthy', () {
      final nodes = MustacheAST('{{#if active}}online{{/if}}').parse();
      expect(renderer.render(nodes, {'active': true}), 'online');
    });

    test('omits when falsy', () {
      final nodes = MustacheAST('{{#if active}}online{{/if}}').parse();
      expect(renderer.render(nodes, {'active': false}), '');
    });

    test('null is falsy', () {
      final nodes = MustacheAST('{{#if name}}yes{{/if}}').parse();
      expect(renderer.render(nodes, {'name': null}), '');
    });

    test('empty string is falsy', () {
      final nodes = MustacheAST('{{#if name}}yes{{/if}}').parse();
      expect(renderer.render(nodes, {'name': ''}), '');
    });

    test('non-empty string is truthy', () {
      final nodes = MustacheAST('{{#if name}}yes{{/if}}').parse();
      expect(renderer.render(nodes, {'name': 'Ada'}), 'yes');
    });

    test('zero is falsy', () {
      final nodes = MustacheAST('{{#if count}}yes{{/if}}').parse();
      expect(renderer.render(nodes, {'count': 0}), '');
    });

    test('non-zero number is truthy', () {
      final nodes = MustacheAST('{{#if count}}yes{{/if}}').parse();
      expect(renderer.render(nodes, {'count': 5}), 'yes');
    });

    test('empty list is falsy', () {
      final nodes = MustacheAST('{{#if items}}yes{{/if}}').parse();
      expect(renderer.render(nodes, {'items': []}), '');
    });

    test('non-empty list is truthy', () {
      final nodes = MustacheAST('{{#if items}}yes{{/if}}').parse();
      expect(
          renderer.render(nodes, {
            'items': [1]
          }),
          'yes');
    });

    test('dotted name', () {
      final nodes = MustacheAST('{{#if user.admin}}admin{{/if}}').parse();
      expect(
          renderer.render(nodes, {
            'user': {'admin': true}
          }),
          'admin');
    });
  });

  group('IfHelper with expressions', () {
    final renderer = _renderer();

    test('== equal strings', () {
      final nodes = MustacheAST('{{#if status == "active"}}yes{{/if}}').parse();
      expect(renderer.render(nodes, {'status': 'active'}), 'yes');
      expect(renderer.render(nodes, {'status': 'inactive'}), '');
    });

    test('!= not equal', () {
      final nodes = MustacheAST('{{#if status != "active"}}no{{/if}}').parse();
      expect(renderer.render(nodes, {'status': 'inactive'}), 'no');
      expect(renderer.render(nodes, {'status': 'active'}), '');
    });

    test('== loose equal number and string', () {
      final nodes = MustacheAST('{{#if count == "5"}}yes{{/if}}').parse();
      expect(renderer.render(nodes, {'count': 5}), 'yes');
    });

    test('> greater than', () {
      final nodes = MustacheAST('{{#if score > 50}}high{{/if}}').parse();
      expect(renderer.render(nodes, {'score': 75}), 'high');
      expect(renderer.render(nodes, {'score': 25}), '');
    });

    test('< less than', () {
      final nodes = MustacheAST('{{#if score < 50}}low{{/if}}').parse();
      expect(renderer.render(nodes, {'score': 25}), 'low');
      expect(renderer.render(nodes, {'score': 75}), '');
    });

    test('>= greater or equal', () {
      final nodes = MustacheAST('{{#if score >= 50}}pass{{/if}}').parse();
      expect(renderer.render(nodes, {'score': 50}), 'pass');
      expect(renderer.render(nodes, {'score': 49}), '');
    });

    test('<= less or equal', () {
      final nodes = MustacheAST('{{#if score <= 50}}pass{{/if}}').parse();
      expect(renderer.render(nodes, {'score': 50}), 'pass');
      expect(renderer.render(nodes, {'score': 51}), '');
    });

    test('&& compound condition', () {
      final nodes = MustacheAST('{{#if active && loaded}}ready{{/if}}').parse();
      expect(renderer.render(nodes, {'active': true, 'loaded': true}), 'ready');
      expect(renderer.render(nodes, {'active': true, 'loaded': false}), '');
    });

    test('|| compound condition', () {
      final nodes = MustacheAST('{{#if a || b}}yes{{/if}}').parse();
      expect(renderer.render(nodes, {'a': false, 'b': true}), 'yes');
      expect(renderer.render(nodes, {'a': false, 'b': false}), '');
    });

    test('arithmetic in condition', () {
      final nodes = MustacheAST('{{#if a + b > 10}}big{{/if}}').parse();
      expect(renderer.render(nodes, {'a': 7, 'b': 5}), 'big');
      expect(renderer.render(nodes, {'a': 2, 'b': 3}), '');
    });

    test('dotted name with comparison', () {
      final nodes =
          MustacheAST('{{#if user.role == "admin"}}admin{{/if}}').parse();
      expect(
          renderer.render(nodes, {
            'user': {'role': 'admin'}
          }),
          'admin');
    });
  });

  group('EachHelper', () {
    final renderer = _renderer();

    test('iterates over list', () {
      final nodes = MustacheAST('{{#each items}}{{.}}{{/each}}').parse();
      expect(
          renderer.render(nodes, {
            'items': ['a', 'b', 'c']
          }),
          'abc');
    });

    test('with objects', () {
      final nodes = MustacheAST('{{#each items}}{{name}},{{/each}}').parse();
      expect(
          renderer.render(nodes, {
            'items': [
              {'name': 'Alice'},
              {'name': 'Bob'},
            ],
          }),
          'Alice,Bob,');
    });

    test('provides @index', () {
      final nodes =
          MustacheAST('{{#each items}}{{@index}}:{{.}};{{/each}}').parse();
      expect(
          renderer.render(nodes, {
            'items': ['a', 'b']
          }),
          '0:a;1:b;');
    });

    test('provides @first and @last', () {
      final nodes = MustacheAST(
        '{{#each items}}{{#if @first}}[{{/if}}{{.}}{{#if @last}}]{{/if}}{{/each}}',
      ).parse();
      expect(
          renderer.render(nodes, {
            'items': ['a', 'b', 'c']
          }),
          '[abc]');
    });

    test('objects merged with loop vars', () {
      final nodes = MustacheAST(
        '{{#each items}}{{name}}-{{@index}};{{/each}}',
      ).parse();
      expect(
          renderer.render(nodes, {
            'items': [
              {'name': 'Alice'},
              {'name': 'Bob'},
            ],
          }),
          'Alice-0;Bob-1;');
    });

    test('empty list produces nothing', () {
      final nodes = MustacheAST('{{#each items}}{{.}}{{/each}}').parse();
      expect(renderer.render(nodes, {'items': []}), '');
    });
  });
}
