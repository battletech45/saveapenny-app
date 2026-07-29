import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/features/ocr/application/ocr_controller.dart';
import 'package:saveapenny/features/ocr/domain/ocr_models.dart';
import 'package:saveapenny/features/ocr/presentation/widgets/ocr_candidate_transaction_sheet.dart';
import 'package:saveapenny/features/ocr/presentation/widgets/ocr_idle_view.dart';
import 'package:saveapenny/features/ocr/presentation/widgets/ocr_processing_view.dart';
import 'package:saveapenny/features/ocr/presentation/widgets/ocr_result_view.dart';
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
            ? OcrIdleView(
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
            ? OcrProcessingView(
                fileName: _fileName(flowState),
                job: flowState.job,
              )
            : (flowState.isCompleted || flowState.isFailed) &&
                  flowState.job != null
            ? OcrResultView(
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
