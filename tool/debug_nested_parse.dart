import 'package:begod/src/ast.dart';

void main() {
  final template = '''{{#a}}
{{one}}
{{#b}}
{{one}}{{two}}{{one}}
{{#c}}
{{one}}{{two}}{{three}}{{two}}{{one}}
{{#d}}
{{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}
{{#five}}
{{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}
{{one}}{{two}}{{three}}{{four}}{{.}}6{{.}}{{four}}{{three}}{{two}}{{one}}
{{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}
{{/five}}
{{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}
{{/d}}
{{one}}{{two}}{{three}}{{two}}{{one}}
{{/c}}
{{one}}{{two}}{{one}}
{{/b}}
{{one}}
{{/a}}''';

  final parser = MustacheAST(template);
  final tokens = parser.parse();

  for (final token in tokens) {
    _printNode(token, 0);
  }
}

void _printNode(Node node, int indent) {
  final prefix = '  ' * indent;
  if (node is TextNode) {
    print('${prefix}TextNode: ${_escape(node.text)}');
  } else if (node is VariableNode) {
    print('${prefix}VariableNode: ${node.expr}');
  } else if (node is SectionNode) {
    print('${prefix}SectionNode: ${node.name}');
    for (final child in node.children) {
      _printNode(child, indent + 1);
    }
  } else if (node is InvertedNode) {
    print('${prefix}InvertedNode: ${node.name}');
    for (final child in node.children) {
      _printNode(child, indent + 1);
    }
  } else if (node is PartialNode) {
    print('${prefix}PartialNode: ${node.name}');
  } else if (node is CommentNode) {
    print('${prefix}CommentNode');
  } else {
    print('${prefix}Unknown: ${node.runtimeType}');
  }
}

String _escape(String s) {
  return s
      .replaceAll('\n', '\\n')
      .replaceAll('\r', '\\r')
      .replaceAll('\t', '\\t');
}
