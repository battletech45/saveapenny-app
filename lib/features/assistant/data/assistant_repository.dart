import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/assistant/data/assistant_api.dart';
import 'package:saveapenny/features/assistant/data/dto/assistant_chat_request.dart';
import 'package:saveapenny/features/assistant/domain/assistant_reply.dart';
import 'package:saveapenny/features/assistant/domain/assistant_repository.dart';

part 'assistant_repository.g.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  const AssistantRepositoryImpl(this._assistantApi);

  final AssistantApi _assistantApi;

  @override
  Future<AssistantReply> chat({
    required String message,
    String? sessionId,
  }) async {
    final response = await _assistantApi.chat(
      AssistantChatRequest(sessionId: sessionId, message: message),
    );

    return AssistantReply(
      sessionId: response.sessionId,
      reply: response.reply,
      disclaimer: response.disclaimer,
    );
  }
}

@Riverpod(keepAlive: true)
AssistantRepository assistantRepository(Ref ref) {
  return AssistantRepositoryImpl(ref.watch(assistantApiProvider));
}
