import 'package:freezed_annotation/freezed_annotation.dart';

part 'assistant_message.freezed.dart';
part 'assistant_message.g.dart';

enum AssistantMessageRole { user, assistant }

@freezed
abstract class AssistantMessage with _$AssistantMessage {
  const factory AssistantMessage({
    required AssistantMessageRole role,
    required String content,
    required DateTime createdAt,
  }) = _AssistantMessage;

  factory AssistantMessage.fromJson(Map<String, dynamic> json) =>
      _$AssistantMessageFromJson(json);
}
