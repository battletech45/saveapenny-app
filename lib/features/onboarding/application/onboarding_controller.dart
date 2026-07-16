import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/storage/secure_token_store.dart';

part 'onboarding_controller.g.dart';

@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  @override
  Future<bool> build() async {
    return ref.read(secureTokenStoreProvider).readHasOnboarded();
  }

  Future<void> markOnboarded() async {
    await ref.read(secureTokenStoreProvider).setHasOnboarded(value: true);
    state = const AsyncData(true);
  }
}
