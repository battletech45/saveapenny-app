import 'package:freezed_annotation/freezed_annotation.dart';

part 'assistant_reply.freezed.dart';

@freezed
abstract class AssistantReply with _$AssistantReply {
  const factory AssistantReply({
    required String sessionId,
    required String reply,
    required String disclaimer,
  }) = _AssistantReply;
}
