import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:saveapenny/core/storage/cache_encryption_key_provider.dart';
import 'package:saveapenny/core/storage/response_cache_store.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockFlutterSecureStorage storage;
  late CacheEncryptionKeyProvider keyProvider;
  late Directory cacheDir;
  late ResponseCacheStore store;

  setUp(() {
    storage = _MockFlutterSecureStorage();
    keyProvider = CacheEncryptionKeyProvider(storage: storage);
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

    cacheDir = Directory.systemTemp.createTempSync('response_cache_store_test');
    store = ResponseCacheStore(
      keyProvider,
      directoryResolver: () async => cacheDir,
    );
  });

  tearDown(() {
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  });

  test('read is a miss before anything is written', () async {
    expect(await store.read('accounts:list'), isNull);
    expect(await store.writtenAt('accounts:list'), isNull);
  });

  test('write then read round-trips the same JSON', () async {
    final payload = <String, dynamic>{
      'items': <dynamic>[
        <String, dynamic>{'id': 'a1', 'name': 'Wallet'},
      ],
    };

    await store.write('accounts:list', payload);
    final result = await store.read('accounts:list');

    expect(result, payload);
  });

  test('what lands on disk is not plaintext JSON', () async {
    await store.write('accounts:list', <String, dynamic>{
      'balance': 'do-not-leak-me',
    });

    final files = cacheDir.listSync().whereType<File>().toList();
    expect(files, hasLength(1));
    final onDisk = await files.single.readAsBytes();
    final asLatin1 = String.fromCharCodes(onDisk);
    expect(asLatin1, isNot(contains('do-not-leak-me')));
  });

  test('writtenAt reflects a completed write', () async {
    await store.write('accounts:list', <String, dynamic>{'items': <dynamic>[]});

    final writtenAt = await store.writtenAt('accounts:list');

    expect(writtenAt, isNotNull);
    expect(
      writtenAt!.difference(DateTime.now()).abs(),
      lessThan(const Duration(seconds: 5)),
    );
  });

  test('invalidate removes a single key without affecting others', () async {
    await store.write('accounts:list', <String, dynamic>{'k': 'accounts'});
    await store.write('budgets:list', <String, dynamic>{'k': 'budgets'});

    await store.invalidate('accounts:list');

    expect(await store.read('accounts:list'), isNull);
    expect(await store.read('budgets:list'), <String, dynamic>{'k': 'budgets'});
  });

  test('invalidatePrefix removes only keys starting with the prefix', () async {
    await store.write(
      'budgets:list:monthly:5:startDate,desc',
      <String, dynamic>{'k': 'a'},
    );
    await store.write('budgets:list:all:20:startDate,desc', <String, dynamic>{
      'k': 'b',
    });
    await store.write('budgets:status:b-1', <String, dynamic>{'k': 'c'});
    await store.write('accounts:list', <String, dynamic>{'k': 'd'});

    await store.invalidatePrefix('budgets:list:');

    expect(await store.read('budgets:list:monthly:5:startDate,desc'), isNull);
    expect(await store.read('budgets:list:all:20:startDate,desc'), isNull);
    expect(await store.read('budgets:status:b-1'), isNotNull);
    expect(await store.read('accounts:list'), isNotNull);
  });

  test('clearAll removes every cached key', () async {
    await store.write('accounts:list', <String, dynamic>{'k': 'accounts'});
    await store.write('budgets:list', <String, dynamic>{'k': 'budgets'});

    await store.clearAll();

    expect(await store.read('accounts:list'), isNull);
    expect(await store.read('budgets:list'), isNull);
  });

  test(
    'a corrupted cache file degrades to a miss instead of throwing',
    () async {
      await store.write('accounts:list', <String, dynamic>{'k': 'accounts'});
      final file = cacheDir.listSync().whereType<File>().single;
      await file.writeAsBytes(<int>[1, 2, 3]);

      expect(await store.read('accounts:list'), isNull);
    },
  );

  test(
    'data written under an old key is unreadable after the key rotates',
    () async {
      await store.write('accounts:list', <String, dynamic>{'k': 'accounts'});
      await keyProvider.delete(); // simulates the logout key wipe
      final rotated = ResponseCacheStore(
        keyProvider,
        directoryResolver: () async => cacheDir,
      );

      expect(await rotated.read('accounts:list'), isNull);
    },
  );
}
