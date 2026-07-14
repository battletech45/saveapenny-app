import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/assistant/data/dto/assistant_message_dto.dart';

part 'assistant_chat_request.freezed.dart';
part 'assistant_chat_request.g.dart';

@freezed
abstract class AssistantChatRequest with _$AssistantChatRequest {
  const factory AssistantChatRequest({
    String? sessionId,
    required String message,
    List<AssistantMessageDto>? history,
  }) = _AssistantChatRequest;

  factory AssistantChatRequest.fromJson(Map<String, dynamic> json) =>
      _$AssistantChatRequestFromJson(json);
}
