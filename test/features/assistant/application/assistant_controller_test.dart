import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/storage/secure_token_store.dart';
import 'package:saveapenny/features/assistant/application/assistant_controller.dart';
import 'package:saveapenny/features/assistant/data/assistant_local_store.dart';
import 'package:saveapenny/features/assistant/data/assistant_repository.dart';
import 'package:saveapenny/features/assistant/domain/assistant_conversation.dart';
import 'package:saveapenny/features/assistant/domain/assistant_message.dart';
import 'package:saveapenny/features/assistant/domain/assistant_reply.dart';
import 'package:saveapenny/features/assistant/domain/assistant_repository.dart';

class _FakeAssistantRepository implements AssistantRepository {
  _FakeAssistantRepository({this.onChat});

  final Future<AssistantReply> Function(String message, String? sessionId)?
  onChat;

  @override
  Future<AssistantReply> chat({required String message, String? sessionId}) {
    return onChat!(message, sessionId);
  }
}

class _FakeAssistantLocalStore extends AssistantLocalStore {
  _FakeAssistantLocalStore({required this.initialConversation})
    : super(tokenStore: SecureTokenStore());

  final AssistantConversation initialConversation;
  AssistantConversation? lastWrittenConversation;
  bool cleared = false;

  @override
  Future<AssistantConversation> readConversation() async {
    return initialConversation;
  }

  @override
  Future<void> writeConversation(AssistantConversation conversation) async {
    lastWrittenConversation = conversation;
  }

  @override
  Future<void> clearConversation() async {
    cleared = true;
  }
}

void main() {
  test('build loads the persisted conversation from local storage', () async {
    final localStore = _FakeAssistantLocalStore(
      initialConversation: AssistantConversation(
        sessionId: 'session-1',
        disclaimer: 'disclaimer',
        messages: <AssistantMessage>[
          AssistantMessage(
            role: AssistantMessageRole.user,
            content: 'Hello',
            createdAt: DateTime.parse('2026-07-14T10:00:00Z'),
          ),
        ],
      ),
    );
    final container = ProviderContainer(
      overrides: [
        assistantLocalStoreProvider.overrideWith((ref) => localStore),
        assistantRepositoryProvider.overrideWith(
          (ref) => _FakeAssistantRepository(
            onChat: (message, _) async => throw UnimplementedError(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(assistantControllerProvider.future);

    expect(state.sessionId, 'session-1');
    expect(state.messages.single.content, 'Hello');
  });

  test(
    'sendMessage appends reply and persists the updated conversation',
    () async {
      final localStore = _FakeAssistantLocalStore(
        initialConversation: const AssistantConversation(),
      );
      final container = ProviderContainer(
        overrides: [
          assistantLocalStoreProvider.overrideWith((ref) => localStore),
          assistantRepositoryProvider.overrideWith(
            (ref) => _FakeAssistantRepository(
              onChat: (message, sessionId) async => const AssistantReply(
                sessionId: 'session-2',
                reply: 'You spent the most on groceries.',
                disclaimer:
                    'This assistant provides general budgeting guidance, not financial, tax, or legal advice.',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(assistantControllerProvider.future);
      final didSend = await container
          .read(assistantControllerProvider.notifier)
          .sendMessage('Where am I spending the most?');

      final state = container.read(assistantControllerProvider).requireValue;
      expect(didSend, isTrue);
      expect(state.sessionId, 'session-2');
      expect(state.messages, hasLength(2));
      expect(state.messages.first.role, AssistantMessageRole.user);
      expect(state.messages.last.role, AssistantMessageRole.assistant);
      expect(localStore.lastWrittenConversation?.sessionId, 'session-2');
    },
  );

  test(
    'sendMessage clears session id on assistant session not found',
    () async {
      final localStore = _FakeAssistantLocalStore(
        initialConversation: AssistantConversation(
          sessionId: 'stale-session',
          messages: <AssistantMessage>[
            AssistantMessage(
              role: AssistantMessageRole.user,
              content: 'Saved message',
              createdAt: DateTime.parse('2026-07-14T10:00:00Z'),
            ),
          ],
        ),
      );
      final container = ProviderContainer(
        overrides: [
          assistantLocalStoreProvider.overrideWith((ref) => localStore),
          assistantRepositoryProvider.overrideWith(
            (ref) => _FakeAssistantRepository(
              onChat: (message, _) async {
                throw const Failure.api(
                  code: ApiErrorCode.assistantChatSessionNotFound,
                  message: 'Session not found.',
                );
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(assistantControllerProvider.future);
      final didSend = await container
          .read(assistantControllerProvider.notifier)
          .sendMessage('Continue');

      final state = container.read(assistantControllerProvider).requireValue;
      expect(didSend, isFalse);
      expect(state.sessionId, isNull);
      expect(state.failure, isA<ApiFailure>());
      expect(localStore.lastWrittenConversation?.sessionId, isNull);
    },
  );
}
