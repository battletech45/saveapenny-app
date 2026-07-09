import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/imports/domain/import_models.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class ImportStatusView extends StatelessWidget {
  const ImportStatusView({
    required this.status,
    required this.onDone,
    super.key,
  });

  final ImportStatus status;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSuccess = status.status == ImportJobStatus.completed;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              size: 64,
              color: isSuccess
                  ? context.finance.income
                  : context.finance.expense,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isSuccess ? l10n.importsCompletedTitle : l10n.importsFailedTitle,
              style: context.textTheme.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            _ResultRow(
              label: l10n.importsCompletedTotalLabel,
              value: status.totalRows.toString(),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ResultRow(
              label: l10n.importsCompletedImportedLabel,
              value: status.importedRows.toString(),
              valueColor: context.finance.income,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ResultRow(
              label: l10n.importsCompletedFailedLabel,
              value: status.failedRows.toString(),
              valueColor: status.failedRows > 0
                  ? context.finance.expense
                  : null,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton(onPressed: onDone, child: Text(l10n.commonContinue)),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label, style: context.textTheme.body)),
            Text(
              value,
              style: context.textTheme.title.copyWith(
                color: valueColor ?? context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
