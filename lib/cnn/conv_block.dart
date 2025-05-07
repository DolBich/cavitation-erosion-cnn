import 'dart:math';

import 'package:diplom/cnn/norm_layer.dart';
import 'package:diplom/cnn/process.dart';

class ConvBlock {
  final List<ConvLayer> convLayers;
  final List<BatchNormLayer> batchNorms;
  final int poolSize;
  List<List<List<double>>>? lastPoolInput;
  List<List<List<double>>>? lastPrePoolOutput;

  ConvBlock({
    required this.convLayers,
    required this.batchNorms,
    required this.poolSize,
  });

  factory ConvBlock.create(int inChannels, int outChannels, {int kernelSize = 3, int padding = 0, int poolSize = 2}) {
    return ConvBlock(
      convLayers: [
        ConvLayer.create(inChannels, outChannels, kernelSize: kernelSize, padding: padding),
        ConvLayer.create(outChannels, outChannels, kernelSize: kernelSize, padding: padding),
      ],
      batchNorms: [
        BatchNormLayer.create(outChannels),
        BatchNormLayer.create(outChannels),
      ],
      poolSize: poolSize,
    );
  }

  List<List<List<double>>> forward(List<List<List<double>>> input) {
    var x = input;
    for (int i = 0; i < convLayers.length; i++) {
      x = convLayers[i].forward(x);
      // print('[ConvBlock] Conv ${i+1} output range: [${_min3D(x)}, ${_max3D(x)}]');

      x = batchNorms[i].forward(x);
      // print('[ConvBlock] BN ${i+1} output range: [${_min3D(x)}, ${_max3D(x)}]');

      x = leakyRelu(x);
      // print('[ConvBlock] ReLU ${i+1} output range: [${_min3D(x)}, ${_max3D(x)}]');
    }
    lastPrePoolOutput = x;
    return maxPool(x, poolSize);
  }

  List<List<List<double>>> backward(List<List<List<double>>> gradOutput, double learningRate) {
    // Исправленный вызов с 3 аргументами
    var gradBeforePool = maxPoolBackward(gradOutput, lastPrePoolOutput!, poolSize);

    for (int i = convLayers.length-1; i >= 0; i--) {
      gradBeforePool = reluBackward(gradBeforePool, batchNorms[i].lastInput!);
      gradBeforePool = batchNorms[i].backward(gradBeforePool, learningRate);
      gradBeforePool = convLayers[i].backward(gradBeforePool, learningRate);
    }

    return gradBeforePool;
  }

  List<List<List<double>>> maxPoolBackward(
      List<List<List<double>>> gradOutput,
      List<List<List<double>>> originalInput,
      int poolSize, // Добавляем poolSize как параметр
      ) {
    List<List<List<double>>> gradInput = List.generate(
      originalInput.length,
          (c) => List.generate(
        originalInput[c].length,
            (h) => List.filled(originalInput[c][h].length, 0.0),
      ),
    );

    for (int c = 0; c < gradOutput.length; c++) {
      for (int i = 0; i < gradOutput[c].length; i++) {
        for (int j = 0; j < gradOutput[c][i].length; j++) {
          double maxVal = double.negativeInfinity;
          int maxH = i * poolSize;
          int maxW = j * poolSize;

          // Находим позицию максимума в оригинальном входе
          for (int di = 0; di < poolSize; di++) {
            for (int dj = 0; dj < poolSize; dj++) {
              int h = i * poolSize + di;
              int w = j * poolSize + dj;
              if (h < originalInput[c].length &&
                  w < originalInput[c][h].length &&
                  originalInput[c][h][w] > maxVal) {
                maxVal = originalInput[c][h][w];
                maxH = h;
                maxW = w;
              }
            }
          }

          // Передаем градиент только в позицию максимума
          gradInput[c][maxH][maxW] += gradOutput[c][i][j];
        }
      }
    }

    return gradInput;
  }

  Map<String, dynamic> toJson() {
    return {
      'convLayers': convLayers.map((l) => l.toJson()).toList(),
      'batchNorms': batchNorms.map((b) => b.toJson()).toList(),
      'poolSize': poolSize,
    };
  }

  factory ConvBlock.fromJson(Map<String, dynamic> json) {
    return ConvBlock(
      convLayers: (json['convLayers'] as List).map((l) => ConvLayer.fromJson(l)).toList(),
      batchNorms: (json['batchNorms'] as List).map((b) => BatchNormLayer.fromJson(b)).toList(),
      poolSize: json['poolSize'],
    );
  }

  /// Логирование
  double _min3D(List<List<List<double>>> tensor) {
    if (tensor.isEmpty || tensor[0].isEmpty || tensor[0][0].isEmpty) return 0.0;

    double minVal = double.infinity;
    for (var channel in tensor) {
      for (var row in channel) {
        final currentMin = row.reduce((a, b) => a < b ? a : b);
        if (currentMin < minVal) minVal = currentMin;
      }
    }
    return minVal;
  }

  double _max3D(List<List<List<double>>> tensor) {
    if (tensor.isEmpty || tensor[0].isEmpty || tensor[0][0].isEmpty) return 0.0;

    double maxVal = -double.infinity;
    for (var channel in tensor) {
      for (var row in channel) {
        final currentMax = row.reduce((a, b) => a > b ? a : b);
        if (currentMax > maxVal) maxVal = currentMax;
      }
    }
    return maxVal;
  }
}

