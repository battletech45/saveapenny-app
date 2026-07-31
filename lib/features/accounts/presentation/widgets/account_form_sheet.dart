import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/accounts/presentation/widgets/account_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class AccountFormSheet extends ConsumerStatefulWidget {
  const AccountFormSheet({super.key, this.existing});

  final Account? existing;

  @override
  ConsumerState<AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends ConsumerState<AccountFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _currencyController;
  late final TextEditingController _initialBalanceController;
  late AccountType _type;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _currencyController = TextEditingController(
      text: widget.existing?.currency ?? 'TRY',
    );
    _initialBalanceController = TextEditingController(
      text: widget.existing?.initialBalance.toString() ?? '0',
    );
    _type = widget.existing?.type ?? AccountType.bank;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currencyController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accountsState = ref.watch(accountsControllerProvider);
    final isSubmitting = accountsState.isLoading;
    final failure = accountsState.hasError
        ? accountsState.error as Failure
        : null;

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
                _isEditing ? l10n.accountsEditTitle : l10n.accountsCreateTitle,
                style: context.textTheme.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isEditing
                    ? l10n.accountsEditSubtitle
                    : l10n.accountsCreateSubtitle,
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              if (failure != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                _SheetFailureNotice(failure: failure),
              ],
              const SizedBox(height: AppSpacing.xxl),
              TextFormField(
                controller: _nameController,
                enabled: !isSubmitting,
                decoration: InputDecoration(labelText: l10n.accountsNameLabel),
                validator: (value) => _validateRequired(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<AccountType>(
                initialValue: _type,
                decoration: InputDecoration(labelText: l10n.accountsTypeLabel),
                items: AccountType.values
                    .map(
                      (type) => DropdownMenuItem<AccountType>(
                        value: type,
                        child: Text(accountTypeLabel(l10n, type)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: isSubmitting
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _type = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _currencyController,
                enabled: !isSubmitting,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n.accountsCurrencyLabel,
                ),
                validator: (value) => _validateCurrency(l10n, value),
              ),
              if (!_isEditing) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _initialBalanceController,
                  enabled: !isSubmitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.accountsInitialBalanceLabel,
                  ),
                  validator: (value) => _validateAmount(l10n, value),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submit,
                child: Text(
                  isSubmitting
                      ? l10n.commonLoading
                      : _isEditing
                      ? l10n.accountsSaveCta
                      : l10n.accountsCreateCta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateRequired(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.authRequiredFieldError;
    }

    return null;
  }

  String? _validateCurrency(AppLocalizations l10n, String? value) {
    final requiredError = _validateRequired(l10n, value);
    if (requiredError != null) {
      return requiredError;
    }

    final currency = value!.trim().toUpperCase();
    if (currency.length != 3) {
      return l10n.accountsCurrencyError;
    }

    return null;
  }

  String? _validateAmount(AppLocalizations l10n, String? value) {
    final requiredError = _validateRequired(l10n, value);
    if (requiredError != null) {
      return requiredError;
    }

    if (num.tryParse(value!.trim()) == null) {
      return l10n.accountsInitialBalanceError;
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(accountsControllerProvider.notifier);
    if (_isEditing) {
      await controller.updateAccount(
        accountId: widget.existing!.id,
        name: _nameController.text.trim(),
        type: _type,
        currency: _currencyController.text.trim().toUpperCase(),
      );
    } else {
      await controller.create(
        name: _nameController.text.trim(),
        type: _type,
        currency: _currencyController.text.trim().toUpperCase(),
        initialBalance: num.parse(_initialBalanceController.text.trim()),
      );
    }

    final state = ref.read(accountsControllerProvider);
    if (!mounted || state.hasError) {
      return;
    }

    Navigator.of(context).pop();
  }
}

class _SheetFailureNotice extends StatelessWidget {
  const _SheetFailureNotice({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = switch (failure) {
      NetworkFailure() => l10n.failureNetworkMessage,
      UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
      RateLimitedFailure() => l10n.failureRateLimitedMessage,
      UnknownFailure() => l10n.failureGenericMessage,
      ApiFailure() => l10n.failureValidationFailedMessage,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.finance.expenseSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.finance.expense),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          message,
          style: context.textTheme.body.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
