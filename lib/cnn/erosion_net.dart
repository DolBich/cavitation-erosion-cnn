
import 'package:diplom/cnn/conv_block.dart';
import 'package:diplom/cnn/dense.dart';
import 'package:diplom/cnn/preprocess.dart';
import 'package:diplom/cnn/process.dart';
import 'package:image/image.dart';

class ErosionNet {
  late List<ConvBlock> convBlocks;
  late List<DenseLayer> denseLayers;

  ErosionNet() {
    convBlocks = [
      ConvBlock(1, 16, kernelSize: 3, padding: 1, poolSize: 2), // 128x128 → 64x64
      ConvBlock(16, 32, padding: 1, poolSize: 2), // 64x64 → 32x32
      ConvBlock(32, 64, poolSize: 2), // 32x32 → 16x16
    ];

    denseLayers = [
      DenseLayer(64 * 14 * 14, 128),  // Пример для входа 256x256
      DenseLayer(128, 1)  // Выход - одно число
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
}