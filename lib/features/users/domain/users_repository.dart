import 'package:saveapenny/features/users/domain/user_profile.dart';

abstract interface class UsersRepository {
  Future<UserProfile> getCurrentUser();

  Future<UserProfile> updateProfile({required String fullName});

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
