import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:saveapenny/core/storage/cache_encryption_key_provider.dart';
import 'package:saveapenny/core/storage/response_cache_store.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

/// A real, encrypted [ResponseCacheStore] backed by a fresh temp directory,
/// for repository tests that exercise the cache fallback/write-through
/// pattern (docs/adr/0003-offline-read-cache.md). Registers `addTearDown` to
/// clean up the temp directory itself.
ResponseCacheStore createTestResponseCacheStore() {
  final storage = _MockFlutterSecureStorage();
  final values = <String, String>{};

  when(() => storage.read(key: any(named: 'key'))).thenAnswer((
    invocation,
  ) async {
    final key = invocation.namedArguments[#key]! as String;
    return values[key];
  });
  when(
    () => storage.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
    ),
  ).thenAnswer((invocation) async {
    final key = invocation.namedArguments[#key]! as String;
    final value = invocation.namedArguments[#value]! as String;
    values[key] = value;
  });
  when(() => storage.delete(key: any(named: 'key'))).thenAnswer((
    invocation,
  ) async {
    final key = invocation.namedArguments[#key]! as String;
    values.remove(key);
  });

  final dir = Directory.systemTemp.createTempSync('response_cache_test');
  addTearDown(() {
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });

  return ResponseCacheStore(
    CacheEncryptionKeyProvider(storage: storage),
    directoryResolver: () async => dir,
  );
}
