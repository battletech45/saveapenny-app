import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/users/data/dto/change_password_request.dart';
import 'package:saveapenny/features/users/data/dto/update_user_profile_request.dart';
import 'package:saveapenny/features/users/data/dto/user_profile_response.dart';

part 'users_api.g.dart';

class UsersApi {
  const UsersApi(this._apiClient);

  final ApiClient _apiClient;

  Future<UserProfileResponse> getCurrentUser() {
    return _apiClient.send<UserProfileResponse>(
      call: (dio) => dio.get<dynamic>('/users/me'),
      fromData: (data) => UserProfileResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<UserProfileResponse> updateProfile(UpdateUserProfileRequest request) {
    return _apiClient.send<UserProfileResponse>(
      call: (dio) => dio.put<dynamic>('/users/me', data: request.toJson()),
      fromData: (data) => UserProfileResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<void> changePassword(ChangePasswordRequest request) {
    return _apiClient.send<void>(
      call: (dio) =>
          dio.put<dynamic>('/users/me/password', data: request.toJson()),
      fromData: (_) {},
    );
  }
}

Map<String, dynamic> _readJsonMap(Object? data) {
  if (data is Map<Object?, Object?>) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }

  throw const FormatException('Expected a JSON object.');
}

@Riverpod(keepAlive: true)
UsersApi usersApi(Ref ref) {
  return UsersApi(ref.watch(apiClientProvider));
}
