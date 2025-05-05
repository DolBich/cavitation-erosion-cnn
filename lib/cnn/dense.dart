import 'dart:math';

import 'package:diplom/cnn/process.dart';

class DenseLayer {
  List<List<double>> weights;
  List<double> biases;
  List<double> lastInput = [];
  List<double> lastOutput = [];
  List<double> gradientsWrtInput = [];
  List<List<double>> weightGradients = [];
  List<double> biasGradients = [];

  DenseLayer({
    required this.weights,
    required this.biases,
  });

  // Фабричный метод для создания нового слоя
  factory DenseLayer.create(int inputSize, int outputSize, {bool isOutput = false}) {
    final stdDev = isOutput ? 1.0 / sqrt(inputSize) : sqrt(2.0 / inputSize);
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
    lastInput = List.from(input);

    List<double> output = List.filled(biases.length, 0.0);
    for (int j = 0; j < biases.length; j++) {
      output[j] = biases[j] + dotProduct(input, weights.map((w) => w[j]).toList());
    }

    lastOutput = List.from(output);
    return output;
  }

  double dotProduct(List<double> a, List<double> b) {
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      sum += a[i] * b[i];
    }
    return sum;
  }

  List<double> backward(List<double> gradOutput) {
    // Градиент по смещениям
    biasGradients = List.from(gradOutput);

    // Градиент по весам
    weightGradients = List.generate(
      weights.length,
          (i) => List.generate(
        weights[i].length,
            (j) => lastInput[i] * gradOutput[j],
      ),
    );

    // Градиент по входу (для передачи предыдущим слоям)
    gradientsWrtInput = List.filled(lastInput.length, 0.0);
    for (int i = 0; i < weights.length; i++) {
      for (int j = 0; j < weights[i].length; j++) {
        gradientsWrtInput[i] += weights[i][j] * gradOutput[j];
      }
    }

    return gradientsWrtInput;
  }

  void applyGradients(double learningRate) {
    // Обновляем веса
    for (int i = 0; i < weights.length; i++) {
      for (int j = 0; j < weights[i].length; j++) {
        weights[i][j] -= learningRate * weightGradients[i][j];
      }
    }

    // Обновляем смещения
    for (int j = 0; j < biases.length; j++) {
      biases[j] -= learningRate * biasGradients[j];
    }
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