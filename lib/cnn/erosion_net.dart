
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:diplom/cnn/conv_block.dart';
import 'package:diplom/cnn/dense.dart';
import 'package:diplom/cnn/preprocess.dart';
import 'package:diplom/cnn/process.dart';
import 'package:image/image.dart';

class ErosionNet {
  late List<ConvBlock> convBlocks;
  late List<DenseLayer> denseLayers;
  List<List<List<double>>>? lastConvOutput;
  List<double>? lastDenseOutput;
  List<int> lastConvShape = [];
  List<double>? lastRawOutput; // Выход ДО активации
  List<double>? lastActivatedOutput;

  ErosionNet({List<ConvBlock>? convBlocks, List<DenseLayer>? denseLayers}) {
    this.convBlocks = convBlocks ?? [
      ConvBlock.create(1, 16, kernelSize: 3, padding: 1, poolSize: 2),
      ConvBlock.create(16, 32, padding: 1, poolSize: 2),
      ConvBlock.create(32, 64, poolSize: 2),
    ];

    this.denseLayers = denseLayers ?? [
      DenseLayer.create(64 * 14 * 14, 128),
      DenseLayer.create(128, 1, isOutput: true),
    ];
  }

  double forward(Image image) {
    var tensor = preprocess(image);
    // print('[ErosionNet.forward] Входные данные после препроцессинга: min=${_min3D(tensor)}, max=${_max3D(tensor)}');

    for (var block in convBlocks) {
      tensor = block.forward(tensor);
    }

    lastConvOutput = tensor;
    lastConvShape = [tensor.length, tensor[0].length, tensor[0][0].length];


    var vector = flatten(tensor);

    for (var layer in denseLayers) {
      vector = layer.forward(vector);
    }

    lastRawOutput = List.from(vector);
    final activated = sigmoid(vector[0]);
    lastActivatedOutput = [activated * 100];

    return lastActivatedOutput![0];
  }

  void backward(double gradOutput, double learningRate) {
    final raw = lastRawOutput![0];
    final derivative = sigmoid(raw) * (1 - sigmoid(raw));
    List<double> grad = [gradOutput * derivative * 100];

    for (int i = denseLayers.length-1; i >= 0; i--) {
      grad = denseLayers[i].backward(grad);
      denseLayers[i].applyGradients(learningRate);
    }

    var gradTensor = unflattenGrad(grad, lastConvShape);

    for (int i = convBlocks.length-1; i >= 0; i--) {
      gradTensor = convBlocks[i].backward(gradTensor, learningRate);
    }
  }

  List<List<List<double>>> unflattenGrad(List<double> grad, List<int> shape) {
    int channels = shape[0];
    int height = shape[1];
    int width = shape[2];

    List<List<List<double>>> tensor = [];
    int idx = 0;

    for (int c = 0; c < channels; c++) {
      List<List<double>> channel = [];
      for (int h = 0; h < height; h++) {
        List<double> row = [];
        for (int w = 0; w < width; w++) {
          row.add(idx < grad.length ? grad[idx++] : 0.0);
        }
        channel.add(row);
      }
      tensor.add(channel);
    }

    return tensor;
  }

  void setTrainMode(bool isTraining) {
    for (var b in convBlocks) {
      for (var bn in b.batchNorms) {
        bn.isTraining = isTraining;
      }
    }
  }

  // Сериализация всей модели
  Map<String, dynamic> toJson() {
    return {
      'convBlocks': convBlocks.map((b) => b.toJson()).toList(),
      'denseLayers': denseLayers.map((l) => l.toJson()).toList(),
    };
  }

  // Десериализация
  factory ErosionNet.fromJson(Map<String, dynamic> json) {
    return ErosionNet(
      convBlocks: (json['convBlocks'] as List)
          .map((b) => ConvBlock.fromJson(b))
          .toList(),
      denseLayers: (json['denseLayers'] as List)
          .map((l) => DenseLayer.fromJson(l))
          .toList(),
    );
  }

  // Сохранение в файл
  static Future<void> saveToFile(ErosionNet model, String path) async {
    final jsonStr = jsonEncode(model.toJson());
    await File(path).writeAsString(jsonStr);
  }

  // Загрузка из файла
  static Future<ErosionNet?> loadFromFile(String path) async {
    try{
      final dir = Directory.current;
      final jsonStr = await File('${dir.path}\\$path').readAsString();
      return ErosionNet.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      return null;
    }
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

  double _mean2D(List<List<double>> matrix) {
    if (matrix.isEmpty || matrix[0].isEmpty) return 0.0;

    double sum = 0.0;
    int count = 0;
    for (var row in matrix) {
      sum += row.reduce((a, b) => a + b);
      count += row.length;
    }
    return sum / count;
  }

  void printDebugInfo() {
    try {
      print('''
      === Network Debug ===
      Last Conv Output Range: [${_min3D(lastConvOutput!)}, ${_max3D(lastConvOutput!)}]
      Dense Weights Mean: ${_mean2D(denseLayers.last.weights).toStringAsFixed(4)}
      BatchNorm Gamma (first 3): ${convBlocks.first.batchNorms.first.gamma.take(3).map((v) => v.toStringAsFixed(4)).join(', ')}
      Raw Output: ${lastRawOutput![0].toStringAsFixed(4)}
      Activated Output: ${lastActivatedOutput![0].toStringAsFixed(4)}
      ''');
    } catch (e) {
      print('Error in debug info: $e');
    }
  }

  void printActivationHistogram() {
    final values = lastConvOutput!.expand((c) => c.expand((r) => r)).toList();
    final histogram = List.filled(10, 0);

    for (var v in values) {
      final bin = ((v.abs() * 10).clamp(0, 9)).toInt();
      histogram[bin]++;
    }

    print('Activation histogram:');
    histogram.asMap().forEach((i, count) {
      print('${i*10}-${(i+1)*10}%: ${'*' * (count ~/ 100)}');
    });
  }

  void printWeightDistribution() {
    final weights = denseLayers.last.weights.expand((w) => w).toList();
    print('''
  Weights distribution:
  - Min: ${weights.reduce(min).toStringAsFixed(4)}
  - Max: ${weights.reduce(max).toStringAsFixed(4)}
  - Mean: ${(weights.reduce((a,b) => a+b) / weights.length).toStringAsFixed(4)}
  ''');
  }
}