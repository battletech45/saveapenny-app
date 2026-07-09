import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/empty_view.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accountsState = ref.watch(accountsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => GoRouter.of(context).go('/home'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(l10n.accountsTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAccountSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.accountsAddCta),
      ),
      body: SafeArea(
        child: accountsState.when(
          data: (accounts) {
            if (accounts.isEmpty) {
              return EmptyView(
                title: l10n.accountsEmptyTitle,
                message: l10n.accountsEmptyMessage,
                action: ElevatedButton(
                  onPressed: () => _showAccountSheet(context, ref),
                  child: Text(l10n.accountsAddFirstCta),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(accountsControllerProvider.notifier).refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: accounts.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: AppSpacing.lg),
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return _AccountCard(
                    account: account,
                    onEdit: () =>
                        _showAccountSheet(context, ref, existing: account),
                    onDelete: () => _confirmDelete(context, ref, account),
                  );
                },
              ),
            );
          },
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () =>
                ref.read(accountsControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Future<void> _showAccountSheet(
    BuildContext context,
    WidgetRef ref, {
    Account? existing,
  }) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => _AccountFormSheet(existing: existing),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.accountsDeleteTitle),
          content: Text(l10n.accountsDeleteMessage(account.name)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonBack),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.accountsDeleteCta),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await ref
        .read(accountsControllerProvider.notifier)
        .deleteAccount(account.id);
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

  final Account account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final balance = MoneyFormatter.format(
      context: context,
      amount: account.balance,
      currencyCode: account.currency,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(account.name, style: context.textTheme.title),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _accountTypeLabel(l10n, account.type),
                        style: context.textTheme.label.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                      return;
                    }
                    onDelete();
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text(l10n.accountsEditCta),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(l10n.accountsDeleteCta),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.accountsBalanceLabel,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                balance.text,
                textAlign: TextAlign.right,
                style: context.textTheme.displayMoney.copyWith(
                  color: balance.color,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: _InfoPill(
                    label: l10n.accountsCurrencyLabel,
                    value: account.currency,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _InfoPill(
                    label: l10n.accountsStatusLabel,
                    value: account.active
                        ? l10n.accountsStatusActive
                        : l10n.accountsStatusArchived,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: context.textTheme.body),
          ],
        ),
      ),
    );
  }
}

class _AccountFormSheet extends ConsumerStatefulWidget {
  const _AccountFormSheet({this.existing});

  final Account? existing;

  @override
  ConsumerState<_AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends ConsumerState<_AccountFormSheet> {
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
                        child: Text(_accountTypeLabel(l10n, type)),
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

String _accountTypeLabel(AppLocalizations l10n, AccountType type) {
  return switch (type) {
    AccountType.cash => l10n.accountsTypeCash,
    AccountType.bank => l10n.accountsTypeBank,
    AccountType.credit => l10n.accountsTypeCredit,
    AccountType.savings => l10n.accountsTypeSavings,
    AccountType.investment => l10n.accountsTypeInvestment,
  };
}
