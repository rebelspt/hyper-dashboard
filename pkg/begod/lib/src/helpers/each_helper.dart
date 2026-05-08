import 'helper.dart';
import '../ast.dart';

class LoopContext {
  final Object? item;
  final int index;
  final bool isFirst;
  final bool isLast;
  const LoopContext(this.item, this.index, this.isFirst, this.isLast);
}

class EachHelper extends MustacheHelper {
  @override
  String get name => 'each';

  @override
  String render(
    List<Node> children,
    List<Arg> args,
    bool inverted,
    Object? context,
    dynamic renderer,
  ) {
    final r = renderer as HelperDelegate;
    final value = args.isNotEmpty ? r.resolveArg(args.first, context) : null;
    final list = r.toList(value);

    if (list.isEmpty) return '';

    final buf = StringBuffer();
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      final loopCtx = LoopContext(item, i, i == 0, i == list.length - 1);
      buf.write(r.renderNodes(children, loopCtx));
    }
    return buf.toString();
  }
}
