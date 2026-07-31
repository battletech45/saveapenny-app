import 'package:flutter/material.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

String categoryTypeLabel(AppLocalizations l10n, CategoryType type) {
  return switch (type) {
    CategoryType.income => l10n.categoriesTypeIncome,
    CategoryType.expense => l10n.categoriesTypeExpense,
  };
}

String categoryFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);

  return switch (failure) {
    NetworkFailure() => l10n.failureNetworkMessage,
    UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
    RateLimitedFailure() => l10n.failureRateLimitedMessage,
    UnknownFailure() => l10n.failureGenericMessage,
    ApiFailure() => l10n.failureValidationFailedMessage,
  };
}

class CategorySheetFailureNotice extends StatelessWidget {
  const CategorySheetFailureNotice({super.key, required this.failure});

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
          categoryFailureMessage(context, failure),
          style: context.textTheme.body.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
