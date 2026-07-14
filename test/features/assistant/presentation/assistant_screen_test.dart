import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/storage/secure_token_store.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/features/assistant/application/assistant_controller.dart';
import 'package:saveapenny/features/assistant/data/assistant_local_store.dart';
import 'package:saveapenny/features/assistant/data/assistant_repository.dart';
import 'package:saveapenny/features/assistant/domain/assistant_conversation.dart';
import 'package:saveapenny/features/assistant/domain/assistant_message.dart';
import 'package:saveapenny/features/assistant/domain/assistant_reply.dart';
import 'package:saveapenny/features/assistant/domain/assistant_repository.dart';
import 'package:saveapenny/features/assistant/presentation/assistant_screen.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

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
  _FakeAssistantLocalStore({this.conversation = const AssistantConversation()})
    : super(tokenStore: SecureTokenStore());

  final AssistantConversation conversation;

  @override
  Future<AssistantConversation> readConversation() async {
    return conversation;
  }

  @override
  Future<void> writeConversation(AssistantConversation conversation) async {}

  @override
  Future<void> clearConversation() async {}
}

Future<void> _pumpWidget(
  WidgetTester tester, {
  required ProviderContainer container,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AssistantScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('assistant screen shows the empty state', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        assistantLocalStoreProvider.overrideWith(
          (ref) => _FakeAssistantLocalStore(),
        ),
        assistantRepositoryProvider.overrideWith(
          (ref) => _FakeAssistantRepository(
            onChat: (message, _) async => throw UnimplementedError(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpWidget(tester, container: container);

    expect(find.text('Start a money conversation'), findsOneWidget);
    expect(find.text('Send message'), findsOneWidget);
    expect(
      find.text('Where am I spending the most this month?'),
      findsOneWidget,
    );
  });

  testWidgets('assistant screen shows assistant-specific session errors', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        assistantLocalStoreProvider.overrideWith(
          (ref) => _FakeAssistantLocalStore(
            conversation: AssistantConversation(
              sessionId: 'session-1',
              messages: <AssistantMessage>[
                AssistantMessage(
                  role: AssistantMessageRole.user,
                  content: 'Saved message',
                  createdAt: DateTime.parse('2026-07-14T10:00:00Z'),
                ),
              ],
            ),
          ),
        ),
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

    await _pumpWidget(tester, container: container);
    await container.read(assistantControllerProvider.future);
    await container
        .read(assistantControllerProvider.notifier)
        .sendMessage('Continue the previous chat');
    await tester.pumpAndSettle();

    expect(
      find.textContaining(
        'This saved chat can no longer be resumed on the server.',
      ),
      findsOneWidget,
    );
    expect(find.text('Start new chat'), findsOneWidget);
  });
}
