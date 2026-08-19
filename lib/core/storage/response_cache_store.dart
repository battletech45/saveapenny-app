import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/storage/cache_encryption_key_provider.dart';

part 'response_cache_store.g.dart';

/// Read-only, encrypted, event-driven cache of last-good API response
/// bodies, keyed by the calling repository (e.g. `accounts:list`). See
/// docs/adr/0003-offline-read-cache.md for the scope and rationale: no TTL,
/// no background refresh — a value only changes when a repository writes
/// through after a successful online call.
class ResponseCacheStore {
  ResponseCacheStore(
    this._keyProvider, {
    Future<Directory> Function()? directoryResolver,
  }) : _directoryResolver = directoryResolver ?? _resolveDirectory;

  static const int _nonceLength = 12;
  static const int _macLength = 16;

  final CacheEncryptionKeyProvider _keyProvider;
  final Future<Directory> Function() _directoryResolver;
  final _algorithm = AesGcm.with256bits();

  Future<SecretKey>? _keyFuture;
  Future<Directory>? _directoryFuture;

  Future<void> write(String key, Map<String, dynamic> json) async {
    final clearBytes = utf8.encode(jsonEncode(json));
    final nonce = _algorithm.newNonce();
    final box = await _algorithm.encrypt(
      clearBytes,
      secretKey: await _key(),
      nonce: nonce,
    );

    final directory = await _directory();
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    final file = await _fileFor(key);
    await file.writeAsBytes(box.concatenation(), flush: true);
  }

  /// Returns `null` on a cache miss, or if the stored blob can't be
  /// decrypted (corrupted, tampered, or written under a key that no longer
  /// exists) — a decrypt failure degrades to a miss, never a crash.
  Future<Map<String, dynamic>?> read(String key) async {
    final file = await _fileFor(key);
    if (!file.existsSync()) {
      return null;
    }

    try {
      final bytes = await file.readAsBytes();
      final box = SecretBox.fromConcatenation(
        bytes,
        nonceLength: _nonceLength,
        macLength: _macLength,
      );
      final clearBytes = await _algorithm.decrypt(box, secretKey: await _key());
      return jsonDecode(utf8.decode(clearBytes)) as Map<String, dynamic>;
    } on Object {
      await invalidate(key);
      return null;
    }
  }

  Future<DateTime?> writtenAt(String key) async {
    final file = await _fileFor(key);
    if (!file.existsSync()) {
      return null;
    }
    return (await file.stat()).modified;
  }

  Future<void> invalidate(String key) async {
    final file = await _fileFor(key);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// Invalidates every cached key starting with [prefix] — for repositories
  /// that cache several parameterized variants of the same logical list
  /// (e.g. `budgets:list:monthly:5:...` and `budgets:list:all:20:...`) and
  /// need to drop all of them after a mutation without tracking each exact
  /// key that was ever written.
  Future<void> invalidatePrefix(String prefix) async {
    final directory = await _directory();
    if (!directory.existsSync()) {
      return;
    }
    for (final entity in directory.listSync().whereType<File>()) {
      final fileName = entity.uri.pathSegments.last;
      if (!fileName.endsWith('.cache')) {
        continue;
      }
      final encodedKey = fileName.substring(
        0,
        fileName.length - '.cache'.length,
      );
      final key = utf8.decode(base64Url.decode(encodedKey));
      if (key.startsWith(prefix)) {
        await entity.delete();
      }
    }
  }

  /// Called from the logout flow, alongside the auth token purge and the
  /// encryption key deletion — see [CacheEncryptionKeyProvider.delete].
  Future<void> clearAll() async {
    final directory = await _directory();
    if (directory.existsSync()) {
      await directory.delete(recursive: true);
    }
  }

  Future<SecretKey> _key() => _keyFuture ??= _keyProvider.readOrCreate();

  Future<Directory> _directory() => _directoryFuture ??= _directoryResolver();

  static Future<Directory> _resolveDirectory() async {
    final supportDir = await getApplicationSupportDirectory();
    return Directory('${supportDir.path}/response_cache');
  }

  Future<File> _fileFor(String key) async {
    final directory = await _directory();
    final fileName = base64Url.encode(utf8.encode(key));
    return File('${directory.path}/$fileName.cache');
  }
}

@Riverpod(keepAlive: true)
ResponseCacheStore responseCacheStore(Ref ref) {
  return ResponseCacheStore(ref.watch(cacheEncryptionKeyProviderProvider));
}
