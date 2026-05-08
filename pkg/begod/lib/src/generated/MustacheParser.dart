// Generated from MustacheParser.g4 by ANTLR 4.13.2
// ignore_for_file: unused_field, unused_import, type=lint
import 'package:antlr4/antlr4.dart';

import 'MustacheParserListener.dart';
import 'MustacheParserBaseListener.dart';
import 'MustacheParserVisitor.dart';
import 'MustacheParserBaseVisitor.dart';

const int RULE_template = 0,
    RULE_element = 1,
    RULE_tag = 2,
    RULE_tagBody = 3,
    RULE_expr = 4,
    RULE_orExpr = 5,
    RULE_andExpr = 6,
    RULE_cmpExpr = 7,
    RULE_addExpr = 8,
    RULE_mulExpr = 9,
    RULE_unaryExpr = 10,
    RULE_pipeAtom = 11,
    RULE_filterCall = 12,
    RULE_exprList = 13,
    RULE_atom = 14,
    RULE_name = 15;

class MustacheParser extends Parser {
  static final checkVersion =
      () => RuntimeMetaData.checkVersion('4.13.2', RuntimeMetaData.VERSION);
  static const int TOKEN_EOF = IntStream.EOF;

  static final List<DFA> _decisionToDFA = List.generate(
      _ATN.numberOfDecisions, (i) => DFA(_ATN.getDecisionState(i), i));
  static final PredictionContextCache _sharedContextCache =
      PredictionContextCache();
  static const int TOKEN_OPEN = 1,
      TOKEN_OPEN_UNESC = 2,
      TOKEN_TEXT = 3,
      TOKEN_CLOSE = 4,
      TOKEN_HASH = 5,
      TOKEN_CARET = 6,
      TOKEN_SLASH = 7,
      TOKEN_GT = 8,
      TOKEN_AMP = 9,
      TOKEN_AND = 10,
      TOKEN_OR = 11,
      TOKEN_EQ = 12,
      TOKEN_NE = 13,
      TOKEN_LTE = 14,
      TOKEN_GTE = 15,
      TOKEN_PIPE = 16,
      TOKEN_COMMA = 17,
      TOKEN_PLUS = 18,
      TOKEN_MINUS = 19,
      TOKEN_STAR = 20,
      TOKEN_LT = 21,
      TOKEN_LPAREN = 22,
      TOKEN_RPAREN = 23,
      TOKEN_COMMENT_CONTENT = 24,
      TOKEN_TAG_WS = 25,
      TOKEN_STRING = 26,
      TOKEN_NUMBER = 27,
      TOKEN_TRUE = 28,
      TOKEN_FALSE = 29,
      TOKEN_NAME = 30,
      TOKEN_UNESC_CLOSE = 31,
      TOKEN_UNESC_WS = 32,
      TOKEN_UNESC_STRING = 33,
      TOKEN_UNESC_NUMBER = 34,
      TOKEN_UNESC_TRUE = 35,
      TOKEN_UNESC_FALSE = 36,
      TOKEN_UNESC_NAME = 37;

  @override
  final List<String> ruleNames = [
    'template',
    'element',
    'tag',
    'tagBody',
    'expr',
    'orExpr',
    'andExpr',
    'cmpExpr',
    'addExpr',
    'mulExpr',
    'unaryExpr',
    'pipeAtom',
    'filterCall',
    'exprList',
    'atom',
    'name'
  ];

  static final List<String?> _LITERAL_NAMES = [
    null,
    "'{{'",
    "'{{{'",
    null,
    "'}}'",
    "'#'",
    "'^'",
    "'/'",
    "'>'",
    "'&'",
    "'&&'",
    "'||'",
    "'=='",
    "'!='",
    "'<='",
    "'>='",
    "'|'",
    "','",
    "'+'",
    "'-'",
    "'*'",
    "'<'",
    "'('",
    "')'",
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    "'}}}'"
  ];
  static final List<String?> _SYMBOLIC_NAMES = [
    null,
    "OPEN",
    "OPEN_UNESC",
    "TEXT",
    "CLOSE",
    "HASH",
    "CARET",
    "SLASH",
    "GT",
    "AMP",
    "AND",
    "OR",
    "EQ",
    "NE",
    "LTE",
    "GTE",
    "PIPE",
    "COMMA",
    "PLUS",
    "MINUS",
    "STAR",
    "LT",
    "LPAREN",
    "RPAREN",
    "COMMENT_CONTENT",
    "TAG_WS",
    "STRING",
    "NUMBER",
    "TRUE",
    "FALSE",
    "NAME",
    "UNESC_CLOSE",
    "UNESC_WS",
    "UNESC_STRING",
    "UNESC_NUMBER",
    "UNESC_TRUE",
    "UNESC_FALSE",
    "UNESC_NAME"
  ];
  static final Vocabulary VOCABULARY =
      VocabularyImpl(_LITERAL_NAMES, _SYMBOLIC_NAMES);

  @override
  Vocabulary get vocabulary {
    return VOCABULARY;
  }

  @override
  String get grammarFileName => 'MustacheParser.g4';

  @override
  List<int> get serializedATN => _serializedATN;

  @override
  ATN getATN() {
    return _ATN;
  }

  MustacheParser(TokenStream input) : super(input) {
    interpreter =
        ParserATNSimulator(this, _ATN, _decisionToDFA, _sharedContextCache);
  }

