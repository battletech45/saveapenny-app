import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/router/app_router.dart';
import 'package:saveapenny/features/auth/data/auth_repository.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  void clearFeedback() {
    state = const AsyncData(null);
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .register(email: email, password: password, fullName: fullName);
      ref.read(authSessionControllerProvider.notifier).setAuthenticated();
    });
    if (state.hasError) {
      ref.read(authSessionControllerProvider.notifier).setUnauthenticated();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).login(email: email, password: password);
      ref.read(authSessionControllerProvider.notifier).setAuthenticated();
    });
    if (state.hasError) {
      ref.read(authSessionControllerProvider.notifier).setUnauthenticated();
    }
  }

  Future<void> refreshSession() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).refresh();
      ref.read(authSessionControllerProvider.notifier).setAuthenticated();
    });
    if (state.hasError) {
      ref.read(authSessionControllerProvider.notifier).setUnauthenticated();
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).logout();
      ref.read(authSessionControllerProvider.notifier).setUnauthenticated();
    });
  }
}
