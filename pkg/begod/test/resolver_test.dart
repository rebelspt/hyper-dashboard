import 'package:test/test.dart';
import 'package:begod/src/resolver.dart';

void main() {
  group('resolveValue', () {
    test('returns null for null context', () {
      expect(resolveValue('name', null), isNull);
    });

    test('returns context itself for dot name', () {
      expect(resolveValue('.', 'hello'), 'hello');
      expect(resolveValue('.', 42), 42);
      expect(resolveValue('.', {'key': 'val'}), {'key': 'val'});
    });

    test('returns null for dot name with null context', () {
      expect(resolveValue('.', null), isNull);
    });

    group('flat map lookup', () {
      test('returns value for existing key', () {
        expect(resolveValue('name', {'name': 'Alice'}), 'Alice');
      });

      test('returns null for missing key', () {
        expect(resolveValue('name', {'other': 'Bob'}), isNull);
      });

      test('returns null value for existing key with null value', () {
        expect(resolveValue('name', {'name': null}), isNull);
      });

      test('handles non-map context', () {
        expect(resolveValue('name', 'string context'), isNull);
        expect(resolveValue('name', [1, 2, 3]), isNull);
      });
    });

    group('dot-path resolution', () {
      test('resolves nested object', () {
        expect(
          resolveValue('user.name', {
            'user': {'name': 'Alice'},
          }),
          'Alice',
        );
      });

      test('returns null when intermediate key is missing', () {
        expect(
          resolveValue('user.name', {
            'other': {'name': 'Alice'},
          }),
          isNull,
        );
      });

      test('returns null when final key is missing', () {
        expect(
          resolveValue('user.name', {
            'user': {'other': 'Alice'},
          }),
          isNull,
        );
      });

      test('returns null when intermediate is not a map', () {
        expect(
          resolveValue('user.name', {
            'user': 'not-a-map',
          }),
          isNull,
        );
      });

      test('prefers exact key match over dot-path', () {
        expect(
          resolveValue('user.name', {
            'user.name': 'flat',
            'user': {'name': 'nested'},
          }),
          'flat',
        );
      });

      test('falls back to dot-path when exact key not present', () {
        expect(
          resolveValue('user.name', {
            'user': {'name': 'nested'},
          }),
          'nested',
        );
      });

      test('resolves deeply nested path', () {
        expect(
          resolveValue('a.b.c', {
            'a': {
              'b': {'c': 'deep'},
            },
          }),
          'deep',
        );
      });

      test('returns null for single part not in map', () {
        expect(resolveValue('key', {}), isNull);
      });
    });

    group('edge cases', () {
      test('empty string name returns null', () {
        expect(resolveValue('', {'key': 'val'}), isNull);
      });

      test('single dot as only character', () {
        expect(resolveValue('.', 'value'), 'value');
      });

      test('trailing dot resolves empty-string key when present', () {
        expect(
          resolveValue('user.', {
            'user': {'': 'trailing'},
          }),
          'trailing',
        );
      });

      test('trailing dot returns null when empty-string key absent', () {
        expect(
          resolveValue('user.', {
            'user': {'name': 'Bob'},
          }),
          isNull,
        );
      });
    });
  });
}
