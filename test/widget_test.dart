import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:saveapenny/app.dart';
import 'package:saveapenny/core/error/failure.dart';
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
  testWidgets('app routes unauthenticated users to login on startup', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureTokenStoreProvider.overrideWith(
            (ref) => SecureTokenStore(storage: storage),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('login screen navigates to register screen', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureTokenStoreProvider.overrideWith(
            (ref) => SecureTokenStore(storage: storage),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Set up your account'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
  });

  testWidgets('login password visibility toggle shows and hides the password', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureTokenStoreProvider.overrideWith(
            (ref) => SecureTokenStore(storage: storage),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(_passwordEditableText(tester).obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(_passwordEditableText(tester).obscureText, isFalse);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(_passwordEditableText(tester).obscureText, isTrue);
  });

  testWidgets('register password visibility toggle shows and hides the password', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureTokenStoreProvider.overrideWith(
            (ref) => SecureTokenStore(storage: storage),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(_passwordEditableText(tester).obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(_passwordEditableText(tester).obscureText, isFalse);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(_passwordEditableText(tester).obscureText, isTrue);
  });

  testWidgets('login completes the guarded home and logout cycle', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'altay@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Foundation ready'), findsOneWidget);

    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('register success authenticates and routes to home', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

    final container = ProviderContainer(
      overrides: [
        secureTokenStoreProvider.overrideWith(
          (ref) => SecureTokenStore(storage: storage),
        ),
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(
            onRegister: (email, password, fullName) async => const AuthSession(
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Altay Yilmaz');
    await tester.enterText(find.byType(TextFormField).at(1), 'altay@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'secret');
    await tester.tap(find.text('Create account').last);
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('register surfaces invalid password failure copy', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

    final container = ProviderContainer(
      overrides: [
        secureTokenStoreProvider.overrideWith(
          (ref) => SecureTokenStore(storage: storage),
        ),
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(
            onRegister: (email, password, fullName) async {
              throw const Failure.api(
                code: ApiErrorCode.invalidPassword,
                message: 'Weak password',
              );
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Altay Yilmaz');
    await tester.enterText(find.byType(TextFormField).at(1), 'altay@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), '123');
    await tester.tap(find.text('Create account').last);
    await tester.pumpAndSettle();

    expect(find.text('The password does not meet the server requirements.'), findsOneWidget);
    expect(find.text('Set up your account'), findsOneWidget);
  });

  testWidgets('session expiry routes an authenticated user back to login', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => 'access-token');

    final container = ProviderContainer(
      overrides: [
        secureTokenStoreProvider.overrideWith(
          (ref) => SecureTokenStore(storage: storage),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);

    container.read(authSessionControllerProvider.notifier).setUnauthenticated();
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('app boots authenticated users to the placeholder home shell', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => 'access-token');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureTokenStoreProvider.overrideWith(
            (ref) => SecureTokenStore(storage: storage),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Foundation ready'), findsOneWidget);
  });

  testWidgets('authenticated shell localizes and previews shared async states', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => 'access-token');

    tester.binding.platformDispatcher.localeTestValue = const Locale('tr');
    tester.binding.platformDispatcher.localesTestValue = const <Locale>[
      Locale('tr'),
    ];
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureTokenStoreProvider.overrideWith(
            (ref) => SecureTokenStore(storage: storage),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Eszamansiz durum onizlemesi'), findsOneWidget);

    await tester.tap(find.text('Yukleniyor'));
    await tester.pump();
    expect(find.text('Yukleniyor...'), findsOneWidget);

    await tester.tap(find.text('Hata'));
    await tester.pump();
    expect(find.text('Baglanti sorunu'), findsOneWidget);
  });
}

EditableText _passwordEditableText(WidgetTester tester) {
  return tester.widget<EditableText>(
    find.byType(EditableText).last,
  );
}
