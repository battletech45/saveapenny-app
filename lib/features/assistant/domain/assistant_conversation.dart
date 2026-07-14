import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/assistant/domain/assistant_message.dart';

part 'assistant_conversation.freezed.dart';
part 'assistant_conversation.g.dart';

@freezed
abstract class AssistantConversation with _$AssistantConversation {
  const factory AssistantConversation({
    String? sessionId,
    String? disclaimer,
    @Default(<AssistantMessage>[]) List<AssistantMessage> messages,
  }) = _AssistantConversation;

  factory AssistantConversation.fromJson(Map<String, dynamic> json) =>
      _$AssistantConversationFromJson(json);
}
