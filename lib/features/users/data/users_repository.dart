import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/users/data/dto/change_password_request.dart';
import 'package:saveapenny/features/users/data/dto/update_user_profile_request.dart';
import 'package:saveapenny/features/users/data/dto/user_profile_response.dart';
import 'package:saveapenny/features/users/data/users_api.dart';
import 'package:saveapenny/features/users/domain/user_profile.dart';
import 'package:saveapenny/features/users/domain/users_repository.dart';

part 'users_repository.g.dart';

class UsersRepositoryImpl implements UsersRepository {
  const UsersRepositoryImpl(this._usersApi);

  final UsersApi _usersApi;

  @override
  Future<UserProfile> getCurrentUser() async {
    final response = await _usersApi.getCurrentUser();
    return response.toDomain();
  }

  @override
  Future<UserProfile> updateProfile({required String fullName}) async {
    final response = await _usersApi.updateProfile(
      UpdateUserProfileRequest(fullName: fullName),
    );
    return response.toDomain();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _usersApi.changePassword(
      ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
  }
}

@Riverpod(keepAlive: true)
UsersRepository usersRepository(Ref ref) {
  return UsersRepositoryImpl(ref.watch(usersApiProvider));
}
