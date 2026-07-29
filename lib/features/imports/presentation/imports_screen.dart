import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/imports/application/imports_controller.dart';
import 'package:saveapenny/features/imports/presentation/widgets/import_idle_view.dart';
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
      appBar: AppBar(title: Text(l10n.importsTitle)),
      body: SafeArea(
        child: flowState.isIdle
            ? ImportIdleView(
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
