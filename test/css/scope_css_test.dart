import 'package:test/test.dart';
import 'package:hyper_dashboard/src/css/scope_css.dart';

void main() {
  group('scopeCss basic selectors', () {
    test('class selector', () {
      expect(
        scopeCss('.card { color: red; }', '.aw-1'),
        '.aw-1 .card { color: red; }',
      );
    });

    test('id selector', () {
      expect(
        scopeCss('#header { font-size: 2rem; }', '.aw-1'),
        '.aw-1 #header { font-size: 2rem; }',
      );
    });

    test('element selector', () {
      expect(
        scopeCss('p { margin: 0; }', '.aw-1'),
        '.aw-1 p { margin: 0; }',
      );
    });

    test('universal selector', () {
      expect(
        scopeCss('* { box-sizing: border-box; }', '.aw-1'),
        '.aw-1 * { box-sizing: border-box; }',
      );
    });

    test('descendant selector', () {
      expect(
        scopeCss('.card .title { font-weight: bold; }', '.aw-1'),
        '.aw-1 .card .title { font-weight: bold; }',
      );
    });

    test('child selector', () {
      expect(
        scopeCss('.card > .title { padding: 8px; }', '.aw-1'),
        '.aw-1 .card > .title { padding: 8px; }',
      );
    });

    test('adjacent sibling selector', () {
      expect(
        scopeCss('.card + .card { margin-top: 8px; }', '.aw-1'),
        '.aw-1 .card + .card { margin-top: 8px; }',
      );
    });

    test('general sibling selector', () {
      expect(
        scopeCss('.card ~ .card { opacity: 0.5; }', '.aw-1'),
        '.aw-1 .card ~ .card { opacity: 0.5; }',
      );
    });

    test('attribute selector', () {
      expect(
        scopeCss('[data-active] { color: blue; }', '.aw-1'),
        '.aw-1 [data-active] { color: blue; }',
      );
    });

    test('attribute selector with value', () {
      expect(
        scopeCss('[type="text"] { border: 1px solid; }', '.aw-1'),
        '.aw-1 [type="text"] { border: 1px solid; }',
      );
    });

    test('pseudo-class selector', () {
      expect(
        scopeCss('.btn:hover { background: red; }', '.aw-1'),
        '.aw-1 .btn:hover { background: red; }',
      );
    });

    test('pseudo-element selector', () {
      expect(
        scopeCss('.link::after { content: "→"; }', '.aw-1'),
        '.aw-1 .link::after { content: "→"; }',
      );
    });

    test('complex combined selector', () {
      expect(
        scopeCss('div.card#hero > span.title::first-letter { font-size: 2em; }',
            '.aw-1',),
        '.aw-1 div.card#hero > span.title::first-letter { font-size: 2em; }',
      );
    });
  });

  group('scopeCss multiple selectors', () {
    test('comma-separated class selectors', () {
      expect(
        scopeCss('.card, .btn { margin: 0; }', '.aw-1'),
        '.aw-1 .card, .aw-1 .btn { margin: 0; }',
      );
    });

    test('comma-separated mixed selectors', () {
      expect(
        scopeCss('h1, h2, h3 { font-family: serif; }', '.aw-1'),
        '.aw-1 h1, .aw-1 h2, .aw-1 h3 { font-family: serif; }',
      );
    });

    test('comma-separated with whitespace', () {
      expect(
        scopeCss('.card , .btn , .link { color: red; }', '.aw-1'),
        '.aw-1 .card, .aw-1 .btn, .aw-1 .link { color: red; }',
      );
    });

    test('multiple rules', () {
      final input = '.card { color: red; } .btn { background: blue; }';
      final expected =
          '.aw-1 .card { color: red; }.aw-1 .btn { background: blue; }';
      expect(scopeCss(input, '.aw-1'), expected);
    });

    test('multiple rules with newlines', () {
      final input = '''
.card {
  color: red;
}
.btn {
  background: blue;
}
''';
      final expected =
          '.aw-1 .card {\n  color: red;\n}.aw-1 .btn {\n  background: blue;\n}';
      expect(scopeCss(input, '.aw-1'), expected);
    });
  });

  group('scopeCss at-rules', () {
    test('@media query', () {
      final input = '@media (min-width: 600px) { .card { width: 100%; } }';
      final expected =
          '@media (min-width: 600px) { .aw-1 .card { width: 100%; } }';
      expect(scopeCss(input, '.aw-1'), expected);
    });

    test('@media with multiple rules inside', () {
      final input =
          '@media (min-width: 600px) { .card { width: 100%; } .btn { padding: 8px; } }';
      final expected =
          '@media (min-width: 600px) { .aw-1 .card { width: 100%; }.aw-1 .btn { padding: 8px; } }';
      expect(scopeCss(input, '.aw-1'), expected);
    });

    test('@media with nested @media', () {
      final input =
          '@media screen { @media (min-width: 600px) { .card { width: 100%; } } }';
      final expected =
          '@media screen { @media (min-width: 600px) { .aw-1 .card { width: 100%; } } }';
      expect(scopeCss(input, '.aw-1'), expected);
    });

    test('@keyframes animation', () {
      final input =
          '@keyframes slide { from { left: 0; } to { left: 100px; } }';
      // @keyframes content is passed through unchanged (keyframe selectors
      // like 'from', 'to', '50%' are not CSS selectors).
      expect(scopeCss(input, '.aw-1'), input);
    });

    test('@supports feature query', () {
      final input = '@supports (display: grid) { .grid { display: grid; } }';
      final expected =
          '@supports (display: grid) { .aw-1 .grid { display: grid; } }';
      expect(scopeCss(input, '.aw-1'), expected);
    });

    test('@layer rule', () {
      final input = '@layer components { .card { background: white; } }';
      final expected =
          '@layer components { .aw-1 .card { background: white; } }';
      expect(scopeCss(input, '.aw-1'), expected);
    });

    test('@import pass-through', () {
      expect(
        scopeCss('@import url("theme.css");', '.aw-1'),
        '@import url("theme.css");',
      );
    });

    test('@charset pass-through', () {
      expect(
        scopeCss('@charset "UTF-8";', '.aw-1'),
        '@charset "UTF-8";',
      );
    });

    test('@font-face pass-through', () {
      final input =
          '@font-face { font-family: "Custom"; src: url("font.woff2"); }';
      expect(scopeCss(input, '.aw-1'), input);
    });

    test('@namespace pass-through', () {
      expect(
        scopeCss('@namespace url(http://www.w3.org/1999/xhtml);', '.aw-1'),
        '@namespace url(http://www.w3.org/1999/xhtml);',
      );
    });
  });

  group('scopeCss edge cases', () {
    test('empty string', () {
      expect(scopeCss('', '.aw-1'), '');
    });

    test('whitespace only', () {
      expect(scopeCss('   \n\t  ', '.aw-1'), '');
    });

    test('no closing brace', () {
      // Without a closing brace the selector is still scoped and the rest
      // of the text is emitted verbatim.
      expect(
          scopeCss('.card { color: red', '.aw-1'), '.aw-1 .card { color: red',);
    });

    test('empty rule block', () {
      expect(scopeCss('.card {}', '.aw-1'), '.aw-1 .card {}');
    });

    test('multiple spaces between selector and block', () {
      expect(
        scopeCss('.card    { color: red; }', '.aw-1'),
        '.aw-1 .card { color: red; }',
      );
    });

    test('selector with curly braces in string value', () {
      final input = '.card::before { content: "{"; }';
      final expected = '.aw-1 .card::before { content: "{"; }';
      expect(scopeCss(input, '.aw-1'), expected);
    });

    test('values containing semicolons', () {
      final input =
          '.card { font-family: "Times New Roman", serif; color: red; }';
      final expected =
          '.aw-1 .card { font-family: "Times New Roman", serif; color: red; }';
      expect(scopeCss(input, '.aw-1'), expected);
    });

    test('complex real-world CSS', () {
      final input = '''
.card {
  display: flex;
  gap: 12px;
  align-items: center;
  margin-bottom: 12px;
}

.sprite {
  width: 72px;
  height: 72px;
  image-rendering: pixelated;
  background: #2a2a2a;
  border-radius: 6px;
}

.btn-row {
  display: flex;
  gap: 6px;
  margin-top: 10px;
}

.btn {
  flex: 1;
  background: #2a2a2a;
  border: 1px solid #414868;
  border-radius: 4px;
  padding: 6px 0;
  color: #e0e0e0;
  font-size: 0.75rem;
  cursor: pointer;
}

.btn:hover {
  border-color: #c084fc;
}

.stat-row {
  margin-bottom: 6px;
}

.stat-label {
  display: flex;
  justify-content: space-between;
  font-size: 0.75rem;
  margin-bottom: 2px;
}

.bar-track {
  background: #2a2a2a;
  border-radius: 3px;
  height: 6px;
  overflow: hidden;
}

.bar-fill {
  background: #c084fc;
  height: 100%;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.info-cell {
  background: #2a2a2a;
  padding: 8px;
  border-radius: 4px;
}
'''
          .trim();
      // Rules are concatenated without blank lines between them.
      final expected = '''
.aw-1 .card {
  display: flex;
  gap: 12px;
  align-items: center;
  margin-bottom: 12px;
}.aw-1 .sprite {
  width: 72px;
  height: 72px;
  image-rendering: pixelated;
  background: #2a2a2a;
  border-radius: 6px;
}.aw-1 .btn-row {
  display: flex;
  gap: 6px;
  margin-top: 10px;
}.aw-1 .btn {
  flex: 1;
  background: #2a2a2a;
  border: 1px solid #414868;
  border-radius: 4px;
  padding: 6px 0;
  color: #e0e0e0;
  font-size: 0.75rem;
  cursor: pointer;
}.aw-1 .btn:hover {
  border-color: #c084fc;
}.aw-1 .stat-row {
  margin-bottom: 6px;
}.aw-1 .stat-label {
  display: flex;
  justify-content: space-between;
  font-size: 0.75rem;
  margin-bottom: 2px;
}.aw-1 .bar-track {
  background: #2a2a2a;
  border-radius: 3px;
  height: 6px;
  overflow: hidden;
}.aw-1 .bar-fill {
  background: #c084fc;
  height: 100%;
}.aw-1 .info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}.aw-1 .info-cell {
  background: #2a2a2a;
  padding: 8px;
  border-radius: 4px;
}
'''
          .trim();
      expect(scopeCss(input, '.aw-1'), expected);
    });

    test('CSS with @media and regular rules mixed', () {
      final input = '''
.card { color: red; }
@media (min-width: 600px) {
  .card { width: 100%; }
  .btn { padding: 8px; }
}
.btn { background: blue; }
''';
      final expected =
          '.aw-1 .card { color: red; }@media (min-width: 600px) { .aw-1 .card { width: 100%; }.aw-1 .btn { padding: 8px; } }.aw-1 .btn { background: blue; }';
      expect(scopeCss(input, '.aw-1'), expected);
    });
  });

  group('scopeCss complex selectors', () {
    test(':is() with commas', () {
      expect(
        scopeCss(':is(.card, .btn) { color: red; }', '.aw-1'),
        '.aw-1 :is(.card, .btn) { color: red; }',
      );
    });

    test(':where() with commas', () {
      expect(
        scopeCss(':where(.card, .btn) { color: red; }', '.aw-1'),
        '.aw-1 :where(.card, .btn) { color: red; }',
      );
    });

    test(':not() with commas', () {
      expect(
        scopeCss(':not(.card, .btn) { color: red; }', '.aw-1'),
        '.aw-1 :not(.card, .btn) { color: red; }',
      );
    });

    test(':has() with commas', () {
      expect(
        scopeCss(':has(.card, .btn) { color: red; }', '.aw-1'),
        '.aw-1 :has(.card, .btn) { color: red; }',
      );
    });

    test('attribute selector with comma in value', () {
      expect(
        scopeCss('[data-val="a,b"] { color: red; }', '.aw-1'),
        '.aw-1 [data-val="a,b"] { color: red; }',
      );
    });

    test('multi-line complex selector', () {
      final input = '''
.card,
.btn,
.link {
  color: red;
}
''';
      final expected =
          '.aw-1 .card, .aw-1 .btn, .aw-1 .link {\n  color: red;\n}';
      expect(scopeCss(input, '.aw-1'), expected);
    });

    test('comments between rules', () {
      final input = '''
.card { color: red; }
/* comment */
.btn { color: blue; }
''';
      final expected = '.aw-1 .card { color: red; }.aw-1 .btn { color: blue; }';
      expect(scopeCss(input, '.aw-1'), expected);
    });

    test('curly brace in string value after block start', () {
      final input = '.card::before { content: "}"; }';
      final expected = '.aw-1 .card::before { content: "}"; }';
      expect(scopeCss(input, '.aw-1'), expected);
    });

    test('nested parentheses with comma', () {
      expect(
        scopeCss('.x:is(.a, .b):where(.c, .d) { color: red; }', '.aw-1'),
        '.aw-1 .x:is(.a, .b):where(.c, .d) { color: red; }',
      );
    });

    test('mixed complex selector with functional pseudo-class and comma', () {
      expect(
        scopeCss('.card, :is(.btn, .link) { color: red; }', '.aw-1'),
        '.aw-1 .card, .aw-1 :is(.btn, .link) { color: red; }',
      );
    });
  });

  group('scopeCss different scope values', () {
    test('dot-prefixed scope class', () {
      expect(
        scopeCss('.card { color: red; }', '.my-widget'),
        '.my-widget .card { color: red; }',
      );
    });

    test('ID scope', () {
      expect(
        scopeCss('.card { color: red; }', '#app'),
        '#app .card { color: red; }',
      );
    });

    test('element scope', () {
      expect(
        scopeCss('.card { color: red; }', 'body'),
        'body .card { color: red; }',
      );
    });

    test('complex scope selector', () {
      expect(
        scopeCss('.card { color: red; }', '[data-widget="api"]'),
        '[data-widget="api"] .card { color: red; }',
      );
    });
  });
}
