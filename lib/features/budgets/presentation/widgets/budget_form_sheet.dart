import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/budgets/application/budgets_controller.dart';
import 'package:saveapenny/features/budgets/domain/budget.dart';
import 'package:saveapenny/features/budgets/presentation/widgets/budget_form_shared.dart';
import 'package:saveapenny/features/budgets/presentation/widgets/budget_shared.dart';
import 'package:saveapenny/features/categories/application/categories_controller.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class BudgetFormSheet extends ConsumerStatefulWidget {
  const BudgetFormSheet({super.key, this.existing});

  final Budget? existing;

  @override
  ConsumerState<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  BudgetPeriod _period = BudgetPeriod.monthly;
  String? _categoryId;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isSubmitting = false;
  Failure? _submissionFailure;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final initialRange = _rangeForPeriod(BudgetPeriod.monthly, DateTime.now());
    _amountController = TextEditingController(
      text: widget.existing?.amount.toString() ?? '',
    );
    _period = widget.existing?.period ?? BudgetPeriod.monthly;
    _categoryId = widget.existing?.categoryId;
    _startDate = widget.existing?.startDate ?? initialRange.start;
    _endDate = widget.existing?.endDate ?? initialRange.end;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoriesState = ref.watch(categoriesControllerProvider);
    final categories = (_readAsyncData(categoriesState) ?? const <Category>[])
        .where((category) => category.type == CategoryType.expense)
        .toList(growable: false);
    final startLabel = _formatDate(context, _startDate);
    final endLabel = _formatDate(context, _endDate);

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
                _isEditing ? l10n.budgetsEditTitle : l10n.budgetsCreateTitle,
                style: context.textTheme.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isEditing
                    ? l10n.budgetsEditSubtitle
                    : l10n.budgetsCreateSubtitle,
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              if (_submissionFailure != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                BudgetSheetFailureNotice(failure: _submissionFailure!),
              ],
              const SizedBox(height: AppSpacing.xxl),
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: InputDecoration(
                  labelText: l10n.budgetsCategoryLabel,
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
                      (Category category) => DropdownMenuItem<String>(
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
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _categoryId = value;
                          _submissionFailure = null;
                        });
                      },
                validator: (value) => _validateRequiredSelection(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _amountController,
                enabled: !_isSubmitting,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l10n.budgetsAmountLabel),
                validator: (value) => _validateAmount(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<BudgetPeriod>(
                initialValue: _period,
                decoration: InputDecoration(labelText: l10n.budgetsPeriodLabel),
                items: <DropdownMenuItem<BudgetPeriod>>[
                  DropdownMenuItem<BudgetPeriod>(
                    value: BudgetPeriod.monthly,
                    child: Text(l10n.budgetsPeriodMonthly),
                  ),
                  DropdownMenuItem<BudgetPeriod>(
                    value: BudgetPeriod.yearly,
                    child: Text(l10n.budgetsPeriodYearly),
                  ),
                ],
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }
                        final nextRange = _rangeForPeriod(
                          value,
                          DateTime.now(),
                        );
                        setState(() {
                          _period = value;
                          if (!_isEditing) {
                            _startDate = nextRange.start;
                            _endDate = nextRange.end;
                          }
                          _submissionFailure = null;
                        });
                      },
              ),
              const SizedBox(height: AppSpacing.lg),
              BudgetReadOnlyActionField(
                label: l10n.budgetsStartDateLabel,
                value: startLabel,
                actionLabel: l10n.commonContinue,
                onPressed: _isSubmitting ? null : _pickStartDate,
              ),
              const SizedBox(height: AppSpacing.lg),
              BudgetReadOnlyActionField(
                label: l10n.budgetsEndDateLabel,
                value: endLabel,
                actionLabel: l10n.commonContinue,
                onPressed: _isSubmitting ? null : _pickEndDate,
              ),
              if (_startDate.isAfter(_endDate)) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.budgetsDateRangeError,
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
                      ? l10n.budgetsSaveCta
                      : l10n.budgetsCreateCta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime value) {
    return formatBudgetDate(context, value);
  }

  String? _validateRequiredSelection(AppLocalizations l10n, String? value) {
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
      return l10n.budgetsAmountError;
    }

    return null;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _startDate = picked;
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _endDate = picked;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_startDate.isAfter(_endDate) || _categoryId == null) {
      setState(() {});
      return;
    }

    final controller = ref.read(budgetsControllerProvider.notifier);
    setState(() {
      _isSubmitting = true;
      _submissionFailure = null;
    });

    try {
      if (_isEditing) {
        await controller.updateBudget(
          budgetId: widget.existing!.id,
          categoryId: _categoryId!,
          amount: num.parse(_amountController.text.trim()),
          period: _period,
          startDate: _startDate,
          endDate: _endDate,
        );
      } else {
        await controller.create(
          categoryId: _categoryId!,
          amount: num.parse(_amountController.text.trim()),
          period: _period,
          startDate: _startDate,
          endDate: _endDate,
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

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.of(context).pop();
  }
}

({DateTime start, DateTime end}) _rangeForPeriod(
  BudgetPeriod period,
  DateTime anchor,
) {
  return switch (period) {
    BudgetPeriod.monthly => (
      start: DateTime(anchor.year, anchor.month, 1),
      end: DateTime(anchor.year, anchor.month + 1, 0),
    ),
    BudgetPeriod.yearly => (
      start: DateTime(anchor.year, 1, 1),
      end: DateTime(anchor.year, 12, 31),
    ),
  };
}

T? _readAsyncData<T>(AsyncValue<T> value) {
  return value is AsyncData<T> ? value.value : null;
}
