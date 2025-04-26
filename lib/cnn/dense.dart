import 'dart:math';

import 'package:diplom/cnn/process.dart';

class DenseLayer {
  final List<List<double>> weights;
  final List<double> biases;
  List<double> lastInput = []; // Для обратного прохода (не сериализуется!)

  DenseLayer({
    required this.weights,
    required this.biases,
  });

  // Фабричный метод для создания нового слоя
  factory DenseLayer.create(int inputSize, int outputSize) {
    final stdDev = sqrt(2.0 / inputSize);
    return DenseLayer(
      weights: List.generate(
        inputSize,
            (i) => List.generate(
          outputSize,
              (j) => GaussianRandom().nextGaussian() * stdDev,
        ),
      ),
      biases: List.filled(outputSize, 0.0),
    );
  }

  List<double> forward(List<double> input) {
    lastInput = List.from(input); // Сохраняем вход для обратного прохода
    List<double> output = List.filled(biases.length, 0.0);

    for (int j = 0; j < biases.length; j++) {
      output[j] = biases[j];
      for (int i = 0; i < input.length; i++) {
        output[j] += input[i] * weights[i][j];
      }
    }

    return output;
  }

  // Сериализация
  Map<String, dynamic> toJson() {
    return {
      'weights': weights,
      'biases': biases,
    };
  }

  // Десериализация
  factory DenseLayer.fromJson(Map<String, dynamic> json) {
    return DenseLayer(
      weights: (json['weights'] as List)
          .map((w) => (w as List).map((v) => (v as num).toDouble()).toList())
          .toList(),
      biases: (json['biases'] as List).map((v) => (v as num).toDouble()).toList(),
    );
  }
}