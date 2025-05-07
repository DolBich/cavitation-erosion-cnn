import 'dart:math';

class BatchNormLayer {
  List<double> gamma;
  List<double> beta;
  List<double> movingMean;
  List<double> movingVariance;
  double epsilon;
  bool isTraining = false;

  List<double>? batchMean;
  List<double>? batchVar;
  List<List<List<double>>>? lastInput;

  BatchNormLayer({
    required this.gamma,
    required this.beta,
    required this.movingMean,
    required this.movingVariance,
    this.epsilon = 1e-5,
  });

  factory BatchNormLayer.create(int numChannels) {
    // print('[BatchNorm.create] Инициализация для $numChannels каналов');
    return BatchNormLayer(
      gamma: List.filled(numChannels, 1.0),
      beta: List.filled(numChannels, 0.0),
      movingMean: List.filled(numChannels, 0.0),
      movingVariance: List.filled(numChannels, 1.0),
    );
  }

  List<List<List<double>>> forward(List<List<List<double>>> x) {
    // print('[BatchNorm.forward] Channels: ${x.length}');
    lastInput = x;

    if (isTraining) {
      // print('[BatchNorm.forward] Режим обучения');
      batchMean = List.filled(x.length, 0.0);
      batchVar = List.filled(x.length, 0.0);

      for (int c = 0; c < x.length; c++) {
        double sum = 0.0;
        double sumSq = 0.0;
        int count = x[c].length * x[c][0].length;

        for (int h = 0; h < x[c].length; h++) {
          for (int w = 0; w < x[c][h].length; w++) {
            sum += x[c][h][w];
            sumSq += pow(x[c][h][w], 2);
          }
        }

        batchMean![c] = sum / count;
        batchVar![c] = (sumSq / count) - pow(batchMean![c], 2);

        movingMean[c] = 0.9 * movingMean[c] + 0.1 * batchMean![c];
        movingVariance[c] = 0.9 * movingVariance[c] + 0.1 * batchVar![c];
      }
    } else {
      // print('[BatchNorm.forward] Режим инференса');
    }

    return _normalize(x);
  }

  List<List<List<double>>> _normalize(List<List<List<double>>> x) {
    List<List<List<double>>> normalized = [];

    for (int c = 0; c < x.length; c++) {
      double mean = isTraining ? batchMean![c] : movingMean[c];
      double variance = isTraining ? batchVar![c] : movingVariance[c];
      double stdDev = sqrt(variance + epsilon);

      List<List<double>> channel = [];
      for (int h = 0; h < x[c].length; h++) {
        List<double> row = [];
        for (int w = 0; w < x[c][h].length; w++) {
          double normalizedVal = (x[c][h][w] - mean) / stdDev;
          row.add(gamma[c] * normalizedVal + beta[c]);
        }
        channel.add(row);
      }
      normalized.add(channel);
    }

    return normalized;
  }

  List<List<List<double>>> backward(List<List<List<double>>> gradOutput, double learningRate) {
    // print('[BatchNorm.backward] Начало, lr=$learningRate');
    assert(isTraining && batchMean != null && lastInput != null);

    List<List<List<double>>> gradInput = List.generate(
      lastInput!.length,
          (c) => List.generate(
        lastInput![c].length,
            (h) => List.filled(lastInput![c][h].length, 0.0),
      ),
    );

    List<double> gradGamma = List.filled(gamma.length, 0.0);
    List<double> gradBeta = List.filled(beta.length, 0.0);

    for (int c = 0; c < gradOutput.length; c++) {
      double stdDev = sqrt(batchVar![c] + epsilon);

      for (int h = 0; h < gradOutput[c].length; h++) {
        for (int w = 0; w < gradOutput[c][h].length; w++) {
          double xCentered = lastInput![c][h][w] - batchMean![c];
          gradGamma[c] += gradOutput[c][h][w] * xCentered / stdDev;
          gradBeta[c] += gradOutput[c][h][w];
        }
      }

      for (int c = 0; c < gradOutput.length; c++) {
        int n = gradOutput[c].length * gradOutput[c][0].length;

        // Усреднение градиентов
        gradGamma[c] /= n;
        gradBeta[c] /= n;

        gamma[c] -= learningRate * gradGamma[c];
        beta[c] -= learningRate * gradBeta[c];
      }
    }

    // print('[BatchNorm.backward] Градиенты gamma: ${gradGamma.sublist(0, 3).map((v) => v.toStringAsFixed(4))}');
    // print('[BatchNorm.backward] Градиенты beta: ${gradBeta.sublist(0, 3).map((v) => v.toStringAsFixed(4))}');
    // print('[BatchNorm.backward] Обновленные gamma: ${gamma.sublist(0, 3).map((v) => v.toStringAsFixed(4))}');
    // print('[BatchNorm.backward] Обновленные beta: ${beta.sublist(0, 3).map((v) => v.toStringAsFixed(4))}');

    return gradInput;
  }

  Map<String, dynamic> toJson() {
    return {
      'gamma': gamma,
      'beta': beta,
      'movingMean': movingMean,
      'movingVariance': movingVariance,
      'epsilon': epsilon,
    };
  }

  factory BatchNormLayer.fromJson(Map<String, dynamic> json) {
    return BatchNormLayer(
      gamma: (json['gamma'] as List).map((v) => (v as num).toDouble()).toList(),
      beta: (json['beta'] as List).map((v) => (v as num).toDouble()).toList(),
      movingMean: (json['movingMean'] as List).map((v) => (v as num).toDouble()).toList(),
      movingVariance: (json['movingVariance'] as List).map((v) => (v as num).toDouble()).toList(),
      epsilon: json['epsilon'] ?? 1e-5,
    );
  }
}