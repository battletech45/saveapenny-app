import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cache_encryption_key_provider.g.dart';

/// Reads (or generates, on first use) the AES-256 key that encrypts
/// [ResponseCacheStore] blobs at rest. The key itself lives in
/// `flutter_secure_storage`, under a namespace kept separate from auth
/// tokens (see docs/adr/0003-offline-read-cache.md) — secure storage holds
/// only this small key, never the bulk cached data.
class CacheEncryptionKeyProvider {
  CacheEncryptionKeyProvider({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyStorageKey = 'cache_encryption_key';

  final FlutterSecureStorage _storage;
  final _algorithm = AesGcm.with256bits();

  Future<SecretKey> readOrCreate() async {
    final stored = await _storage.read(key: _keyStorageKey);
    if (stored != null) {
      return SecretKey(base64Decode(stored));
    }

    final generated = await _algorithm.newSecretKey();
    final bytes = await generated.extractBytes();
    await _storage.write(key: _keyStorageKey, value: base64Encode(bytes));
    return generated;
  }

  /// Wiped on logout, alongside the auth tokens — see [SecureTokenStore.clearTokens].
  Future<void> delete() {
    return _storage.delete(key: _keyStorageKey);
  }
}

@Riverpod(keepAlive: true)
CacheEncryptionKeyProvider cacheEncryptionKeyProvider(Ref ref) {
  return CacheEncryptionKeyProvider();
}
