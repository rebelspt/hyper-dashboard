lexer grammar MustacheLexer;

options { language=Dart; }

OPEN: '{{' -> pushMode(TAG);
OPEN_UNESC: '{{{' -> pushMode(UNESC);

TEXT: (~[{])+ | '{';

mode TAG;
CLOSE: '}}' -> popMode;
HASH: '#';
CARET: '^';
SLASH: '/';
GT: '>';
AMP: '&';
AND: '&&';
OR: '||';
EQ: '==';
NE: '!=';
LTE: '<=';
GTE: '>=';
PIPE: '|';
COMMA: ',';
PLUS: '+';
MINUS: '-';
STAR: '*';
LT: '<';
LPAREN: '(';
RPAREN: ')';
COMMENT_CONTENT: '!' ~[}=] (~[}])* | '!';
TAG_WS: [ \t\r\n]+ -> skip;
STRING: '"' (~["])* '"' | '\'' (~['])* '\'';
NUMBER: '-'? [0-9]+ ('.' [0-9]+)?;
TRUE: 'true';
FALSE: 'false';
NAME: '.' | '@' [a-zA-Z_][a-zA-Z0-9_]* | [a-zA-Z_][a-zA-Z0-9_.-]*;

mode UNESC;
UNESC_CLOSE: '}}}' -> popMode;
UNESC_WS: [ \t\r\n]+ -> skip;
UNESC_STRING: '"' (~["])* '"' | '\'' (~['])* '\'';
UNESC_NUMBER: '-'? [0-9]+ ('.' [0-9]+)?;
UNESC_TRUE: 'true';
UNESC_FALSE: 'false';
UNESC_NAME: '.' | '@' [a-zA-Z_][a-zA-Z0-9_]* | [a-zA-Z_][a-zA-Z0-9_.-]*;
