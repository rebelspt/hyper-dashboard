import 'helper.dart';
import '../ast.dart';

class LetContext {
  final Object? parent;
  final String name;
  final Object? value;
  const LetContext(this.parent, this.name, this.value);
}

class LetHelper extends MustacheHelper {
  @override
  String get name => 'let';

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
    String varName;
    Arg valueExpr;

    if (args.length >= 2) {
      varName = _extractName(args[0]);
      valueExpr = args[1];
    } else if (args.length == 1 && args[0] is BinaryExpr) {
      final bin = args[0] as BinaryExpr;
      varName = _extractName(bin.left);
      if (varName.isEmpty) return '';
      valueExpr = UnaryExpr(bin.operator, bin.right);
    } else {
      return '';
    }

    if (varName.isEmpty) return '';
    final value = r.resolveArg(valueExpr, context);
    final letCtx = LetContext(context, varName, value);
    return r.renderNodes(children, letCtx);
  }

  String _extractName(Arg arg) {
    return arg is VariableArg ? arg.name : '';
  }
}
