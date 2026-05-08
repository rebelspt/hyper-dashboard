// Generated from MustacheParser.g4 by ANTLR 4.13.2
// ignore_for_file: unused_field, unused_import, type=lint
import 'package:antlr4/antlr4.dart';

import 'MustacheParser.dart';

/// This abstract class defines a complete listener for a parse tree produced by
/// [MustacheParser].
abstract class MustacheParserListener extends ParseTreeListener {
  /// Enter a parse tree produced by [MustacheParser.template].
  /// [ctx] the parse tree
  void enterTemplate(TemplateContext ctx);

  /// Exit a parse tree produced by [MustacheParser.template].
  /// [ctx] the parse tree
  void exitTemplate(TemplateContext ctx);

  /// Enter a parse tree produced by [MustacheParser.element].
  /// [ctx] the parse tree
  void enterElement(ElementContext ctx);

  /// Exit a parse tree produced by [MustacheParser.element].
  /// [ctx] the parse tree
  void exitElement(ElementContext ctx);

  /// Enter a parse tree produced by [MustacheParser.tag].
  /// [ctx] the parse tree
  void enterTag(TagContext ctx);

  /// Exit a parse tree produced by [MustacheParser.tag].
  /// [ctx] the parse tree
  void exitTag(TagContext ctx);

  /// Enter a parse tree produced by the [sectionStart]
  /// labeled alternative in [file.parserName>.tagBody].
  /// [ctx] the parse tree
  void enterSectionStart(SectionStartContext ctx);

  /// Exit a parse tree produced by the [sectionStart]
  /// labeled alternative in [MustacheParser.tagBody].
  /// [ctx] the parse tree
  void exitSectionStart(SectionStartContext ctx);

  /// Enter a parse tree produced by the [sectionEnd]
  /// labeled alternative in [file.parserName>.tagBody].
  /// [ctx] the parse tree
  void enterSectionEnd(SectionEndContext ctx);

  /// Exit a parse tree produced by the [sectionEnd]
  /// labeled alternative in [MustacheParser.tagBody].
  /// [ctx] the parse tree
  void exitSectionEnd(SectionEndContext ctx);

  /// Enter a parse tree produced by the [invertedStart]
  /// labeled alternative in [file.parserName>.tagBody].
  /// [ctx] the parse tree
  void enterInvertedStart(InvertedStartContext ctx);

  /// Exit a parse tree produced by the [invertedStart]
  /// labeled alternative in [MustacheParser.tagBody].
  /// [ctx] the parse tree
  void exitInvertedStart(InvertedStartContext ctx);

  /// Enter a parse tree produced by the [partial]
  /// labeled alternative in [file.parserName>.tagBody].
  /// [ctx] the parse tree
  void enterPartial(PartialContext ctx);

  /// Exit a parse tree produced by the [partial]
  /// labeled alternative in [MustacheParser.tagBody].
  /// [ctx] the parse tree
  void exitPartial(PartialContext ctx);

  /// Enter a parse tree produced by the [ampersandVar]
  /// labeled alternative in [file.parserName>.tagBody].
  /// [ctx] the parse tree
  void enterAmpersandVar(AmpersandVarContext ctx);

  /// Exit a parse tree produced by the [ampersandVar]
  /// labeled alternative in [MustacheParser.tagBody].
  /// [ctx] the parse tree
  void exitAmpersandVar(AmpersandVarContext ctx);

  /// Enter a parse tree produced by the [comment]
  /// labeled alternative in [file.parserName>.tagBody].
  /// [ctx] the parse tree
  void enterComment(CommentContext ctx);

  /// Exit a parse tree produced by the [comment]
  /// labeled alternative in [MustacheParser.tagBody].
  /// [ctx] the parse tree
  void exitComment(CommentContext ctx);

  /// Enter a parse tree produced by the [variableExpr]
  /// labeled alternative in [file.parserName>.tagBody].
  /// [ctx] the parse tree
  void enterVariableExpr(VariableExprContext ctx);

