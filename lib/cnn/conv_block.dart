import 'dart:math';

import 'package:diplom/cnn/norm_layer.dart';
import 'package:diplom/cnn/process.dart';

class ConvBlock {
  late List<ConvLayer> convLayers;
  late List<BatchNormLayer> batchNorms;
  int inChannels;
  int outChannels;
  int kernelSize;
  int padding;
  int poolSize;

  ConvBlock(this.inChannels, this.outChannels, {this.kernelSize = 3, this.padding = 0, this.poolSize = 2}) {
    convLayers = [
      ConvLayer(inChannels, outChannels, kernelSize: kernelSize, padding: padding),
      ConvLayer(outChannels, outChannels, kernelSize: kernelSize, padding: padding)
    ];
    batchNorms = [
      BatchNormLayer(outChannels),
      BatchNormLayer(outChannels),
    ];
  }

  List<List<List<double>>> forward(List<List<List<double>>> input) {
    var x = input;
    for (int i = 0; i < convLayers.length; i++) {
      x = convLayers[i].forward(x);
      x = batchNorms[i].forward(x); // Добавляем BatchNorm
      x = relu(x);
    }
    return maxPool(x, poolSize);
  }
}

class ConvLayer {
  late List<List<List<List<double>>>> filters; // [numFilters][inputChannels][kH][kW]
  late List<double> biases;
  int kernelSize;
  int padding; // Новый параметр

  ConvLayer(int inputChannels, int numFilters, {this.kernelSize = 3, this.padding = 0}) {
    double stddev = sqrt(2.0 / (inputChannels * kernelSize * kernelSize));

    // Инициализация фильтров с учётом inputChannels
    filters = List.generate(
      numFilters,
          (f) => List.generate(
        inputChannels, // Каждый фильтр имеет inputChannels каналов
            (c) => List.generate(
          kernelSize,
              (i) => List.generate(
            kernelSize,
                (j) => GaussianRandom().nextGaussian() * stddev, // Веса от -1 до 1
          ),
        ),
      ),
    );
    biases = List.filled(numFilters, 0.0);
  }

  List<List<List<double>>> forward(List<List<List<double>>> input) {
    // Проверка совпадения количества каналов
    assert(input.length == filters[0].length,
    'Input channels (${input.length}) != filter channels (${filters[0].length})');

    List<List<List<double>>> paddedInput = _addPadding(input);

    int outputHeight = paddedInput[0].length - kernelSize + 1;
    int outputWidth = paddedInput[0][0].length - kernelSize + 1;
    assert(outputHeight > 0 && outputWidth > 0,
    'Некорректные размеры после свертки: ${outputHeight}x$outputWidth');


    List<List<List<double>>> output = List.generate(
      filters.length,
          (f) => List.generate(
        outputHeight,
            (i) => List.filled(outputWidth, 0.0),
      ),
    );

    // Проход по каждому фильтру
    for (int f = 0; f < filters.length; f++) {
      // Проход по каждому положению фильтра
      for (int i = 0; i < outputHeight; i++) {
        for (int j = 0; j < outputWidth; j++) {
          double sum = 0.0;

          // Суммирование по всем каналам и ядрам фильтра
          for (int c = 0; c < paddedInput.length; c++) { // inputChannels
            for (int di = 0; di < kernelSize; di++) {
              for (int dj = 0; dj < kernelSize; dj++) {
                sum += paddedInput[c][i + di][j + dj] * filters[f][c][di][dj];
              }
            }
          }

          output[f][i][j] = sum + biases[f];
        }
      }
    }
    return output;
  }

  List<List<List<double>>> _addPadding(List<List<List<double>>> input) {
    if (padding == 0) return input;

    return input.map((channel) {
      List<List<double>> paddedChannel = [];
      // int newHeight = channel.length + 2 * padding;
      int newWidth = channel[0].length + 2 * padding;

      // Верхний padding
      for (int i = 0; i < padding; i++) {
        paddedChannel.add(List.filled(newWidth, 0.0));
      }
      // Центральная часть
      for (int i = 0; i < channel.length; i++) {
        List<double> row = [];
        row.addAll(List.filled(padding, 0.0)); // Левый padding
        row.addAll(channel[i]);
        row.addAll(List.filled(padding, 0.0)); // Правый padding
        paddedChannel.add(row);
      }
      // Нижний padding
      for (int i = 0; i < padding; i++) {
        paddedChannel.add(List.filled(newWidth, 0.0));
      }
      return paddedChannel;
    }).toList();
  }
}