class ConvLayer {
  final List<List<List<List<double>>>> filters;
  final List<double> biases;
  final int kernelSize;
  final int padding;
  List<List<List<double>>>? lastInput;
  List<List<List<double>>>? lastOutput;

  List<List<List<List<double>>>>? weightGradients;

  ConvLayer({
    required this.filters,
    required this.biases,
    required this.kernelSize,
    required this.padding,
  });

  factory ConvLayer.create(int inputChannels, int numFilters, {int kernelSize = 3, int padding = 0}) {
    final stddev = sqrt(2.0 / (inputChannels * kernelSize * kernelSize + numFilters));

    final filters = List.generate(
      numFilters,
      (f) => List.generate(
        inputChannels,
        (c) => List.generate(
          kernelSize,
          (i) => List.generate(
            kernelSize,
            (j) => GaussianRandom().nextGaussian() * stddev,
          ),
        ),
      ),
    );

    return ConvLayer(
      filters: filters,
      biases: List.generate(numFilters, (i) => GaussianRandom().nextGaussian() * 0.1),
      kernelSize: kernelSize,
      padding: padding,
    );
  }

  List<List<List<double>>> forward(List<List<List<double>>> input) {
    lastInput = input;
    // Проверка совпадения количества каналов
    assert(input.length == filters[0].length,
        'Input channels (${input.length}) != filter channels (${filters[0].length})');

    List<List<List<double>>> paddedInput = _addPadding(input);

    int outputHeight = paddedInput[0].length - kernelSize + 1;
    int outputWidth = paddedInput[0][0].length - kernelSize + 1;
    assert(outputHeight > 0 && outputWidth > 0, 'Некорректные размеры после свертки: ${outputHeight}x$outputWidth');

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
          for (int c = 0; c < paddedInput.length; c++) {
            // inputChannels
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
    lastOutput = output;
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

  List<List<List<double>>> backward(List<List<List<double>>> gradOutput, double learningRate) {
    // Инициализация градиента входа
    List<List<List<double>>> gradInput = List.generate(
      lastInput!.length,
          (c) => List.generate(
        lastInput![c].length,
            (h) => List.filled(lastInput![c][h].length, 0.0),
      ),
    );

    // Инициализация градиентов весов
    List<List<List<List<double>>>> weightGradients = List.generate(
      filters.length,
          (f) => List.generate(
        filters[f].length,
            (c) => List.generate(
          kernelSize,
              (i) => List.filled(kernelSize, 0.0),
        ),
      ),
    );

    try {
      // Расчет градиентов для фильтров
      for (int f = 0; f < filters.length; f++) {
        final outputHeight = gradOutput[f].length;
        final outputWidth = gradOutput[f][0].length;

        for (int c = 0; c < filters[f].length; c++) {
          for (int di = 0; di < kernelSize; di++) {
            for (int dj = 0; dj < kernelSize; dj++) {
              double sum = 0.0;

              for (int i = 0; i < outputHeight; i++) {
                for (int j = 0; j < outputWidth; j++) {
                  final inputRow = i + di;
                  final inputCol = j + dj;

                  if (inputRow < lastInput![c].length &&
                      inputCol < lastInput![c][inputRow].length) {
                    sum += lastInput![c][inputRow][inputCol] * gradOutput[f][i][j];
                  }
                }
              }

              final outputSize = outputHeight * outputWidth;
              weightGradients[f][c][di][dj] = sum / outputSize;

              // Обновление весов
              filters[f][c][di][dj] -= learningRate * weightGradients[f][c][di][dj];
            }
          }
        }
      }

      // Логирование градиентов
      // _logGradients(weightGradients, learningRate);

    } catch (e, stackTrace) {
      print('[ConvLayer.backward] Ошибка: $e');
      print(stackTrace);
      rethrow;
    }

    return gradInput;
  }

  void _logGradients(List<List<List<List<double>>>> weightGradients, double learningRate) {
    try {
      // Поиск максимального градиента
      double maxGrad = double.negativeInfinity;
      for (var f in weightGradients) {
        for (var c in f) {
          for (var row in c) {
            for (var val in row) {
              if (val > maxGrad) maxGrad = val;
            }
          }
        }
      }

      // Логирование только если есть значения
      if (maxGrad != double.negativeInfinity) {
        print('[ConvLayer.backward] Макс. градиент весов: ${maxGrad.toStringAsFixed(6)}');
      }

      // Логирование первого веса
      if (filters.isNotEmpty &&
          filters[0].isNotEmpty &&
          filters[0][0].isNotEmpty &&
          filters[0][0][0].isNotEmpty) {
        print('[ConvLayer.backward] Пример веса до: ${filters[0][0][0][0].toStringAsFixed(4)}');
        print('[ConvLayer.backward] Пример веса после: ${(filters[0][0][0][0] - learningRate * weightGradients[0][0][0][0]).toStringAsFixed(4)}');
      }
    } catch (e) {
      print('[ConvLayer.backward] Ошибка логирования: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'filters': filters,
      'biases': biases,
      'kernelSize': kernelSize,
      'padding': padding,
    };
  }

  factory ConvLayer.fromJson(Map<String, dynamic> json) {
    return ConvLayer(
      filters: (json['filters'] as List)
          .map((f) => (f as List)
              .map((c) => (c as List).map((r) => (r as List).map((v) => (v as num).toDouble()).toList()).toList())
              .toList())
          .toList(),
      biases: (json['biases'] as List).map((v) => (v as num).toDouble()).toList(),
      kernelSize: json['kernelSize'] as int,
      padding: json['padding'] as int,
    );
  }
}
