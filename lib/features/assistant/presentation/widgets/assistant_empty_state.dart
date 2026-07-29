import 'package:flutter/material.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/assistant/presentation/widgets/assistant_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class AssistantEmptyState extends StatelessWidget {
  const AssistantEmptyState({
    super.key,
    required this.prompts,
    required this.onPromptSelected,
    this.failure,
  });

  final Failure? failure;
  final List<String> prompts;
  final Future<void> Function(String prompt) onPromptSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.smart_toy_rounded,
                  size: AppSpacing.giant,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.assistantEmptyTitle,
                  style: context.textTheme.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.assistantEmptyMessage,
                  style: context.textTheme.body.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AssistantInfoCard(
          title: l10n.assistantExamplesTitle,
          message: l10n.assistantExamplesMessage,
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: prompts
              .map(
                (prompt) => ActionChip(
                  label: Text(prompt),
                  onPressed: () async {
                    await onPromptSelected(prompt);
                  },
                ),
              )
              .toList(growable: false),
        ),
        if (failure != null) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          AssistantErrorNotice(failure: failure!),
        ],
      ],
    );
  }
}
