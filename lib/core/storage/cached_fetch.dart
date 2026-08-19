import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/storage/response_cache_store.dart';

/// Shared read-through/write-through wrapper implementing the fallback
/// pattern from docs/adr/0003-offline-read-cache.md: on success, write the
/// DTO-shaped JSON through to [cache]; on [Failure.network], fall back to
/// the last cached value under [key]. Any other failure (validation, auth,
/// rate limit) is never masked by a stale cache — it's rethrown as-is, same
/// as an uncached call.
Future<T> cachedFetch<T>({
  required ResponseCacheStore cache,
  required String key,
  required Future<T> Function() call,
  required Map<String, dynamic> Function(T value) toJson,
  required T Function(Map<String, dynamic> json) fromJson,
}) async {
  try {
    final value = await call();
    try {
      await cache.write(key, toJson(value));
    } on Object {
      // Best-effort — a cache write failure must not fail an otherwise
      // successful online call.
    }
    return value;
  } on Failure catch (failure) {
    if (failure is! NetworkFailure) {
      rethrow;
    }
    final cached = await cache.read(key);
    if (cached == null) {
      rethrow;
    }
    return fromJson(cached);
  }
}
