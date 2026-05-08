class _CacheEntry<T> {
  final T value;
  final DateTime expiry;
  _CacheEntry(this.value, this.expiry);
}

abstract interface class CacheStore {
  Future<T> fetch<T>(String key, Duration ttl, Future<T> Function() loader);
  void invalidate(String key);

  /// Any entry exists (fresh or expired).
  bool get hasData;

  /// At least one entry exists and has passed its expiry.
  bool get hasExpiredData;
}

class WidgetCacheStore implements CacheStore {
  final _entries = <String, _CacheEntry<dynamic>>{};
  final _inflight = <String, Future<dynamic>>{};

  @override
  bool get hasData => _entries.isNotEmpty;

  @override
  bool get hasExpiredData =>
      _entries.values.any((e) => DateTime.now().isAfter(e.expiry));

  @override
  Future<T> fetch<T>(String key, Duration ttl, Future<T> Function() loader) {
    final entry = _entries[key];
    if (entry != null && !DateTime.now().isAfter(entry.expiry)) {
      return Future.value(entry.value as T);
    }
    return (_inflight[key] ??= _load<T>(key, ttl, loader)) as Future<T>;
  }

  @override
  void invalidate(String key) => _entries.remove(key);

  Future<T> _load<T>(
    String key,
    Duration ttl,
    Future<T> Function() loader,
  ) async {
    try {
      final value = await loader();
      _entries[key] = _CacheEntry(value, DateTime.now().add(ttl));
      return value;
    } finally {
      _inflight.remove(key);
    }
  }
}

/// Returns stale (possibly expired) entries immediately. Falls through to a
/// real fetch only when no entry exists for the key yet.
class StaleCacheStore implements CacheStore {
  final WidgetCacheStore _inner;
  StaleCacheStore(this._inner);

  @override
  bool get hasData => _inner.hasData;

  @override
  bool get hasExpiredData => _inner.hasExpiredData;

  @override
  void invalidate(String key) => _inner.invalidate(key);

  @override
  Future<T> fetch<T>(String key, Duration ttl, Future<T> Function() loader) {
    final entry = _inner._entries[key];
    if (entry != null) return Future.value(entry.value as T);
    return _inner.fetch(key, ttl, loader);
  }
}
