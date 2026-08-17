import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/analytics/analytics_service.dart';
import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/imports/data/imports_repository.dart';
import 'package:saveapenny/features/imports/domain/import_models.dart';

part 'imports_controller.g.dart';

enum ImportStep {
  idle,
  previewing,
  previewReady,
  confirming,
  completed,
  failed,
}

class ImportFlowState {
  const ImportFlowState({
    required this.step,
    this.preview,
    this.status,
    this.error,
  });

  final ImportStep step;
  final ImportPreview? preview;
  final ImportStatus? status;
  final Failure? error;

  ImportFlowState copyWith({
    ImportStep? step,
    ImportPreview? preview,
    ImportStatus? status,
    Failure? error,
    bool clearError = false,
  }) {
    return ImportFlowState(
      step: step ?? this.step,
      preview: preview ?? this.preview,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get isIdle => step == ImportStep.idle;
  bool get isPreviewing => step == ImportStep.previewing;
  bool get isPreviewReady => step == ImportStep.previewReady;
  bool get isConfirming => step == ImportStep.confirming;
  bool get isCompleted => step == ImportStep.completed;
  bool get isFailed => step == ImportStep.failed;
}

@Riverpod(keepAlive: true)
class ImportsController extends _$ImportsController {
  Timer? _pollTimer;
  bool _isPolling = false;

  @override
  ImportFlowState build() {
    ref.onDispose(() {
      _pollTimer?.cancel();
    });
    return const ImportFlowState(step: ImportStep.idle);
  }

  Future<void> previewFile({required String filePath}) async {
    state = state.copyWith(step: ImportStep.previewing, clearError: true);
    try {
      final preview = await ref
          .read(importsRepositoryProvider)
          .preview(filePath: filePath);
      state = ImportFlowState(step: ImportStep.previewReady, preview: preview);
      unawaited(ref.read(analyticsServiceProvider).logImportStarted());
    } on Failure catch (error) {
      state = ImportFlowState(step: ImportStep.idle, error: error);
    } on Object catch (error, stackTrace) {
      state = ImportFlowState(
        step: ImportStep.idle,
        error: Failure.unknown(message: error.toString()),
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> confirmImport() async {
    final preview = state.preview;
    if (preview == null) return;

    state = state.copyWith(step: ImportStep.confirming, clearError: true);
    try {
      final status = await ref
          .read(importsRepositoryProvider)
          .confirm(importId: preview.importId);
      state = ImportFlowState(step: _stepFromStatus(status), status: status);

      if (status.status == ImportJobStatus.running) {
        _startPolling(preview.importId);
      } else if (status.status == ImportJobStatus.completed) {
        await _syncAccounts();
      }
    } on Failure catch (error) {
      state = state.copyWith(step: ImportStep.previewReady, error: error);
    } on Object catch (error, stackTrace) {
      state = state.copyWith(
        step: ImportStep.previewReady,
        error: Failure.unknown(message: error.toString()),
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> retryStatusCheck() async {
    final importId = state.status?.importId ?? state.preview?.importId;
    if (importId == null) return;

    state = state.copyWith(step: ImportStep.confirming, clearError: true);
    await _pollStatus(importId);
  }

  void _startPolling(String importId) {
    _pollTimer?.cancel();
    // A one-shot timer that only re-arms after the previous status check
    // finishes, instead of Timer.periodic, which would tick again even if
    // the prior check was still in flight and cause overlapping calls.
    _pollTimer = Timer(const Duration(seconds: 2), () => _pollStatus(importId));
  }

  Future<void> _pollStatus(String importId) async {
    if (_isPolling) return;
    _isPolling = true;
    try {
      final status = await ref
          .read(importsRepositoryProvider)
          .status(importId: importId);
      state = ImportFlowState(step: _stepFromStatus(status), status: status);

      if (status.status == ImportJobStatus.running) {
        _startPolling(importId);
      } else {
        _pollTimer?.cancel();
        if (status.status == ImportJobStatus.completed) {
          unawaited(ref.read(analyticsServiceProvider).logImportCompleted());
          await _syncAccounts();
        }
      }
    } on Failure catch (error) {
      _pollTimer?.cancel();
      state = state.copyWith(error: error);
    } on Object catch (error) {
      _pollTimer?.cancel();
      state = state.copyWith(error: Failure.unknown(message: error.toString()));
    } finally {
      _isPolling = false;
    }
  }

  Future<void> _syncAccounts() async {
    try {
      await ref.read(accountsControllerProvider.notifier).sync();
    } on Object {
      // Import state should stay successful even if the dependent account
      // refresh misses one cycle.
    }
  }

  void reset() {
    _pollTimer?.cancel();
    state = const ImportFlowState(step: ImportStep.idle);
  }
}

ImportStep _stepFromStatus(ImportStatus status) {
  return switch (status.status) {
    ImportJobStatus.pending || ImportJobStatus.running => ImportStep.confirming,
    ImportJobStatus.completed => ImportStep.completed,
    ImportJobStatus.failed => ImportStep.failed,
  };
}
