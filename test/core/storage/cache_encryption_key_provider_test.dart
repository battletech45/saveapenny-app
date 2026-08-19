import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:saveapenny/core/storage/cache_encryption_key_provider.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockFlutterSecureStorage storage;
  late CacheEncryptionKeyProvider provider;
  late Map<String, String> values;

  setUp(() {
    storage = _MockFlutterSecureStorage();
    provider = CacheEncryptionKeyProvider(storage: storage);
    values = <String, String>{};

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
  });

  test('generates and persists a key on first use', () async {
    final key = await provider.readOrCreate();

    expect(await key.extractBytes(), hasLength(32));
    expect(values['cache_encryption_key'], isNotNull);
  });

  test('returns the same key bytes on repeated reads', () async {
    final first = await provider.readOrCreate();
    final second = await provider.readOrCreate();

    expect(await second.extractBytes(), await first.extractBytes());
  });

  test('a new key is generated after delete', () async {
    final first = await provider.readOrCreate();
    await provider.delete();
    final second = await provider.readOrCreate();

    expect(await second.extractBytes(), isNot(await first.extractBytes()));
  });
}
