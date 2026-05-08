import 'package:test/test.dart';
import 'package:dartkup/dartkup.dart';

void main() {
  group('t()', () {
    test('creates an escaped text node', () {
      expect(t('hello').render(), 'hello');
    });

    test('escapes HTML special characters', () {
      expect(t('<b>&</b>').render(), '&lt;b&gt;&amp;&lt;/b&gt;');
    });
  });

  group('raw()', () {
    test('creates an unescaped raw node', () {
      expect(raw('<b>bold</b>').render(), '<b>bold</b>');
    });

    test('passes through special characters unchanged', () {
      expect(raw('1 < 2 && 3 > 0').render(), '1 < 2 && 3 > 0');
    });
  });

  group('fragment()', () {
    test('renders children in order', () {
      expect(fragment([t('a'), t('b'), t('c')]).render(), 'abc');
    });

    test('auto-escapes String entries', () {
      expect(fragment(['<x>']).render(), '&lt;x&gt;');
    });

    test('empty list renders empty string', () {
      expect(fragment([]).render(), '');
    });
  });

  group('el()', () {
    test('builds element by tag name', () {
      expect(el('section').render(), '<section></section>');
    });

    test('cls key maps to class attribute', () {
      expect(el('div', {'cls': 'card'}).render(), '<div class="card"></div>');
    });

    test('other keys pass through verbatim', () {
      expect(el('div', {'id': 'main', 'role': 'main'}).render(),
          '<div id="main" role="main"></div>');
    });

    test('null value produces boolean attribute', () {
      expect(el('input', {'disabled': null}).render(), '<input disabled>');
    });

    test('accepts single Node child', () {
      expect(el('div', {}, t('hi')).render(), '<div>hi</div>');
    });

    test('accepts List of children', () {
      expect(el('div', {}, [t('a'), t('b')]).render(), '<div>ab</div>');
    });

    test('accepts Iterable of children', () {
      final items = ['x', 'y'].map(t);
      expect(el('div', {}, items).render(), '<div>xy</div>');
    });

    test('null children produce empty element', () {
      expect(el('div', {}, null).render(), '<div></div>');
    });
  });

  group('shorthand block elements', () {
    test('div', () => expect(div({}, t('x')).render(), '<div>x</div>'));
    test('span', () => expect(span({}, t('x')).render(), '<span>x</span>'));
    test('p', () => expect(p({}, t('x')).render(), '<p>x</p>'));
    test('header', () => expect(header().render(), '<header></header>'));
    test('nav', () => expect(nav().render(), '<nav></nav>'));
    test('mainEl renders as <main>',
        () => expect(mainEl().render(), '<main></main>'));
  });

  group('shorthand list elements', () {
    test('ul wrapping li children', () {
      expect(
        ul({}, [li({}, t('one')), li({}, t('two'))]).render(),
        '<ul><li>one</li><li>two</li></ul>',
      );
    });
  });

  group('shorthand interactive elements', () {
    test('a with href', () {
      expect(
          a({'href': '/home'}, t('Home')).render(), '<a href="/home">Home</a>');
    });

    test('button', () {
      expect(button({'cls': 'btn'}, t('Click')).render(),
          '<button class="btn">Click</button>');
    });
  });

  group('void elements', () {
    test('img has no closing tag', () {
      expect(img({'src': 'a.png', 'alt': 'A'}).render(),
          '<img src="a.png" alt="A">');
    });

    test('meta has no closing tag', () {
      expect(meta({'charset': 'UTF-8'}).render(), '<meta charset="UTF-8">');
    });
  });

  group('raw-content elements', () {
    test('script does not escape text content', () {
      expect(script({}, t('1 < 2')).render(), '<script>1 < 2</script>');
    });

    test('script with defer boolean attribute', () {
      expect(script({'src': '/app.js', 'defer': null}).render(),
          '<script src="/app.js" defer></script>');
    });

    test('style does not escape content', () {
      expect(style({}, t('a > b {}')).render(), '<style>a > b {}</style>');
    });
  });

  group('htmlDoc()', () {
    test('output starts with DOCTYPE declaration', () {
      final doc = htmlDoc(lang: 'en', head: [], body: []).render();
      expect(doc, startsWith('<!DOCTYPE html>'));
    });

    test('sets the lang attribute on <html>', () {
      final doc = htmlDoc(lang: 'pt', head: [], body: []).render();
      expect(doc, contains('<html lang="pt">'));
    });

    test('renders head children inside <head>', () {
      final doc = htmlDoc(
        lang: 'en',
        head: [
          meta({'charset': 'UTF-8'})
        ],
        body: [],
      ).render();
      expect(doc, contains('<head><meta charset="UTF-8"></head>'));
    });

    test('renders body children inside <body>', () {
      final doc = htmlDoc(
        lang: 'en',
        head: [],
        body: [div({}, t('content'))],
      ).render();
      expect(doc, contains('<body><div>content</div></body>'));
    });

    test('full document structure is correct', () {
      final doc = htmlDoc(
        lang: 'en',
        head: [el('title', {}, t('My Page'))],
        body: [p({}, t('Hello'))],
      ).render();
      expect(
        doc,
        '<!DOCTYPE html><html lang="en"><head><title>My Page</title></head><body><p>Hello</p></body></html>',
      );
    });
  });
}
