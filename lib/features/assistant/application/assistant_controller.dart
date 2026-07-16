import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/analytics/analytics_service.dart';
import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/assistant/data/assistant_local_store.dart';
import 'package:saveapenny/features/assistant/data/assistant_repository.dart';
import 'package:saveapenny/features/assistant/domain/assistant_conversation.dart';
import 'package:saveapenny/features/assistant/domain/assistant_message.dart';

part 'assistant_controller.freezed.dart';
part 'assistant_controller.g.dart';

@freezed
abstract class AssistantState with _$AssistantState {
  const factory AssistantState({
    String? sessionId,
    String? disclaimer,
    @Default(<AssistantMessage>[]) List<AssistantMessage> messages,
    Failure? failure,
    @Default(false) bool isSending,
  }) = _AssistantState;
}

@Riverpod(keepAlive: true)
class AssistantController extends _$AssistantController {
  @override
  Future<AssistantState> build() async {
    final conversation = await ref
        .read(assistantLocalStoreProvider)
        .readConversation();
    return AssistantState(
      sessionId: conversation.sessionId,
      disclaimer: conversation.disclaimer,
      messages: conversation.messages,
    );
  }

  Future<bool> sendMessage(String message) async {
    final trimmed = message.trim();
    final current = state.asData?.value;
    if (trimmed.isEmpty || current == null || current.isSending) {
      return false;
    }

    state = AsyncData(current.copyWith(isSending: true, failure: null));

    try {
      final reply = await ref
          .read(assistantRepositoryProvider)
          .chat(message: trimmed, sessionId: current.sessionId);

      final timestamp = DateTime.now().toUtc();
      final next = current.copyWith(
        sessionId: reply.sessionId,
        disclaimer: reply.disclaimer,
        isSending: false,
        failure: null,
        messages: <AssistantMessage>[
          ...current.messages,
          AssistantMessage(
            role: AssistantMessageRole.user,
            content: trimmed,
            createdAt: timestamp,
          ),
          AssistantMessage(
            role: AssistantMessageRole.assistant,
            content: reply.reply,
            createdAt: timestamp,
          ),
        ],
      );

      state = AsyncData(next);
      await ref
          .read(assistantLocalStoreProvider)
          .writeConversation(
            AssistantConversation(
              sessionId: next.sessionId,
              disclaimer: next.disclaimer,
              messages: next.messages,
            ),
          );
      unawaited(ref.read(analyticsServiceProvider).logAssistantMessageSent());
      return true;
    } on Failure catch (failure) {
      final next = current.copyWith(
        sessionId:
            failure is ApiFailure &&
                failure.code == ApiErrorCode.assistantChatSessionNotFound
            ? null
            : current.sessionId,
        isSending: false,
        failure: failure,
      );
      state = AsyncData(next);
      await ref
          .read(assistantLocalStoreProvider)
          .writeConversation(
            AssistantConversation(
              sessionId: next.sessionId,
              disclaimer: next.disclaimer,
              messages: next.messages,
            ),
          );
      return false;
    }
  }

  Future<void> clearConversation() async {
    final current = state.asData?.value;
    if (current == null) {
      return;
    }

    state = const AsyncData(AssistantState());
    await ref.read(assistantLocalStoreProvider).clearConversation();
  }

  void clearFailure() {
    final current = state.asData?.value;
    if (current == null || current.failure == null) {
      return;
    }

    state = AsyncData(current.copyWith(failure: null));
  }
}
