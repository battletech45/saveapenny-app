import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/router/app_router.dart';
import 'package:saveapenny/core/storage/secure_token_store.dart';
import 'package:saveapenny/features/auth/application/auth_controller.dart';
import 'package:saveapenny/features/auth/data/auth_repository.dart';
import 'package:saveapenny/features/auth/domain/auth_repository.dart';
import 'package:saveapenny/features/auth/domain/auth_session.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.onLogin});

  final Future<AuthSession> Function(String email, String password)? onLogin;

  @override
  Future<AuthSession> login({required String email, required String password}) {
    return onLogin!(email, password);
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession> refresh() {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  late _MockFlutterSecureStorage storage;

  setUp(() {
    storage = _MockFlutterSecureStorage();
    when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => null);
  });

  test('login marks the session authenticated', () async {
    final container = ProviderContainer(
      overrides: [
        secureTokenStoreProvider.overrideWith(
          (ref) => SecureTokenStore(storage: storage),
        ),
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(
            onLogin: (email, password) async => const AuthSession(
              accessToken: 'access-1',
              refreshToken: 'refresh-1',
              tokenType: 'Bearer',
              expiresIn: 900,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(authControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.login(email: 'altay@example.com', password: 'secret');

    expect(container.read(authControllerProvider), const AsyncData<void>(null));
    expect(container.read(authSessionControllerProvider), AuthStatus.authenticated);
  });

  test('login preserves unauthenticated state when the repository fails', () async {
    final container = ProviderContainer(
      overrides: [
        secureTokenStoreProvider.overrideWith(
          (ref) => SecureTokenStore(storage: storage),
        ),
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(
            onLogin: (email, password) async {
              throw const Failure.api(
                code: ApiErrorCode.invalidCredentials,
                message: 'Invalid credentials',
              );
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(authControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.login(email: 'altay@example.com', password: 'wrong');

    expect(container.read(authControllerProvider).hasError, isTrue);
    expect(container.read(authSessionControllerProvider), AuthStatus.unauthenticated);
  });
}
