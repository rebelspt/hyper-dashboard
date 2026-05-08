import 'package:test/test.dart';
import 'package:begod/src/ast.dart';
import 'package:begod/src/expression_evaluator.dart';

ExpressionEvaluator _evaluator() {
  return ExpressionEvaluator(
    resolve: (name, context) {
      if (context is Map<String, Object?>) {
        return context[name];
      }
      return null;
    },
    stringify: (v) {
      if (v == null) return '';
      if (v is String) return v;
      return v.toString();
    },
    isTruthy: (v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is String) return v.isNotEmpty;
      if (v is List) return v.isNotEmpty;
      if (v is Map) return v.isNotEmpty;
      if (v is num) return v != 0;
      return true;
    },
    looseEqual: (a, b) {
      if (a == null && b == null) return true;
      if (a == null || b == null) return false;
      if (a.runtimeType == b.runtimeType) return a == b;
      if (a is num && b is String) return a.toString() == b;
      if (a is String && b is num) return a == b.toString();
      return a == b;
    },
  );
}

void main() {
  group('ExpressionEvaluator atoms', () {
    final e = _evaluator();

    test('StringArg returns value', () {
      expect(e.evaluate(StringArg('hello'), null), 'hello');
    });

    test('NumberArg returns value', () {
      expect(e.evaluate(NumberArg(42), null), 42);
      expect(e.evaluate(NumberArg(3.14), null), 3.14);
    });

    test('BoolArg returns value', () {
      expect(e.evaluate(BoolArg(true), null), true);
      expect(e.evaluate(BoolArg(false), null), false);
    });

    test('VariableArg resolves from context', () {
      expect(e.evaluate(VariableArg('name'), {'name': 'Alice'}), 'Alice');
    });

    test('VariableArg returns null for missing key', () {
      expect(e.evaluate(VariableArg('name'), {}), isNull);
    });

    test('VariableArg returns null for null context', () {
      expect(e.evaluate(VariableArg('name'), null), isNull);
    });
  });

  group('ExpressionEvaluator arithmetic', () {
    final e = _evaluator();

    test('addition with numbers', () {
      final arg = BinaryExpr(NumberArg(2), '+', NumberArg(3));
      expect(e.evaluate(arg, null), 5);
    });

    test('subtraction', () {
      final arg = BinaryExpr(NumberArg(10), '-', NumberArg(4));
      expect(e.evaluate(arg, null), 6);
    });

    test('multiplication', () {
      final arg = BinaryExpr(NumberArg(3), '*', NumberArg(4));
      expect(e.evaluate(arg, null), 12);
    });

    test('division', () {
      final arg = BinaryExpr(NumberArg(10), '/', NumberArg(2));
      expect(e.evaluate(arg, null), 5.0);
    });

    test('division by zero returns 0', () {
      final arg = BinaryExpr(NumberArg(10), '/', NumberArg(0));
      expect(e.evaluate(arg, null), 0);
    });

    test('non-numeric subtraction returns 0', () {
      final arg = BinaryExpr(StringArg('a'), '-', StringArg('b'));
      expect(e.evaluate(arg, null), 0);
    });

    test('non-numeric division returns 0', () {
      final arg = BinaryExpr(StringArg('a'), '/', StringArg('b'));
      expect(e.evaluate(arg, null), 0);
    });
  });

  group('ExpressionEvaluator string concatenation', () {
    final e = _evaluator();

    test('+ concatenates strings', () {
      final arg = BinaryExpr(StringArg('Hello, '), '+', StringArg('World'));
      expect(e.evaluate(arg, null), 'Hello, World');
    });

    test('+ concatenates string and number', () {
      final arg = BinaryExpr(StringArg('count: '), '+', NumberArg(5));
      expect(e.evaluate(arg, null), 'count: 5');
    });

    test('+ concatenates number and string', () {
      final arg = BinaryExpr(NumberArg(5), '+', StringArg(' items'));
      expect(e.evaluate(arg, null), '5 items');
    });

    test('+ concatenates null as empty string', () {
      final arg = BinaryExpr(StringArg('Hello'), '+', VariableArg('missing'));
      expect(e.evaluate(arg, null), 'Hello');
    });
  });

  group('ExpressionEvaluator boolean operators', () {
    final e = _evaluator();

    test('&& with both true', () {
      final arg = BinaryExpr(BoolArg(true), '&&', BoolArg(true));
      expect(e.evaluate(arg, null), true);
    });

    test('&& with one false', () {
      final arg = BinaryExpr(BoolArg(true), '&&', BoolArg(false));
      expect(e.evaluate(arg, null), false);
    });

    test('|| with one true', () {
      final arg = BinaryExpr(BoolArg(false), '||', BoolArg(true));
      expect(e.evaluate(arg, null), true);
    });

    test('|| with both false', () {
      final arg = BinaryExpr(BoolArg(false), '||', BoolArg(false));
      expect(e.evaluate(arg, null), false);
    });

    test('&& truthy on numbers', () {
      final arg = BinaryExpr(NumberArg(1), '&&', NumberArg(2));
      expect(e.evaluate(arg, null), true);
    });

    test('&& with zero is falsy', () {
      final arg = BinaryExpr(NumberArg(0), '&&', BoolArg(true));
      expect(e.evaluate(arg, null), false);
    });
  });

  group('ExpressionEvaluator comparison operators', () {
    final e = _evaluator();

    test('== equal numbers', () {
      expect(
          e.evaluate(BinaryExpr(NumberArg(5), '==', NumberArg(5)), null), true);
      expect(e.evaluate(BinaryExpr(NumberArg(5), '==', NumberArg(3)), null),
          false);
    });

    test('== loose equal number and string', () {
      final arg = BinaryExpr(NumberArg(5), '==', StringArg('5'));
      expect(e.evaluate(arg, null), true);
    });

    test('!= not equal', () {
      expect(
          e.evaluate(BinaryExpr(NumberArg(5), '!=', NumberArg(3)), null), true);
      expect(e.evaluate(BinaryExpr(NumberArg(5), '!=', NumberArg(5)), null),
          false);
    });

    test('< less than', () {
      expect(
          e.evaluate(BinaryExpr(NumberArg(3), '<', NumberArg(5)), null), true);
      expect(
          e.evaluate(BinaryExpr(NumberArg(5), '<', NumberArg(3)), null), false);
      expect(
          e.evaluate(BinaryExpr(NumberArg(5), '<', NumberArg(5)), null), false);
    });

    test('> greater than', () {
      expect(
          e.evaluate(BinaryExpr(NumberArg(5), '>', NumberArg(3)), null), true);
      expect(
          e.evaluate(BinaryExpr(NumberArg(3), '>', NumberArg(5)), null), false);
      expect(
          e.evaluate(BinaryExpr(NumberArg(5), '>', NumberArg(5)), null), false);
    });

    test('<= less than or equal', () {
      expect(
          e.evaluate(BinaryExpr(NumberArg(3), '<=', NumberArg(5)), null), true);
      expect(
          e.evaluate(BinaryExpr(NumberArg(5), '<=', NumberArg(5)), null), true);
      expect(e.evaluate(BinaryExpr(NumberArg(5), '<=', NumberArg(3)), null),
          false);
    });

    test('>= greater than or equal', () {
      expect(
          e.evaluate(BinaryExpr(NumberArg(5), '>=', NumberArg(3)), null), true);
      expect(
          e.evaluate(BinaryExpr(NumberArg(5), '>=', NumberArg(5)), null), true);
      expect(e.evaluate(BinaryExpr(NumberArg(3), '>=', NumberArg(5)), null),
          false);
    });

    test('non-numeric comparison returns false', () {
      expect(e.evaluate(BinaryExpr(StringArg('a'), '<', StringArg('b')), null),
          false);
      expect(e.evaluate(BinaryExpr(StringArg('a'), '>', StringArg('b')), null),
          false);
    });
  });

  group('ExpressionEvaluator unary', () {
    final e = _evaluator();

    test('unary minus on positive number', () {
      final arg = UnaryExpr('-', NumberArg(5));
      expect(e.evaluate(arg, null), -5);
    });

    test('unary minus on negative number', () {
      final arg = UnaryExpr('-', NumberArg(-3));
      expect(e.evaluate(arg, null), 3);
    });

    test('unary minus on zero', () {
      final arg = UnaryExpr('-', NumberArg(0));
      expect(e.evaluate(arg, null), 0);
    });

    test('unary minus on non-number returns 0', () {
      final arg = UnaryExpr('-', StringArg('hello'));
      expect(e.evaluate(arg, null), 0);
    });
  });

  group('ExpressionEvaluator nested expressions', () {
    final e = _evaluator();

    test('nested binary expressions', () {
      final inner = BinaryExpr(NumberArg(3), '*', NumberArg(4));
      final outer = BinaryExpr(inner, '+', NumberArg(2));
      expect(e.evaluate(outer, null), 14);
    });

    test('deeply nested binary expressions', () {
      final mul = BinaryExpr(NumberArg(3), '*', NumberArg(4));
      final div = BinaryExpr(mul, '/', NumberArg(2));
      final sub = BinaryExpr(NumberArg(10), '-', div);
      expect(e.evaluate(sub, null), 4.0);
    });

    test('nested comparison with boolean', () {
      final cmp = BinaryExpr(NumberArg(5), '>', NumberArg(3));
      final combined = BinaryExpr(cmp, '&&', BoolArg(true));
      expect(e.evaluate(combined, null), true);
    });

    test('nested unary inside binary', () {
      final neg = UnaryExpr('-', NumberArg(5));
      final sum = BinaryExpr(NumberArg(10), '+', neg);
      expect(e.evaluate(sum, null), 5);
    });
  });

  group('ExpressionEvaluator precedence via tree structure', () {
    final e = _evaluator();

    test('left-associative: (10 - 4) - 2 == 4', () {
      final inner = BinaryExpr(NumberArg(10), '-', NumberArg(4));
      final outer = BinaryExpr(inner, '-', NumberArg(2));
      expect(e.evaluate(outer, null), 4);
    });

    test('multiplication before addition: (2 + 3) * 4 == 20', () {
      final sum = BinaryExpr(NumberArg(2), '+', NumberArg(3));
      final mul = BinaryExpr(sum, '*', NumberArg(4));
      expect(e.evaluate(mul, null), 20);
    });

    test('comparison before AND: (5 > 3) && (2 < 4) == true', () {
      final left = BinaryExpr(NumberArg(5), '>', NumberArg(3));
      final right = BinaryExpr(NumberArg(2), '<', NumberArg(4));
      final combined = BinaryExpr(left, '&&', right);
      expect(e.evaluate(combined, null), true);
    });
  });

  group('ExpressionEvaluator edge cases', () {
    final e = _evaluator();

    test('unknown operator returns null', () {
      final arg = BinaryExpr(NumberArg(1), '?', NumberArg(2));
      expect(e.evaluate(arg, null), isNull);
    });

    test('unknown unary operator returns value as-is', () {
      final arg = UnaryExpr('+', NumberArg(5));
      expect(e.evaluate(arg, null), 5);
    });

    test('variable resolution inside nested expression', () {
      final v = VariableArg('price');
      final tax = BinaryExpr(NumberArg(1), '+', VariableArg('rate'));
      final mul = BinaryExpr(v, '*', tax);
      final result = e.evaluate(mul, {'price': 100, 'rate': 0.1});
      expect(result, isA<num>());
      expect((result as num).round(), 110);
    });
  });
}