  /// Exit a parse tree produced by the [variableExpr]
  /// labeled alternative in [MustacheParser.tagBody].
  /// [ctx] the parse tree
  void exitVariableExpr(VariableExprContext ctx);

  /// Enter a parse tree produced by [MustacheParser.expr].
  /// [ctx] the parse tree
  void enterExpr(ExprContext ctx);

  /// Exit a parse tree produced by [MustacheParser.expr].
  /// [ctx] the parse tree
  void exitExpr(ExprContext ctx);

  /// Enter a parse tree produced by [MustacheParser.orExpr].
  /// [ctx] the parse tree
  void enterOrExpr(OrExprContext ctx);

  /// Exit a parse tree produced by [MustacheParser.orExpr].
  /// [ctx] the parse tree
  void exitOrExpr(OrExprContext ctx);

  /// Enter a parse tree produced by [MustacheParser.andExpr].
  /// [ctx] the parse tree
  void enterAndExpr(AndExprContext ctx);

  /// Exit a parse tree produced by [MustacheParser.andExpr].
  /// [ctx] the parse tree
  void exitAndExpr(AndExprContext ctx);

  /// Enter a parse tree produced by [MustacheParser.cmpExpr].
  /// [ctx] the parse tree
  void enterCmpExpr(CmpExprContext ctx);

  /// Exit a parse tree produced by [MustacheParser.cmpExpr].
  /// [ctx] the parse tree
  void exitCmpExpr(CmpExprContext ctx);

  /// Enter a parse tree produced by [MustacheParser.addExpr].
  /// [ctx] the parse tree
  void enterAddExpr(AddExprContext ctx);

  /// Exit a parse tree produced by [MustacheParser.addExpr].
  /// [ctx] the parse tree
  void exitAddExpr(AddExprContext ctx);

  /// Enter a parse tree produced by [MustacheParser.mulExpr].
  /// [ctx] the parse tree
  void enterMulExpr(MulExprContext ctx);

  /// Exit a parse tree produced by [MustacheParser.mulExpr].
  /// [ctx] the parse tree
  void exitMulExpr(MulExprContext ctx);

  /// Enter a parse tree produced by [MustacheParser.unaryExpr].
  /// [ctx] the parse tree
  void enterUnaryExpr(UnaryExprContext ctx);

  /// Exit a parse tree produced by [MustacheParser.unaryExpr].
  /// [ctx] the parse tree
  void exitUnaryExpr(UnaryExprContext ctx);

  /// Enter a parse tree produced by [MustacheParser.pipeAtom].
  /// [ctx] the parse tree
  void enterPipeAtom(PipeAtomContext ctx);

  /// Exit a parse tree produced by [MustacheParser.pipeAtom].
  /// [ctx] the parse tree
  void exitPipeAtom(PipeAtomContext ctx);

  /// Enter a parse tree produced by [MustacheParser.filterCall].
  /// [ctx] the parse tree
  void enterFilterCall(FilterCallContext ctx);

  /// Exit a parse tree produced by [MustacheParser.filterCall].
  /// [ctx] the parse tree
  void exitFilterCall(FilterCallContext ctx);

  /// Enter a parse tree produced by [MustacheParser.exprList].
  /// [ctx] the parse tree
  void enterExprList(ExprListContext ctx);

  /// Exit a parse tree produced by [MustacheParser.exprList].
  /// [ctx] the parse tree
  void exitExprList(ExprListContext ctx);

  /// Enter a parse tree produced by [MustacheParser.atom].
  /// [ctx] the parse tree
  void enterAtom(AtomContext ctx);

  /// Exit a parse tree produced by [MustacheParser.atom].
  /// [ctx] the parse tree
  void exitAtom(AtomContext ctx);

  /// Enter a parse tree produced by [MustacheParser.name].
  /// [ctx] the parse tree
  void enterName(NameContext ctx);

  /// Exit a parse tree produced by [MustacheParser.name].
  /// [ctx] the parse tree
  void exitName(NameContext ctx);
}
