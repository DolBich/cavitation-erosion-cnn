part of 'app_bloc.dart';

class AppState with EquatableMixin {
  final int iteration;
  final bool isTraining;
  final TrainingConfig? trainingConfig;
  final List<TrainingSample> trainingData;
  final List<TestingSample> testData;
  final Either<Failure, Unit>? failureOrSuccessOption;
  final ErosionNet cnn;
  final double totalError;

  const AppState({
    required this.iteration,
    required this.isTraining,
    required this.trainingConfig,
    required this.trainingData,
    required this.testData,
    required this.failureOrSuccessOption,
    required this.cnn,
    required this.totalError,
  });

  factory AppState.initial(ErosionNet initialNet) {
    return AppState(
      iteration: 0,
      isTraining: false,
      trainingConfig: null,
      trainingData: [],
      testData: [],
      failureOrSuccessOption: null,
      cnn: initialNet,
      totalError: double.maxFinite,
    );
  }

  AppState copyWith({
    int? iteration,
    bool? isTraining,
    TrainingConfig? trainingConfig,
    List<TrainingSample>? trainingData,
    List<TestingSample>? testData,
    Either<Failure, Unit>? failureOrSuccessOption,
    ErosionNet? cnn,
    double? totalError,
  }) {
    return AppState(
      iteration: iteration ?? this.iteration,
      isTraining: isTraining ?? this.isTraining,
      trainingConfig: trainingConfig ?? this.trainingConfig,
      trainingData: trainingData ?? this.trainingData,
      testData: testData ?? this.testData,
      failureOrSuccessOption: failureOrSuccessOption,
      cnn: cnn ?? this.cnn,
      totalError: totalError ?? this.totalError,
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
        cnn,
        totalError,
      ];
}
