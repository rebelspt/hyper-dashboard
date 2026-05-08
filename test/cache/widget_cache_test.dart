import 'package:test/test.dart';
import 'package:hyper_dashboard/src/cache/widget_cache.dart';

void main() {
  group('WidgetCacheStore', () {
    late WidgetCacheStore cache;

    setUp(() {
      cache = WidgetCacheStore();
    });

    group('hasData', () {
      test('returns false when cache is empty', () {
        expect(cache.hasData, isFalse);
      });

      test('returns true after adding an entry', () async {
        await cache.fetch('key', Duration(minutes: 5), () async => 'value');
        expect(cache.hasData, isTrue);
      });

      test('returns true even after entry expires', () async {
        await cache.fetch(
            'key', Duration(milliseconds: 1), () async => 'value',);
        await Future.delayed(Duration(milliseconds: 10));
        expect(cache.hasData, isTrue);
      });
    });

    group('hasExpiredData', () {
      test('returns false when cache is empty', () {
        expect(cache.hasExpiredData, isFalse);
      });

      test('returns false when all entries are fresh', () async {
        await cache.fetch('key', Duration(minutes: 5), () async => 'value');
        expect(cache.hasExpiredData, isFalse);
      });

      test('returns true when an entry has expired', () async {
        await cache.fetch(
            'key', Duration(milliseconds: 1), () async => 'value',);
        await Future.delayed(Duration(milliseconds: 10));
        expect(cache.hasExpiredData, isTrue);
      });
    });

    group('fetch', () {
      test('calls loader when key does not exist', () async {
        var callCount = 0;
        final result = await cache.fetch('key', Duration(minutes: 5), () async {
          callCount++;
          return 'value';
        });
        expect(result, equals('value'));
        expect(callCount, equals(1));
      });

      test('returns cached value without calling loader for fresh entry',
          () async {
        var callCount = 0;
        await cache.fetch('key', Duration(minutes: 5), () async {
          callCount++;
          return 'value';
        });

        final result = await cache.fetch('key', Duration(minutes: 5), () async {
          callCount++;
          return 'new_value';
        });

        expect(result, equals('value'));
        expect(callCount, equals(1));
      });

      test('calls loader when entry has expired', () async {
        var callCount = 0;
        await cache.fetch('key', Duration(milliseconds: 1), () async {
          callCount++;
          return 'old_value';
        });
        await Future.delayed(Duration(milliseconds: 10));

        final result = await cache.fetch('key', Duration(minutes: 5), () async {
          callCount++;
          return 'new_value';
        });

        expect(result, equals('new_value'));
        expect(callCount, equals(2));
      });

      test('handles different types', () async {
        final intResult =
            await cache.fetch('int_key', Duration(minutes: 5), () async => 42);
        expect(intResult, equals(42));

        final boolResult = await cache.fetch(
            'bool_key', Duration(minutes: 5), () async => true,);
        expect(boolResult, isTrue);

        final listResult = await cache.fetch(
            'list_key', Duration(minutes: 5), () async => [1, 2, 3],);
        expect(listResult, equals([1, 2, 3]));
      });

      test('handles concurrent fetches for same key', () async {
        var callCount = 0;
        Future<String> loader() async {
          callCount++;
          await Future.delayed(Duration(milliseconds: 50));
          return 'value';
        }

        final results = await Future.wait([
          cache.fetch('key', Duration(minutes: 5), loader),
          cache.fetch('key', Duration(minutes: 5), loader),
          cache.fetch('key', Duration(minutes: 5), loader),
        ]);

        expect(results, equals(['value', 'value', 'value']));
        expect(callCount, equals(1));
      });

      test('handles concurrent fetches for different keys', () async {
        var callCount = 0;
        Future<String> loader(String key) async {
          callCount++;
          await Future.delayed(Duration(milliseconds: 10));
          return 'value_$key';
        }

        final results = await Future.wait([
          cache.fetch('key1', Duration(minutes: 5), () => loader('key1')),
          cache.fetch('key2', Duration(minutes: 5), () => loader('key2')),
          cache.fetch('key3', Duration(minutes: 5), () => loader('key3')),
        ]);

        expect(results, equals(['value_key1', 'value_key2', 'value_key3']));
        expect(callCount, equals(3));
      });

      test('cleans up inflight after completion', () async {
        await cache.fetch('key', Duration(minutes: 5), () async => 'value');

        // Second call should use cache, not create new inflight
        var secondCall = false;
        await cache.fetch('key', Duration(minutes: 5), () async {
          secondCall = true;
          return 'new_value';
        });

        expect(secondCall, isFalse);
      });

      test('cleans up inflight even when loader throws', () async {
        Future<String> failingLoader() async {
          throw Exception('Failed');
        }

        // First fetch should throw
        await expectLater(
          cache.fetch('key', Duration(minutes: 5), failingLoader),
          throwsException,
        );

        // Next fetch should try again (inflight was cleaned up)
        var called = false;
        await cache.fetch('key', Duration(minutes: 5), () async {
          called = true;
          return 'value';
        });
        expect(called, isTrue);
      });
    });

    group('invalidate', () {
      test('removes entry from cache', () async {
        await cache.fetch('key', Duration(minutes: 5), () async => 'value');
        expect(cache.hasData, isTrue);

        cache.invalidate('key');
        expect(cache.hasData, isFalse);
      });

      test('does nothing for non-existent key', () {
        cache.invalidate('non_existent');
        expect(cache.hasData, isFalse);
      });

      test('allows re-fetching after invalidation', () async {
        var callCount = 0;
        await cache.fetch('key', Duration(minutes: 5), () async {
          callCount++;
          return 'value1';
        });

        cache.invalidate('key');

        final result = await cache.fetch('key', Duration(minutes: 5), () async {
          callCount++;
          return 'value2';
        });

        expect(result, equals('value2'));
        expect(callCount, equals(2));
      });

      test('invalidates only specified key', () async {
        await cache.fetch('key1', Duration(minutes: 5), () async => 'value1');
        await cache.fetch('key2', Duration(minutes: 5), () async => 'value2');

        cache.invalidate('key1');

        expect(cache.hasData, isTrue);

        final key2Result = await cache.fetch(
            'key2', Duration(minutes: 5), () async => 'new_value2',);
        expect(key2Result, equals('value2'));
      });
    });
  });

  group('StaleCacheStore', () {
    late WidgetCacheStore innerCache;
    late StaleCacheStore staleCache;

    setUp(() {
      innerCache = WidgetCacheStore();
      staleCache = StaleCacheStore(innerCache);
    });

    test('delegates hasData to inner cache', () async {
      expect(staleCache.hasData, isFalse);
      await innerCache.fetch('key', Duration(minutes: 5), () async => 'value');
      expect(staleCache.hasData, isTrue);
    });

    test('delegates hasExpiredData to inner cache', () async {
      expect(staleCache.hasExpiredData, isFalse);
      await innerCache.fetch(
          'key', Duration(milliseconds: 1), () async => 'value',);
      await Future.delayed(Duration(milliseconds: 10));
      expect(staleCache.hasExpiredData, isTrue);
    });

    test('delegates invalidate to inner cache', () async {
      await innerCache.fetch('key', Duration(minutes: 5), () async => 'value');
      expect(innerCache.hasData, isTrue);

      staleCache.invalidate('key');
      expect(innerCache.hasData, isFalse);
    });

    group('fetch', () {
      test('returns fresh entry without calling loader', () async {
        await innerCache.fetch(
            'key', Duration(minutes: 5), () async => 'value',);

        var called = false;
        final result =
            await staleCache.fetch('key', Duration(minutes: 5), () async {
          called = true;
          return 'new_value';
        });

        expect(result, equals('value'));
        expect(called, isFalse);
      });

      test('returns stale entry without calling loader', () async {
        await innerCache.fetch(
            'key', Duration(milliseconds: 1), () async => 'value',);
        await Future.delayed(Duration(milliseconds: 10));

        var called = false;
        final result =
            await staleCache.fetch('key', Duration(minutes: 5), () async {
          called = true;
          return 'new_value';
        });

        expect(result, equals('value'));
        expect(called, isFalse);
      });

      test('calls loader when no entry exists', () async {
        var called = false;
        final result =
            await staleCache.fetch('key', Duration(minutes: 5), () async {
          called = true;
          return 'value';
        });

        expect(result, equals('value'));
        expect(called, isTrue);
      });

      test('returns stale data and inner cache refreshes on next access',
          () async {
        await innerCache.fetch(
            'key', Duration(milliseconds: 1), () async => 'old_value',);
        await Future.delayed(Duration(milliseconds: 10));

        // Stale cache returns old value immediately (even though expired)
        final staleResult = await staleCache.fetch(
            'key', Duration(minutes: 5), () async => 'new_value',);
        expect(staleResult, equals('old_value'));

        // The inner cache now has the expired entry still, so accessing it triggers refresh
        final freshResult = await innerCache.fetch(
            'key', Duration(minutes: 5), () async => 'new_value',);
        expect(freshResult, equals('new_value'));
      });

      test('handles concurrent stale fetches for same key', () async {
        await innerCache.fetch(
            'key', Duration(milliseconds: 1), () async => 'stale_value',);
        await Future.delayed(Duration(milliseconds: 10));

        var callCount = 0;
        Future<String> loader() async {
          callCount++;
          await Future.delayed(Duration(milliseconds: 50));
          return 'new_value';
        }

        final results = await Future.wait([
          staleCache.fetch('key', Duration(minutes: 5), loader),
          staleCache.fetch('key', Duration(minutes: 5), loader),
          staleCache.fetch('key', Duration(minutes: 5), loader),
        ]);

        expect(results, equals(['stale_value', 'stale_value', 'stale_value']));
        // Stale cache returns cached value immediately without calling loader
        // Loader is only called when inner cache is accessed for expired entry
        expect(callCount, equals(0));
      });
    });
  });
}
