import 'package:test/test.dart';
import 'package:dartkup/dartkup.dart';

void main() {
  group('TextNode', () {
    test('renders plain text', () {
      expect(TextNode('hello').render(), 'hello');
    });

    test('escapes <', () {
      expect(TextNode('<tag>').render(), '&lt;tag&gt;');
    });

    test('escapes &', () {
      expect(TextNode('a & b').render(), 'a &amp; b');
    });

    test('does not escape double-quotes in element mode', () {
      expect(TextNode('"quoted"').render(), '"quoted"');
    });

    test('renders empty string', () {
      expect(TextNode('').render(), '');
    });
  });

  group('RawNode', () {
    test('renders without escaping', () {
      expect(RawNode('<b>bold</b>').render(), '<b>bold</b>');
    });

    test('passes through already-encoded entities unchanged', () {
      expect(RawNode('&amp; &lt;').render(), '&amp; &lt;');
    });

    test('renders empty string', () {
      expect(RawNode('').render(), '');
    });
  });

  group('FragmentNode', () {
    test('renders empty list as empty string', () {
      expect(FragmentNode([]).render(), '');
    });

    test('renders multiple Node children in order', () {
      final node = FragmentNode([TextNode('a'), TextNode('b'), TextNode('c')]);
      expect(node.render(), 'abc');
    });

    test('auto-escapes String children', () {
      final node = FragmentNode(['<x>', '&']);
      expect(node.render(), '&lt;x&gt;&amp;');
    });

    test('mixes Node and String children', () {
      final node = FragmentNode([TextNode('hello '), '<world>']);
      expect(node.render(), 'hello &lt;world&gt;');
    });

    test('passes RawNode children through unescaped', () {
      final node = FragmentNode([RawNode('<em>raw</em>'), TextNode(' text')]);
      expect(node.render(), '<em>raw</em> text');
    });
  });

  group('ElementNode', () {
    group('basic rendering', () {
      test('renders empty element', () {
        expect(ElementNode(tag: 'div').render(), '<div></div>');
      });

      test('renders element with text child', () {
        expect(ElementNode(tag: 'p', children: [TextNode('hi')]).render(),
            '<p>hi</p>');
      });

      test('auto-escapes String children', () {
        expect(
          ElementNode(tag: 'div', children: ['<b>text</b>']).render(),
          '<div>&lt;b&gt;text&lt;/b&gt;</div>',
        );
      });

      test('renders multiple children in order', () {
        expect(
          ElementNode(tag: 'div', children: [TextNode('a'), TextNode('b')])
              .render(),
          '<div>ab</div>',
        );
      });

      test('renders nested elements', () {
        final node = ElementNode(
          tag: 'ul',
          children: [
            ElementNode(tag: 'li', children: [
              TextNode('one'),
            ]),
            ElementNode(tag: 'li', children: [
              TextNode('two'),
            ]),
          ],
        );
        expect(node.render(), '<ul><li>one</li><li>two</li></ul>');
      });
    });

    group('attributes', () {
      test('renders a single attribute', () {
        expect(
          ElementNode(tag: 'div', attrs: {'id': 'main'}).render(),
          '<div id="main"></div>',
        );
      });

      test('escapes attribute values', () {
        expect(
          ElementNode(tag: 'div', attrs: {'title': '"a&b"'}).render(),
          '<div title="&quot;a&amp;b&quot;"></div>',
        );
      });

      test('null value produces a boolean attribute', () {
        expect(
          ElementNode(tag: 'script', attrs: {'defer': null}).render(),
          '<script defer></script>',
        );
      });

      test('multiple attributes rendered in insertion order', () {
        expect(
          ElementNode(tag: 'a', attrs: {'href': '/x', 'target': '_blank'})
              .render(),
          '<a href="/x" target="_blank"></a>',
        );
      });
    });

    group('void elements', () {
      test('br renders without closing tag', () {
        expect(ElementNode(tag: 'br').render(), '<br>');
      });

      test('img with attrs renders without closing tag', () {
        expect(
          ElementNode(tag: 'img', attrs: {'src': 'photo.jpg', 'alt': 'Photo'})
              .render(),
          '<img src="photo.jpg" alt="Photo">',
        );
      });

      test('meta renders without closing tag', () {
        expect(
          ElementNode(tag: 'meta', attrs: {'charset': 'UTF-8'}).render(),
          '<meta charset="UTF-8">',
        );
      });

      test('input renders without closing tag', () {
        expect(ElementNode(tag: 'input', attrs: {'type': 'text'}).render(),
            '<input type="text">');
      });
    });

    group('raw-content elements', () {
      test('script does not escape TextNode children', () {
        expect(
          ElementNode(tag: 'script', children: [TextNode('a < b && c > d')])
              .render(),
          '<script>a < b && c > d</script>',
        );
      });

      test('script does not escape String children', () {
        expect(
          ElementNode(tag: 'script', children: ['x < 1']).render(),
          '<script>x < 1</script>',
        );
      });

      test('style does not escape content', () {
        expect(
          ElementNode(
              tag: 'style',
              children: [TextNode('.a > .b { color: red; }')]).render(),
          '<style>.a > .b { color: red; }</style>',
        );
      });

      test('script still escapes attribute values', () {
        expect(
          ElementNode(tag: 'script', attrs: {'data-x': '"val"'}).render(),
          '<script data-x="&quot;val&quot;"></script>',
        );
      });
    });

    group('renderTo', () {
      test('appends to an existing StringBuffer', () {
        final buf = StringBuffer('prefix:');
        ElementNode(tag: 'span', children: [TextNode('x')]).renderTo(buf);
        expect(buf.toString(), 'prefix:<span>x</span>');
      });
    });
  });

  group('style map integration', () {
    test('renders style map via ElementNode', () {
      final el = ElementNode(
        tag: 'div',
        attrs: {
          'style': {
            'fontSize': '12px',
            'backgroundColor': 'red',
          },
        },
      );
      expect(el.render(),
          '<div style="font-size:12px;background-color:red;"></div>');
    });

    test('style map via shortcut function', () {
      final el = div({
        'style': {
          'padding': '8px',
          'border': '1px solid #ccc',
        },
      }, 'Hello');
      final html = el.render();
      expect(html, contains('padding:8px;'));
      expect(html, contains('border:1px solid #ccc;'));
      expect(html, contains('>Hello<'));
    });

    test('string style attribute still works', () {
      final el = div({
        'style': 'color: red; padding: 4px;',
      }, 'text');
      expect(el.render(), '<div style="color: red; padding: 4px;">text</div>');
    });

    test('empty style map produces style attribute with no properties', () {
      final el = div({
        'style': <String, Object?>{},
      }, 'text');
      expect(el.render(), '<div style="">text</div>');
    });
  });
}
