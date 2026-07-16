import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/ocr/application/ocr_controller.dart';
import 'package:saveapenny/features/ocr/domain/ocr_models.dart';
import 'package:saveapenny/features/ocr/presentation/widgets/ocr_candidate_transaction_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class OcrScreen extends ConsumerWidget {
  const OcrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final flowState = ref.watch(ocrControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ocrTitle)),
      body: SafeArea(
        child: flowState.isIdle
            ? _IdleView(
                error: flowState.error,
                onPickFile: () => _pickAndSubmit(context, ref),
              )
            : flowState.isPolling && flowState.error != null
            ? FailureView(
                failure: flowState.error!,
                onRetry: () =>
                    ref.read(ocrControllerProvider.notifier).retryStatusCheck(),
              )
            : flowState.isUploading || flowState.isPolling
            ? _ProcessingView(
                fileName: _fileName(flowState),
                job: flowState.job,
              )
            : (flowState.isCompleted || flowState.isFailed) &&
                  flowState.job != null
            ? _ResultView(
                job: flowState.job!,
                onUseCandidate: (candidate) => _showCandidateSheet(
                  context,
                  candidate: candidate,
                  merchantName: flowState.job!.merchantName,
                ),
                onReset: () => ref.read(ocrControllerProvider.notifier).reset(),
              )
            : FailureView(
                failure: flowState.error ?? const Failure.unknown(),
                onRetry: () async =>
                    ref.read(ocrControllerProvider.notifier).reset(),
              ),
      ),
    );
  }

  Future<void> _pickAndSubmit(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['png', 'jpg', 'jpeg', 'pdf'],
    );

    if (result == null || result.files.isEmpty || !context.mounted) {
      return;
    }

    final filePath = result.files.single.path;
    if (filePath == null) {
      return;
    }

    await ref
        .read(ocrControllerProvider.notifier)
        .submitFile(filePath: filePath);
  }

  Future<void> _showCandidateSheet(
    BuildContext context, {
    required OcrTransactionCandidate candidate,
    String? merchantName,
  }) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => OcrCandidateTransactionSheet(
        candidate: candidate,
        merchantName: merchantName,
      ),
    );
  }

  String _fileName(OcrFlowState state) {
    final jobName = state.job?.originalFileName;
    if (jobName != null && jobName.isNotEmpty) {
      return jobName;
    }

    final path = state.filePath;
    if (path == null || path.isEmpty) {
      return '';
    }

    return path.split(RegExp(r'[\\/]')).last;
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({required this.onPickFile, this.error});

  final VoidCallback onPickFile;
  final Failure? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.document_scanner_rounded,
              size: 48,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.ocrIdleTitle,
              style: context.textTheme.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.ocrIdleMessage,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.ocrAcceptedFormatsMessage,
              style: context.textTheme.label.copyWith(
                color: context.colors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            if (error != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              _ErrorNotice(failure: error!),
            ],
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: onPickFile,
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(l10n.ocrPickFileCta),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcessingView extends StatelessWidget {
  const _ProcessingView({required this.fileName, this.job});

  final String fileName;
  final OcrJob? job;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const LoadingView(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.ocrProcessingTitle,
              style: context.textTheme.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              fileName.isEmpty
                  ? l10n.ocrProcessingMessage
                  : l10n.ocrProcessingFileMessage(fileName),
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (job != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                '${l10n.ocrStatusLabel}: ${ocrStatusLabel(context, job!.status)}',
                style: context.textTheme.label.copyWith(
                  color: context.colors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.job,
    required this.onUseCandidate,
    required this.onReset,
  });

  final OcrJob job;
  final ValueChanged<OcrTransactionCandidate> onUseCandidate;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
                    _StatusPill(status: job.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  job.originalFileName,
                  style: context.textTheme.body.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                if (job.errorMessage != null &&
                    job.errorMessage!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  _ErrorNotice(
                    failure: Failure.unknown(message: job.errorMessage),
                    customMessage: job.errorMessage,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                _InfoRow(
                  label: l10n.ocrDocumentTypeLabel,
                  value: job.documentType ?? l10n.commonNotAvailable,
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(
                  label: l10n.ocrMerchantLabel,
                  value: job.merchantName ?? l10n.commonNotAvailable,
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(
                  label: l10n.ocrCurrencyLabel,
                  value: job.currency ?? l10n.commonNotAvailable,
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(
                  label: l10n.ocrConfidenceLabel,
                  value: job.parseConfidence == null
                      ? l10n.commonNotAvailable
                      : '${(job.parseConfidence! * 100).toStringAsFixed(0)}%',
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(
                  label: l10n.ocrPaymentDateLabel,
                  value: _formatDate(context, job.paymentDate),
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(
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
          _InlineEmptyState(
            title: l10n.ocrCandidatesEmptyTitle,
            message: l10n.ocrCandidatesEmptyMessage,
          )
        else
          ...job.transactionCandidates.map(
            (candidate) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _CandidateCard(
                candidate: candidate,
                onUse: () => onUseCandidate(candidate),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xxl),
        Text(l10n.ocrRawResultTitle, style: context.textTheme.title),
        const SizedBox(height: AppSpacing.sm),
        if ((job.resultSnippet ?? '').isEmpty && (job.rawText ?? '').isEmpty)
          _InlineEmptyState(
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
        _DiagnosticsCard(job: job),
        const SizedBox(height: AppSpacing.xxl),
        OutlinedButton(onPressed: onReset, child: Text(l10n.ocrStartOverCta)),
      ],
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
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({required this.candidate, required this.onUse});

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

class _DiagnosticsCard extends StatelessWidget {
  const _DiagnosticsCard({required this.job});

  final OcrJob job;

  @override
  Widget build(BuildContext context) {
    final diagnostics = job.parseDiagnostics;
    final l10n = AppLocalizations.of(context);

    if (diagnostics == null) {
      return _InlineEmptyState(
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
            _InfoRow(
              label: l10n.ocrDetectedDocumentTypeLabel,
              value:
                  diagnostics.detectedDocumentType ?? l10n.commonNotAvailable,
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              label: l10n.ocrSelectedReasonLabel,
              value:
                  diagnostics.selectedCandidateReason ??
                  l10n.commonNotAvailable,
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final OcrJobStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      OcrJobStatus.pending || OcrJobStatus.running => (
        context.finance.warningSurface,
        context.finance.warning,
      ),
      OcrJobStatus.completed => (
        context.finance.incomeSurface,
        context.finance.income,
      ),
      OcrJobStatus.failed => (
        context.finance.expenseSurface,
        context.finance.expense,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          ocrStatusLabel(context, status),
          style: context.textTheme.label.copyWith(color: foreground),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 132,
          child: Text(
            label,
            style: context.textTheme.label.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Text(value, style: context.textTheme.body)),
      ],
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: context.textTheme.body),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.failure, this.customMessage});

  final Failure failure;
  final String? customMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message =
        customMessage ??
        switch (failure) {
          NetworkFailure() => l10n.failureNetworkMessage,
          UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
          RateLimitedFailure() => l10n.failureRateLimitedMessage,
          UnknownFailure() => l10n.failureGenericMessage,
          ApiFailure(code: final code) => switch (code) {
            ApiErrorCode.invalidOcrFile => l10n.ocrInvalidFileError,
            ApiErrorCode.ocrJobNotFound => l10n.failureResourceNotFoundMessage,
            ApiErrorCode.ocrProcessingFailed => l10n.ocrProcessingFailedError,
            _ => l10n.failureValidationFailedMessage,
          },
        };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.finance.expenseSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.finance.expense),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: 20,
              color: context.finance.expense,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String ocrStatusLabel(BuildContext context, OcrJobStatus status) {
  final l10n = AppLocalizations.of(context);

  return switch (status) {
    OcrJobStatus.pending => l10n.ocrStatusPending,
    OcrJobStatus.running => l10n.ocrStatusRunning,
    OcrJobStatus.completed => l10n.ocrStatusCompleted,
    OcrJobStatus.failed => l10n.ocrStatusFailed,
  };
}