  TemplateContext template() {
    dynamic _localctx = TemplateContext(context, state);
    enterRule(_localctx, 0, RULE_template);
    int _la;
    try {
      enterOuterAlt(_localctx, 1);
      state = 35;
      errorHandler.sync(this);
      _la = tokenStream.LA(1)!;
      while ((((_la) & ~0x3f) == 0 && ((1 << _la) & 14) != 0)) {
        state = 32;
        element();
        state = 37;
        errorHandler.sync(this);
        _la = tokenStream.LA(1)!;
      }
      state = 38;
      match(TOKEN_EOF);
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  ElementContext element() {
    dynamic _localctx = ElementContext(context, state);
    enterRule(_localctx, 2, RULE_element);
    try {
      state = 42;
      errorHandler.sync(this);
      switch (tokenStream.LA(1)!) {
        case TOKEN_OPEN:
        case TOKEN_OPEN_UNESC:
          enterOuterAlt(_localctx, 1);
          state = 40;
          tag();
          break;
        case TOKEN_TEXT:
          enterOuterAlt(_localctx, 2);
          state = 41;
          match(TOKEN_TEXT);
          break;
        default:
          throw NoViableAltException(this);
      }
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  TagContext tag() {
    dynamic _localctx = TagContext(context, state);
    enterRule(_localctx, 4, RULE_tag);
    try {
      state = 51;
      errorHandler.sync(this);
      switch (tokenStream.LA(1)!) {
        case TOKEN_OPEN:
          enterOuterAlt(_localctx, 1);
          state = 44;
          match(TOKEN_OPEN);
          state = 45;
          tagBody();
          state = 46;
          match(TOKEN_CLOSE);
          break;
        case TOKEN_OPEN_UNESC:
          enterOuterAlt(_localctx, 2);
          state = 48;
          match(TOKEN_OPEN_UNESC);
          state = 49;
          match(TOKEN_UNESC_NAME);
          state = 50;
          match(TOKEN_UNESC_CLOSE);
          break;
        default:
          throw NoViableAltException(this);
      }
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  TagBodyContext tagBody() {
    dynamic _localctx = TagBodyContext(context, state);
    enterRule(_localctx, 6, RULE_tagBody);
    int _la;
    try {
      state = 77;
      errorHandler.sync(this);
      switch (tokenStream.LA(1)!) {
        case TOKEN_HASH:
          _localctx = SectionStartContext(_localctx);
          enterOuterAlt(_localctx, 1);
          state = 53;
          match(TOKEN_HASH);
          state = 54;
          name();
          state = 58;
          errorHandler.sync(this);
          _la = tokenStream.LA(1)!;
          while ((((_la) & ~0x3f) == 0 && ((1 << _la) & 2085093376) != 0)) {
            state = 55;
            expr();
            state = 60;
            errorHandler.sync(this);
            _la = tokenStream.LA(1)!;
          }
          break;
        case TOKEN_SLASH:
          _localctx = SectionEndContext(_localctx);
          enterOuterAlt(_localctx, 2);
          state = 61;
          match(TOKEN_SLASH);
          state = 62;
          name();
          break;
        case TOKEN_CARET:
          _localctx = InvertedStartContext(_localctx);
          enterOuterAlt(_localctx, 3);
          state = 63;
          match(TOKEN_CARET);
          state = 64;
          name();
          state = 68;
          errorHandler.sync(this);
          _la = tokenStream.LA(1)!;
          while ((((_la) & ~0x3f) == 0 && ((1 << _la) & 2085093376) != 0)) {
            state = 65;
            expr();
            state = 70;
            errorHandler.sync(this);
            _la = tokenStream.LA(1)!;
          }
          break;
        case TOKEN_GT:
          _localctx = PartialContext(_localctx);
          enterOuterAlt(_localctx, 4);
          state = 71;
          match(TOKEN_GT);
          state = 72;
          name();
          break;
        case TOKEN_AMP:
          _localctx = AmpersandVarContext(_localctx);
          enterOuterAlt(_localctx, 5);
          state = 73;
          match(TOKEN_AMP);
          state = 74;
          name();
          break;
        case TOKEN_COMMENT_CONTENT:
          _localctx = CommentContext(_localctx);
          enterOuterAlt(_localctx, 6);
          state = 75;
          match(TOKEN_COMMENT_CONTENT);
          break;
        case TOKEN_MINUS:
        case TOKEN_LPAREN:
        case TOKEN_STRING:
        case TOKEN_NUMBER:
        case TOKEN_TRUE:
        case TOKEN_FALSE:
        case TOKEN_NAME:
          _localctx = VariableExprContext(_localctx);
          enterOuterAlt(_localctx, 7);
          state = 76;
          expr();
          break;
        default:
          throw NoViableAltException(this);
      }
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  ExprContext expr() {
    dynamic _localctx = ExprContext(context, state);
    enterRule(_localctx, 8, RULE_expr);
    try {
      enterOuterAlt(_localctx, 1);
      state = 79;
      orExpr();
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  OrExprContext orExpr() {
    dynamic _localctx = OrExprContext(context, state);
    enterRule(_localctx, 10, RULE_orExpr);
    int _la;
    try {
      enterOuterAlt(_localctx, 1);
      state = 81;
      andExpr();
      state = 86;
      errorHandler.sync(this);
      _la = tokenStream.LA(1)!;
      while (_la == TOKEN_OR) {
        state = 82;
        _localctx._OR = match(TOKEN_OR);
        _localctx.ops.add(_localctx._OR);
        state = 83;
        andExpr();
        state = 88;
        errorHandler.sync(this);
        _la = tokenStream.LA(1)!;
      }
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  AndExprContext andExpr() {
    dynamic _localctx = AndExprContext(context, state);
    enterRule(_localctx, 12, RULE_andExpr);
    int _la;
    try {
      enterOuterAlt(_localctx, 1);
      state = 89;
      cmpExpr();
      state = 94;
      errorHandler.sync(this);
      _la = tokenStream.LA(1)!;
      while (_la == TOKEN_AND) {
        state = 90;
        _localctx._AND = match(TOKEN_AND);
        _localctx.ops.add(_localctx._AND);
        state = 91;
        cmpExpr();
        state = 96;
        errorHandler.sync(this);
        _la = tokenStream.LA(1)!;
      }
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  CmpExprContext cmpExpr() {
    dynamic _localctx = CmpExprContext(context, state);
    enterRule(_localctx, 14, RULE_cmpExpr);
    int _la;
    try {
      enterOuterAlt(_localctx, 1);
      state = 97;
      addExpr();
      state = 102;
      errorHandler.sync(this);
      _la = tokenStream.LA(1)!;
      while ((((_la) & ~0x3f) == 0 && ((1 << _la) & 2158848) != 0)) {
        state = 98;
        _localctx._tset179 = tokenStream.LT(1);
        _la = tokenStream.LA(1)!;
        if (!((((_la) & ~0x3f) == 0 && ((1 << _la) & 2158848) != 0))) {
          _localctx._tset179 = errorHandler.recoverInline(this);
        } else {
          if (tokenStream.LA(1)! == IntStream.EOF) matchedEOF = true;
          errorHandler.reportMatch(this);
          consume();
        }
        _localctx.ops.add(_localctx._tset179);
        state = 99;
        addExpr();
        state = 104;
        errorHandler.sync(this);
        _la = tokenStream.LA(1)!;
      }
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  AddExprContext addExpr() {
    dynamic _localctx = AddExprContext(context, state);
    enterRule(_localctx, 16, RULE_addExpr);
    int _la;
    try {
      int _alt;
      enterOuterAlt(_localctx, 1);
      state = 105;
      mulExpr();
      state = 110;
      errorHandler.sync(this);
      _alt = interpreter!.adaptivePredict(tokenStream, 9, context);
      while (_alt != 2 && _alt != ATN.INVALID_ALT_NUMBER) {
        if (_alt == 1) {
          state = 106;
          _localctx._tset216 = tokenStream.LT(1);
          _la = tokenStream.LA(1)!;
          if (!(_la == TOKEN_PLUS || _la == TOKEN_MINUS)) {
            _localctx._tset216 = errorHandler.recoverInline(this);
          } else {
            if (tokenStream.LA(1)! == IntStream.EOF) matchedEOF = true;
            errorHandler.reportMatch(this);
            consume();
          }
          _localctx.ops.add(_localctx._tset216);
          state = 107;
          mulExpr();
        }
        state = 112;
        errorHandler.sync(this);
        _alt = interpreter!.adaptivePredict(tokenStream, 9, context);
      }
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  MulExprContext mulExpr() {
    dynamic _localctx = MulExprContext(context, state);
    enterRule(_localctx, 18, RULE_mulExpr);
    int _la;
    try {
      enterOuterAlt(_localctx, 1);
      state = 113;
      unaryExpr();
      state = 118;
      errorHandler.sync(this);
      _la = tokenStream.LA(1)!;
      while (_la == TOKEN_SLASH || _la == TOKEN_STAR) {
        state = 114;
        _localctx._tset237 = tokenStream.LT(1);
        _la = tokenStream.LA(1)!;
        if (!(_la == TOKEN_SLASH || _la == TOKEN_STAR)) {
          _localctx._tset237 = errorHandler.recoverInline(this);
        } else {
          if (tokenStream.LA(1)! == IntStream.EOF) matchedEOF = true;
          errorHandler.reportMatch(this);
          consume();
        }
        _localctx.ops.add(_localctx._tset237);
        state = 115;
        unaryExpr();
        state = 120;
        errorHandler.sync(this);
        _la = tokenStream.LA(1)!;
      }
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  UnaryExprContext unaryExpr() {
    dynamic _localctx = UnaryExprContext(context, state);
    enterRule(_localctx, 20, RULE_unaryExpr);
    int _la;
    try {
      enterOuterAlt(_localctx, 1);
      state = 122;
      errorHandler.sync(this);
      _la = tokenStream.LA(1)!;
      if (_la == TOKEN_MINUS) {
        state = 121;
        match(TOKEN_MINUS);
      }

      state = 124;
      pipeAtom();
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  PipeAtomContext pipeAtom() {
    dynamic _localctx = PipeAtomContext(context, state);
    enterRule(_localctx, 22, RULE_pipeAtom);
    int _la;
    try {
      enterOuterAlt(_localctx, 1);
      state = 126;
      atom();
      state = 131;
      errorHandler.sync(this);
      _la = tokenStream.LA(1)!;
      while (_la == TOKEN_PIPE) {
        state = 127;
        match(TOKEN_PIPE);
        state = 128;
        filterCall();
        state = 133;
        errorHandler.sync(this);
        _la = tokenStream.LA(1)!;
      }
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  FilterCallContext filterCall() {
    dynamic _localctx = FilterCallContext(context, state);
    enterRule(_localctx, 24, RULE_filterCall);
    int _la;
    try {
      enterOuterAlt(_localctx, 1);
      state = 134;
      match(TOKEN_NAME);
      state = 140;
      errorHandler.sync(this);
      switch (interpreter!.adaptivePredict(tokenStream, 14, context)) {
        case 1:
          state = 135;
          match(TOKEN_LPAREN);
          state = 137;
          errorHandler.sync(this);
          _la = tokenStream.LA(1)!;
          if ((((_la) & ~0x3f) == 0 && ((1 << _la) & 2085093376) != 0)) {
            state = 136;
            exprList();
          }

          state = 139;
          match(TOKEN_RPAREN);
          break;
      }
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  ExprListContext exprList() {
    dynamic _localctx = ExprListContext(context, state);
    enterRule(_localctx, 26, RULE_exprList);
    int _la;
    try {
      enterOuterAlt(_localctx, 1);
      state = 142;
      expr();
      state = 147;
      errorHandler.sync(this);
      _la = tokenStream.LA(1)!;
      while (_la == TOKEN_COMMA) {
        state = 143;
        match(TOKEN_COMMA);
        state = 144;
        expr();
        state = 149;
        errorHandler.sync(this);
        _la = tokenStream.LA(1)!;
      }
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  AtomContext atom() {
    dynamic _localctx = AtomContext(context, state);
    enterRule(_localctx, 28, RULE_atom);
    try {
      state = 159;
      errorHandler.sync(this);
      switch (tokenStream.LA(1)!) {
        case TOKEN_NUMBER:
          enterOuterAlt(_localctx, 1);
          state = 150;
          match(TOKEN_NUMBER);
          break;
        case TOKEN_STRING:
          enterOuterAlt(_localctx, 2);
          state = 151;
          match(TOKEN_STRING);
          break;
        case TOKEN_TRUE:
          enterOuterAlt(_localctx, 3);
          state = 152;
          match(TOKEN_TRUE);
          break;
        case TOKEN_FALSE:
          enterOuterAlt(_localctx, 4);
          state = 153;
          match(TOKEN_FALSE);
          break;
        case TOKEN_NAME:
          enterOuterAlt(_localctx, 5);
          state = 154;
          match(TOKEN_NAME);
          break;
        case TOKEN_LPAREN:
          enterOuterAlt(_localctx, 6);
          state = 155;
          match(TOKEN_LPAREN);
          state = 156;
          expr();
          state = 157;
          match(TOKEN_RPAREN);
          break;
        default:
          throw NoViableAltException(this);
      }
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  NameContext name() {
    dynamic _localctx = NameContext(context, state);
    enterRule(_localctx, 30, RULE_name);
    try {
      enterOuterAlt(_localctx, 1);
      state = 161;
      match(TOKEN_NAME);
    } on RecognitionException catch (re) {
      _localctx.exception = re;
      errorHandler.reportError(this, re);
      errorHandler.recover(this, re);
    } finally {
      exitRule();
    }
    return _localctx;
  }

  static const List<int> _serializedATN = [
    4,
    1,
    37,
    164,
    2,
    0,
    7,
    0,
    2,
    1,
    7,
    1,
    2,
    2,
    7,
    2,
    2,
    3,
    7,
    3,
    2,
    4,
    7,
    4,
    2,
    5,
    7,
    5,
    2,
    6,
    7,
    6,
    2,
    7,
    7,
    7,
    2,
    8,
    7,
    8,
    2,
    9,
    7,
    9,
    2,
    10,
    7,
    10,
    2,
    11,
    7,
    11,
    2,
    12,
    7,
    12,
    2,
    13,
    7,
    13,
    2,
    14,
    7,
    14,
    2,
    15,
    7,
    15,
    1,
    0,
    5,
    0,
    34,
    8,
    0,
    10,
    0,
    12,
    0,
    37,
    9,
    0,
    1,
    0,
    1,
    0,
    1,
    1,
    1,
    1,
    3,
    1,
    43,
    8,
    1,
    1,
    2,
    1,
    2,
    1,
    2,
    1,
    2,
    1,
    2,
    1,
    2,
    1,
    2,
    3,
    2,
    52,
    8,
    2,
    1,
    3,
    1,
    3,
    1,
    3,
    5,
    3,
    57,
    8,
    3,
    10,
    3,
    12,
    3,
    60,
    9,
    3,
    1,
    3,
    1,
    3,
    1,
    3,
    1,
    3,
    1,
    3,
    5,
    3,
    67,
    8,
    3,
    10,
    3,
    12,
    3,
    70,
    9,
    3,
    1,
    3,
    1,
    3,
    1,
    3,
    1,
    3,
    1,
    3,
    1,
    3,
    3,
    3,
    78,
    8,
    3,
    1,
    4,
    1,
    4,
    1,
    5,
    1,
    5,
    1,
    5,
    5,
    5,
    85,
    8,
    5,
    10,
    5,
    12,
    5,
    88,
    9,
    5,
    1,
    6,
    1,
    6,
    1,
    6,
    5,
    6,
    93,
    8,
    6,
    10,
    6,
    12,
    6,
    96,
    9,
    6,
    1,
    7,
    1,
    7,
    1,
    7,
    5,
    7,
    101,
    8,
    7,
    10,
    7,
    12,
    7,
    104,
    9,
    7,
    1,
    8,
    1,
    8,
    1,
    8,
    5,
    8,
    109,
    8,
    8,
    10,
    8,
    12,
    8,
    112,
    9,
    8,
    1,
    9,
    1,
    9,
    1,
    9,
    5,
    9,
    117,
    8,
    9,
    10,
    9,
    12,
    9,
    120,
    9,
    9,
    1,
    10,
    3,
    10,
    123,
    8,
    10,
    1,
    10,
    1,
    10,
    1,
    11,
    1,
    11,
    1,
    11,
    5,
    11,
    130,
    8,
    11,
    10,
    11,
    12,
    11,
    133,
    9,
    11,
    1,
    12,
    1,
    12,
    1,
    12,
    3,
    12,
    138,
    8,
    12,
    1,
    12,
    3,
    12,
    141,
    8,
    12,
    1,
    13,
    1,
    13,
    1,
    13,
    5,
    13,
    146,
    8,
    13,
    10,
    13,
    12,
    13,
    149,
    9,
    13,
    1,
    14,
    1,
    14,
    1,
    14,
    1,
    14,
    1,
    14,
    1,
    14,
    1,
    14,
    1,
    14,
    1,
    14,
    3,
    14,
    160,
    8,
    14,
    1,
    15,
    1,
    15,
    1,
    15,
    0,
    0,
    16,
    0,
    2,
    4,
    6,
    8,
    10,
    12,
    14,
    16,
    18,
    20,
    22,
    24,
    26,
    28,
    30,
    0,
    3,
    3,
    0,
    8,
    8,
    12,
    15,
    21,
    21,
    1,
    0,
    18,
    19,
    2,
    0,
    7,
    7,
    20,
    20,
    173,
    0,
    35,
    1,
    0,
    0,
    0,
    2,
    42,
    1,
    0,
    0,
    0,
    4,
    51,
    1,
    0,
    0,
    0,
    6,
    77,
    1,
    0,
    0,
    0,
    8,
    79,
    1,
    0,
    0,
    0,
    10,
    81,
    1,
    0,
    0,
    0,
    12,
    89,
    1,
    0,
    0,
    0,
    14,
    97,
    1,
    0,
    0,
    0,
    16,
    105,
    1,
    0,
    0,
    0,
    18,
    113,
    1,
    0,
    0,
    0,
    20,
    122,
    1,
    0,
    0,
    0,
    22,
    126,
    1,
    0,
    0,
    0,
    24,
    134,
    1,
    0,
    0,
    0,
    26,
    142,
    1,
    0,
    0,
    0,
    28,
    159,
    1,
    0,
    0,
    0,
    30,
    161,
    1,
    0,
    0,
    0,
    32,
    34,
    3,
    2,
    1,
    0,
    33,
    32,
    1,
    0,
    0,
    0,
    34,
    37,
    1,
    0,
    0,
    0,
    35,
    33,
    1,
    0,
    0,
    0,
    35,
    36,
    1,
    0,
    0,
    0,
    36,
    38,
    1,
    0,
    0,
    0,
    37,
    35,
    1,
    0,
    0,
    0,
    38,
    39,
    5,
    0,
    0,
    1,
    39,
    1,
    1,
    0,
    0,
    0,
    40,
    43,
    3,
    4,
    2,
    0,
    41,
    43,
    5,
    3,
    0,
    0,
    42,
    40,
    1,
    0,
    0,
    0,
    42,
    41,
    1,
    0,
    0,
    0,
    43,
    3,
    1,
    0,
    0,
    0,
    44,
    45,
    5,
    1,
    0,
    0,
    45,
    46,
    3,
    6,
    3,
    0,
    46,
    47,
    5,
    4,
    0,
    0,
    47,
    52,
    1,
    0,
    0,
    0,
    48,
    49,
    5,
    2,
    0,
    0,
    49,
    50,
    5,
    37,
    0,
    0,
    50,
    52,
    5,
    31,
    0,
    0,
    51,
    44,
    1,
    0,
    0,
    0,
    51,
    48,
    1,
    0,
    0,
    0,
    52,
    5,
    1,
    0,
    0,
    0,
    53,
    54,
    5,
    5,
    0,
    0,
    54,
    58,
    3,
    30,
    15,
    0,
    55,
    57,
    3,
    8,
    4,
    0,
    56,
    55,
    1,
    0,
    0,
    0,
    57,
    60,
    1,
    0,
    0,
    0,
    58,
    56,
    1,
    0,
    0,
    0,
    58,
    59,
    1,
    0,
    0,
    0,
    59,
    78,
    1,
    0,
    0,
    0,
    60,
    58,
    1,
    0,
    0,
    0,
    61,
    62,
    5,
    7,
    0,
    0,
    62,
    78,
    3,
    30,
    15,
    0,
    63,
    64,
    5,
    6,
    0,
    0,
    64,
    68,
    3,
    30,
    15,
    0,
    65,
    67,
    3,
    8,
    4,
    0,
    66,
    65,
    1,
    0,
    0,
    0,
    67,
    70,
    1,
    0,
    0,
    0,
    68,
    66,
    1,
    0,
    0,
    0,
    68,
    69,
    1,
    0,
    0,
    0,
    69,
    78,
    1,
    0,
    0,
    0,
    70,
    68,
    1,
    0,
    0,
    0,
    71,
    72,
    5,
    8,
    0,
    0,
    72,
    78,
    3,
    30,
    15,
    0,
    73,
    74,
    5,
    9,
    0,
    0,
    74,
    78,
    3,
    30,
    15,
    0,
    75,
    78,
    5,
    24,
    0,
    0,
    76,
    78,
    3,
    8,
    4,
    0,
    77,
    53,
    1,
    0,
    0,
    0,
    77,
    61,
    1,
    0,
    0,
    0,
    77,
    63,
    1,
    0,
    0,
    0,
    77,
    71,
    1,
    0,
    0,
    0,
    77,
    73,
    1,
    0,
    0,
    0,
    77,
    75,
    1,
    0,
    0,
    0,
    77,
    76,
    1,
    0,
    0,
    0,
    78,
    7,
    1,
    0,
    0,
    0,
    79,
    80,
    3,
    10,
    5,
    0,
    80,
    9,
    1,
    0,
    0,
    0,
    81,
    86,
    3,
    12,
    6,
    0,
    82,
    83,
    5,
    11,
    0,
    0,
    83,
    85,
    3,
    12,
    6,
    0,
    84,
    82,
    1,
    0,
    0,
    0,
    85,
    88,
    1,
    0,
    0,
    0,
    86,
    84,
    1,
    0,
    0,
    0,
    86,
    87,
    1,
    0,
    0,
    0,
    87,
    11,
    1,
    0,
    0,
    0,
    88,
    86,
    1,
    0,
    0,
    0,
    89,
    94,
    3,
    14,
    7,
    0,
    90,
    91,
    5,
    10,
    0,
    0,
    91,
    93,
    3,
    14,
    7,
    0,
    92,
    90,
    1,
    0,
    0,
    0,
    93,
    96,
    1,
    0,
    0,
    0,
    94,
    92,
    1,
    0,
    0,
    0,
    94,
    95,
    1,
    0,
    0,
    0,
    95,
    13,
    1,
    0,
    0,
    0,
    96,
    94,
    1,
    0,
    0,
    0,
    97,
    102,
    3,
    16,
    8,
    0,
    98,
    99,
    7,
    0,
    0,
    0,
    99,
    101,
    3,
    16,
    8,
    0,
    100,
    98,
    1,
    0,
    0,
    0,
    101,
    104,
    1,
    0,
    0,
    0,
    102,
    100,
    1,
    0,
    0,
    0,
    102,
    103,
    1,
    0,
    0,
    0,
    103,
    15,
    1,
    0,
    0,
    0,
    104,
    102,
    1,
    0,
    0,
    0,
    105,
    110,
    3,
    18,
    9,
    0,
    106,
    107,
    7,
    1,
    0,
    0,
    107,
    109,
    3,
    18,
    9,
    0,
    108,
    106,
    1,
    0,
    0,
    0,
    109,
    112,
    1,
    0,
    0,
    0,
    110,
    108,
    1,
    0,
    0,
    0,
    110,
    111,
    1,
    0,
    0,
    0,
    111,
    17,
    1,
    0,
    0,
    0,
    112,
    110,
    1,
    0,
    0,
    0,
    113,
    118,
    3,
    20,
    10,
    0,
    114,
    115,
    7,
    2,
    0,
    0,
    115,
    117,
    3,
    20,
    10,
    0,
    116,
    114,
    1,
    0,
    0,
    0,
    117,
    120,
    1,
    0,
    0,
    0,
    118,
    116,
    1,
    0,
    0,
    0,
    118,
    119,
    1,
    0,
    0,
    0,
    119,
    19,
    1,
    0,
    0,
    0,
    120,
    118,
    1,
    0,
    0,
    0,
    121,
    123,
    5,
    19,
    0,
    0,
    122,
    121,
    1,
    0,
    0,
    0,
    122,
    123,
    1,
    0,
    0,
    0,
    123,
    124,
    1,
    0,
    0,
    0,
    124,
    125,
    3,
    22,
    11,
    0,
    125,
    21,
    1,
    0,
    0,
    0,
    126,
    131,
    3,
    28,
    14,
    0,
    127,
    128,
    5,
    16,
    0,
    0,
    128,
    130,
    3,
    24,
    12,
    0,
    129,
    127,
    1,
    0,
    0,
    0,
    130,
    133,
    1,
    0,
    0,
    0,
    131,
    129,
    1,
    0,
    0,
    0,
    131,
    132,
    1,
    0,
    0,
    0,
    132,
    23,
    1,
    0,
    0,
    0,
    133,
    131,
    1,
    0,
    0,
    0,
    134,
    140,
    5,
    30,
    0,
    0,
    135,
    137,
    5,
    22,
    0,
    0,
    136,
    138,
    3,
    26,
    13,
    0,
    137,
    136,
    1,
    0,
    0,
    0,
    137,
    138,
    1,
    0,
    0,
    0,
    138,
    139,
    1,
    0,
    0,
    0,
    139,
    141,
    5,
    23,
    0,
    0,
    140,
    135,
    1,
    0,
    0,
    0,
    140,
    141,
    1,
    0,
    0,
    0,
    141,
    25,
    1,
    0,
    0,
    0,
    142,
    147,
    3,
    8,
    4,
    0,
    143,
    144,
    5,
    17,
    0,
    0,
    144,
    146,
    3,
    8,
    4,
    0,
    145,
    143,
    1,
    0,
    0,
    0,
    146,
    149,
    1,
    0,
    0,
    0,
    147,
    145,
    1,
    0,
    0,
    0,
    147,
    148,
    1,
    0,
    0,
    0,
    148,
    27,
    1,
    0,
    0,
    0,
    149,
    147,
    1,
    0,
    0,
    0,
    150,
    160,
    5,
    27,
    0,
    0,
    151,
    160,
    5,
    26,
    0,
    0,
    152,
    160,
    5,
    28,
    0,
    0,
    153,
    160,
    5,
    29,
    0,
    0,
    154,
    160,
    5,
    30,
    0,
    0,
    155,
    156,
    5,
    22,
    0,
    0,
    156,
    157,
    3,
    8,
    4,
    0,
    157,
    158,
    5,
    23,
    0,
    0,
    158,
    160,
    1,
    0,
    0,
    0,
    159,
    150,
    1,
    0,
    0,
    0,
    159,
    151,
    1,
    0,
    0,
    0,
    159,
    152,
    1,
    0,
    0,
    0,
    159,
    153,
    1,
    0,
    0,
    0,
    159,
    154,
    1,
    0,
    0,
    0,
    159,
    155,
    1,
    0,
    0,
    0,
    160,
    29,
    1,
    0,
    0,
    0,
    161,
    162,
    5,
    30,
    0,
    0,
    162,
    31,
    1,
    0,
    0,
    0,
    17,
    35,
    42,
    51,
    58,
    68,
    77,
    86,
    94,
    102,
    110,
    118,
    122,
    131,
    137,
    140,
    147,
    159
  ];

  static final ATN _ATN = ATNDeserializer().deserialize(_serializedATN);
}

class TemplateContext extends ParserRuleContext {
  TerminalNode? EOF() => getToken(MustacheParser.TOKEN_EOF, 0);
  List<ElementContext> elements() => getRuleContexts<ElementContext>();
  ElementContext? element(int i) => getRuleContext<ElementContext>(i);
  TemplateContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_template;
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterTemplate(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitTemplate(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitTemplate(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class ElementContext extends ParserRuleContext {
  TagContext? tag() => getRuleContext<TagContext>(0);
  TerminalNode? TEXT() => getToken(MustacheParser.TOKEN_TEXT, 0);
  ElementContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_element;
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterElement(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitElement(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitElement(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class TagContext extends ParserRuleContext {
  TerminalNode? OPEN() => getToken(MustacheParser.TOKEN_OPEN, 0);
  TagBodyContext? tagBody() => getRuleContext<TagBodyContext>(0);
  TerminalNode? CLOSE() => getToken(MustacheParser.TOKEN_CLOSE, 0);
  TerminalNode? OPEN_UNESC() => getToken(MustacheParser.TOKEN_OPEN_UNESC, 0);
  TerminalNode? UNESC_NAME() => getToken(MustacheParser.TOKEN_UNESC_NAME, 0);
  TerminalNode? UNESC_CLOSE() => getToken(MustacheParser.TOKEN_UNESC_CLOSE, 0);
  TagContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_tag;
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterTag(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitTag(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitTag(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class TagBodyContext extends ParserRuleContext {
  TagBodyContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_tagBody;

  @override
  void copyFrom(ParserRuleContext ctx) {
    super.copyFrom(ctx);
  }
}

class ExprContext extends ParserRuleContext {
  OrExprContext? orExpr() => getRuleContext<OrExprContext>(0);
  ExprContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_expr;
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterExpr(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitExpr(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitExpr(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class OrExprContext extends ParserRuleContext {
  Token? _OR;
  var ops = <Token>[];
  List<AndExprContext> andExprs() => getRuleContexts<AndExprContext>();
  AndExprContext? andExpr(int i) => getRuleContext<AndExprContext>(i);
  List<TerminalNode> ORs() => getTokens(MustacheParser.TOKEN_OR);
  TerminalNode? OR(int i) => getToken(MustacheParser.TOKEN_OR, i);
  OrExprContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_orExpr;
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterOrExpr(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitOrExpr(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitOrExpr(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class AndExprContext extends ParserRuleContext {
  Token? _AND;
  var ops = <Token>[];
  List<CmpExprContext> cmpExprs() => getRuleContexts<CmpExprContext>();
  CmpExprContext? cmpExpr(int i) => getRuleContext<CmpExprContext>(i);
  List<TerminalNode> ANDs() => getTokens(MustacheParser.TOKEN_AND);
  TerminalNode? AND(int i) => getToken(MustacheParser.TOKEN_AND, i);
  AndExprContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_andExpr;
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterAndExpr(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitAndExpr(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitAndExpr(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class CmpExprContext extends ParserRuleContext {
  Token? _EQ;
  var ops = <Token>[];
  Token? _NE;
  Token? _LT;
  Token? _GT;
  Token? _LTE;
  Token? _GTE;
  Token? _tset179;
  List<AddExprContext> addExprs() => getRuleContexts<AddExprContext>();
  AddExprContext? addExpr(int i) => getRuleContext<AddExprContext>(i);
  List<TerminalNode> EQs() => getTokens(MustacheParser.TOKEN_EQ);
  TerminalNode? EQ(int i) => getToken(MustacheParser.TOKEN_EQ, i);
  List<TerminalNode> NEs() => getTokens(MustacheParser.TOKEN_NE);
  TerminalNode? NE(int i) => getToken(MustacheParser.TOKEN_NE, i);
  List<TerminalNode> LTs() => getTokens(MustacheParser.TOKEN_LT);
  TerminalNode? LT(int i) => getToken(MustacheParser.TOKEN_LT, i);
  List<TerminalNode> GTs() => getTokens(MustacheParser.TOKEN_GT);
  TerminalNode? GT(int i) => getToken(MustacheParser.TOKEN_GT, i);
  List<TerminalNode> LTEs() => getTokens(MustacheParser.TOKEN_LTE);
  TerminalNode? LTE(int i) => getToken(MustacheParser.TOKEN_LTE, i);
  List<TerminalNode> GTEs() => getTokens(MustacheParser.TOKEN_GTE);
  TerminalNode? GTE(int i) => getToken(MustacheParser.TOKEN_GTE, i);
  CmpExprContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_cmpExpr;
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterCmpExpr(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitCmpExpr(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitCmpExpr(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class AddExprContext extends ParserRuleContext {
  Token? _PLUS;
  var ops = <Token>[];
  Token? _MINUS;
  Token? _tset216;
  List<MulExprContext> mulExprs() => getRuleContexts<MulExprContext>();
  MulExprContext? mulExpr(int i) => getRuleContext<MulExprContext>(i);
  List<TerminalNode> PLUSs() => getTokens(MustacheParser.TOKEN_PLUS);
  TerminalNode? PLUS(int i) => getToken(MustacheParser.TOKEN_PLUS, i);
  List<TerminalNode> MINUSs() => getTokens(MustacheParser.TOKEN_MINUS);
  TerminalNode? MINUS(int i) => getToken(MustacheParser.TOKEN_MINUS, i);
  AddExprContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_addExpr;
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterAddExpr(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitAddExpr(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitAddExpr(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class MulExprContext extends ParserRuleContext {
  Token? _STAR;
  var ops = <Token>[];
  Token? _SLASH;
  Token? _tset237;
  List<UnaryExprContext> unaryExprs() => getRuleContexts<UnaryExprContext>();
  UnaryExprContext? unaryExpr(int i) => getRuleContext<UnaryExprContext>(i);
  List<TerminalNode> STARs() => getTokens(MustacheParser.TOKEN_STAR);
  TerminalNode? STAR(int i) => getToken(MustacheParser.TOKEN_STAR, i);
  List<TerminalNode> SLASHs() => getTokens(MustacheParser.TOKEN_SLASH);
  TerminalNode? SLASH(int i) => getToken(MustacheParser.TOKEN_SLASH, i);
  MulExprContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_mulExpr;
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterMulExpr(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitMulExpr(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitMulExpr(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class UnaryExprContext extends ParserRuleContext {
  PipeAtomContext? pipeAtom() => getRuleContext<PipeAtomContext>(0);
  TerminalNode? MINUS() => getToken(MustacheParser.TOKEN_MINUS, 0);
  UnaryExprContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_unaryExpr;
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterUnaryExpr(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitUnaryExpr(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitUnaryExpr(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class PipeAtomContext extends ParserRuleContext {
  AtomContext? atom() => getRuleContext<AtomContext>(0);
  List<TerminalNode> PIPEs() => getTokens(MustacheParser.TOKEN_PIPE);
  TerminalNode? PIPE(int i) => getToken(MustacheParser.TOKEN_PIPE, i);
  List<FilterCallContext> filterCalls() => getRuleContexts<FilterCallContext>();
  FilterCallContext? filterCall(int i) => getRuleContext<FilterCallContext>(i);
  PipeAtomContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_pipeAtom;
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterPipeAtom(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitPipeAtom(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitPipeAtom(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class FilterCallContext extends ParserRuleContext {
  TerminalNode? NAME() => getToken(MustacheParser.TOKEN_NAME, 0);
  TerminalNode? LPAREN() => getToken(MustacheParser.TOKEN_LPAREN, 0);
  TerminalNode? RPAREN() => getToken(MustacheParser.TOKEN_RPAREN, 0);
  ExprListContext? exprList() => getRuleContext<ExprListContext>(0);
  FilterCallContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_filterCall;
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterFilterCall(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitFilterCall(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitFilterCall(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class ExprListContext extends ParserRuleContext {
  List<ExprContext> exprs() => getRuleContexts<ExprContext>();
  ExprContext? expr(int i) => getRuleContext<ExprContext>(i);
  List<TerminalNode> COMMAs() => getTokens(MustacheParser.TOKEN_COMMA);
  TerminalNode? COMMA(int i) => getToken(MustacheParser.TOKEN_COMMA, i);
  ExprListContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_exprList;
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterExprList(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitExprList(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitExprList(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class AtomContext extends ParserRuleContext {
  TerminalNode? NUMBER() => getToken(MustacheParser.TOKEN_NUMBER, 0);
  TerminalNode? STRING() => getToken(MustacheParser.TOKEN_STRING, 0);
  TerminalNode? TRUE() => getToken(MustacheParser.TOKEN_TRUE, 0);
  TerminalNode? FALSE() => getToken(MustacheParser.TOKEN_FALSE, 0);
  TerminalNode? NAME() => getToken(MustacheParser.TOKEN_NAME, 0);
  TerminalNode? LPAREN() => getToken(MustacheParser.TOKEN_LPAREN, 0);
  ExprContext? expr() => getRuleContext<ExprContext>(0);
  TerminalNode? RPAREN() => getToken(MustacheParser.TOKEN_RPAREN, 0);
  AtomContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_atom;
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterAtom(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitAtom(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitAtom(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class NameContext extends ParserRuleContext {
  TerminalNode? NAME() => getToken(MustacheParser.TOKEN_NAME, 0);
  NameContext([ParserRuleContext? parent, int? invokingState])
      : super(parent, invokingState);
  @override
  int get ruleIndex => RULE_name;
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterName(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitName(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitName(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class SectionStartContext extends TagBodyContext {
  TerminalNode? HASH() => getToken(MustacheParser.TOKEN_HASH, 0);
  NameContext? name() => getRuleContext<NameContext>(0);
  List<ExprContext> exprs() => getRuleContexts<ExprContext>();
  ExprContext? expr(int i) => getRuleContext<ExprContext>(i);
  SectionStartContext(TagBodyContext ctx) {
    copyFrom(ctx);
  }
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterSectionStart(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitSectionStart(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitSectionStart(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class VariableExprContext extends TagBodyContext {
  ExprContext? expr() => getRuleContext<ExprContext>(0);
  VariableExprContext(TagBodyContext ctx) {
    copyFrom(ctx);
  }
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterVariableExpr(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitVariableExpr(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitVariableExpr(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class AmpersandVarContext extends TagBodyContext {
  TerminalNode? AMP() => getToken(MustacheParser.TOKEN_AMP, 0);
  NameContext? name() => getRuleContext<NameContext>(0);
  AmpersandVarContext(TagBodyContext ctx) {
    copyFrom(ctx);
  }
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterAmpersandVar(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitAmpersandVar(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitAmpersandVar(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class SectionEndContext extends TagBodyContext {
  TerminalNode? SLASH() => getToken(MustacheParser.TOKEN_SLASH, 0);
  NameContext? name() => getRuleContext<NameContext>(0);
  SectionEndContext(TagBodyContext ctx) {
    copyFrom(ctx);
  }
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterSectionEnd(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitSectionEnd(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitSectionEnd(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class InvertedStartContext extends TagBodyContext {
  TerminalNode? CARET() => getToken(MustacheParser.TOKEN_CARET, 0);
  NameContext? name() => getRuleContext<NameContext>(0);
  List<ExprContext> exprs() => getRuleContexts<ExprContext>();
  ExprContext? expr(int i) => getRuleContext<ExprContext>(i);
  InvertedStartContext(TagBodyContext ctx) {
    copyFrom(ctx);
  }
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterInvertedStart(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitInvertedStart(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitInvertedStart(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class CommentContext extends TagBodyContext {
  TerminalNode? COMMENT_CONTENT() =>
      getToken(MustacheParser.TOKEN_COMMENT_CONTENT, 0);
  CommentContext(TagBodyContext ctx) {
    copyFrom(ctx);
  }
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterComment(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitComment(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitComment(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}

class PartialContext extends TagBodyContext {
  TerminalNode? GT() => getToken(MustacheParser.TOKEN_GT, 0);
  NameContext? name() => getRuleContext<NameContext>(0);
  PartialContext(TagBodyContext ctx) {
    copyFrom(ctx);
  }
  @override
  void enterRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.enterPartial(this);
  }

  @override
  void exitRule(ParseTreeListener listener) {
    if (listener is MustacheParserListener) listener.exitPartial(this);
  }

  @override
  T? accept<T>(ParseTreeVisitor<T> visitor) {
    if (visitor is MustacheParserVisitor<T>) {
      return visitor.visitPartial(this);
    } else {
      return visitor.visitChildren(this);
    }
  }
}
