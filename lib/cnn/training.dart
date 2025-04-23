import 'dart:math';

import 'package:image/image.dart';

import 'dense.dart';
import 'erosion_net.dart';

void train(List<Image> images, List<double> labels) {
  var net = ErosionNet();
  double lr = 0.001;

  for (int epoch = 0; epoch < 100; epoch++) {
    double totalLoss = 0;

    for (int i = 0; i < images.length; i++) {
      // Прямой проход
      double prediction = net.forward(images[i]);
      double error = prediction - labels[i];

      // Обратное распространение (упрощённо)
      var gradients = calculateGradients(net, error);
      updateWeights(net, gradients, lr);

      totalLoss += pow(error, 2);
    }

    print('Epoch ${epoch+1}, MSE: ${totalLoss / images.length}');
  }
}

List<List<List<double>>> calculateGradients(ErosionNet net, double error) {
  List<List<List<double>>> gradients = [];

  // Градиенты для последнего DenseLayer
  DenseLayer lastLayer = net.denseLayers.last;
  List<List<double>> lastWeightsGrad = [];
  List<double> lastBiasesGrad = [];

  // Вход последнего слоя (предположим, что он сохранён)
  List<double> lastLayerInput = lastLayer.lastInput;

  for (int i = 0; i < lastLayer.weights.length; i++) {
    List<double> neuronGrads = [];
    for (int j = 0; j < lastLayer.weights[i].length; j++) {
      // Градиент весов: dL/dw = error * вход нейрона
      neuronGrads.add(error * lastLayerInput[i]);
    }
    lastWeightsGrad.add(neuronGrads);
  }

  // Градиент смещений: dL/db = error
  lastBiasesGrad = List.filled(lastLayer.biases.length, error);

  gradients.add(lastWeightsGrad); // Градиенты весов
  gradients.add([lastBiasesGrad]); // Градиенты смещений

  return gradients;
}

void updateWeights(ErosionNet net, List<List<List<double>>> gradients, double lr) {
  // Обновление последнего DenseLayer
  DenseLayer lastLayer = net.denseLayers.last;

  // Градиенты весов и смещений
  List<List<double>> weightGradients = gradients[0];
  List<double> biasGradients = gradients[1][0];

  // Обновление весов
  for (int i = 0; i < lastLayer.weights.length; i++) {
    for (int j = 0; j < lastLayer.weights[i].length; j++) {
      lastLayer.weights[i][j] -= lr * weightGradients[i][j];
    }
  }

  // Обновление смещений
  for (int j = 0; j < lastLayer.biases.length; j++) {
    lastLayer.biases[j] -= lr * biasGradients[j];
  }
}