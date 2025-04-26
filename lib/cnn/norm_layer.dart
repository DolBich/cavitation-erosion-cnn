import 'dart:math';

class BatchNormLayer {
  final List<double> gamma;
  final List<double> beta;
  final List<double> movingMean;
  final List<double> movingVariance;
  final double epsilon;

  BatchNormLayer({
    required this.gamma,
    required this.beta,
    required this.movingMean,
    required this.movingVariance,
    this.epsilon = 1e-5,
  });

  factory BatchNormLayer.create(int numChannels) {
    return BatchNormLayer(
      gamma: List.filled(numChannels, 1.0),
      beta: List.filled(numChannels, 0.0),
      movingMean: List.filled(numChannels, 0.0),
      movingVariance: List.filled(numChannels, 1.0),
    );
  }

  List<List<List<double>>> forward(List<List<List<double>>> x) {
    List<List<List<double>>> normalized = [];
    for (int c = 0; c < x.length; c++) {
      List<List<double>> channel = [];
      for (int h = 0; h < x[c].length; h++) {
        List<double> row = [];
        for (int w = 0; w < x[c][h].length; w++) {
          double mean = movingMean[c];
          double variance = movingVariance[c];
          double normalizedVal = (x[c][h][w] - mean) / sqrt(variance + epsilon);
          row.add(gamma[c] * normalizedVal + beta[c]);
        }
        channel.add(row);
      }
      normalized.add(channel);
    }
    return normalized;
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