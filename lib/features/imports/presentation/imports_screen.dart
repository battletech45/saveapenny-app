import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/imports/application/imports_controller.dart';
import 'package:saveapenny/features/imports/presentation/widgets/import_preview_view.dart';
import 'package:saveapenny/features/imports/presentation/widgets/import_status_view.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class ImportsScreen extends ConsumerWidget {
  const ImportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final flowState = ref.watch(importsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => GoRouter.of(context).go('/home'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(l10n.importsTitle),
      ),
      body: SafeArea(
        child: flowState.isIdle
            ? _IdleView(
                onPickFile: () => _pickAndPreview(context, ref),
                error: flowState.error,
              )
            : flowState.isConfirming && flowState.error != null
            ? FailureView(
                failure: flowState.error!,
                onRetry: () => ref
                    .read(importsControllerProvider.notifier)
                    .retryStatusCheck(),
              )
            : flowState.isPreviewing || flowState.isConfirming
            ? const LoadingView()
            : flowState.isPreviewReady && flowState.preview != null
            ? ImportPreviewView(
                preview: flowState.preview!,
                onConfirm: () => _confirm(context, ref),
                onCancel: () =>
                    ref.read(importsControllerProvider.notifier).reset(),
              )
            : (flowState.isCompleted || flowState.isFailed) &&
                  flowState.status != null
            ? ImportStatusView(
                status: flowState.status!,
                onDone: () =>
                    ref.read(importsControllerProvider.notifier).reset(),
              )
            : FailureView(
                failure: flowState.error ?? const Failure.unknown(),
                onRetry: () async =>
                    ref.read(importsControllerProvider.notifier).reset(),
              ),
      ),
    );
  }

  Future<void> _pickAndPreview(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['csv'],
    );

    if (result == null || result.files.isEmpty || !context.mounted) return;

    final filePath = result.files.single.path;
    if (filePath == null) return;

    await ref
        .read(importsControllerProvider.notifier)
        .previewFile(filePath: filePath);
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.importsConfirmTitle),
          content: Text(l10n.importsConfirmMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonBack),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.importsConfirmCta),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(importsControllerProvider.notifier).confirmImport();
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
              Icons.upload_file_rounded,
              size: 48,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.importsIdleTitle,
              style: context.textTheme.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.importsIdleMessage,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
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
              icon: const Icon(Icons.folder_open_rounded),
              label: Text(l10n.importsPickFileCta),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = switch (failure) {
      NetworkFailure() => l10n.failureNetworkMessage,
      UnauthenticatedFailure() => l10n.failureUnauthenticatedMessage,
      RateLimitedFailure() => l10n.failureRateLimitedMessage,
      UnknownFailure() => l10n.failureGenericMessage,
      ApiFailure(code: final code) => switch (code) {
        ApiErrorCode.invalidImportFile => l10n.importsInvalidFileError,
        ApiErrorCode.importNotFound => l10n.failureResourceNotFoundMessage,
        ApiErrorCode.importAlreadyRunning => l10n.importsAlreadyRunningError,
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
