import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/credit_cards/application/credit_cards_controller.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_card_payment.dart';
import 'package:saveapenny/features/credit_cards/presentation/widgets/credit_card_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class CreditCardPaymentSheet extends ConsumerStatefulWidget {
  const CreditCardPaymentSheet({super.key, required this.creditAccount});

  final Account creditAccount;

  @override
  ConsumerState<CreditCardPaymentSheet> createState() =>
      _CreditCardPaymentSheetState();
}

class _CreditCardPaymentSheetState
    extends ConsumerState<CreditCardPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  String? _sourceAccountId;
  CreditCardPaymentType _paymentType = CreditCardPaymentType.minimumDue;
  bool _isSubmitting = false;
  Failure? _failure;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  List<Account> _eligibleSourceAccounts(List<Account> accounts) {
    return accounts
        .where(
          (account) =>
              account.id != widget.creditAccount.id &&
              account.type != AccountType.credit &&
              account.active &&
              account.currency == widget.creditAccount.currency,
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accountsState = ref.watch(accountsControllerProvider);
    final sourceAccounts = _eligibleSourceAccounts(
      accountsState.asData?.value ?? const <Account>[],
    );

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
                l10n.creditCardPaymentSheetTitle,
                style: context.textTheme.title,
              ),
              if (_failure != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.finance.expenseSurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: context.finance.expense),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      creditCardFailureMessage(context, _failure!),
                      style: context.textTheme.body.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              DropdownButtonFormField<String>(
                initialValue: _sourceAccountId,
                decoration: InputDecoration(
                  labelText: l10n.creditCardPaymentSourceAccountLabel,
                ),
                items: sourceAccounts
                    .map(
                      (account) => DropdownMenuItem<String>(
                        value: account.id,
                        child: Text(account.name),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isSubmitting
                    ? null
                    : (value) => setState(() => _sourceAccountId = value),
                validator: (value) => value == null
                    ? l10n.creditCardPaymentSourceRequiredError
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.creditCardPaymentTypeLabel,
                style: context.textTheme.label.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<CreditCardPaymentType>(
                segments: <ButtonSegment<CreditCardPaymentType>>[
                  ButtonSegment<CreditCardPaymentType>(
                    value: CreditCardPaymentType.minimumDue,
                    label: Text(l10n.creditCardPaymentTypeMinimumDue),
                  ),
                  ButtonSegment<CreditCardPaymentType>(
                    value: CreditCardPaymentType.fullBalance,
                    label: Text(l10n.creditCardPaymentTypeFullBalance),
                  ),
                  ButtonSegment<CreditCardPaymentType>(
                    value: CreditCardPaymentType.custom,
                    label: Text(l10n.creditCardPaymentTypeCustom),
                  ),
                ],
                selected: <CreditCardPaymentType>{_paymentType},
                onSelectionChanged: _isSubmitting
                    ? null
                    : (selection) =>
                          setState(() => _paymentType = selection.first),
              ),
              if (_paymentType == CreditCardPaymentType.custom) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _amountController,
                  enabled: !_isSubmitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.creditCardPaymentAmountLabel,
                  ),
                  validator: (value) {
                    final parsed = num.tryParse((value ?? '').trim());
                    if (parsed == null || parsed <= 0) {
                      return l10n.creditCardPaymentAmountError;
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(
                  _isSubmitting
                      ? l10n.commonLoading
                      : l10n.creditCardPaymentSubmitCta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _failure = null;
    });

    try {
      await ref
          .read(
            creditCardDetailControllerProvider(
              widget.creditAccount.id,
            ).notifier,
          )
          .makePayment(
            sourceAccountId: _sourceAccountId!,
            paymentType: _paymentType,
            amount: _paymentType == CreditCardPaymentType.custom
                ? num.parse(_amountController.text.trim())
                : null,
          );
    } on Failure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _failure = failure;
        _isSubmitting = false;
      });
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }
}
