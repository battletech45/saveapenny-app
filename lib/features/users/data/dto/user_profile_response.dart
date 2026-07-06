import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/users/domain/user_profile.dart';

part 'user_profile_response.freezed.dart';
part 'user_profile_response.g.dart';

@freezed
abstract class UserProfileResponse with _$UserProfileResponse {
  const factory UserProfileResponse({
    required String id,
    required String email,
    required String fullName,
    required bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfileResponse;

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UserProfileResponseFromJson(json);
}

extension UserProfileResponseX on UserProfileResponse {
  UserProfile toDomain() {
    return UserProfile(
      id: id,
      email: email,
      fullName: fullName,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
