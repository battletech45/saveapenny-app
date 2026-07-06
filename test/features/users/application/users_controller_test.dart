import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/router/app_router.dart';
import 'package:saveapenny/core/storage/secure_token_store.dart';
import 'package:saveapenny/features/users/application/users_controller.dart';
import 'package:saveapenny/features/users/data/users_repository.dart';
import 'package:saveapenny/features/users/domain/user_profile.dart';
import 'package:saveapenny/features/users/domain/users_repository.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class _FakeUsersRepository implements UsersRepository {
  _FakeUsersRepository({
    this.onGetCurrentUser,
    this.onUpdateProfile,
    this.onChangePassword,
  });

  final Future<UserProfile> Function()? onGetCurrentUser;
  final Future<UserProfile> Function(String fullName)? onUpdateProfile;
  final Future<void> Function(String currentPassword, String newPassword)?
  onChangePassword;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return onChangePassword!(currentPassword, newPassword);
  }

  @override
  Future<UserProfile> getCurrentUser() {
    return onGetCurrentUser!();
  }

  @override
  Future<UserProfile> updateProfile({required String fullName}) {
    return onUpdateProfile!(fullName);
  }
}

void main() {
  late _MockFlutterSecureStorage storage;
  late Map<String, String> values;

  setUp(() {
    storage = _MockFlutterSecureStorage();
    values = <String, String>{'access_token': 'access-1'};

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

  test(
    'change password clears tokens and marks the session unauthenticated',
    () async {
      final profile = UserProfile(
        id: 'u-1',
        email: 'altay@example.com',
        fullName: 'Altay Yilmaz',
        active: true,
        createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
        updatedAt: DateTime.parse('2026-06-10T15:30:00Z'),
      );

      final container = ProviderContainer(
        overrides: [
          secureTokenStoreProvider.overrideWith(
            (ref) => SecureTokenStore(storage: storage),
          ),
          usersRepositoryProvider.overrideWith(
            (ref) => _FakeUsersRepository(
              onGetCurrentUser: () async => profile,
              onChangePassword: (currentPassword, newPassword) async {},
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(usersControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      container.read(authSessionControllerProvider.notifier).setAuthenticated();

      await controller.changePassword(
        currentPassword: 'old-secret',
        newPassword: 'StrongPass123!',
      );

      expect(values, isEmpty);
      expect(
        container.read(authSessionControllerProvider),
        AuthStatus.unauthenticated,
      );
    },
  );

  test('update profile exposes validation failures', () async {
    final profile = UserProfile(
      id: 'u-1',
      email: 'altay@example.com',
      fullName: 'Altay Yilmaz',
      active: true,
      createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
      updatedAt: DateTime.parse('2026-06-10T15:30:00Z'),
    );

    final container = ProviderContainer(
      overrides: [
        secureTokenStoreProvider.overrideWith(
          (ref) => SecureTokenStore(storage: storage),
        ),
        usersRepositoryProvider.overrideWith(
          (ref) => _FakeUsersRepository(
            onGetCurrentUser: () async => profile,
            onUpdateProfile: (fullName) async {
              throw const Failure.api(
                code: ApiErrorCode.validationFailed,
                message: 'Request validation failed.',
              );
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(usersControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.updateProfile(fullName: '');

    expect(container.read(usersControllerProvider).hasError, isTrue);
  });
}
