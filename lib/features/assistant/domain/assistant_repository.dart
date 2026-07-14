import 'package:saveapenny/features/assistant/domain/assistant_reply.dart';

abstract interface class AssistantRepository {
  Future<AssistantReply> chat({required String message, String? sessionId});
}
