import 'package:saveapenny/features/auth/domain/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession> refresh();

  Future<void> logout();
}
