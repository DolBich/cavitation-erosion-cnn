
import 'package:diplom/cnn/preprocess.dart';
import 'package:diplom/cnn/process.dart';
import 'package:image/image.dart';

import 'conv_block.dart';
import 'dense.dart';

class ErosionNet {
  late List<ConvBlock> convBlocks;
  late List<DenseLayer> denseLayers;

  ErosionNet() {
    convBlocks = [
      ConvBlock(3, 16, kernelSize: 3, padding: 1, poolSize: 2), // 128x128 → 64x64
      ConvBlock(16, 32, padding: 1, poolSize: 2), // 64x64 → 32x32
      ConvBlock(32, 64, poolSize: 2), // 32x32 → 16x16
    ];

    denseLayers = [
      DenseLayer(64 * 16 * 16, 128),  // Пример для входа 256x256
      DenseLayer(128, 1)  // Выход - одно число
    ];
  }

  double forward(Image image) {
    var tensor = preprocess(image);
    for (var block in convBlocks) {
      tensor = block.forward(tensor);
    }
    var vector = flatten(tensor);
    for (var layer in denseLayers) {
      vector = layer.forward(vector);
    }
    return sigmoid(vector[0]); // Коэффициент 0-1
  }
}