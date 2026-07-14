import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/assistant/application/assistant_controller.dart';
import 'package:saveapenny/features/assistant/domain/assistant_message.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  int _lastRenderedMessageCount = 0;
  bool _lastSendingState = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final assistantState = ref.watch(assistantControllerProvider);

    final current = assistantState.asData?.value;
    final currentMessageCount = current?.messages.length ?? 0;
    final isSending = current?.isSending ?? false;
    if (currentMessageCount != _lastRenderedMessageCount ||
        (isSending && !_lastSendingState)) {
      _lastRenderedMessageCount = currentMessageCount;
      _lastSendingState = isSending;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } else {
      _lastSendingState = isSending;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => GoRouter.of(context).go('/home'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(l10n.assistantTitle),
        actions: <Widget>[
          IconButton(
            onPressed: assistantState.asData?.value.messages.isEmpty ?? true
                ? null
                : _confirmClearConversation,
            tooltip: l10n.assistantNewChatCta,
            icon: const Icon(Icons.auto_awesome_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: assistantState.when(
          data: (data) => Column(
            children: <Widget>[
              Expanded(
                child: data.messages.isEmpty
                    ? _EmptyState(
                        failure: data.failure,
                        prompts: <String>[
                          l10n.assistantExamplePromptSpending,
                          l10n.assistantExamplePromptBudget,
                          l10n.assistantExamplePromptCashFlow,
                        ],
                        onPromptSelected: _sendPrompt,
                      )
                    : _ConversationView(
                        messages: data.messages,
                        disclaimer: data.disclaimer,
                        failure: data.failure,
                        isSending: data.isSending,
                        onResetConversation:
                            _shouldShowResetAction(data.failure)
                            ? _confirmClearConversation
                            : null,
                        scrollController: _scrollController,
                      ),
              ),
              _Composer(
                controller: _messageController,
                focusNode: _messageFocusNode,
                isSending: data.isSending,
                onChanged: () {
                  if (data.failure != null) {
                    ref
                        .read(assistantControllerProvider.notifier)
                        .clearFailure();
                  }
                  setState(() {});
                },
                onSend: () => _send(data.isSending),
              ),
            ],
          ),
          loading: () => const LoadingView(),
          error: (error, _) => _EmptyState(
            failure: error as Failure,
            prompts: <String>[
              l10n.assistantExamplePromptSpending,
              l10n.assistantExamplePromptBudget,
              l10n.assistantExamplePromptCashFlow,
            ],
            onPromptSelected: _sendPrompt,
          ),
        ),
      ),
    );
  }

  bool _shouldShowResetAction(Failure? failure) {
    return failure is ApiFailure &&
        failure.code == ApiErrorCode.assistantChatSessionNotFound;
  }

  Future<void> _sendPrompt(String prompt) async {
    _messageController
      ..text = prompt
      ..selection = TextSelection.collapsed(offset: prompt.length);
    _messageFocusNode.requestFocus();
    await _send(false);
  }

  Future<void> _send(bool isSending) async {
    final message = _messageController.text;
    if (isSending || message.trim().isEmpty) {
      return;
    }

    final didSend = await ref
        .read(assistantControllerProvider.notifier)
        .sendMessage(message);
    if (!didSend || !mounted) {
      return;
    }

    _messageController.clear();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _confirmClearConversation() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.assistantClearTitle),
          content: Text(l10n.assistantClearMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonBack),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.assistantNewChatCta),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    _messageController.clear();
    setState(() {});
    await ref.read(assistantControllerProvider.notifier).clearConversation();
    _messageFocusNode.requestFocus();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    unawaited(
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppDuration.base,
        curve: Curves.easeInOutCubic,
      ),
    );
  }
}

class _ConversationView extends StatelessWidget {
  const _ConversationView({
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
            child: _MessageBubble(message: messages[index]),
          );
        }

        final disclaimerIndex = messages.length;
        if (disclaimer != null && index == disclaimerIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _InfoCard(
              title: l10n.assistantDisclaimerTitle,
              message: disclaimer!,
            ),
          );
        }

        final sendingIndex = disclaimerIndex + (disclaimer == null ? 0 : 1);
        if (isSending && index == sendingIndex) {
          return const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: _TypingBubble(),
          );
        }

        return _ErrorNotice(
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
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
        _InfoCard(
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
          _ErrorNotice(failure: failure!),
        ],
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onChanged;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canSend = !isSending && controller.text.trim().isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: <Widget>[
            TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onChanged: (_) => onChanged(),
              onSubmitted: (_) async {
                await onSend();
              },
              decoration: InputDecoration(hintText: l10n.assistantComposerHint),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canSend
                    ? () async {
                        await onSend();
                      }
                    : null,
                icon: isSending
                    ? const SizedBox(
                        width: AppSpacing.lg,
                        height: AppSpacing.lg,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  isSending ? l10n.assistantSendingCta : l10n.assistantSendCta,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

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

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.failure, this.actionLabel, this.onAction});

  final Failure failure;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.finance.expenseSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.finance.expense),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.error_outline_rounded, color: context.finance.expense),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _message(l10n),
                    style: context.textTheme.body.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (actionLabel != null && onAction != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () async {
                        await onAction!();
                      },
                      child: Text(actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _message(AppLocalizations l10n) {
    return switch (failure) {
      NetworkFailure() => l10n.failureNetworkMessage,
      UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
      RateLimitedFailure() => l10n.failureRateLimitedMessage,
      UnknownFailure() => l10n.failureGenericMessage,
      ApiFailure(code: final code) => switch (code) {
        ApiErrorCode.assistantDisabled => l10n.assistantDisabledError,
        ApiErrorCode.assistantProcessingFailed =>
          l10n.assistantProcessingFailedError,
        ApiErrorCode.assistantChatSessionNotFound =>
          l10n.assistantSessionNotFoundError,
        _ when code.isFeatureDisabled => l10n.failureFeatureDisabledMessage,
        _ => l10n.failureValidationFailedMessage,
      },
    };
  }
}
