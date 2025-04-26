part of 'app_bloc.dart';

sealed class AppEvent {
  const AppEvent();

  const factory AppEvent.stopTraining({Failure? withFailure}) = _StopTraining;

  const factory AppEvent.pickTrainData() = _PickTrainData;

  const factory AppEvent.pickTestData() = _PickTestData;

  const factory AppEvent.trainingEnded() = _TrainingEnded;

  const factory AppEvent.resetCNN() = _ResetCNN;

  const factory AppEvent.train({required List<double> errors, required List<double> results}) = _Train;

  const factory AppEvent.testDone(List<double> results) = _TestDone;

  const factory AppEvent.trainStarted(TrainingConfig config) = _TrainingStarted;

  const factory AppEvent.updateSample({
    required UuidV4 id,
    required double predictedCoefficient,
    double? error,
  }) = _UpdateSample;

  const factory AppEvent.epochDone() = _EpochDone;

  const factory AppEvent.failureInTest({required Failure withFailure}) = _FailureInTest;

}

class _FailureInTest extends AppEvent {
  final Failure withFailure;

  const _FailureInTest({required this.withFailure});
}

class _EpochDone extends AppEvent {
  const _EpochDone();
}

class _UpdateSample extends AppEvent {
  final UuidV4 id;
  final double predictedCoefficient;
  final double? error;

  const _UpdateSample({
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
  const _ResetCNN();
}

class _Train extends AppEvent {
  final List<double> errors;
  final List<double> results;

  const _Train({required this.errors, required this.results});
}

class _TestDone extends AppEvent {
  final List<double> results;

  const _TestDone(this.results);
}
