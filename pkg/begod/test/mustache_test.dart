import 'package:test/test.dart';
import 'package:begod/src/ast.dart';
import 'package:begod/src/renderer.dart';

void main() {
  group('MustacheAST parse', () {
    test('parses plain text', () {
      final nodes = MustacheAST('Hello world').parse();
      expect(nodes, [isA<TextNode>()]);
      expect((nodes[0] as TextNode).text, 'Hello world');
    });

    test('parses a simple variable', () {
      final nodes = MustacheAST('{{name}}').parse();
      expect(nodes, [isA<VariableNode>()]);
      final expr = (nodes[0] as VariableNode).expr;
      expect(expr, isA<VariableArg>());
      expect((expr as VariableArg).name, 'name');
    });

    test('parses mixed text and variable', () {
      final nodes = MustacheAST('Hello, {{subject}}!').parse();
      expect(nodes.length, 3);
      expect((nodes[0] as TextNode).text, 'Hello, ');
      final varNode = nodes[1] as VariableNode;
      expect(varNode.expr, isA<VariableArg>());
      expect((varNode.expr as VariableArg).name, 'subject');
      expect((nodes[2] as TextNode).text, '!');
    });

    test('parses unescaped via triple braces', () {
      final nodes = MustacheAST('{{{html}}}').parse();
      expect(nodes, [isA<UnescapedNode>()]);
      expect((nodes[0] as UnescapedNode).name, 'html');
    });

    test('parses unescaped via ampersand', () {
      final nodes = MustacheAST('{{&html}}').parse();
      expect(nodes, [isA<UnescapedNode>()]);
      expect((nodes[0] as UnescapedNode).name, 'html');
    });

    test('parses a section', () {
      final nodes = MustacheAST('{{#items}}item{{/items}}').parse();
      expect(nodes, [isA<SectionNode>()]);
      final section = nodes[0] as SectionNode;
      expect(section.name, 'items');
      expect(section.children.length, 1);
      expect((section.children[0] as TextNode).text, 'item');
    });

    test('parses an inverted section', () {
      final nodes = MustacheAST('{{^empty}}no items{{/empty}}').parse();
      expect(nodes, [isA<InvertedNode>()]);
      final section = nodes[0] as InvertedNode;
      expect(section.name, 'empty');
      expect(section.children.length, 1);
      expect((section.children[0] as TextNode).text, 'no items');
    });

    test('parses nested sections', () {
      final nodes =
          MustacheAST('{{#outer}}{{#inner}}x{{/inner}}{{/outer}}').parse();
      expect(nodes, [isA<SectionNode>()]);
      final outer = nodes[0] as SectionNode;
      expect(outer.name, 'outer');
      expect(outer.children, [isA<SectionNode>()]);
      final inner = outer.children[0] as SectionNode;
      expect(inner.name, 'inner');
      expect(inner.children.length, 1);
      expect((inner.children[0] as TextNode).text, 'x');
    });

    test('parses a comment', () {
      final nodes = MustacheAST('{{! this is a comment }}').parse();
      expect(nodes, [isA<CommentNode>()]);
    });

    test('parses a partial', () {
      final nodes = MustacheAST('{{>header}}').parse();
      expect(nodes, [isA<PartialNode>()]);
      expect((nodes[0] as PartialNode).name, 'header');
    });

    test('ignores lone braces without double', () {
      final nodes = MustacheAST('Hello {world}').parse();
      expect(nodes.length, 3);
      expect((nodes[0] as TextNode).text, 'Hello ');
      expect((nodes[1] as TextNode).text, '{');
      expect((nodes[2] as TextNode).text, 'world}');
    });
  });

  group('MustacheRenderer', () {
    final renderer = MustacheRenderer();

    test('renders plain text unchanged', () {
      final nodes = MustacheAST('Hello world').parse();
      expect(renderer.render(nodes, {}), 'Hello world');
    });

    test('renders variable interpolation', () {
      final nodes = MustacheAST('Hello, {{subject}}!').parse();
      expect(
        renderer.render(nodes, {'subject': 'world'}),
        'Hello, world!',
      );
    });

    test('HTML escapes variables', () {
      final nodes = MustacheAST('{{forbidden}}').parse();
      expect(
        renderer.render(nodes, {'forbidden': '& " < >'}),
        '&amp; &quot; &lt; &gt;',
      );
    });

    test('triple mustache does not escape', () {
      final nodes = MustacheAST('{{{html}}}').parse();
      expect(
        renderer.render(nodes, {'html': '<b>bold</b>'}),
        '<b>bold</b>',
      );
    });

    test('ampersand does not escape', () {
      final nodes = MustacheAST('{{&html}}').parse();
      expect(
        renderer.render(nodes, {'html': '<b>bold</b>'}),
        '<b>bold</b>',
      );
    });

    test('renders sections with truthy value', () {
      final nodes = MustacheAST('{{#show}}visible{{/show}}').parse();
      expect(renderer.render(nodes, {'show': true}), 'visible');
    });

    test('hides sections with falsy value', () {
      final nodes = MustacheAST('{{#show}}visible{{/show}}').parse();
      expect(renderer.render(nodes, {'show': false}), '');
    });

    test('renders sections with lists', () {
      final nodes = MustacheAST('{{#items}}{{.}}{{/items}}').parse();
      expect(
        renderer.render(nodes, {
          'items': ['a', 'b', 'c'],
        }),
        'abc',
      );
    });

    test('renders inverted sections when empty', () {
      final nodes = MustacheAST('{{^items}}no items{{/items}}').parse();
      expect(renderer.render(nodes, {'items': []}), 'no items');
    });

    test('hides inverted sections when not empty', () {
      final nodes = MustacheAST('{{^items}}no items{{/items}}').parse();
      expect(
          renderer.render(nodes, {
            'items': [1]
          }),
          '');
    });

    test('comments produce no output', () {
      final nodes = MustacheAST('before{{! comment }}after').parse();
      expect(renderer.render(nodes, {}), 'beforeafter');
    });

    test('renders dotted names', () {
      final nodes = MustacheAST('{{user.name}}').parse();
      expect(
        renderer.render(nodes, {
          'user.name': 'Alice',
        }),
        'Alice',
      );
    });

    test('renders nested dot-path resolution', () {
      final nodes = MustacheAST('{{user.name}}').parse();
      expect(
        renderer.render(nodes, {
          'user': {'name': 'Bob'},
        }),
        'Bob',
      );
    });

    test('renders nested sections', () {
      final nodes = MustacheAST(
        '{{#outer}}{{#inner}}x{{/inner}}{{/outer}}',
      ).parse();
      expect(
        renderer.render(nodes, {
          'outer': [
            {
              'inner': [1]
            },
          ],
        }),
        'x',
      );
    });
  });
}
