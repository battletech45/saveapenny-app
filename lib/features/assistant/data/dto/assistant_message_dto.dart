import 'package:freezed_annotation/freezed_annotation.dart';

part 'assistant_message_dto.freezed.dart';
part 'assistant_message_dto.g.dart';

@freezed
abstract class AssistantMessageDto with _$AssistantMessageDto {
  const factory AssistantMessageDto({
    required String role,
    required String content,
  }) = _AssistantMessageDto;

  factory AssistantMessageDto.fromJson(Map<String, dynamic> json) =>
      _$AssistantMessageDtoFromJson(json);
}
