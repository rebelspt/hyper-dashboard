// Generated from MustacheParser.g4 by ANTLR 4.13.2
// ignore_for_file: unused_field, unused_import, type=lint
import 'package:antlr4/antlr4.dart';

import 'MustacheParser.dart';

/// This abstract class defines a complete generic visitor for a parse tree
/// produced by [MustacheParser].
///
/// [T] is the eturn type of the visit operation. Use `void` for
/// operations with no return type.
abstract class MustacheParserVisitor<T> extends ParseTreeVisitor<T> {
  /// Visit a parse tree produced by [MustacheParser.template].
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitTemplate(TemplateContext ctx);

  /// Visit a parse tree produced by [MustacheParser.element].
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitElement(ElementContext ctx);

  /// Visit a parse tree produced by [MustacheParser.tag].
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitTag(TagContext ctx);

  /// Visit a parse tree produced by the {@code sectionStart}
  /// labeled alternative in {@link MustacheParser#tagBody}.
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitSectionStart(SectionStartContext ctx);

  /// Visit a parse tree produced by the {@code sectionEnd}
  /// labeled alternative in {@link MustacheParser#tagBody}.
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitSectionEnd(SectionEndContext ctx);

  /// Visit a parse tree produced by the {@code invertedStart}
  /// labeled alternative in {@link MustacheParser#tagBody}.
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitInvertedStart(InvertedStartContext ctx);

  /// Visit a parse tree produced by the {@code partial}
  /// labeled alternative in {@link MustacheParser#tagBody}.
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitPartial(PartialContext ctx);

  /// Visit a parse tree produced by the {@code ampersandVar}
  /// labeled alternative in {@link MustacheParser#tagBody}.
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitAmpersandVar(AmpersandVarContext ctx);

  /// Visit a parse tree produced by the {@code comment}
  /// labeled alternative in {@link MustacheParser#tagBody}.
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitComment(CommentContext ctx);

  /// Visit a parse tree produced by the {@code variableExpr}
  /// labeled alternative in {@link MustacheParser#tagBody}.
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitVariableExpr(VariableExprContext ctx);

  /// Visit a parse tree produced by [MustacheParser.expr].
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitExpr(ExprContext ctx);

  /// Visit a parse tree produced by [MustacheParser.orExpr].
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitOrExpr(OrExprContext ctx);

  /// Visit a parse tree produced by [MustacheParser.andExpr].
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitAndExpr(AndExprContext ctx);

  /// Visit a parse tree produced by [MustacheParser.cmpExpr].
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitCmpExpr(CmpExprContext ctx);

  /// Visit a parse tree produced by [MustacheParser.addExpr].
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitAddExpr(AddExprContext ctx);

  /// Visit a parse tree produced by [MustacheParser.mulExpr].
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitMulExpr(MulExprContext ctx);

  /// Visit a parse tree produced by [MustacheParser.unaryExpr].
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitUnaryExpr(UnaryExprContext ctx);

  /// Visit a parse tree produced by [MustacheParser.pipeAtom].
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitPipeAtom(PipeAtomContext ctx);

  /// Visit a parse tree produced by [MustacheParser.filterCall].
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitFilterCall(FilterCallContext ctx);

  /// Visit a parse tree produced by [MustacheParser.exprList].
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitExprList(ExprListContext ctx);

  /// Visit a parse tree produced by [MustacheParser.atom].
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitAtom(AtomContext ctx);

  /// Visit a parse tree produced by [MustacheParser.name].
  /// [ctx] the parse tree.
  /// Return the visitor result.
  T? visitName(NameContext ctx);
}
