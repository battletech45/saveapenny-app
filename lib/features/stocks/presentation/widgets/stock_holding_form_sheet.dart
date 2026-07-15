import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/stocks/application/stock_holdings_controller.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class StockHoldingFormSheet extends ConsumerStatefulWidget {
  const StockHoldingFormSheet({super.key, this.existing});

  final StockHolding? existing;

  @override
  ConsumerState<StockHoldingFormSheet> createState() =>
      _StockHoldingFormSheetState();
}

class _StockHoldingFormSheetState extends ConsumerState<StockHoldingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _symbolController;
  late final TextEditingController _quantityController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _notesController;

  late DateTime _purchaseDate;
  bool _isSubmitting = false;
  Failure? _submissionFailure;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _symbolController = TextEditingController(
      text: widget.existing?.symbol ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.existing?.quantity.toString() ?? '',
    );
    _purchasePriceController = TextEditingController(
      text: widget.existing?.purchasePrice.toString() ?? '',
    );
    _currencyController = TextEditingController(
      text: widget.existing?.currency ?? 'USD',
    );
    _notesController = TextEditingController(
      text: widget.existing?.notes ?? '',
    );
    _purchaseDate = widget.existing?.purchaseDate ?? _today();
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _currencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(_purchaseDate);

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
                _isEditing ? l10n.stocksEditTitle : l10n.stocksCreateTitle,
                style: context.textTheme.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isEditing
                    ? l10n.stocksEditSubtitle
                    : l10n.stocksCreateSubtitle,
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              if (_submissionFailure != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                _FailureNotice(failure: _submissionFailure!),
              ],
              const SizedBox(height: AppSpacing.xxl),
              TextFormField(
                controller: _symbolController,
                enabled: !_isSubmitting && !_isEditing,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: l10n.stocksSymbolLabel),
                validator: (value) => _validateSymbol(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _quantityController,
                enabled: !_isSubmitting,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.stocksQuantityLabel,
                ),
                validator: (value) => _validateQuantity(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _purchasePriceController,
                enabled: !_isSubmitting,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.stocksPurchasePriceLabel,
                ),
                validator: (value) => _validatePurchasePrice(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _currencyController,
                enabled: !_isSubmitting,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n.stocksCurrencyLabel,
                ),
                validator: (value) => _validateCurrency(l10n, value),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ReadOnlyActionField(
                label: l10n.stocksPurchaseDateLabel,
                value: dateLabel,
                actionLabel: l10n.commonContinue,
                onPressed: _isSubmitting ? null : _pickPurchaseDate,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _notesController,
                enabled: !_isSubmitting,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(labelText: l10n.stocksNotesLabel),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(
                  _isSubmitting
                      ? l10n.commonLoading
                      : _isEditing
                      ? l10n.stocksSaveCta
                      : l10n.stocksAddCta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateSymbol(AppLocalizations l10n, String? value) {
    final text = value?.trim().toUpperCase() ?? '';
    final pattern = RegExp(r'^[A-Z0-9.-]{1,10}$');
    if (!pattern.hasMatch(text)) {
      return l10n.stocksSymbolError;
    }
    return null;
  }

  String? _validateQuantity(AppLocalizations l10n, String? value) {
    final amount = num.tryParse(value?.trim() ?? '');
    if (amount == null || amount <= 0) {
      return l10n.stocksQuantityError;
    }
    return null;
  }

  String? _validatePurchasePrice(AppLocalizations l10n, String? value) {
    final amount = num.tryParse(value?.trim() ?? '');
    if (amount == null || amount <= 0) {
      return l10n.stocksPurchasePriceError;
    }
    return null;
  }

  String? _validateCurrency(AppLocalizations l10n, String? value) {
    final text = value?.trim().toUpperCase() ?? '';
    if (text.length != 3) {
      return l10n.stocksCurrencyError;
    }
    return null;
  }

  Future<void> _pickPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: _today(),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _purchaseDate = picked;
      _submissionFailure = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionFailure = null;
    });

    try {
      final controller = ref.read(stockHoldingsControllerProvider.notifier);
      if (_isEditing) {
        await controller.updateHolding(
          holdingId: widget.existing!.id,
          quantity: num.parse(_quantityController.text.trim()),
          purchasePrice: num.parse(_purchasePriceController.text.trim()),
          currency: _currencyController.text.trim().toUpperCase(),
          purchaseDate: _purchaseDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      } else {
        await controller.createHolding(
          symbol: _symbolController.text.trim().toUpperCase(),
          quantity: num.parse(_quantityController.text.trim()),
          purchasePrice: num.parse(_purchasePriceController.text.trim()),
          currency: _currencyController.text.trim().toUpperCase(),
          purchaseDate: _purchaseDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
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

class _ReadOnlyActionField extends StatelessWidget {
  const _ReadOnlyActionField({
    required this.label,
    required this.value,
    required this.actionLabel,
    required this.onPressed,
  });

  final String label;
  final String value;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(value, style: context.textTheme.body)),
          const SizedBox(width: AppSpacing.md),
          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(64, AppSpacing.giant),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _FailureNotice extends StatelessWidget {
  const _FailureNotice({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.finance.expenseSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.finance.expense),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          stockFailureMessage(context, failure),
          style: context.textTheme.body.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

String stockFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);

  return switch (failure) {
    NetworkFailure() => l10n.failureNetworkMessage,
    UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
    RateLimitedFailure() => l10n.failureRateLimitedMessage,
    UnknownFailure(message: final message) =>
      message != null && message.isNotEmpty
          ? message
          : l10n.failureGenericMessage,
    ApiFailure(
      code: final code,
      message: final message,
      details: final details,
    ) =>
      switch (code) {
        ApiErrorCode.invalidStockSymbol => l10n.stocksInvalidSymbolError,
        ApiErrorCode.stockQuoteNotAvailable => l10n.stocksQuoteUnavailableError,
        ApiErrorCode.stockHoldingNotFound =>
          l10n.failureResourceNotFoundMessage,
        ApiErrorCode.duplicateStockHolding => l10n.stocksDuplicateHoldingError,
        ApiErrorCode.stockProviderError => l10n.stocksProviderError,
        ApiErrorCode.validationFailed =>
          details.isNotEmpty
              ? details.first
              : l10n.failureValidationFailedMessage,
        _ when code.isFeatureDisabled => l10n.failureFeatureDisabledMessage,
        _ => message.isNotEmpty ? message : l10n.failureValidationFailedMessage,
      },
  };
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
