import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/ocr/domain/ocr_models.dart';
import 'package:saveapenny/features/ocr/presentation/widgets/ocr_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class OcrResultView extends StatelessWidget {
  const OcrResultView({
    super.key,
    required this.job,
    this.filePath,
    required this.onUseCandidate,
    required this.onReset,
  });

  final OcrJob job;
  final String? filePath;
  final ValueChanged<OcrTransactionCandidate> onUseCandidate;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          job.status == OcrJobStatus.failed
                              ? l10n.ocrFailedTitle
                              : l10n.ocrCompletedTitle,
                          style: context.textTheme.title,
                        ),
                      ),
                      OcrStatusPill(status: job.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    job.originalFileName,
                    style: context.textTheme.body.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  if (_isImagePath(filePath)) ...<Widget>[
                    const SizedBox(height: AppSpacing.lg),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.file(
                        File(filePath!),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ],
                  if (job.errorMessage != null &&
                      job.errorMessage!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.lg),
                    OcrErrorNotice(
                      failure: Failure.unknown(message: job.errorMessage),
                      customMessage: job.errorMessage,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  OcrInfoRow(
                    label: l10n.ocrDocumentTypeLabel,
                    value: job.documentType ?? l10n.commonNotAvailable,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OcrInfoRow(
                    label: l10n.ocrMerchantLabel,
                    value: job.merchantName ?? l10n.commonNotAvailable,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OcrInfoRow(
                    label: l10n.ocrCurrencyLabel,
                    value: job.currency ?? l10n.commonNotAvailable,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OcrInfoRow(
                    label: l10n.ocrConfidenceLabel,
                    value: job.parseConfidence == null
                        ? l10n.commonNotAvailable
                        : '${(job.parseConfidence! * 100).toStringAsFixed(0)}%',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OcrInfoRow(
                    label: l10n.ocrPaymentDateLabel,
                    value: _formatDate(context, job.paymentDate),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OcrInfoRow(
                    label: l10n.ocrIssueDateLabel,
                    value: _formatDate(context, job.issueDate),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(l10n.ocrCandidatesTitle, style: context.textTheme.title),
          const SizedBox(height: AppSpacing.sm),
          if (job.transactionCandidates.isEmpty)
            OcrInlineEmptyState(
              title: l10n.ocrCandidatesEmptyTitle,
              message: l10n.ocrCandidatesEmptyMessage,
            )
          else
            ...job.transactionCandidates.map(
              (candidate) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: OcrCandidateCard(
                  candidate: candidate,
                  onUse: () => onUseCandidate(candidate),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
          Text(l10n.ocrRawResultTitle, style: context.textTheme.title),
          const SizedBox(height: AppSpacing.sm),
          if ((job.resultSnippet ?? '').isEmpty && (job.rawText ?? '').isEmpty)
            OcrInlineEmptyState(
              title: l10n.ocrRawResultEmptyTitle,
              message: l10n.ocrRawResultEmptyMessage,
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  job.rawText?.isNotEmpty == true
                      ? job.rawText!
                      : job.resultSnippet!,
                  style: context.textTheme.body,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
          Text(l10n.ocrDiagnosticsTitle, style: context.textTheme.title),
          const SizedBox(height: AppSpacing.sm),
          OcrDiagnosticsCard(job: job),
          const SizedBox(height: AppSpacing.xxl),
          OutlinedButton(onPressed: onReset, child: Text(l10n.ocrStartOverCta)),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime? value) {
    if (value == null) {
      return AppLocalizations.of(context).commonNotAvailable;
    }

    return DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(value);
  }

  bool _isImagePath(String? path) {
    if (path == null || path.isEmpty) {
      return false;
    }
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg');
  }
}

class OcrCandidateCard extends StatelessWidget {
  const OcrCandidateCard({
    super.key,
    required this.candidate,
    required this.onUse,
  });

  final OcrTransactionCandidate candidate;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(candidate.description, style: context.textTheme.body),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(candidate.date)} · ${candidate.categoryHint}',
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    candidate.amount.toString(),
                    style: context.textTheme.money,
                  ),
                ),
                OutlinedButton(
                  onPressed: onUse,
                  child: Text(l10n.ocrUseCandidateCta),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OcrDiagnosticsCard extends StatelessWidget {
  const OcrDiagnosticsCard({super.key, required this.job});

  final OcrJob job;

  @override
  Widget build(BuildContext context) {
    final diagnostics = job.parseDiagnostics;
    final l10n = AppLocalizations.of(context);

    if (diagnostics == null) {
      return OcrInlineEmptyState(
        title: l10n.ocrDiagnosticsEmptyTitle,
        message: l10n.ocrDiagnosticsEmptyMessage,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            OcrInfoRow(
              label: l10n.ocrDetectedDocumentTypeLabel,
              value:
                  diagnostics.detectedDocumentType ?? l10n.commonNotAvailable,
            ),
            const SizedBox(height: AppSpacing.sm),
            OcrInfoRow(
              label: l10n.ocrSelectedReasonLabel,
              value:
                  diagnostics.selectedCandidateReason ??
                  l10n.commonNotAvailable,
            ),
            const SizedBox(height: AppSpacing.sm),
            OcrInfoRow(
              label: l10n.ocrNoCandidateReasonLabel,
              value: diagnostics.noCandidateReason ?? l10n.commonNotAvailable,
            ),
            if (diagnostics.warnings.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.ocrWarningsTitle, style: context.textTheme.body),
              const SizedBox(height: AppSpacing.xs),
              ...diagnostics.warnings.map(
                (warning) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    '• $warning',
                    style: context.textTheme.label.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
            if (diagnostics.notes.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.ocrNotesTitle, style: context.textTheme.body),
              const SizedBox(height: AppSpacing.xs),
              ...diagnostics.notes.map(
                (note) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    '• $note',
                    style: context.textTheme.label.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
