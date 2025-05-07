import 'dart:math';

import 'package:diplom/cnn/erosion_net.dart';
import 'package:diplom/main.dart';
import 'package:image/image.dart';

class MSELossWithPenalty {
  double forward(double prediction, double target) {
    final mse = pow(prediction - target, 2);
    final penalty = _calculatePenalty(prediction);
    return mse + penalty;
  }

  double backward(double prediction, double target) {
    final gradMSE = 2 * (prediction - target);
    final gradPenalty = _penaltyDerivative(prediction);
    return gradMSE + gradPenalty;
  }

  double _calculatePenalty(double x) {
    // Штрафуем значения вне диапазона
    if (x < 0) return pow(x, 2) * 10;
    if (x > 100) return pow(x - 100, 2) * 10;
    return 0.0;
  }

  double _penaltyDerivative(double x) {
    if (x < 0) return 2 * x * 10;
    if (x > 100) return 2 * (x - 100) * 10;
    return 0.0;
  }
}


class Trainer {
  final ErosionNet model;
  final double learningRate;
  final loss = MSELossWithPenalty();
  final int batchSize = 16;

  Trainer(this.model, {this.learningRate = TRAIN_SPEED});

  void trainStep(Image image, double target) {
    double prediction = 0;
    try {
      prediction = model.forward(image);
    } catch (e, stackTrace) {
      print('[Trainer.trainStep] Ошибка в прямом проходе: $e');
      print(stackTrace);
      rethrow;
    }

    double grad = loss.backward(prediction, target);
    try {
      grad = loss.backward(prediction, target);
    } catch (e, stackTrace) {
      print('[Trainer.trainStep] Ошибка в обратном проходе: $e');
      print(stackTrace);
      rethrow;
    }

    final clippedGrad = grad.clamp(-1.0, 1.0);
    model.backward(clippedGrad, learningRate);
  }
}