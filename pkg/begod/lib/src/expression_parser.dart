import 'generated/MustacheParser.dart';
import 'ast.dart';

extension ExprToArg on ExprContext {
  Arg toArg() {
    return orExpr()?.toArg() ?? StringArg('');
  }
}

extension OrExprToArg on OrExprContext {
  Arg toArg() {
    final operands = andExprs();
    if (operands.isEmpty) return StringArg('');
    Arg result = operands[0].toArg();
    for (var i = 0; i < ops.length && i + 1 < operands.length; i++) {
      final op = ops[i].text!;
      result = BinaryExpr(result, op, operands[i + 1].toArg());
    }
    return result;
  }
}

extension AndExprToArg on AndExprContext {
  Arg toArg() {
    final operands = cmpExprs();
    if (operands.isEmpty) return StringArg('');
    Arg result = operands[0].toArg();
    for (var i = 0; i < ops.length && i + 1 < operands.length; i++) {
      final op = ops[i].text!;
      result = BinaryExpr(result, op, operands[i + 1].toArg());
    }
    return result;
  }
}

extension CmpExprToArg on CmpExprContext {
  Arg toArg() {
    final operands = addExprs();
    if (operands.isEmpty) return StringArg('');
    Arg result = operands[0].toArg();
    for (var i = 0; i < ops.length && i + 1 < operands.length; i++) {
      final op = ops[i].text!;
      result = BinaryExpr(result, op, operands[i + 1].toArg());
    }
    return result;
  }
}

extension AddExprToArg on AddExprContext {
  Arg toArg() {
    final operands = mulExprs();
    if (operands.isEmpty) return StringArg('');
    Arg result = operands[0].toArg();
    for (var i = 0; i < ops.length && i + 1 < operands.length; i++) {
      final op = ops[i].text!;
      result = BinaryExpr(result, op, operands[i + 1].toArg());
    }
    return result;
  }
}

extension MulExprToArg on MulExprContext {
  Arg toArg() {
    final operands = unaryExprs();
    if (operands.isEmpty) return StringArg('');
    Arg result = operands[0].toArg();
    for (var i = 0; i < ops.length && i + 1 < operands.length; i++) {
      final op = ops[i].text!;
      result = BinaryExpr(result, op, operands[i + 1].toArg());
    }
    return result;
  }
}

extension UnaryExprToArg on UnaryExprContext {
  Arg toArg() {
    final pa = pipeAtom();
    if (pa == null) return StringArg('');
    final arg = pa.toArg();
    if (MINUS() != null) {
      return UnaryExpr('-', arg);
    }
    return arg;
  }
}

extension PipeAtomToArg on PipeAtomContext {
  Arg toArg() {
    final a = atom();
    if (a == null) return StringArg('');
    final input = a.toArg();
    final calls = filterCalls();
    if (calls.isEmpty) return input;
    final filters = calls
        .map((c) => FilterCall(
              c.NAME()?.text ?? '',
              c.exprList()?.exprs().map((e) => e.toArg()).toList() ?? [],
            ))
        .toList();
    return FilterExpr(input, filters);
  }
}

extension AtomToArg on AtomContext {
  Arg toArg() {
    if (NUMBER() != null) {
      return NumberArg(num.parse(NUMBER()!.text!));
    }
    if (STRING() != null) {
      var text = STRING()!.text!;
      text = text.substring(1, text.length - 1);
      return StringArg(text);
    }
    if (TRUE() != null) return BoolArg(true);
    if (FALSE() != null) return BoolArg(false);
    if (NAME() != null) return VariableArg(NAME()!.text!);
    if (expr() != null) return expr()!.toArg();
    return StringArg('');
  }
}
