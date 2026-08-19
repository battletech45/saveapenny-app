import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/app_dropdown_field.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/categories/application/categories_controller.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/ocr/domain/ocr_models.dart';
import 'package:saveapenny/features/transactions/application/transactions_controller.dart';
import 'package:saveapenny/features/transactions/domain/transaction.dart';
import 'package:saveapenny/features/transactions/presentation/widgets/transaction_form_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class OcrCandidateTransactionSheet extends ConsumerStatefulWidget {
  const OcrCandidateTransactionSheet({
    super.key,
    required this.candidate,
    this.merchantName,
  });

  final OcrTransactionCandidate candidate;
  final String? merchantName;

  @override
  ConsumerState<OcrCandidateTransactionSheet> createState() =>
      _OcrCandidateTransactionSheetState();
}

class _OcrCandidateTransactionSheetState
    extends ConsumerState<OcrCandidateTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  late TransactionType _type;
  String? _accountId;
  String? _categoryId;
  late DateTime _transactionDate;
  bool _isSubmitting = false;
  Failure? _submissionFailure;

  @override
  void initState() {
    super.initState();
    _type = widget.candidate.categoryHint.toUpperCase() == 'INCOME'
        ? TransactionType.income
        : TransactionType.expense;
    _transactionDate = widget.candidate.date;
    _amountController = TextEditingController(
      text: widget.candidate.amount.abs().toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.candidate.description.isEmpty
          ? (widget.merchantName ?? '')
          : widget.candidate.description,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accountsState = ref.watch(accountsControllerProvider);
    final categoriesState = ref.watch(categoriesControllerProvider);
    final accounts = readAsyncData(accountsState) ?? const <Account>[];
    final categories = readAsyncData(categoriesState) ?? const <Category>[];
    final selectedAccount = selectedAccountById(accounts, _accountId);
    final filteredCategories = categories
        .where((category) => category.type == categoryTypeFor(_type))
        .toList(growable: false);
    final dateLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(_transactionDate);

    return AppSheetScaffold(
      title: l10n.ocrCreateTransactionTitle,
      subtitle: l10n.ocrCreateTransactionSubtitle,
      failure: _submissionFailure == null
          ? null
          : TransactionsSheetFailureNotice(failure: _submissionFailure!),
      actionBar: AppSheetActionBar(
        primaryLabel: _isSubmitting
            ? l10n.commonLoading
            : l10n.ocrCreateTransactionCta,
        onPrimaryPressed: _isSubmitting ? null : () => _submit(selectedAccount),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppDropdownField<TransactionType>(
              label: l10n.transactionsTypeLabel,
              value: _type,
              options: <AppDropdownOption<TransactionType>>[
                AppDropdownOption<TransactionType>(
                  value: TransactionType.income,
                  label: l10n.transactionsTypeIncome,
                  icon: Icons.add_circle_outline_rounded,
                ),
                AppDropdownOption<TransactionType>(
                  value: TransactionType.expense,
                  label: l10n.transactionsTypeExpense,
                  icon: Icons.remove_circle_outline_rounded,
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
            AppDropdownField<String>(
              label: l10n.transactionsAccountLabel,
              value: _accountId,
              hint: l10n.commonNotAvailable,
              options: accounts
                  .where((account) => account.active)
                  .map(
                    (account) => AppDropdownOption<String>(
                      value: account.id,
                      label: account.name,
                      subtitle: account.currency,
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
              validator: (value) => validateRequiredSelection(l10n, value),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppDropdownField<String>(
              key: ValueKey<TransactionType>(_type),
              value:
                  filteredCategories.any(
                    (category) => category.id == _categoryId,
                  )
                  ? _categoryId
                  : null,
              label: l10n.transactionsCategoryLabel,
              hint: categoriesState.isLoading
                  ? l10n.commonLoading
                  : l10n.commonNotAvailable,
              options: filteredCategories
                  .map(
                    (category) => AppDropdownOption<String>(
                      value: category.id,
                      label: category.name,
                    ),
                  )
                  .toList(growable: false),
              onChanged: _isSubmitting || filteredCategories.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        _categoryId = value;
                        _submissionFailure = null;
                      });
                    },
              validator: (value) => validateRequiredSelection(l10n, value),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _amountController,
              focusNode: _amountFocusNode,
              enabled: !_isSubmitting,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              onTapOutside: (_) => _amountFocusNode.unfocus(),
              onFieldSubmitted: (_) => _descriptionFocusNode.requestFocus(),
              decoration: InputDecoration(
                labelText: l10n.transactionsAmountLabel,
              ),
              validator: (value) => validateAmount(l10n, value),
            ),
            const SizedBox(height: AppSpacing.lg),
            TransactionsReadOnlyField(
              label: l10n.transactionsCurrencyLabel,
              value: selectedAccount?.currency ?? l10n.commonNotAvailable,
            ),
            const SizedBox(height: AppSpacing.lg),
            TransactionsReadOnlyActionField(
              label: l10n.transactionsDateLabel,
              value: dateLabel,
              actionLabel: l10n.commonContinue,
              onPressed: _isSubmitting ? null : _pickDate,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              enabled: !_isSubmitting,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              onTapOutside: (_) => _descriptionFocusNode.unfocus(),
              decoration: InputDecoration(
                labelText: l10n.transactionsDescriptionLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showTransactionDatePicker(context, _transactionDate);
    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _transactionDate = picked;
      _submissionFailure = null;
    });
  }

  Future<void> _submit(Account? selectedAccount) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (selectedAccount == null || _accountId == null || _categoryId == null) {
      setState(() {
        _submissionFailure = const Failure.unknown();
      });
      return;
    }

    final amount = num.tryParse(_amountController.text.trim());
    if (amount == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionFailure = null;
    });

    try {
      await ref
          .read(transactionsControllerProvider.notifier)
          .create(
            accountId: _accountId!,
            categoryId: _categoryId!,
            type: _type,
            amount: amount,
            currency: selectedAccount.currency,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            transactionDate: _transactionDate,
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } on Failure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _submissionFailure = failure;
      });
    }
  }
}
