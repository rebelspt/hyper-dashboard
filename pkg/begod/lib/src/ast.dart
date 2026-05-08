import 'package:antlr4/antlr4.dart';

import 'generated/MustacheLexer.dart';
import 'generated/MustacheParser.dart';
import 'expression_parser.dart';

/// Parses a Mustache template string into a list of [Node]s.
class MustacheAST {
  final String template;

  MustacheAST(this.template);

  /// Parses the template and returns the list of top-level nodes.
  List<Node> parse() {
    final input = InputStream.fromString(template);
    final lexer = MustacheLexer(input);
    final tokens = CommonTokenStream(lexer);
    final parser = MustacheParser(tokens);
    parser.buildParseTree = true;

    final tree = parser.template();
    return _walk(tree);
  }

  /// Walks the parse tree, pairing section starts/ends.
  List<Node> _walk(TemplateContext ctx) {
    final nodes = <Node>[];
    final elements = ctx.elements();
    var i = 0;
    while (i < elements.length) {
      final el = elements[i];
      final tag = el.tag();
      if (tag != null && tag.tagBody() is SectionStartContext) {
        final ssc = tag.tagBody() as SectionStartContext;
        final sectionName = ssc.name()?.NAME()?.text ?? '';
        final args = _extractExprs(ssc);
        final (children, endIndex) = _collectUntil(
          elements,
          i + 1,
          sectionName,
        );
        nodes.add(SectionNode(sectionName, args, children));
        i = endIndex;
      } else if (tag != null && tag.tagBody() is InvertedStartContext) {
        final isc = tag.tagBody() as InvertedStartContext;
        final sectionName = isc.name()?.NAME()?.text ?? '';
        final args = _extractExprs(isc);
        final (children, endIndex) = _collectUntil(
          elements,
          i + 1,
          sectionName,
        );
        nodes.add(InvertedNode(sectionName, args, children));
        i = endIndex;
      } else if (tag != null) {
        final tagBody = tag.tagBody();
        if (tagBody is SectionEndContext || tagBody is InvertedStartContext) {
          i++;
          continue;
        }
        nodes.add(_tagToNode(tag));
        i++;
      } else {
        final text = el.TEXT()?.text ?? '';
        nodes.add(TextNode(text));
        i++;
      }
    }
    return nodes;
  }

  Node _tagToNode(TagContext tag) {
    final tagBody = tag.tagBody();

    if (tagBody == null) {
      final name = tag.UNESC_NAME()?.text ?? '';
      return UnescapedNode(name);
    }

    if (tagBody is VariableExprContext) {
      final arg = tagBody.expr()!.toArg();
      return VariableNode(arg);
    }
    if (tagBody is AmpersandVarContext) {
      final name = tagBody.name()?.NAME()?.text ?? '';
      return UnescapedNode(name);
    }
    if (tagBody is PartialContext) {
      final name = tagBody.name()?.NAME()?.text ?? '';
      return PartialNode(name);
    }
    if (tagBody is CommentContext) {
      return CommentNode();
    }
    return TextNode('');
  }

  List<Arg> _extractExprs(TagBodyContext tagBody) {
    final args = <Arg>[];
    List<ExprContext>? exprs;
    if (tagBody is SectionStartContext) {
      exprs = tagBody.exprs();
    } else if (tagBody is InvertedStartContext) {
      exprs = tagBody.exprs();
    }
    if (exprs == null) return args;

    for (final e in exprs) {
      args.add(e.toArg());
    }
    return args;
  }

  (List<Node>, int) _collectUntil(
    List<ElementContext> elements,
    int start,
    String name,
  ) {
    final children = <Node>[];
    var i = start;
    while (i < elements.length) {
      final el = elements[i];
      final tag = el.tag();
      if (tag != null) {
        final tagBody = tag.tagBody();
        if (tagBody is SectionEndContext) {
          final endName = tagBody.name()?.NAME()?.text ?? '';
          if (endName == name) {
            return (children, i + 1);
          }
        }

        if (tagBody is SectionStartContext) {
          final innerName = tagBody.name()?.NAME()?.text ?? '';
          final innerArgs = _extractExprs(tagBody);
          final (innerChildren, endIndex) =
              _collectUntil(elements, i + 1, innerName);
          children.add(SectionNode(innerName, innerArgs, innerChildren));
          i = endIndex;
          continue;
        }

        if (tagBody is InvertedStartContext) {
          final innerName = tagBody.name()?.NAME()?.text ?? '';
          final innerArgs = _extractExprs(tagBody);
          final (innerChildren, endIndex) =
              _collectUntil(elements, i + 1, innerName);
          children.add(InvertedNode(innerName, innerArgs, innerChildren));
          i = endIndex;
          continue;
        }

        children.add(_tagToNode(tag));
      } else {
        final text = el.TEXT()?.text ?? '';
        children.add(TextNode(text));
      }
      i++;
    }
    return (children, i);
  }
}

sealed class Node {}

sealed class Arg {}

class StringArg extends Arg {
  final String value;
  StringArg(this.value);

  @override
  String toString() => 'StringArg("$value")';
}

class NumberArg extends Arg {
  final num value;
  NumberArg(this.value);

  @override
  String toString() => 'NumberArg($value)';
}

class BoolArg extends Arg {
  final bool value;
  BoolArg(this.value);

  @override
  String toString() => 'BoolArg($value)';
}

class VariableArg extends Arg {
  final String name;
  VariableArg(this.name);

  @override
  String toString() => 'VariableArg($name)';
}

class BinaryExpr extends Arg {
  final Arg left;
  final String operator;
  final Arg right;
  BinaryExpr(this.left, this.operator, this.right);

  @override
  String toString() => 'BinaryExpr($left $operator $right)';
}

class UnaryExpr extends Arg {
  final String operator;
  final Arg operand;
  UnaryExpr(this.operator, this.operand);

  @override
  String toString() => 'UnaryExpr($operator$operand)';
}

class FilterCall {
  final String name;
  final List<Arg> args;
  FilterCall(this.name, this.args);

  @override
  String toString() => 'FilterCall($name, $args)';
}

class FilterExpr extends Arg {
  final Arg input;
  final List<FilterCall> filters;
  FilterExpr(this.input, this.filters);

  @override
  String toString() => 'FilterExpr($input, $filters)';
}

class TextNode extends Node {
  final String text;
  TextNode(this.text);

  @override
  String toString() => 'TextNode("$text")';
}

class VariableNode extends Node {
  final Arg expr;
  VariableNode(this.expr);

  @override
  String toString() => 'VariableNode($expr)';
}

class UnescapedNode extends Node {
  final String name;
  UnescapedNode(this.name);

  @override
  String toString() => 'UnescapedNode($name)';
}

class SectionNode extends Node {
  final String name;
  final List<Arg> args;
  final List<Node> children;
  SectionNode(this.name, this.args, this.children);

  @override
  String toString() => 'SectionNode($name, $args, $children)';
}

class InvertedNode extends Node {
  final String name;
  final List<Arg> args;
  final List<Node> children;
  InvertedNode(this.name, this.args, this.children);

  @override
  String toString() => 'InvertedNode($name, $args, $children)';
}

class PartialNode extends Node {
  final String name;
  PartialNode(this.name);

  @override
  String toString() => 'PartialNode($name)';
}

class CommentNode extends Node {
  CommentNode();

  @override
  String toString() => 'CommentNode()';
}
