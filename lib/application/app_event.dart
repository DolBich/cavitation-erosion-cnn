
part of 'app_bloc.dart';

sealed class AppEvent {
  const AppEvent();

  const factory AppEvent.startTraining() = _StartTraining;

  const factory AppEvent.stopTraining() = _StopTraining;

  const factory AppEvent.pickTrainData(Either<Failure, List<Map<String, dynamic>>>? data) = _PickTrainData;

  const factory AppEvent.setTrainingConfig(Map<String, dynamic> config) = _SetTrainingConfig;

  const factory AppEvent.trainingEnded() = _TrainingEnded;

  const factory AppEvent.resetPerceptron() = _ResetPerceptron;

  const factory AppEvent.train({required List<double> errors, required List<double> results, required int iteration}) = _Train;

}

class _PickTrainData extends AppEvent {
  final Either<Failure, List<Map<String, dynamic>>>? data;
  const _PickTrainData(this.data);
}

class _StartTraining extends AppEvent {
  const _StartTraining();
}

class _StopTraining extends AppEvent {
  const _StopTraining();
}

class _SetTrainingConfig extends AppEvent {
  final Map<String, dynamic> config;
  const _SetTrainingConfig(this.config);
}

class _TrainingEnded extends AppEvent {
  const _TrainingEnded();
}

class _ResetPerceptron extends AppEvent {
  const _ResetPerceptron();
}

class _Train extends AppEvent {
  final List<double> errors;
  final List<double> results;
  final int iteration;
  const _Train({required this.errors, required this.results, required this.iteration});
}