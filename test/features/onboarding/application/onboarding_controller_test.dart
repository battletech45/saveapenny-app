import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/storage/secure_token_store.dart';
import 'package:saveapenny/features/onboarding/application/onboarding_controller.dart';

class _FakeSecureTokenStore extends SecureTokenStore {
  _FakeSecureTokenStore({this.storedValue = false});

  bool storedValue;

  @override
  Future<bool> readHasOnboarded() async => storedValue;

  @override
  Future<void> setHasOnboarded({required bool value}) async {
    storedValue = value;
  }
}

void main() {
  test('build returns false when hasOnboarded flag is not set', () async {
    final tokenStore = _FakeSecureTokenStore();
    final container = ProviderContainer(
      overrides: [secureTokenStoreProvider.overrideWith((ref) => tokenStore)],
    );
    addTearDown(container.dispose);

    final value = await container.read(onboardingControllerProvider.future);

    expect(value, false);
  });

  test('build returns true when hasOnboarded flag is set', () async {
    final tokenStore = _FakeSecureTokenStore(storedValue: true);
    final container = ProviderContainer(
      overrides: [secureTokenStoreProvider.overrideWith((ref) => tokenStore)],
    );
    addTearDown(container.dispose);

    final value = await container.read(onboardingControllerProvider.future);

    expect(value, true);
  });

  test('markOnboarded persists the flag and updates state', () async {
    final tokenStore = _FakeSecureTokenStore();
    final container = ProviderContainer(
      overrides: [secureTokenStoreProvider.overrideWith((ref) => tokenStore)],
    );
    addTearDown(container.dispose);

    await container.read(onboardingControllerProvider.notifier).markOnboarded();

    expect(tokenStore.storedValue, true);
    expect(container.read(onboardingControllerProvider).value, true);
  });
}
