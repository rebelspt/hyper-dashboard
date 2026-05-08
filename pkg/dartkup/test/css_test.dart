import 'package:test/test.dart';
import 'package:dartkup/dartkup.dart';

void main() {
  group('renderStyle', () {
    test('converts camelCase to kebab-case', () {
      expect(
        renderStyle({'fontSize': '12px'}),
        'font-size:12px;',
      );
    });

    test('converts multiple camelCase properties', () {
      expect(
        renderStyle({
          'fontSize': '12px',
          'backgroundColor': 'red',
        }),
        'font-size:12px;background-color:red;',
      );
    });

    test('passes kebab-case keys through', () {
      expect(
        renderStyle({'margin-top': '10px'}),
        'margin-top:10px;',
      );
    });

    test('handles mixed camelCase and kebab-case', () {
      final result = renderStyle({
        'fontSize': '14px',
        'line-height': '1.5',
      });
      expect(result, contains('font-size:14px'));
      expect(result, contains('line-height:1.5'));
    });

    test('escapes double quotes in values', () {
      final result = renderStyle({
        'fontFamily': '"Times New Roman"',
      });
      expect(result, contains('&quot;Times New Roman&quot;'));
    });

    test('handles numerical values', () {
      expect(
        renderStyle({'opacity': 0.5}),
        'opacity:0.5;',
      );
    });

    test('handles null values', () {
      expect(
        renderStyle({'color': null}),
        'color:;',
      );
    });

    test('handles empty string values', () {
      expect(
        renderStyle({'content': ''}),
        'content:;',
      );
    });

    test('empty map produces empty string', () {
      expect(renderStyle({}), '');
    });

    test('multi-word camelCase properties', () {
      expect(
        renderStyle({'borderTopLeftRadius': '8px'}),
        'border-top-left-radius:8px;',
      );
    });
  });

  group('renderStyle arrays', () {
    test('border shorthand via list', () {
      final result = renderStyle({
        'border': ['1px', 'solid', '#ccc'],
      });
      expect(result, 'border:1px solid #ccc;');
    });

    test('numbers in array', () {
      final result = renderStyle({
        'padding': [8, 16],
      });
      expect(result, 'padding:8 16;');
    });

    test('mixed types in array', () {
      final result = renderStyle({
        'font': ['bold', 14, 'sans-serif'],
      });
      expect(result, 'font:bold 14 sans-serif;');
    });

    test('font-family as string (comma-separated)', () {
      final result = renderStyle({
        'fontFamily': '"Times New Roman", serif',
      });
      expect(result, 'font-family:&quot;Times New Roman&quot;, serif;');
    });

    test('array with null element', () {
      final result = renderStyle({
        'margin': [10, null, 20],
      });
      expect(result, 'margin:10  20;');
    });

    test('single element array', () {
      final result = renderStyle({
        'zIndex': [100],
      });
      expect(result, 'z-index:100;');
    });

    test('empty array', () {
      final result = renderStyle({
        'value': [],
      });
      expect(result, 'value:;');
    });

    test('array elements are individually escaped', () {
      final result = renderStyle({
        'content': ['">malicious"', '<safe>'],
      });
      expect(result, contains('&quot;&gt;malicious&quot;'));
      expect(result, contains('&lt;safe&gt;'));
    });
  });
}
