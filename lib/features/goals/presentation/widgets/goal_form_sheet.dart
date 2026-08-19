import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_date_picker.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/goals/application/goal_detail_controller.dart';
import 'package:saveapenny/features/goals/application/goals_controller.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/features/goals/presentation/widgets/goal_form_shared.dart';
import 'package:saveapenny/features/goals/presentation/widgets/goal_inputs_form.dart';
import 'package:saveapenny/features/goals/presentation/widgets/goal_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class GoalFormSheet extends ConsumerStatefulWidget {
  const GoalFormSheet({super.key, this.existing, this.goalId});

  final Goal? existing;
  final String? goalId;

  @override
  ConsumerState<GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<GoalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _targetAmountController;
  late final TextEditingController _currencyController;
  late final GoalInputsFormData _inputsData;

  late GoalType _type;
  String? _linkedAccountId;
  late DateTime _targetDate;
  bool _isSubmitting = false;
  Failure? _submissionFailure;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existing?.title ?? '',
    );
    _targetAmountController = TextEditingController(
      text: widget.existing?.targetAmount.toString() ?? '',
    );
    _currencyController = TextEditingController(
      text: widget.existing?.currency ?? 'TRY',
    );
    _type = widget.existing?.type ?? GoalType.savings;
    _inputsData = GoalInputsFormData(
      widget.existing?.inputs ?? defaultGoalInputs(_type),
    );
    _linkedAccountId = widget.existing?.linkedAccountId;
    _targetDate =
        widget.existing?.targetDate ??
        DateTime.now().add(const Duration(days: 365));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _currencyController.dispose();
    _inputsData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accountsState = ref.watch(accountsControllerProvider);
    final seenAccountIds = <String>{};
    final accounts = <Account>[
      for (final account in readAsyncData(accountsState) ?? const <Account>[])
        if (account.active && seenAccountIds.add(account.id)) account,
    ];
    final hasLinkedAccountInItems =
        _linkedAccountId == null ||
        accounts.any((account) => account.id == _linkedAccountId);
    final dateLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(_targetDate);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _isEditing ? l10n.goalsEditTitle : l10n.goalsCreateTitle,
                style: context.textTheme.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isEditing ? l10n.goalsEditSubtitle : l10n.goalsCreateSubtitle,
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              if (_submissionFailure != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                GoalSheetFailureNotice(failure: _submissionFailure!),
              ],
              const SizedBox(height: AppSpacing.xxl),
              DropdownButtonFormField<GoalType>(
                initialValue: _type,
                decoration: InputDecoration(labelText: l10n.goalsTypeLabel),
                items: GoalType.values
                    .map(
                      (type) => DropdownMenuItem<GoalType>(
                        value: type,
                        child: Text(goalTypeLabel(l10n, type)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isSubmitting || _isEditing
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _type = value;
                          _inputsData.applyDefaultsFor(value);
                          _submissionFailure = null;
                        });
                      },
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _titleController,
                enabled: !_isSubmitting,
                decoration: InputDecoration(labelText: l10n.goalsTitleLabel),
                validator: (value) => _validateTitle(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _targetAmountController,
                enabled: !_isSubmitting,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.goalsTargetAmountLabel,
                ),
                validator: (value) => _validateTargetAmount(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _currencyController,
                enabled: !_isSubmitting,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: l10n.goalsCurrencyLabel),
                validator: (value) => _validateCurrency(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              GoalReadOnlyActionField(
                label: l10n.goalsTargetDateLabel,
                value: dateLabel,
                actionLabel: l10n.commonContinue,
                onPressed: _isSubmitting ? null : _pickTargetDate,
              ),
              if (!_targetDate.isAfter(goalToday())) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.goalsInvalidDateError,
                  style: context.textTheme.label.copyWith(
                    color: context.finance.expense,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<String?>(
                initialValue: _linkedAccountId,
                decoration: InputDecoration(
                  labelText: l10n.goalsLinkedAccountLabel,
                ),
                items: <DropdownMenuItem<String?>>[
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.goalsNoLinkedAccount),
                  ),
                  if (!hasLinkedAccountInItems && _linkedAccountId != null)
                    DropdownMenuItem<String?>(
                      value: _linkedAccountId,
                      child: Text(_linkedAccountId!),
                    ),
                  ...accounts.map(
                    (account) => DropdownMenuItem<String?>(
                      value: account.id,
                      child: Text(account.name),
                    ),
                  ),
                ],
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        setState(() {
                          _linkedAccountId = value;
                          _submissionFailure = null;
                        });
                      },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.goalsInputsLabel,
                style: context.textTheme.label.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GoalInputsFields(
                type: _type,
                data: _inputsData,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(
                  _isSubmitting
                      ? l10n.commonLoading
                      : _isEditing
                      ? l10n.goalsSaveCta
                      : l10n.goalsCreateCta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateTitle(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty || value.trim().length > 120) {
      return l10n.goalsTitleError;
    }

    return null;
  }

  String? _validateTargetAmount(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.authRequiredFieldError;
    }

    final amount = num.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return l10n.goalsTargetAmountError;
    }

    return null;
  }

  String? _validateCurrency(AppLocalizations l10n, String? value) {
    if (value == null ||
        value.trim().isEmpty ||
        value.trim().toUpperCase().length != 3) {
      return l10n.goalsCurrencyError;
    }

    return null;
  }

  Future<void> _pickTargetDate() async {
    final today = goalToday();
    final firstSelectableDate = today.add(const Duration(days: 1));
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _targetDate.isAfter(today)
          ? _targetDate
          : firstSelectableDate,
      firstDate: firstSelectableDate,
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _targetDate = picked;
      _submissionFailure = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_targetDate.isAfter(goalToday())) {
      setState(() {});
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionFailure = null;
    });

    try {
      final inputs = _inputsData.toInputs(_type);

      if (_isEditing) {
        await ref
            .read(goalDetailControllerProvider(widget.goalId!).notifier)
            .updateGoal(
              title: _titleController.text.trim(),
              targetAmount: num.parse(_targetAmountController.text.trim()),
              currency: _currencyController.text.trim().toUpperCase(),
              targetDate: _targetDate,
              linkedAccountId: _linkedAccountId,
              inputs: inputs,
            );
      } else {
        await ref
            .read(goalsControllerProvider.notifier)
            .create(
              type: _type,
              title: _titleController.text.trim(),
              targetAmount: num.parse(_targetAmountController.text.trim()),
              currency: _currencyController.text.trim().toUpperCase(),
              targetDate: _targetDate,
              linkedAccountId: _linkedAccountId,
              inputs: inputs,
            );
      }
    } on Failure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _submissionFailure = failure;
      });
      return;
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _submissionFailure = Failure.unknown(message: error.toString());
      });
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }
}
