import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/categories/application/categories_controller.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/transactions/application/transactions_controller.dart';
import 'package:saveapenny/features/transactions/domain/transaction.dart';
import 'package:saveapenny/features/transactions/presentation/widgets/transaction_form_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class TransferFormSheet extends ConsumerStatefulWidget {
  const TransferFormSheet({super.key});

  @override
  ConsumerState<TransferFormSheet> createState() => _TransferFormSheetState();
}

class _TransferFormSheetState extends ConsumerState<TransferFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  String? _fromAccountId;
  String? _toAccountId;
  String? _categoryId;
  DateTime _transactionDate = DateTime.now();
  bool _isSubmitting = false;
  Failure? _submissionFailure;

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

    final accounts = (readAsyncData(accountsState) ?? const <Account>[])
        .where((Account account) => account.active)
        .toList(growable: false);
    final categories = (readAsyncData(categoriesState) ?? const <Category>[])
        .where(
          (Category category) =>
              category.type == categoryTypeFor(TransactionType.transfer),
        )
        .toList(growable: false);
    final selectedFromAccount = selectedAccountById(accounts, _fromAccountId);
    final selectedToAccount = selectedAccountById(accounts, _toAccountId);
    final dateLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(_transactionDate);

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
                l10n.transactionsTransferTitle,
                style: context.textTheme.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.transactionsTransferSubtitle,
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              if (_submissionFailure != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                TransactionsSheetFailureNotice(failure: _submissionFailure!),
              ],
              const SizedBox(height: AppSpacing.xxl),
              DropdownButtonFormField<String>(
                initialValue: _fromAccountId,
                decoration: InputDecoration(
                  labelText: l10n.transactionsFromLabel,
                ),
                items: accounts
                    .map(
                      (Account account) => DropdownMenuItem<String>(
                        value: account.id,
                        child: Text(account.name),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _fromAccountId = value;
                          if (_toAccountId == value) {
                            _toAccountId = null;
                          }
                          _submissionFailure = null;
                        });
                      },
                validator: (value) => validateRequiredSelection(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<String>(
                key: ValueKey<String?>(_fromAccountId),
                initialValue: _toAccountId,
                decoration: InputDecoration(
                  labelText: l10n.transactionsToLabel,
                ),
                items: accounts
                    .where((Account account) => account.id != _fromAccountId)
                    .map(
                      (Account account) => DropdownMenuItem<String>(
                        value: account.id,
                        child: Text(account.name),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _toAccountId = value;
                          _submissionFailure = null;
                        });
                      },
                validator: (value) => validateRequiredSelection(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: InputDecoration(
                  labelText: l10n.transactionsCategoryLabel,
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
                value: withFallback(
                  resolveTransferCurrency(
                    fromAccount: selectedFromAccount,
                    toAccount: selectedToAccount,
                  ),
                  l10n.commonNotAvailable,
                ),
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
                onFieldSubmitted: (_) => _descriptionFocusNode.unfocus(),
                decoration: InputDecoration(
                  labelText: l10n.transactionsDescriptionLabel,
                ),
              ),
              if (_fromAccountId != null &&
                  _fromAccountId == _toAccountId) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.transactionsTransferSameAccountError,
                  style: context.textTheme.label.copyWith(
                    color: context.finance.expense,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _submit(selectedFromAccount),
                child: Text(
                  _isSubmitting
                      ? l10n.commonLoading
                      : l10n.transactionsTransferCreateCta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showTransactionDatePicker(context, _transactionDate);
    if (picked == null) {
      return;
    }

    setState(() {
      _transactionDate = picked;
    });
  }

  Future<void> _submit(Account? selectedFromAccount) async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fromAccountId == _toAccountId) {
      setState(() {});
      return;
    }

    final selectedToAccount = selectedAccountById(
      readAsyncData(ref.read(accountsControllerProvider)) ?? const <Account>[],
      _toAccountId,
    );
    if (selectedFromAccount == null || selectedToAccount == null) {
      return;
    }

    if (selectedFromAccount.currency != selectedToAccount.currency) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionsCurrencyMismatchError)),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionFailure = null;
    });

    try {
      await ref
          .read(transactionsControllerProvider.notifier)
          .createTransfer(
            fromAccountId: selectedFromAccount.id,
            toAccountId: selectedToAccount.id,
            categoryId: _categoryId!,
            amount: num.parse(_amountController.text.trim()),
            currency: selectedFromAccount.currency,
            description: _descriptionController.text,
            transactionDate: _transactionDate,
          );
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
