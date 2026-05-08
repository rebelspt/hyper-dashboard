import 'ast.dart';
import 'renderer.dart';
import 'helpers/registry.dart';
import 'filters/registry.dart';

/// Public API for the Mustache template engine.
///
/// Usage:
/// ```dart
/// final template = MustacheTemplate('Hello, {{name}}!');
/// final output = template.render({'name': 'World'});
/// ```
class MustacheTemplate {
  final List<Node> _ast;
  final HelperRegistry? _helperRegistry;
  final FilterRegistry? _filterRegistry;

  MustacheTemplate._(
    this._ast, {
    HelperRegistry? helperRegistry,
    FilterRegistry? filterRegistry,
  })  : _helperRegistry = helperRegistry,
        _filterRegistry = filterRegistry;

  factory MustacheTemplate(
    String template, {
    HelperRegistry? helperRegistry,
    FilterRegistry? filterRegistry,
  }) {
    final parser = MustacheAST(template);
    final ast = parser.parse();
    return MustacheTemplate._(
      ast,
      helperRegistry: helperRegistry,
      filterRegistry: filterRegistry,
    );
  }

  bool hasReference(String name) {
    return _hasReference(_ast, name);
  }

  bool _hasReference(List<Node> nodes, String key) {
    for (final node in nodes) {
      switch (node) {
        case VariableNode(:final expr):
          if (_exprRefers(expr, key)) return true;
        case SectionNode(:final name, :final args, :final children):
          if (name == key || name.startsWith('$key.')) return true;
          for (final arg in args) {
            if (_argRefers(arg, key)) return true;
          }
          if (_hasReference(children, key)) return true;
        case InvertedNode(:final name, :final args, :final children):
          if (name == key || name.startsWith('$key.')) return true;
          for (final arg in args) {
            if (_argRefers(arg, key)) return true;
          }
          if (_hasReference(children, key)) return true;
        case PartialNode():
        case CommentNode():
        case TextNode():
        case UnescapedNode():
          break;
      }
    }
    return false;
  }

  bool _exprRefers(Arg expr, String key) {
    switch (expr) {
      case VariableArg(:final name):
        return name == key || name.startsWith('$key.');
      case BinaryExpr(:final left, :final right):
        return _exprRefers(left, key) || _exprRefers(right, key);
      case UnaryExpr(:final operand):
        return _exprRefers(operand, key);
      case FilterExpr(:final input, :final filters):
        if (_exprRefers(input, key)) return true;
        for (final f in filters) {
          for (final arg in f.args) {
            if (_argRefers(arg, key)) return true;
          }
        }
        return false;
      case StringArg():
      case NumberArg():
      case BoolArg():
        return false;
    }
  }

  bool _argRefers(Arg arg, String key) {
    if (arg is VariableArg) {
      return arg.name == key || arg.name.startsWith('$key.');
    }
    return _exprRefers(arg, key);
  }

  String render(dynamic data, {Map<String, String> partials = const {}}) {
    final renderer = MustacheRenderer(
      partialResolver:
          partials.isNotEmpty ? (name) => partials[name] ?? '' : null,
      helperRegistry: _helperRegistry,
      filterRegistry: _filterRegistry,
    );
    return renderer.render(_ast, data);
  }
}
