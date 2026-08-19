import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/app_dropdown_field.dart';
import 'package:saveapenny/core/ui/star_rating.dart';
import 'package:saveapenny/features/feedback/application/submit_feedback_controller.dart';
import 'package:saveapenny/features/feedback/domain/feedback.dart';
import 'package:saveapenny/features/feedback/presentation/widgets/feedback_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class FeedbackFormSheet extends ConsumerStatefulWidget {
  const FeedbackFormSheet({super.key, required this.sourceScreen});

  final String sourceScreen;

  @override
  ConsumerState<FeedbackFormSheet> createState() => _FeedbackFormSheetState();
}

class _FeedbackFormSheetState extends ConsumerState<FeedbackFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _messageController;
  FeedbackType _selectedType = FeedbackType.general;
  int? _selectedRating;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final submitState = ref.watch(submitFeedbackControllerProvider);
    final isSubmitting = submitState.isLoading;
    final failure = submitState.hasError ? submitState.error as Failure : null;

    return AppSheetScaffold(
      title: l10n.feedbackFormTitle,
      subtitle: l10n.feedbackFormSubtitle,
      failure: failure == null ? null : FeedbackFailureNotice(failure: failure),
      actionBar: AppSheetActionBar(
        primaryLabel: isSubmitting
            ? l10n.commonLoading
            : l10n.feedbackSubmitCta,
        onPrimaryPressed: isSubmitting ? null : _submit,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppDropdownField<FeedbackType>(
              label: l10n.feedbackTypeLabel,
              value: _selectedType,
              options: FeedbackType.values
                  .map(
                    (type) => AppDropdownOption<FeedbackType>(
                      value: type,
                      label: feedbackTypeLabel(context, type),
                    ),
                  )
                  .toList(growable: false),
              onChanged: isSubmitting
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedType = value;
                      });
                    },
            ),
            const SizedBox(height: AppSpacing.lg),
            InputDecorator(
              decoration: InputDecoration(labelText: l10n.feedbackRatingLabel),
              child: Row(
                children: <Widget>[
                  StarRating(
                    value: _selectedRating ?? 0,
                    onChanged: isSubmitting
                        ? null
                        : (value) => setState(() => _selectedRating = value),
                  ),
                  const Spacer(),
                  if (_selectedRating != null)
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () => setState(() => _selectedRating = null),
                      child: Text(l10n.feedbackNoRating),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _messageController,
              enabled: !isSubmitting,
              minLines: 5,
              maxLines: 8,
              maxLength: 5000,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                labelText: l10n.feedbackMessageLabel,
                hintText: l10n.feedbackMessageHint,
                alignLabelWithHint: true,
              ),
              validator: (value) => validateFeedbackMessage(l10n, value),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(submitFeedbackControllerProvider.notifier)
        .submit(
          type: _selectedType,
          rating: _selectedRating,
          message: _messageController.text.trim(),
          screen: widget.sourceScreen,
        );

    final state = ref.read(submitFeedbackControllerProvider);
    if (!mounted || state.hasError) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).feedbackSubmitSuccess),
        ),
      );
  }
}
