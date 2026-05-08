parser grammar MustacheParser;

options { language=Dart; tokenVocab=MustacheLexer; }

template: element* EOF;

element: tag | TEXT;

tag: OPEN tagBody CLOSE
   | OPEN_UNESC UNESC_NAME UNESC_CLOSE
   ;

tagBody
    : HASH name expr*       # sectionStart
    | SLASH name            # sectionEnd
    | CARET name expr*      # invertedStart
    | GT name               # partial
    | AMP name              # ampersandVar
    | COMMENT_CONTENT       # comment
    | expr                  # variableExpr
    ;

expr: orExpr;
orExpr: andExpr (ops+=OR andExpr)*;
andExpr: cmpExpr (ops+=AND cmpExpr)*;
cmpExpr: addExpr (ops+=(EQ | NE | LT | GT | LTE | GTE) addExpr)*;
addExpr: mulExpr (ops+=(PLUS | MINUS) mulExpr)*;
mulExpr: unaryExpr (ops+=(STAR | SLASH) unaryExpr)*;
unaryExpr: (MINUS)? pipeAtom;
pipeAtom: atom (PIPE filterCall)*;
filterCall: NAME (LPAREN exprList? RPAREN)?;
exprList: expr (COMMA expr)*;
atom: NUMBER | STRING | TRUE | FALSE | NAME | LPAREN expr RPAREN;

name: NAME;
