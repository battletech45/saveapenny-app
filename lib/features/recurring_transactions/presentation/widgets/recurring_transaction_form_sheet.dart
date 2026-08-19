import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_date_picker.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/billing/presentation/widgets/plan_limit_banner.dart';
import 'package:saveapenny/features/categories/application/categories_controller.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/recurring_transactions/application/recurring_transactions_controller.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction.dart';
import 'package:saveapenny/features/recurring_transactions/presentation/widgets/recurring_transaction_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class RecurringTransactionFormSheet extends ConsumerStatefulWidget {
  const RecurringTransactionFormSheet({
    super.key,
    this.existing,
    required this.advancedRecurringUnlocked,
  });

  final RecurringTransaction? existing;
  final bool advancedRecurringUnlocked;

  @override
  ConsumerState<RecurringTransactionFormSheet> createState() =>
      _RecurringTransactionFormSheetState();
}

class _RecurringTransactionFormSheetState
    extends ConsumerState<RecurringTransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late RecurringTransactionType _type;
  late RecurringFrequency _frequency;
  String? _accountId;
  String? _categoryId;
  DateTime _nextRunDate = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  RecurringClassification? _classification;
  bool _isSubmitting = false;
  Failure? _submissionFailure;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.existing?.amount.toString() ?? '',
    );
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.existing?.description ?? '',
    );
    _type = widget.existing?.type ?? RecurringTransactionType.expense;
    _frequency = widget.existing?.frequency ?? RecurringFrequency.monthly;
    _accountId = widget.existing?.accountId;
    _categoryId = widget.existing?.categoryId;
    _nextRunDate = widget.existing?.nextRunDate ?? DateTime.now();
    _startDate = widget.existing?.startDate;
    _endDate = widget.existing?.endDate;
    _classification = widget.existing?.classification;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accountsState = ref.watch(accountsControllerProvider);
    final categoriesState = ref.watch(categoriesControllerProvider);
    final accounts =
        (readRecurringAsyncData(accountsState) ?? const <Account>[])
            .where((account) => account.active)
            .toList(growable: false);
    final categories =
        (readRecurringAsyncData(categoriesState) ?? const <Category>[])
            .where(
              (category) => category.type == recurringCategoryTypeFor(_type),
            )
            .toList(growable: false);

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
                _isEditing
                    ? l10n.recurringTransactionsEditTitle
                    : l10n.recurringTransactionsCreateTitle,
                style: context.textTheme.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isEditing
                    ? l10n.recurringTransactionsEditSubtitle
                    : l10n.recurringTransactionsCreateSubtitle,
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              if (_submissionFailure != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                RecurringFailureNotice(failure: _submissionFailure!),
              ],
              const SizedBox(height: AppSpacing.xxl),
              DropdownButtonFormField<RecurringTransactionType>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: l10n.recurringTransactionsTypeLabel,
                ),
                items: <DropdownMenuItem<RecurringTransactionType>>[
                  DropdownMenuItem(
                    value: RecurringTransactionType.income,
                    child: Text(l10n.recurringTransactionsTypeIncome),
                  ),
                  DropdownMenuItem(
                    value: RecurringTransactionType.expense,
                    child: Text(l10n.recurringTransactionsTypeExpense),
                  ),
                ],
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _type = value;
                          _categoryId = null;
                          _submissionFailure = null;
                        });
                      },
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<String>(
                initialValue: _accountId,
                decoration: InputDecoration(
                  labelText: l10n.recurringTransactionsAccountLabel,
                ),
                items: accounts
                    .map(
                      (account) => DropdownMenuItem<String>(
                        value: account.id,
                        child: Text(account.name),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        setState(() {
                          _accountId = value;
                          _submissionFailure = null;
                        });
                      },
                validator: (value) => _validateRequired(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<String>(
                key: ValueKey<RecurringTransactionType>(_type),
                initialValue:
                    categories.any((category) => category.id == _categoryId)
                    ? _categoryId
                    : null,
                decoration: InputDecoration(
                  labelText: l10n.recurringTransactionsCategoryLabel,
                ),
                hint: categories.isEmpty
                    ? Text(
                        categoriesState.isLoading
                            ? l10n.commonLoading
                            : l10n.commonNotAvailable,
                      )
                    : null,
                items: categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isSubmitting
                    ? null
                    : categories.isEmpty
                    ? null
                    : (value) {
                        setState(() {
                          _categoryId = value;
                          _submissionFailure = null;
                        });
                      },
                validator: (value) => _validateRequired(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _amountController,
                enabled: !_isSubmitting,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.recurringTransactionsAmountLabel,
                ),
                validator: (value) => _validateAmount(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<RecurringFrequency>(
                initialValue: _frequency,
                decoration: InputDecoration(
                  labelText: l10n.recurringTransactionsFrequencyLabel,
                ),
                items: <DropdownMenuItem<RecurringFrequency>>[
                  DropdownMenuItem(
                    value: RecurringFrequency.daily,
                    child: Text(l10n.recurringTransactionsFrequencyDaily),
                  ),
                  DropdownMenuItem(
                    value: RecurringFrequency.weekly,
                    child: Text(l10n.recurringTransactionsFrequencyWeekly),
                  ),
                  DropdownMenuItem(
                    value: RecurringFrequency.monthly,
                    child: Text(l10n.recurringTransactionsFrequencyMonthly),
                  ),
                  DropdownMenuItem(
                    value: RecurringFrequency.yearly,
                    child: Text(l10n.recurringTransactionsFrequencyYearly),
                  ),
                ],
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _frequency = value;
                          _submissionFailure = null;
                        });
                      },
              ),
              const SizedBox(height: AppSpacing.lg),
              RecurringRequiredDateField(
                label: l10n.recurringTransactionsNextRunDateLabel,
                value: _formatDate(context, _nextRunDate),
                actionLabel: l10n.commonContinue,
                onPressed: _isSubmitting ? null : _pickNextRunDate,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _nameController,
                enabled: !_isSubmitting,
                maxLength: 150,
                decoration: InputDecoration(
                  labelText: l10n.recurringTransactionsNameLabel,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _descriptionController,
                enabled: !_isSubmitting,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.recurringTransactionsDescriptionLabel,
                ),
              ),
              if (widget.advancedRecurringUnlocked) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                RecurringOptionalDateField(
                  label: l10n.recurringTransactionsStartDateLabel,
                  value: _startDate == null
                      ? l10n.recurringTransactionsNoDateValue
                      : _formatDate(context, _startDate!),
                  actionLabel: l10n.commonContinue,
                  onPressed: _isSubmitting ? null : _pickStartDate,
                  onClear: _isSubmitting || _startDate == null
                      ? null
                      : () => setState(() => _startDate = null),
                ),
                const SizedBox(height: AppSpacing.lg),
                RecurringOptionalDateField(
                  label: l10n.recurringTransactionsEndDateLabel,
                  value: _endDate == null
                      ? l10n.recurringTransactionsNoDateValue
                      : _formatDate(context, _endDate!),
                  actionLabel: l10n.commonContinue,
                  onPressed: _isSubmitting ? null : _pickEndDate,
                  onClear: _isSubmitting || _endDate == null
                      ? null
                      : () => setState(() => _endDate = null),
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<RecurringClassification?>(
                  initialValue: _classification,
                  decoration: InputDecoration(
                    labelText: l10n.recurringTransactionsClassificationLabel,
                  ),
                  items: <DropdownMenuItem<RecurringClassification?>>[
                    DropdownMenuItem<RecurringClassification?>(
                      value: null,
                      child: Text(l10n.recurringTransactionsClassificationNone),
                    ),
                    ...RecurringClassification.values.map(
                      (value) => DropdownMenuItem<RecurringClassification?>(
                        value: value,
                        child: Text(recurringClassificationLabel(l10n, value)),
                      ),
                    ),
                  ],
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          setState(() {
                            _classification = value;
                            _submissionFailure = null;
                          });
                        },
                ),
              ] else ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                PlanLockedFeatureBanner(
                  isUnlocked: false,
                  message: l10n.recurringTransactionsAdvancedLockedMessage,
                ),
              ],
              if (_endDate != null &&
                  _startDate != null &&
                  _startDate!.isAfter(_endDate!)) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.recurringTransactionsDateRangeError,
                  style: context.textTheme.label.copyWith(
                    color: context.finance.expense,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(
                  _isSubmitting
                      ? l10n.commonLoading
                      : _isEditing
                      ? l10n.recurringTransactionsSaveCta
                      : l10n.recurringTransactionsCreateCta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime value) {
    return DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(value);
  }

  String? _validateRequired(AppLocalizations l10n, String? value) {
    if (value == null || value.isEmpty) {
      return l10n.authRequiredFieldError;
    }
    return null;
  }

  String? _validateAmount(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.authRequiredFieldError;
    }
    final amount = num.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return l10n.recurringTransactionsAmountError;
    }
    return null;
  }

  Future<void> _pickNextRunDate() async {
    final picked = await _pickDate(initialDate: _nextRunDate);
    if (picked == null) {
      return;
    }
    setState(() => _nextRunDate = picked);
  }

  Future<void> _pickStartDate() async {
    final picked = await _pickDate(initialDate: _startDate ?? _nextRunDate);
    if (picked == null) {
      return;
    }
    setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await _pickDate(initialDate: _endDate ?? _nextRunDate);
    if (picked == null) {
      return;
    }
    setState(() => _endDate = picked);
  }

  Future<DateTime?> _pickDate({required DateTime initialDate}) {
    return showAppDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final nextRunOnly = DateTime(
      _nextRunDate.year,
      _nextRunDate.month,
      _nextRunDate.day,
    );
    if (_categoryId == null ||
        _accountId == null ||
        nextRunOnly.isBefore(todayOnly) ||
        (_startDate != null &&
            _endDate != null &&
            _startDate!.isAfter(_endDate!))) {
      setState(() {
        _submissionFailure = nextRunOnly.isBefore(todayOnly)
            ? const Failure.api(
                code: ApiErrorCode.invalidRecurringTransactionNextRunDate,
                message: 'Invalid next run date.',
              )
            : null;
      });
      return;
    }

    final controller = ref.read(
      recurringTransactionsControllerProvider.notifier,
    );
    setState(() {
      _isSubmitting = true;
      _submissionFailure = null;
    });

    try {
      if (_isEditing) {
        await controller.updateRecurringTransaction(
          recurringTransactionId: widget.existing!.id,
          accountId: _accountId!,
          categoryId: _categoryId!,
          type: _type,
          amount: num.parse(_amountController.text.trim()),
          frequency: _frequency,
          nextRunDate: _nextRunDate,
          status: widget.existing!.status,
          name: _nameController.text,
          description: _descriptionController.text,
          startDate: _startDate,
          endDate: _endDate,
          classification: _classification,
        );
      } else {
        await controller.create(
          accountId: _accountId!,
          categoryId: _categoryId!,
          type: _type,
          amount: num.parse(_amountController.text.trim()),
          frequency: _frequency,
          nextRunDate: _nextRunDate,
          name: _nameController.text,
          description: _descriptionController.text,
          startDate: _startDate,
          endDate: _endDate,
          classification: _classification,
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
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }
}
