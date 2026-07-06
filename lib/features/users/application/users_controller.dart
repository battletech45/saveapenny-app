import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/router/app_router.dart';
import 'package:saveapenny/core/storage/secure_token_store.dart';
import 'package:saveapenny/features/users/data/users_repository.dart';
import 'package:saveapenny/features/users/domain/user_profile.dart';

part 'users_controller.g.dart';

@Riverpod(keepAlive: true)
class UsersController extends _$UsersController {
  @override
  Future<UserProfile> build() {
    return ref.read(usersRepositoryProvider).getCurrentUser();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(usersRepositoryProvider).getCurrentUser(),
    );
  }

  Future<void> updateProfile({required String fullName}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(usersRepositoryProvider).updateProfile(fullName: fullName),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final current = state is AsyncData<UserProfile>
        ? (state as AsyncData<UserProfile>).value
        : null;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final profile =
          current ?? await ref.read(usersRepositoryProvider).getCurrentUser();

      await ref
          .read(usersRepositoryProvider)
          .changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );

      await ref.read(secureTokenStoreProvider).clearTokens();
      ref.read(authSessionControllerProvider.notifier).setUnauthenticated();

      return profile;
    });
  }
}
