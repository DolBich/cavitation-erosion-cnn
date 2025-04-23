part of 'app_bloc.dart';

class AppState with EquatableMixin {
  final int iteration;
  final bool isTraining;
  final TrainingConfig? trainingConfig;
  final List<TrainingSample> trainingData;
  final List<TestingSample> testData;
  final Either<Failure, Unit>? failureOrSuccessOption;
  final bool trainingEnded;
  final List<double> errors;
  final List<double> results;
  final List<double> testResults;
  final ErosionNet cnn;

  const AppState({
    required this.iteration,
    required this.isTraining,
    required this.trainingConfig,
    required this.trainingData,
    required this.testData,
    required this.failureOrSuccessOption,
    required this.trainingEnded,
    required this.errors,
    required this.results,
    required this.testResults,
    required this.cnn,
  });

  factory AppState.initial() {
    return AppState(
      iteration: 0,
      isTraining: false,
      trainingConfig: null,
      trainingData: [],
      testData: [],
      failureOrSuccessOption: null,
      trainingEnded: false,
      errors: [],
      results: [],
      testResults: [],
      cnn: ErosionNet(),
    );
  }

  AppState copyWith({
    int? iteration,
    bool? isTraining,
    TrainingConfig? trainingConfig,
    List<TrainingSample>? trainingData,
    List<TestingSample>? testData,
    Either<Failure, Unit>? failureOrSuccessOption,
    bool? trainingEnded,
    List<double>? errors,
    List<double>? results,
    List<double>? testResults,
    ErosionNet? cnn,
  }) {
    return AppState(
      iteration: iteration ?? this.iteration,
      isTraining: isTraining ?? this.isTraining,
      trainingConfig: trainingConfig ?? this.trainingConfig,
      trainingData: trainingData ?? this.trainingData,
      testData: testData ?? this.testData,
      failureOrSuccessOption: failureOrSuccessOption,
      trainingEnded: trainingEnded ?? false,
      errors: errors ?? this.errors,
      results: results ?? this.results,
      testResults: testResults ?? this.testResults,
      cnn: cnn ?? this.cnn,
    );
  }

  @override
  List<Object?> get props => [
        iteration,
        isTraining,
        trainingConfig,
        trainingData,
        testData,
        failureOrSuccessOption,
        trainingEnded,
        errors,
        results,
        testResults,
        cnn,
      ];
}
