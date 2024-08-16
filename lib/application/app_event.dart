
part of 'app_bloc.dart';

sealed class AppEvent {
  const AppEvent();

  const factory AppEvent.startTraining(Map<String, dynamic> config) = _StartTraining;

  const factory AppEvent.stopTraining() = _StopTraining;

  const factory AppEvent.pickTrainData(Either<Failure, List<Map<String, dynamic>>>? data) = _PickTrainData;

  const factory AppEvent.pickTestData(Either<Failure, List<Map<String, dynamic>>>? data) = _PickTestData;

  const factory AppEvent.trainingEnded() = _TrainingEnded;

  const factory AppEvent.resetPerceptron() = _ResetPerceptron;

  const factory AppEvent.train({required List<double> errors, required List<double> results}) = _Train;

  const factory AppEvent.testDone(List<double> results) = _TestDone;

}

class _PickTrainData extends AppEvent {
  final Either<Failure, List<Map<String, dynamic>>>? data;
  const _PickTrainData(this.data);
}

class _PickTestData extends AppEvent {
  final Either<Failure, List<Map<String, dynamic>>>? data;
  const _PickTestData(this.data);
}

class _StartTraining extends AppEvent {
  final Map<String, dynamic> config;
  const _StartTraining(this.config);
}

class _StopTraining extends AppEvent {
  const _StopTraining();
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

  const _Train({required this.errors, required this.results});
}

class _TestDone extends AppEvent {
  final List<double> results;

  const _TestDone(this.results);
}