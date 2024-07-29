part of 'app_bloc.dart';

class AppState with EquatableMixin {
  final int iteration;
  final bool isTraining;
  final ConfigModes? mode;
  final String? modeValue;
  final List<Map<String, dynamic>> trainingData;
  final List<Map<String, dynamic>> testData;
  final Either<Failure, Unit>? failureOrSuccessOption;
  final bool trainingEnded;
  final Perceptron perceptron;
  final List<double> errors;
  final List<double> results;

  const AppState({required this.iteration,
    required this.isTraining,
    required this.mode,
    required this.modeValue,
    required this.trainingData,
    required this.testData,
    required this.failureOrSuccessOption,
    required this.trainingEnded,
    required this.perceptron,
    required this.errors,
    required this.results,
  });


  factory AppState.initial(){
    return AppState(
        iteration: 0,
        isTraining: false,
        mode: null,
        modeValue: null,
        trainingData: [],
        testData: [],
        failureOrSuccessOption: null,
      trainingEnded: false,
        perceptron: appPerceptron,
      errors: [],
      results: [],
    );
  }

  AppState copyWith({
    int? iteration,
    bool? isTraining,
    ConfigModes? mode,
    String? modeValue,
    List<Map<String, dynamic>>? trainingData,
    List<Map<String, dynamic>>? testData,
    Either<Failure, Unit>? failureOrSuccessOption,
    bool? trainingEnded,
    Perceptron? perceptron,
    List<double>? errors,
    List<double>? results,
  }) {

    return AppState(
        iteration: iteration ?? this.iteration,
        isTraining: isTraining ?? this.isTraining,
        mode: mode ?? this.mode,
        modeValue: modeValue ?? this.modeValue,
        trainingData: trainingData ?? this.trainingData,
        testData: testData ?? this.testData,
        failureOrSuccessOption: failureOrSuccessOption,
        trainingEnded: trainingEnded ?? false,
      perceptron: perceptron ?? this.perceptron,
        errors: errors ?? this.errors,
        results: results ?? this.results
    );
  }

  List<TrainingData> get getTrainData {
    final List<Image> pictures = [];
    for(final tData in trainingData) {
      final picture = decodeImage(tData["image"]);
      if(picture != null) {
        pictures.add(picture);
      }
    }

    final List<TrainingData> data = List.generate(trainingData.length, (i) {
      // final image = trainingData[i]["image"] as Uint8List;
      final values = trainingData[i]["value"] as String;

      return TrainingData(
          List.generate(6000, (index) {
            // final List<double> source = [];
            // for(int i = 0; i < 6000; i++) {
            //   source.add(pictures[index].getPixel(i%120, i~/120).average);
            // }

            return pictures[i].getPixel(index%120, index~/120).average;
          }),
          List.generate(1, (index) { // TODO: заменить 1 на длину списка результатов
              return double.parse(values);
          }));
    });
    return data;
  }


  @override
  List<Object?> get props => [iteration, isTraining, mode, modeValue, trainingData, testData, failureOrSuccessOption, trainingEnded, perceptron, errors, results];
}
