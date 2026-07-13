import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/features/ocr/data/ocr_repository.dart';
import 'package:saveapenny/features/ocr/domain/ocr_models.dart';

part 'ocr_controller.g.dart';

enum OcrStep { idle, uploading, polling, completed, failed }

class OcrFlowState {
  const OcrFlowState({
    required this.step,
    this.submitJob,
    this.job,
    this.error,
    this.filePath,
  });

  final OcrStep step;
  final OcrSubmitJob? submitJob;
  final OcrJob? job;
  final Failure? error;
  final String? filePath;

  OcrFlowState copyWith({
    OcrStep? step,
    OcrSubmitJob? submitJob,
    OcrJob? job,
    Failure? error,
    String? filePath,
    bool clearError = false,
  }) {
    return OcrFlowState(
      step: step ?? this.step,
      submitJob: submitJob ?? this.submitJob,
      job: job ?? this.job,
      error: clearError ? null : (error ?? this.error),
      filePath: filePath ?? this.filePath,
    );
  }

  bool get isIdle => step == OcrStep.idle;
  bool get isUploading => step == OcrStep.uploading;
  bool get isPolling => step == OcrStep.polling;
  bool get isCompleted => step == OcrStep.completed;
  bool get isFailed => step == OcrStep.failed;
}

@Riverpod(keepAlive: true)
class OcrController extends _$OcrController {
  Timer? _pollTimer;

  @override
  OcrFlowState build() {
    ref.onDispose(() {
      _pollTimer?.cancel();
    });

    return const OcrFlowState(step: OcrStep.idle);
  }

  Future<void> submitFile({required String filePath}) async {
    state = OcrFlowState(step: OcrStep.uploading, filePath: filePath);

    try {
      final submitJob = await ref
          .read(ocrRepositoryProvider)
          .submit(filePath: filePath);
      state = OcrFlowState(
        step: OcrStep.polling,
        submitJob: submitJob,
        filePath: filePath,
      );
      await _pollStatus(submitJob.jobId, startTimerIfPending: true);
    } on Failure catch (error) {
      state = OcrFlowState(
        step: OcrStep.idle,
        filePath: filePath,
        error: error,
      );
    } on Object catch (error, stackTrace) {
      final failure = Failure.unknown(message: error.toString());
      state = OcrFlowState(
        step: OcrStep.idle,
        filePath: filePath,
        error: failure,
      );
      Error.throwWithStackTrace(failure, stackTrace);
    }
  }

  Future<void> retryStatusCheck() async {
    final jobId = state.job?.jobId ?? state.submitJob?.jobId;
    if (jobId == null) {
      return;
    }

    state = state.copyWith(step: OcrStep.polling, clearError: true);
    await _pollStatus(jobId, startTimerIfPending: true);
  }

  void reset() {
    _pollTimer?.cancel();
    state = const OcrFlowState(step: OcrStep.idle);
  }

  void _startPolling(String jobId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _pollStatus(jobId),
    );
  }

  Future<void> _pollStatus(
    String jobId, {
    bool startTimerIfPending = false,
  }) async {
    try {
      final job = await ref.read(ocrRepositoryProvider).status(jobId: jobId);
      final nextStep = _stepFromStatus(job.status);
      state = state.copyWith(step: nextStep, job: job, clearError: true);

      if (job.status == OcrJobStatus.pending ||
          job.status == OcrJobStatus.running) {
        if (startTimerIfPending || _pollTimer?.isActive != true) {
          _startPolling(jobId);
        }
      } else {
        _pollTimer?.cancel();
      }
    } on Failure catch (error) {
      _pollTimer?.cancel();
      state = state.copyWith(step: OcrStep.polling, error: error);
    } on Object catch (error) {
      _pollTimer?.cancel();
      state = state.copyWith(
        step: OcrStep.polling,
        error: Failure.unknown(message: error.toString()),
      );
    }
  }
}

OcrStep _stepFromStatus(OcrJobStatus status) {
  return switch (status) {
    OcrJobStatus.pending || OcrJobStatus.running => OcrStep.polling,
    OcrJobStatus.completed => OcrStep.completed,
    OcrJobStatus.failed => OcrStep.failed,
  };
}
