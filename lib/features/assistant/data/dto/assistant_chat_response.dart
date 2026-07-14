import 'package:freezed_annotation/freezed_annotation.dart';

part 'assistant_chat_response.freezed.dart';
part 'assistant_chat_response.g.dart';

@freezed
abstract class AssistantChatResponse with _$AssistantChatResponse {
  const factory AssistantChatResponse({
    required String sessionId,
    required String reply,
    required String disclaimer,
  }) = _AssistantChatResponse;

  factory AssistantChatResponse.fromJson(Map<String, dynamic> json) =>
      _$AssistantChatResponseFromJson(json);
}
