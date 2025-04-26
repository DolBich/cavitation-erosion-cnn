import 'dart:math';

class BatchNormLayer {
  late List<double> gamma;
  late List<double> beta;
  late List<double> movingMean;
  late List<double> movingVariance;
  double epsilon;

  BatchNormLayer(int numChannels, {this.epsilon = 1e-5}) {
    gamma = List.filled(numChannels, 1.0);
    beta = List.filled(numChannels, 0.0);
    movingMean = List.filled(numChannels, 0.0);
    movingVariance = List.filled(numChannels, 1.0);
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
}