import 'ast.dart';
import 'filters/registry.dart';

class ExpressionEvaluator {
  final Object? Function(String name, Object? context) _resolve;
  final String Function(Object? value) _stringify;
  final bool Function(Object? value) _isTruthy;
  final bool Function(Object? a, Object? b) _looseEqual;
  final FilterRegistry _filterRegistry;

  ExpressionEvaluator({
    required Object? Function(String name, Object? context) resolve,
    required String Function(Object? value) stringify,
    required bool Function(Object? value) isTruthy,
    required bool Function(Object? a, Object? b) looseEqual,
    FilterRegistry? filterRegistry,
  })  : _resolve = resolve,
        _stringify = stringify,
        _isTruthy = isTruthy,
        _looseEqual = looseEqual,
        _filterRegistry = filterRegistry ?? FilterRegistry();

  Object? evaluate(Arg arg, Object? context) {
    switch (arg) {
      case VariableArg(:final name):
        return _resolve(name, context);
      case StringArg(:final value):
        return value;
      case NumberArg(:final value):
        return value;
      case BoolArg(:final value):
        return value;
      case BinaryExpr(:final left, :final operator, :final right):
        return _evalBinary(left, operator, right, context);
      case UnaryExpr(:final operator, :final operand):
        return _evalUnary(operator, operand, context);
      case FilterExpr(:final input, :final filters):
        return _evalFilters(input, filters, context);
    }
  }

  Object? _evalFilters(Arg input, List<FilterCall> filters, Object? context) {
    var result = evaluate(input, context);
    for (final filter in filters) {
      final f = _filterRegistry.get(filter.name);
      if (f == null) continue;
      final resolvedArgs =
          filter.args.map((a) => evaluate(a, context)).toList();
      result = f.apply(result, resolvedArgs);
    }
    return result;
  }

  Object? _evalBinary(Arg left, String op, Arg right, Object? context) {
    final lv = evaluate(left, context);
    final rv = evaluate(right, context);

    switch (op) {
      case '+':
        if (lv is String || rv is String) {
          return _stringify(lv) + _stringify(rv);
        }
        if (lv is num && rv is num) return lv + rv;
        return _stringify(lv) + _stringify(rv);
      case '-':
        if (lv is num && rv is num) return lv - rv;
        return 0;
      case '*':
        if (lv is num && rv is num) return lv * rv;
        return 0;
      case '/':
        if (lv is num && rv is num && rv != 0) return lv / rv;
        return 0;
      case '&&':
        return _isTruthy(lv) && _isTruthy(rv);
      case '||':
        return _isTruthy(lv) || _isTruthy(rv);
      case '==':
        return _looseEqual(lv, rv);
      case '!=':
        return !_looseEqual(lv, rv);
      case '<':
        if (lv is num && rv is num) return lv < rv;
        return false;
      case '>':
        if (lv is num && rv is num) return lv > rv;
        return false;
      case '<=':
        if (lv is num && rv is num) return lv <= rv;
        return false;
      case '>=':
        if (lv is num && rv is num) return lv >= rv;
        return false;
      default:
        return null;
    }
  }

  Object? _evalUnary(String op, Arg operand, Object? context) {
    final v = evaluate(operand, context);
    switch (op) {
      case '-':
        if (v is num) return -v;
        return 0;
      default:
        return v;
    }
  }
}
