import 'dart:math';

import 'package:diplom/cnn/process.dart';

class DenseLayer {
  late List<List<double>> weights; // [inputSize, outputSize]
  late List<double> biases;        // [outputSize]
  int inputSize;
  int outputSize;
  late List<double> lastInput;

  DenseLayer(this.inputSize, this.outputSize) {
    // Инициализация весов (метод He)
    double stdDev = sqrt(2.0 / inputSize);
    weights = List.generate(
      inputSize,
          (i) => List.generate(
        outputSize,
            (j) => GaussianRandom().nextGaussian() * stdDev,
      ),
    );
    biases = List.filled(outputSize, 0.0);
  }

  List<double> forward(List<double> input) {
    // assert(input.length == inputSize,
    // 'Неверный размер входа: ${input.length} != $inputSize');

    lastInput = List.from(input);
    List<double> output = List.filled(outputSize, 0.0);

    for (int j = 0; j < outputSize; j++) {
      double sum = biases[j];
      for (int i = 0; i < inputSize; i++) {
        sum += input[i] * weights[i][j];
      }
      output[j] = sum;
    }

    return output;
  }
}