import 'dart:math';

import 'package:diplom/cnn/norm_layer.dart';
import 'package:diplom/cnn/process.dart';

class ConvBlock {
  final List<ConvLayer> convLayers;
  final List<BatchNormLayer> batchNorms;
  final int poolSize;

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
      x = batchNorms[i].forward(x); // Добавляем BatchNorm
      x = relu(x);
    }
    return maxPool(x, poolSize);
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
      convLayers: (json['convLayers'] as List)
          .map((l) => ConvLayer.fromJson(l))
          .toList(),
      batchNorms: (json['batchNorms'] as List)
          .map((b) => BatchNormLayer.fromJson(b))
          .toList(),
      poolSize: json['poolSize'],
    );
  }
}

class ConvLayer {
  final List<List<List<List<double>>>> filters;
  final List<double> biases;
  final int kernelSize;
  final int padding;

  ConvLayer({
    required this.filters,
    required this.biases,
    required this.kernelSize,
    required this.padding,
  });

  factory ConvLayer.create(int inputChannels, int numFilters, {int kernelSize = 3, int padding = 0}) {
    final stddev = sqrt(2.0 / (inputChannels * kernelSize * kernelSize));

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
      biases: List.filled(numFilters, 0.0),
      kernelSize: kernelSize,
      padding: padding,
    );
  }

  List<List<List<double>>> forward(List<List<List<double>>> input) {
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
          .map((c) => (c as List)
          .map((r) => (r as List)
          .map((v) => (v as num).toDouble())
          .toList())
          .toList())
          .toList())
          .toList(),
      biases: (json['biases'] as List)
          .map((v) => (v as num).toDouble())
          .toList(),
      kernelSize: json['kernelSize'] as int,
      padding: json['padding'] as int,
    );
  }
}
