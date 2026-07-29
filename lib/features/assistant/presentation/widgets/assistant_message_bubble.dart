import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/assistant/domain/assistant_message.dart';

class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({super.key, required this.message});

  final AssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AssistantMessageRole.user;
    final scheme = Theme.of(context).colorScheme;
    final bubbleColor = isUser
        ? scheme.primaryContainer
        : context.colors.surfaceSubtle;
    final textColor = isUser
        ? scheme.onPrimaryContainer
        : context.colors.textPrimary;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final time = DateFormat.Hm(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(message.createdAt.toLocal());

    return Column(
      crossAxisAlignment: align,
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.colors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                message.content,
                style: context.textTheme.body.copyWith(color: textColor),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          time,
          style: context.textTheme.label.copyWith(
            color: context.colors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class AssistantTypingBubble extends StatelessWidget {
  const AssistantTypingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.colors.border),
            ),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: AppSpacing.xxl,
                height: AppSpacing.xxl,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
