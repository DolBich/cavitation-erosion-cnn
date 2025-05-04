
import 'dart:convert';
import 'dart:io';

import 'package:diplom/cnn/conv_block.dart';
import 'package:diplom/cnn/dense.dart';
import 'package:diplom/cnn/preprocess.dart';
import 'package:diplom/cnn/process.dart';
import 'package:image/image.dart';

class ErosionNet {
  late List<ConvBlock> convBlocks;
  late List<DenseLayer> denseLayers;

  ErosionNet({List<ConvBlock>? convBlocks, List<DenseLayer>? denseLayers}) {
    this.convBlocks = convBlocks ?? [
      ConvBlock.create(1, 16, kernelSize: 3, padding: 1, poolSize: 2),
      ConvBlock.create(16, 32, padding: 1, poolSize: 2),
      ConvBlock.create(32, 64, poolSize: 2),
    ];

    this.denseLayers = denseLayers ?? [
      DenseLayer.create(64 * 14 * 14, 128),  // Пример для входа 256x256
      DenseLayer.create(128, 1)  // Выход - одно число
    ];
  }

  double forward(Image image) {
    var tensor = preprocess(image);
    // print("Input range: [${tensor[0][0][0]}, ${tensor[0].last.last}]");
    for (var block in convBlocks) {
      tensor = block.forward(tensor);
      // print("ConvBlock output range: [${tensor[0][0][0]}, ${tensor[0].last.last}]");
    }
    var vector = flatten(tensor);
    // print("Flattened vector length: ${vector.length}");
    for (var layer in denseLayers) {
      vector = layer.forward(vector);
      // print("DenseLayer output: ${vector}");
    }
    // Масштабирование выхода: 0-1 -> 0-100
    final sig = sigmoid(vector[0]);
    return sig * 100; // Коэффициент 0-1
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
}