import 'package:test/test.dart';
import 'package:begod/src/ast.dart';
import 'package:begod/src/renderer.dart';

/// Parses and renders a template, returning the result string.
/// Re-throws any exception for test assertions.
String _render(String template, [Object? data = const {}]) {
  final nodes = MustacheAST(template).parse();
  return MustacheRenderer().render(nodes, data);
}

/// Parses a template, returning nodes. Re-throws any exception.
List<Node> _parse(String template) {
  return MustacheAST(template).parse();
}

void main() {
  group('robustness: no crash on malformed templates', () {
    test('unclosed variable tag', () {
      expect(() => _render('Hello {{name'), returnsNormally);
    });

    test('unclosed variable tag with text after', () {
      expect(() => _render('Hello {{name World'), returnsNormally);
    });

    test('unclosed triple-brace tag', () {
      expect(() => _render('Hello {{{name'), returnsNormally);
    });

    test('unclosed section', () {
      expect(() => _render('start {{#section}}middle'), returnsNormally);
    });

    test('extra closing tag at end', () {
      expect(() => _render('Hello {{/unknown}}'), returnsNormally);
    });

    test('extra closing tag in middle', () {
      expect(() => _render('Hello {{/x}} World'), returnsNormally);
    });

    test('mismatched section open and close', () {
      expect(() => _render('{{#foo}}hello{{/bar}}'), returnsNormally);
    });

    test('mismatched inverted section', () {
      expect(() => _render('{{^foo}}hello{{/bar}}'), returnsNormally);
    });

    test('incomplete expression: trailing operator', () {
      expect(() => _parse('{{a +}}'), returnsNormally);
    });

    test('incomplete expression: leading operator', () {
      expect(() => _parse('{{+ a}}'), returnsNormally);
    });

    test('incomplete expression: double operator', () {
      expect(() => _parse('{{a + * b}}'), returnsNormally);
    });

    test('incomplete expression: empty parentheses', () {
      expect(() => _parse('{{()}}'), returnsNormally);
    });

    test('incomplete expression: unclosed parentheses', () {
      expect(() => _parse('{{(a + b}}'), returnsNormally);
    });

    test('incomplete expression: extra closing paren', () {
      expect(() => _parse('{{a + b)}}'), returnsNormally);
    });

    test('incomplete expression: dangling and', () {
      expect(() => _parse('{{a &&}}'), returnsNormally);
    });

    test('incomplete expression: dangling or', () {
      expect(() => _parse('{{a ||}}'), returnsNormally);
    });

    test('incomplete expression: dangling comparison', () {
      expect(() => _parse('{{a ==}}'), returnsNormally);
    });

    test('incomplete filter: trailing pipe', () {
      expect(() => _parse('{{name |}}'), returnsNormally);
    });

    test('incomplete filter: unclosed paren args', () {
      expect(() => _parse('{{name | truncate(5}}'), returnsNormally);
    });

    test('incomplete filter: extra closing paren', () {
      expect(() => _parse('{{name | uppercase)}}'), returnsNormally);
    });

    test('nested sections that close in wrong order', () {
      expect(() => _render('{{#a}}{{#b}}{{/a}}{{/b}}'), returnsNormally);
    });

    test('deeply nested sections', () {
      final open = List.generate(50, (i) => '{{#l$i}}').join();
      final close = List.generate(50, (i) => '{{/l${49 - i}}}').join();
      final template = '$open${'x'}$close';
      expect(() => _parse(template), returnsNormally);
    });

    test('empty template', () {
      expect(() => _parse(''), returnsNormally);
      expect(() => _parse('   \n  \t '), returnsNormally);
    });

    test('null bytes in template', () {
      expect(() => _parse('Hello\u0000World'), returnsNormally);
    });

    test('lone brace without closing', () {
      expect(() => _render('Hello {world'), returnsNormally);
    });

    test('unclosed comment', () {
      expect(() => _parse('{{! this comment never ends'), returnsNormally);
    });

    test('tag with only whitespace', () {
      expect(() => _parse('{{   }}'), returnsNormally);
    });

    test('tag with unknown operator', () {
      expect(() => _parse('{{@something}}'), returnsNormally);
    });

    test('very long template', () {
      final long = 'x' * 10000;
      expect(() => _parse(long), returnsNormally);
    });

    test('many unclosed tags', () {
      expect(() => _parse('{{a}} {{b}} {{c} {{d}} {{e}'), returnsNormally);
    });
  });

  group('graceful degradation', () {
    test('unclosed variable produces partial output', () {
      final result = _render('Hello {{name');
      expect(result, isNotEmpty);
    });

    test('unclosed section still renders content', () {
      final result = _render('start {{#section}}middle');
      expect(result, contains('start'));
    });

    test('mismatched section renders what it can', () {
      final result = _render('{{#foo}}hello{{/bar}}');
      // Section "foo" is unmatched and not found in context; still no crash
      expect(result, isNotNull);
    });

    test('incomplete expression renders gracefully', () {
      final result = _render('{{a +}}');
      expect(result, isNotNull);
    });

    test('rendering with null data does not crash', () {
      expect(() => _render('Hello {{name}}', null), returnsNormally);
    });

    test('rendering with non-map data does not crash', () {
      expect(() => _render('Hello {{name}}', 42), returnsNormally);
    });

    test('rendering deep context does not stack overflow', () {
      var ctx = <String, dynamic>{};
      var current = ctx;
      for (var i = 0; i < 20; i++) {
        current['nested'] = <String, dynamic>{};
        current = current['nested'] as Map<String, dynamic>;
      }
      current['leaf'] = 'found';
      expect(() => _render('{{leaf}}', ctx), returnsNormally);
    });
  });

  group('informative error output', () {
    test('mismatched section produces warning-like behavior', () {
      // The parser should not throw; instead produce partial output
      final result = _render('before {{#ok}}inside{{/wrong}} after');
      expect(result, isNotNull);
      expect(result, isNotEmpty);
    });

    test('filter with unknown name passes through', () {
      final result = _render('{{name | nosuchfilter}}', {'name': 'hello'});
      expect(result, contains('hello'));
    });

    test('chained filters with unknown middle filter', () {
      final result =
          _render('{{name | nosuchfilter | uppercase}}', {'name': 'hello'});
      expect(result, contains('HELLO'));
    });
  });
}
