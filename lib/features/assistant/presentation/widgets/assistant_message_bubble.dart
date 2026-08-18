import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/initials_avatar.dart';
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

    final bubble = Column(
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

    return Row(
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (!isUser) ...<Widget>[
          const InitialsAvatar(name: 'SaveAPenny', size: 32),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(child: bubble),
        if (isUser) ...<Widget>[
          const SizedBox(width: AppSpacing.sm),
          const InitialsAvatar(name: 'User', size: 32),
        ],
      ],
    );
  }
}

class AssistantTypingBubble extends StatefulWidget {
  const AssistantTypingBubble({super.key});

  @override
  State<AssistantTypingBubble> createState() => _AssistantTypingBubbleState();
}

class _AssistantTypingBubbleState extends State<AssistantTypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDuration.slow)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const InitialsAvatar(name: 'SaveAPenny', size: 32),
        const SizedBox(width: AppSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.colors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (var i = 0; i < 3; i++) ...<Widget>[
                        _TypingDot(
                          active: ((_controller.value * 3).floor() % 3) == i,
                        ),
                        if (i != 2) const SizedBox(width: AppSpacing.xs),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypingDot extends StatelessWidget {
  const _TypingDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDuration.fast,
      width: active ? AppSpacing.sm : AppSpacing.xs,
      height: active ? AppSpacing.sm : AppSpacing.xs,
      decoration: BoxDecoration(
        color: active
            ? Theme.of(context).colorScheme.primary
            : context.colors.textTertiary,
        shape: BoxShape.circle,
      ),
    );
  }
}
