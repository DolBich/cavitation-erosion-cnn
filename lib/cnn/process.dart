import 'dart:math';

List<List<List<double>>> leakyRelu(List<List<List<double>>> x, {double alpha = 0.01}) {
  return x.map((channel) => channel.map((row) => row.map(
          (v) => v > 0 ? v : alpha * v
  ).toList()).toList()).toList();
}

List<List<List<double>>> reluBackward(
    List<List<List<double>>> gradOutput,
    List<List<List<double>>> preReluInput,
    ) {
  return List.generate(preReluInput.length, (c) {
    return List.generate(preReluInput[c].length, (h) {
      return List.generate(preReluInput[c][h].length, (w) {
        // Градиент проходит только там, где вход был > 0
        return preReluInput[c][h][w] > 0 ? gradOutput[c][h][w] : 0.0;
      });
    });
  });
}

List<List<List<double>>> maxPool(List<List<List<double>>> input, int poolSize) {
  int channels = input.length;
  int newH = input[0].length ~/ poolSize;
  int newW = input[0][0].length ~/ poolSize;

  return List.generate(channels, (c) {
    return List.generate(newH, (i) {
      return List.generate(newW, (j) {
        double maxVal = double.negativeInfinity;
        for (int di = 0; di < poolSize; di++) {
          for (int dj = 0; dj < poolSize; dj++) {
            maxVal = max(maxVal, input[c][i * poolSize + di][j * poolSize + dj]);
          }
        }
        return maxVal;
      });
    });
  });
}

List<double> flatten(List<List<List<double>>> tensor) {
  return tensor.expand((channel) => channel.expand((row) => row).toList()).toList();
}

class GaussianRandom {
  final Random _random = Random();
  double? _next;

  double nextGaussian() {
    if (_next != null) {
      final result = _next!;
      _next = null;
      return result;
    }

    double u, v, s;
    do {
      u = _random.nextDouble() * 2 - 1;
      v = _random.nextDouble() * 2 - 1;
      s = u * u + v * v;
    } while (s >= 1 || s == 0);

    final mul = sqrt(-2 * log(s) / s);
    _next = v * mul;
    return u * mul;
  }
}

double sigmoid(double x) {
  return 1.0 / (1.0 + exp(-x));
}

double sigmoidDerivative(double x) {
  final s = sigmoid(x);
  return s * (1 - s);
}
