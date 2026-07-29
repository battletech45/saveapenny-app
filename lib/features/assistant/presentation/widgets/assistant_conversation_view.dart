import 'package:flutter/material.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/assistant/domain/assistant_message.dart';
import 'package:saveapenny/features/assistant/presentation/widgets/assistant_message_bubble.dart';
import 'package:saveapenny/features/assistant/presentation/widgets/assistant_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class AssistantConversationView extends StatelessWidget {
  const AssistantConversationView({
    super.key,
    required this.messages,
    required this.disclaimer,
    required this.failure,
    required this.isSending,
    required this.onResetConversation,
    required this.scrollController,
  });

  final List<AssistantMessage> messages;
  final String? disclaimer;
  final Failure? failure;
  final bool isSending;
  final Future<void> Function()? onResetConversation;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount:
          messages.length +
          (disclaimer == null ? 0 : 1) +
          (isSending ? 1 : 0) +
          (failure == null ? 0 : 1),
      itemBuilder: (context, index) {
        if (index < messages.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AssistantMessageBubble(message: messages[index]),
          );
        }

        final disclaimerIndex = messages.length;
        if (disclaimer != null && index == disclaimerIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AssistantInfoCard(
              title: l10n.assistantDisclaimerTitle,
              message: disclaimer!,
            ),
          );
        }

        final sendingIndex = disclaimerIndex + (disclaimer == null ? 0 : 1);
        if (isSending && index == sendingIndex) {
          return const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: AssistantTypingBubble(),
          );
        }

        return AssistantErrorNotice(
          failure: failure!,
          actionLabel: onResetConversation == null
              ? null
              : l10n.assistantNewChatCta,
          onAction: onResetConversation,
        );
      },
    );
  }
}
