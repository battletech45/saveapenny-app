import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol/patrol.dart';

import 'package:saveapenny/app.dart';
import 'package:saveapenny/core/error/failure.dart' as app_failure;
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/router/app_router.dart';
import 'package:saveapenny/core/storage/secure_token_store.dart';
import 'package:saveapenny/features/auth/data/auth_repository.dart';
import 'package:saveapenny/features/auth/domain/auth_repository.dart';
import 'package:saveapenny/features/auth/domain/auth_session.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.onLogin,
    this.onRegister,
  });

  final Future<AuthSession> Function(String email, String password)? onLogin;
  final Future<AuthSession> Function(
    String email,
    String password,
    String fullName,
  )?
  onRegister;

  @override
  Future<AuthSession> login({required String email, required String password}) {
    return onLogin!(email, password);
  }

  @override
  Future<void> logout() {
    return Future<void>.value();
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
    return onRegister!(email, password, fullName);
  }
}

void main() {
  patrolTest('login, guarded home, logout, and forced session expiry flow', ($) async {
    final storage = _MockFlutterSecureStorage();
    when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => null);

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

    await $.pumpWidgetAndSettle(
      UncontrolledProviderScope(container: container, child: const App()),
    );

    expect($('Welcome back'), findsOneWidget);

    await $(TextFormField).at(0).enterText('altay@example.com');
    await $(TextFormField).at(1).enterText('secret');
    await $('Sign in').tap();
    await $.pumpAndSettle();

    expect($('Home'), findsOneWidget);
    expect($('Foundation ready'), findsOneWidget);

    container.read(authSessionControllerProvider.notifier).setUnauthenticated();
    await $.pumpAndSettle();

    expect($('Welcome back'), findsOneWidget);

    await $(TextFormField).at(0).enterText('altay@example.com');
    await $(TextFormField).at(1).enterText('secret');
    await $('Sign in').tap();
    await $.pumpAndSettle();

    await $(Icons.logout_rounded).tap();
    await $.pumpAndSettle();

    expect($('Welcome back'), findsOneWidget);
  });

  patrolTest('register surfaces invalid password from backend mapping', ($) async {
    final storage = _MockFlutterSecureStorage();
    when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => null);

    final container = ProviderContainer(
      overrides: [
        secureTokenStoreProvider.overrideWith(
          (ref) => SecureTokenStore(storage: storage),
        ),
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(
            onRegister: (email, password, fullName) async {
              throw const app_failure.Failure.api(
                code: ApiErrorCode.invalidPassword,
                message: 'Weak password',
              );
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await $.pumpWidgetAndSettle(
      UncontrolledProviderScope(container: container, child: const App()),
    );

    await $('Create account').tap();
    await $.pumpAndSettle();

    await $(TextFormField).at(0).enterText('Altay Yilmaz');
    await $(TextFormField).at(1).enterText('altay@example.com');
    await $(TextFormField).at(2).enterText('123');
    await $('Create account').tap();
    await $.pumpAndSettle();

    expect($('The password does not meet the server requirements.'), findsOneWidget);
    expect($('Set up your account'), findsOneWidget);
  });
}
