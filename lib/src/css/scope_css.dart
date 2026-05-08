// ---------------------------------------------------------------------------
// Character constants
// ---------------------------------------------------------------------------

const int $space = 0x20;
const int $tab = 0x09;
const int $lf = 0x0A;
const int $cr = 0x0D;
const int $openBrace = 0x7B; // {
const int $closeBrace = 0x7D; // }
const int $openParen = 0x28; // (
const int $closeParen = 0x29; // )
const int $openBracket = 0x5B; // [
const int $closeBracket = 0x5D; // ]
const int $doubleQuote = 0x22; // "
const int $singleQuote = 0x27; // '
const int $backslash = 0x5C; // \
const int $slash = 0x2F; // /
const int $asterisk = 0x2A; // *
const int $comma = 0x2C; // ,

/// Scopes a CSS string by prefixing every top-level selector with [scope].
///
/// This is used by the API widget to ensure widget-level CSS only affects
/// elements inside that widget instance.
///
/// Example:
/// ```dart
/// final scoped = scopeCss('.card { color: red; }', '.aw-api-5');
/// // '.aw-api-5 .card { color: red; }'
/// ```
String scopeCss(String css, String scope) {
  final result = StringBuffer();
  var pos = 0;

  while (pos < css.length) {
    // Skip leading whitespace and comments.
    pos = _skipWhitespaceAndComments(css, pos);
    if (pos >= css.length) break;

    final ruleStart = pos;

    // Find the opening `{` of the declaration block,
    // skipping over strings and comments.
    var blockStart = -1;
    while (pos < css.length) {
      final ch = css.codeUnitAt(pos);
      if (ch == $openBrace) {
        blockStart = pos;
        break;
      } else if (ch == $doubleQuote || ch == $singleQuote) {
        pos = _skipString(css, pos);
      } else if (ch == $slash &&
          pos + 1 < css.length &&
          css.codeUnitAt(pos + 1) == $asterisk) {
        pos = _skipComment(css, pos);
      } else {
        pos++;
      }
    }

    if (blockStart == -1) {
      // No `{` found — emit the rest verbatim (e.g. @import;).
      result.write(css.substring(ruleStart));
      break;
    }

    final selector = css.substring(ruleStart, blockStart).trim();
    if (selector.isEmpty) {
      // Skip past this `{` and keep looking.
      pos = blockStart + 1;
      continue;
    }

    // Find the matching `}`, respecting nesting and skipping strings/comments.
    var depth = 1;
    pos = blockStart + 1;
    while (pos < css.length && depth > 0) {
      final ch = css.codeUnitAt(pos);
      if (ch == $openBrace) {
        depth++;
        pos++;
      } else if (ch == $closeBrace) {
        depth--;
        pos++;
      } else if (ch == $doubleQuote || ch == $singleQuote) {
        pos = _skipString(css, pos);
      } else if (ch == $slash &&
          pos + 1 < css.length &&
          css.codeUnitAt(pos + 1) == $asterisk) {
        pos = _skipComment(css, pos);
      } else {
        pos++;
      }
    }

    if (selector.startsWith('@media') ||
        selector.startsWith('@supports') ||
        selector.startsWith('@layer')) {
      // Scope nested rules inside at-rules that contain selectors.
      final innerStart = blockStart + 1;
      final innerEnd = pos - 1; // before the closing `}`
      final inner =
          innerEnd > innerStart ? css.substring(innerStart, innerEnd) : '';
      result.write('$selector { ${scopeCss(inner, scope)} }');
    } else if (selector.startsWith('@keyframes')) {
      // @keyframes contains keyframe selectors (from, to, %), not CSS
      // selectors — pass through unchanged.
      result.write(css.substring(ruleStart, pos));
    } else if (selector.startsWith('@import') ||
        selector.startsWith('@charset') ||
        selector.startsWith('@namespace') ||
        selector.startsWith('@font-face')) {
      // Pass-through at-rules that have no selectors to scope.
      result.write(css.substring(ruleStart, pos));
    } else {
      final scopedSelectors = _splitSelectors(selector)
          .where((s) => s.isNotEmpty)
          .map((s) => '$scope $s')
          .join(', ');
      result.write('$scopedSelectors ${css.substring(blockStart, pos)}');
    }
  }

  return result.toString();
}

/// Splits a selector list on commas that are not inside parentheses,
/// brackets, or strings.
List<String> _splitSelectors(String selector) {
  final parts = <String>[];
  final buffer = StringBuffer();
  var parenDepth = 0;
  var bracketDepth = 0;
  var pos = 0;

  while (pos < selector.length) {
    final ch = selector.codeUnitAt(pos);
    if (ch == $doubleQuote || ch == $singleQuote) {
      final end = _skipString(selector, pos);
      buffer.write(selector.substring(pos, end));
      pos = end;
    } else if (ch == $openParen) {
      parenDepth++;
      buffer.writeCharCode(ch);
      pos++;
    } else if (ch == $closeParen) {
      parenDepth--;
      buffer.writeCharCode(ch);
      pos++;
    } else if (ch == $openBracket) {
      bracketDepth++;
      buffer.writeCharCode(ch);
      pos++;
    } else if (ch == $closeBracket) {
      bracketDepth--;
      buffer.writeCharCode(ch);
      pos++;
    } else if (ch == $comma && parenDepth == 0 && bracketDepth == 0) {
      parts.add(buffer.toString().trim());
      buffer.clear();
      pos++;
    } else {
      buffer.writeCharCode(ch);
      pos++;
    }
  }

  if (buffer.isNotEmpty) {
    parts.add(buffer.toString().trim());
  }
  return parts;
}

/// Skips a CSS string starting at [start] (which must be a quote character)
/// and returns the index just past the closing quote.
int _skipString(String css, int start) {
  final quote = css.codeUnitAt(start);
  var pos = start + 1;
  while (pos < css.length) {
    final ch = css.codeUnitAt(pos);
    if (ch == $backslash) {
      pos++;
      if (pos < css.length) pos++;
    } else if (ch == quote) {
      return pos + 1;
    } else {
      pos++;
    }
  }
  return pos;
}

/// Skips a CSS comment starting at [start] (which must be `/*`) and returns
/// the index just past the closing `*/`.
int _skipComment(String css, int start) {
  var pos = start + 2; // skip /*
  while (pos + 1 < css.length) {
    if (css.codeUnitAt(pos) == $asterisk && css.codeUnitAt(pos + 1) == $slash) {
      return pos + 2;
    }
    pos++;
  }
  return css.length;
}

/// Skips whitespace and comments, returning the new position.
int _skipWhitespaceAndComments(String css, int start) {
  var pos = start;
  while (pos < css.length) {
    final ch = css.codeUnitAt(pos);
    if (_isWhitespace(ch)) {
      pos++;
    } else if (ch == $slash &&
        pos + 1 < css.length &&
        css.codeUnitAt(pos + 1) == $asterisk) {
      pos = _skipComment(css, pos);
    } else {
      break;
    }
  }
  return pos;
}

bool _isWhitespace(int code) =>
    code == $space || code == $tab || code == $lf || code == $cr;
