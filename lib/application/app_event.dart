part of 'app_bloc.dart';

sealed class AppEvent {
  const AppEvent();

  const factory AppEvent.stopTraining({Failure? withFailure}) = _StopTraining;

  const factory AppEvent.pickTrainData() = _PickTrainData;

  const factory AppEvent.pickTestData() = _PickTestData;

  const factory AppEvent.trainingEnded() = _TrainingEnded;

  const factory AppEvent.resetCNN({ErosionNet? net}) = _ResetCNN;

  const factory AppEvent.trainStarted(TrainingConfig config) = _TrainingStarted;

  const factory AppEvent.updateTrainingSample({
    required UuidV4 id,
    required double predictedCoefficient,
    required double error,
  }) = _UpdateTrainingSample;

  const factory AppEvent.updateTestingSample({
    required UuidV4 id,
    required double predictedCoefficient,
  }) = _UpdateTestingSample;

  const factory AppEvent.epochDone() = _EpochDone;

  const factory AppEvent.failure({required Failure failure}) = _Failure;

  const factory AppEvent.updateTotalError(double error) = _UpdateTotalError;

}

class _UpdateTotalError extends AppEvent {
  final double error;

  const _UpdateTotalError(this.error);
}

class _Failure extends AppEvent {
  final Failure failure;

  const _Failure({required this.failure});
}

class _EpochDone extends AppEvent {
  const _EpochDone();
}


class _UpdateTestingSample extends AppEvent {
  final UuidV4 id;
  final double predictedCoefficient;

  const _UpdateTestingSample({
    required this.id,
    required this.predictedCoefficient,
  });
}


class _UpdateTrainingSample extends AppEvent {
  final UuidV4 id;
  final double predictedCoefficient;
  final double? error;

  const _UpdateTrainingSample({
    required this.id,
    required this.predictedCoefficient,
    this.error,
  });
}

class _PickTrainData extends AppEvent {
  const _PickTrainData();
}

class _PickTestData extends AppEvent {
  const _PickTestData();
}

class _TrainingStarted extends AppEvent {
  final TrainingConfig config;

  const _TrainingStarted(this.config);
}

class _StopTraining extends AppEvent {
  final Failure? withFailure;

  const _StopTraining({this.withFailure});
}

class _TrainingEnded extends AppEvent {
  const _TrainingEnded();
}

class _ResetCNN extends AppEvent {
  final ErosionNet? net;
  const _ResetCNN({this.net});
}
