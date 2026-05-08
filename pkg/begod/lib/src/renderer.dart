import 'ast.dart';
import 'resolver.dart';
import 'expression_evaluator.dart';
import 'helpers/helper.dart';
import 'helpers/registry.dart';
import 'helpers/each_helper.dart';
import 'helpers/let_helper.dart';
import 'filters/registry.dart';

Map<String, String> _htmlEscapeCache = {
  '&': '&amp;',
  '"': '&quot;',
  '<': '&lt;',
  '>': '&gt;',
};

String htmlEscape(String s) {
  return s.replaceAllMapped(
    RegExp('[&"<>]'),
    (m) => _htmlEscapeCache[m.group(0)!]!,
  );
}

typedef PartialResolver = String Function(String name);
typedef ValueResolver = Object? Function(String name);

class MustacheRenderer implements HelperDelegate {
  final PartialResolver? partialResolver;
  final HelperRegistry _helperRegistry;
  late final ExpressionEvaluator _evaluator;

  MustacheRenderer({
    this.partialResolver,
    HelperRegistry? helperRegistry,
    FilterRegistry? filterRegistry,
  }) : _helperRegistry = helperRegistry ?? HelperRegistry.defaults() {
    _evaluator = ExpressionEvaluator(
      resolve: resolve,
      stringify: stringify,
      isTruthy: isTruthy,
      looseEqual: looseEqual,
      filterRegistry: filterRegistry ?? FilterRegistry.defaults(),
    );
  }

  String render(List<Node> nodes, Object? context) {
    return renderNodes(nodes, context);
  }

  @override
  String renderNodes(List<Node> nodes, Object? context) {
    final buf = StringBuffer();
    for (final node in nodes) {
      buf.write(_renderNode(node, context));
    }
    return buf.toString();
  }

  String _renderNode(Node node, Object? context) {
    switch (node) {
      case TextNode(:final text):
        return text;

      case VariableNode(:final expr):
        final value = resolveArg(expr, context);
        final str = stringify(value);
        return htmlEscape(str);

      case UnescapedNode(:final name):
        final value = resolve(name, context);
        return stringify(value);

      case SectionNode(:final name, :final args, :final children):
        final helper = _helperRegistry.get(name);
        if (helper != null) {
          return helper.render(children, args, false, context, this);
        }
        final value = resolve(name, context);
        return _renderSection(value, children, context);

      case InvertedNode(:final name, :final args, :final children):
        final helper = _helperRegistry.get(name);
        if (helper != null) {
          return helper.render(children, args, true, context, this);
        }
        final value = resolve(name, context);
        final list = toList(value);
        if (list.isEmpty) {
          return render(children, context);
        }
        return '';

      case PartialNode(:final name):
        if (partialResolver == null) return '';
        final partialTemplate = partialResolver!(name);
        final parser = MustacheAST(partialTemplate);
        final partialNodes = parser.parse();
        return render(partialNodes, context);

      case CommentNode():
        return '';
    }
  }

  String _renderSection(
    Object? value,
    List<Node> children,
    Object? context,
  ) {
    if (value is bool && !value) return '';

    final list = toList(value);
    if (list.isEmpty) return '';

    final buf = StringBuffer();
    for (final item in list) {
      buf.write(render(children, _SectionContext(item, context)));
    }
    return buf.toString();
  }

  @override
  List<Object?> toList(Object? value) {
    if (value == null) return const [];
    if (value is List) return value;
    if (value is bool) return value ? [value] : const [];
    return [value];
  }

  @override
  bool compare(Arg a, Arg b, Object? context, bool Function(num, num) op) {
    var av = resolveArg(a, context);
    var bv = resolveArg(b, context);
    if (av is String) av = num.tryParse(av);
    if (bv is String) bv = num.tryParse(bv);
    if (av is num && bv is num) return op(av, bv);
    return false;
  }

  @override
  String stringify(Object? value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  @override
  Object? resolve(String name, Object? context) {
    if (context is LetContext) {
      if (name == context.name) return context.value;
      return resolve(name, context.parent);
    }
    if (context is LoopContext) {
      switch (name) {
        case '@index':
          return context.index;
        case '@first':
          return context.isFirst;
        case '@last':
          return context.isLast;
        case '.':
          return context.item;
        default:
          return resolveValue(name, context.item);
      }
    }
    if (context is _SectionContext) {
      final result = resolveValue(name, context.child);
      if (result != null ||
          (context.child is Map && (context.child as Map).containsKey(name))) {
        return result;
      }
      return resolve(name, context.parent);
    }
    return resolveValue(name, context);
  }

  @override
  String htmlEscape(String s) {
    return s.replaceAllMapped(
      RegExp('[&"<>]'),
      (m) => _htmlEscapeCache[m.group(0)!]!,
    );
  }

  @override
  Object? resolveArg(Arg arg, Object? context) {
    return _evaluator.evaluate(arg, context);
  }

  @override
  bool isTruthy(Object? value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    if (value is num) return value != 0;
    return true;
  }

  @override
  bool looseEqual(Object? a, Object? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.runtimeType == b.runtimeType) return a == b;
    if (a is num && b is String) return a.toString() == b;
    if (a is String && b is num) return a == b.toString();
    return a == b;
  }
}

class _SectionContext {
  final Object? child;
  final Object? parent;
  _SectionContext(this.child, this.parent);
}
