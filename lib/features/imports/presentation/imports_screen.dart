import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/imports/application/imports_controller.dart';
import 'package:saveapenny/features/imports/presentation/widgets/import_idle_view.dart';
import 'package:saveapenny/features/imports/presentation/widgets/import_preview_view.dart';
import 'package:saveapenny/features/imports/presentation/widgets/import_shared.dart';
import 'package:saveapenny/features/imports/presentation/widgets/import_status_view.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class ImportsScreen extends ConsumerWidget {
  const ImportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final flowState = ref.watch(importsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.importsTitle)),
      body: SafeArea(
        child: flowState.isIdle
            ? _ImportScaffold(
                step: flowState.step,
                child: ImportIdleView(
                  onPickFile: () => _pickAndPreview(context, ref),
                  error: flowState.error,
                ),
              )
            : flowState.isConfirming && flowState.error != null
            ? _ImportScaffold(
                step: flowState.step,
                child: FailureView(
                  failure: flowState.error!,
                  onRetry: () => ref
                      .read(importsControllerProvider.notifier)
                      .retryStatusCheck(),
                ),
              )
            : flowState.isPreviewing || flowState.isConfirming
            ? _ImportScaffold(step: flowState.step, child: const LoadingView())
            : flowState.isPreviewReady && flowState.preview != null
            ? _ImportScaffold(
                step: flowState.step,
                child: ImportPreviewView(
                  preview: flowState.preview!,
                  onConfirm: () => _confirm(context, ref),
                  onCancel: () =>
                      ref.read(importsControllerProvider.notifier).reset(),
                ),
              )
            : (flowState.isCompleted || flowState.isFailed) &&
                  flowState.status != null
            ? _ImportScaffold(
                step: flowState.step,
                child: ImportStatusView(
                  status: flowState.status!,
                  onDone: () =>
                      ref.read(importsControllerProvider.notifier).reset(),
                ),
              )
            : _ImportScaffold(
                step: flowState.step,
                child: FailureView(
                  failure: flowState.error ?? const Failure.unknown(),
                  onRetry: () async =>
                      ref.read(importsControllerProvider.notifier).reset(),
                ),
              ),
      ),
    );
  }

  Future<void> _pickAndPreview(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
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

class _ImportScaffold extends StatelessWidget {
  const _ImportScaffold({required this.step, required this.child});

  final ImportStep step;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ImportStepStrip(
            currentIndex: switch (step) {
              ImportStep.idle || ImportStep.previewing => 0,
              ImportStep.previewReady => 1,
              ImportStep.confirming => 2,
              ImportStep.completed || ImportStep.failed => 3,
            },
            labels: <String>[
              l10n.importsPickFileCta,
              l10n.importsPreviewTitle,
              l10n.importsConfirmCta,
              step == ImportStep.failed
                  ? l10n.importsFailedTitle
                  : l10n.importsCompletedTitle,
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
