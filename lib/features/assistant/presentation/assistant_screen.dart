import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/assistant/application/assistant_controller.dart';
import 'package:saveapenny/features/assistant/presentation/widgets/assistant_composer.dart';
import 'package:saveapenny/features/assistant/presentation/widgets/assistant_conversation_view.dart';
import 'package:saveapenny/features/assistant/presentation/widgets/assistant_empty_state.dart';
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
                    ? AssistantEmptyState(
                        failure: data.failure,
                        prompts: <String>[
                          l10n.assistantExamplePromptSpending,
                          l10n.assistantExamplePromptBudget,
                          l10n.assistantExamplePromptCashFlow,
                        ],
                        onPromptSelected: _sendPrompt,
                      )
                    : AssistantConversationView(
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
              AssistantComposer(
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
          error: (error, _) => AssistantEmptyState(
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
