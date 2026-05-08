import 'package:begod/src/ast.dart';

void main() {
  final parser =
      MustacheAST('| This Is\n{{#boolean}}\n|\n{{/boolean}}\n| A Line');
  final nodes = parser.parse();
  printNodes(nodes, 0);
}

void printNodes(List<Node> nodes, int depth) {
  final indent = '  ' * depth;
  for (final node in nodes) {
    switch (node) {
      case TextNode(:final text):
        print('${indent}Text: ${text.codeUnits}');
      case SectionNode(:final name, :final children):
        print('${indent}Section: $name');
        printNodes(children, depth + 1);
      case VariableNode(:final expr):
        print('${indent}Var: $expr');
      default:
        print('${indent}${node.runtimeType}');
    }
  }
}
