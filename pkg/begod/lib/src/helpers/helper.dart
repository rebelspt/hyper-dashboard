import '../ast.dart';

/// A block helper that intercepts section-style tags (e.g. {{#name}}).
///
/// Subclasses override [render] to implement custom behaviour.
abstract class MustacheHelper {
  /// The tag name that triggers this helper (e.g. "if").
  String get name;

  /// Renders the helper.
  ///
  /// * [children] — nodes inside the block.
  /// * [args]     — parsed arguments from the opening tag.
  /// * [inverted] — `true` when opened with `{{^name}}`.
  /// * [context]  — the current data context.
  /// * [renderer] — the calling renderer (to render sub-nodes).
  String render(
    List<Node> children,
    List<Arg> args,
    bool inverted,
    Object? context,
    dynamic renderer,
  );
}

/// Minimal interface that [MustacheHelper] implementations can call to render
/// child nodes, resolve variables, and resolve arguments.
abstract class HelperDelegate {
  String renderNodes(List<Node> nodes, Object? context);
  Object? resolve(String name, Object? context);
  Object? resolveArg(Arg arg, Object? context);
  String stringify(Object? value);
  String htmlEscape(String s);
  bool isTruthy(Object? value);
  bool looseEqual(Object? a, Object? b);
  bool compare(Arg a, Arg b, Object? context, bool Function(num, num) op);
  List<Object?> toList(Object? value);
}
