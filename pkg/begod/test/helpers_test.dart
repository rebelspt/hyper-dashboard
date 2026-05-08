import 'package:test/test.dart';
import 'package:begod/src/ast.dart';
import 'package:begod/src/renderer.dart';
import 'package:begod/src/helpers/helper.dart';
import 'package:begod/src/helpers/registry.dart';

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
    if (inverted) return '';
    final name = (renderer as HelperDelegate).resolve('name', context);
    return 'Hello, ${(renderer).stringify(name)}!';
  }
}

class WrapHelper extends MustacheHelper {
  @override
  String get name => 'wrap';

  @override
  String render(
    List<Node> children,
    List<Arg> args,
    bool inverted,
    Object? context,
    dynamic renderer,
  ) {
    if (inverted) return '';
    final r = renderer as HelperDelegate;
    final inner = r.renderNodes(children, context);
    return '<div class="wrap">$inner</div>';
  }
}

void main() {
  group('HelperRegistry', () {
    test('registers and retrieves helpers', () {
      final registry = HelperRegistry();
      final helper = GreetHelper();
      registry.register(helper);
      expect(registry.get('greet'), same(helper));
    });

    test('returns null for unregistered helper', () {
      final registry = HelperRegistry();
      expect(registry.get('unknown'), isNull);
    });

    test('contains returns true for registered helper', () {
      final registry = HelperRegistry();
      registry.register(GreetHelper());
      expect(registry.contains('greet'), isTrue);
      expect(registry.contains('unknown'), isFalse);
    });
  });

  group('custom GreetHelper', () {
    test('renders greeting using context', () {
      final registry = HelperRegistry()..register(GreetHelper());
      final renderer = MustacheRenderer(helperRegistry: registry);
      final nodes = MustacheAST('{{#greet}}{{/greet}}').parse();
      expect(renderer.render(nodes, {'name': 'Alice'}), 'Hello, Alice!');
    });
  });

  group('custom WrapHelper', () {
    test('renders children inside wrapper', () {
      final registry = HelperRegistry()..register(WrapHelper());
      final renderer = MustacheRenderer(helperRegistry: registry);
      final nodes = MustacheAST('{{#wrap}}inner text{{/wrap}}').parse();
      expect(renderer.render(nodes, {}), '<div class="wrap">inner text</div>');
    });

    test('renders children with variable interpolation', () {
      final registry = HelperRegistry()..register(WrapHelper());
      final renderer = MustacheRenderer(helperRegistry: registry);
      final nodes = MustacheAST('{{#wrap}}Hello, {{name}}{{/wrap}}').parse();
      expect(
        renderer.render(nodes, {'name': 'Bob'}),
        '<div class="wrap">Hello, Bob</div>',
      );
    });
  });

  group('section fallback', () {
    test('unregistered name still works as data section', () {
      final registry = HelperRegistry();
      final renderer = MustacheRenderer(helperRegistry: registry);
      final nodes = MustacheAST('{{#items}}{{.}}{{/items}}').parse();
      expect(
        renderer.render(nodes, {
          'items': ['a', 'b']
        }),
        'ab',
      );
    });
  });

  group('arg parsing', () {
    test('parses string args', () {
      final nodes = MustacheAST('{{#greet "hello"}}x{{/greet}}').parse();
      final section = nodes[0] as SectionNode;
      expect(section.args, [isA<StringArg>()]);
      expect((section.args[0] as StringArg).value, 'hello');
    });

    test('parses number args', () {
      final nodes = MustacheAST('{{#if count > 10}}x{{/if}}').parse();
      final section = nodes[0] as SectionNode;
      expect(section.args.length, 1);
      final expr = section.args[0] as BinaryExpr;
      expect(expr.left, isA<VariableArg>());
      expect((expr.left as VariableArg).name, 'count');
      expect(expr.operator, '>');
      expect(expr.right, isA<NumberArg>());
      expect((expr.right as NumberArg).value, 10);
    });

    test('parses boolean args', () {
      final nodes = MustacheAST('{{#if show == true}}x{{/if}}').parse();
      final section = nodes[0] as SectionNode;
      final expr = section.args[0] as BinaryExpr;
      expect(expr.right, isA<BoolArg>());
      expect((expr.right as BoolArg).value, true);
    });

    test('parses variable args', () {
      final nodes = MustacheAST('{{#if a == b}}x{{/if}}').parse();
      final section = nodes[0] as SectionNode;
      final expr = section.args[0] as BinaryExpr;
      expect(expr.left, isA<VariableArg>());
      expect(expr.right, isA<VariableArg>());
      expect((expr.left as VariableArg).name, 'a');
      expect((expr.right as VariableArg).name, 'b');
    });

    test('no args produces empty list', () {
      final nodes = MustacheAST('{{#items}}x{{/items}}').parse();
      final section = nodes[0] as SectionNode;
      expect(section.args, isEmpty);
    });
  });
}
