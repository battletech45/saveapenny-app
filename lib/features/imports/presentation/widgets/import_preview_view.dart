import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/imports/domain/import_models.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class ImportPreviewView extends StatelessWidget {
  const ImportPreviewView({
    required this.preview,
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });

  final ImportPreview preview;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasErrors = preview.invalidRows > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(l10n.importsPreviewTitle, style: context.textTheme.title),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.importsPreviewSubtitle(preview.fileName),
            style: context.textTheme.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _StatCard(
            icon: Icons.description_rounded,
            label: l10n.importsPreviewTotalRowsLabel,
            value: preview.totalRows.toString(),
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatCard(
            icon: Icons.check_circle_rounded,
            label: l10n.importsPreviewValidRowsLabel,
            value: preview.validRows.toString(),
            valueColor: context.finance.income,
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatCard(
            icon: Icons.error_rounded,
            label: l10n.importsPreviewInvalidRowsLabel,
            value: preview.invalidRows.toString(),
            valueColor: context.finance.expense,
          ),
          if (hasErrors) ...<Widget>[
            const SizedBox(height: AppSpacing.xxl),
            Text(
              l10n.importsPreviewErrorsTitle,
              style: context.textTheme.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...preview.errors.map((error) => _ErrorRow(error: error)),
          ],
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: Text(l10n.commonBack),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: preview.validRows > 0 ? onConfirm : null,
                  child: Text(l10n.importsConfirmCta),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
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
            Icon(icon, color: context.colors.textSecondary),
            const SizedBox(width: AppSpacing.md),
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

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.error});

  final ImportPreviewRowError error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.importsPreviewErrorRowLabel(error.rowNumber),
                style: context.textTheme.label.copyWith(
                  color: context.finance.expense,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(error.errorMessage, style: context.textTheme.body),
              if (error.rawData.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  error.rawData,
                  style: context.textTheme.label.copyWith(
                    color: context.colors.textTertiary,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
