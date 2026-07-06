import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    required String fullName,
    required bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfile;
}
