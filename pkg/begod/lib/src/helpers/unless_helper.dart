import 'helper.dart';
import '../ast.dart';

class UnlessHelper extends MustacheHelper {
  @override
  String get name => 'unless';

  @override
  String render(
    List<Node> children,
    List<Arg> args,
    bool inverted,
    Object? context,
    dynamic renderer,
  ) {
    final r = renderer as HelperDelegate;
    var condition = !r.isTruthy(
      r.resolveArg(
        args.isNotEmpty ? args.first : VariableArg('.'),
        context,
      ),
    );
    if (inverted) condition = !condition;

    return condition ? r.renderNodes(children, context) : '';
  }
}
