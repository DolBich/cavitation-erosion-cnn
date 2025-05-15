

import 'dart:async';
import 'dart:ui';

import 'package:diplom/cnn/preprocess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class TrainUnit extends StatelessWidget {
  const TrainUnit({
    super.key,
    required this.image,

  });

  final Image image;


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<img.Image>(
      future: imageProviderToImage(image.image),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Text('No image data');
        }

        try {
          final processed = preprocess(snapshot.data!);
          final outputImage = _tensorToImage(processed);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: image.image),
              const SizedBox(width: 20,),
              Image.memory(img.encodePng(outputImage))
            ],
          );
        } catch (e) {
          return Text('Processing error: $e');
        }
      },
    );
  }
}

img.Image _tensorToImage(List<List<List<double>>> tensor) {
  final data = tensor[0];
  final image = img.Image(width: 128, height: 128);

  // Нормализация и масштабирование
  final min = data.expand((row) => row).reduce((a, b) => a < b ? a : b);
  final max = data.expand((row) => row).reduce((a, b) => a > b ? a : b);

  for (var y = 0; y < 128; y++) {
    for (var x = 0; x < 128; x++) {
      final value = ((data[y][x] - min) / (max - min) * 255).clamp(0, 255).toInt();
      image.setPixel(x, y, img.ColorRgb8(value, value, value));
    }
  }

  return image;
}

Future<img.Image> imageProviderToImage(ImageProvider provider) async {
  final imageStream = provider.resolve(ImageConfiguration.empty);
  final completer = Completer<img.Image>();

  ImageStreamListener? listener;
  listener = ImageStreamListener(
          (ImageInfo frame, bool _) async {
        try {
          // 1. Конвертация в PNG формат перед декодированием
          final byteData = await frame.image.toByteData(
              format: ImageByteFormat.png
          );

          if (byteData == null) {
            completer.completeError('Failed to get byte data');
            return;
          }

          // 2. Конвертация в Uint8List
          final bytes = byteData.buffer.asUint8List();
          print('Received ${bytes.length} bytes for decoding');

          // 3. Декодирование с явным указанием формата
          final decodedImage = img.decodePng(bytes);
          if (decodedImage == null) {
            completer.completeError('Failed to decode PNG');
            return;
          }

          completer.complete(decodedImage);
        } catch (e, stack) {
          print('Error in conversion: $e\n$stack');
          completer.completeError(e);
        } finally {
          imageStream.removeListener(listener!);
        }
      },
      onError: (error, stack) {
        print('Image stream error: $error\n$stack');
        completer.completeError(error, stack);
        imageStream.removeListener(listener!);
      }
  );

  imageStream.addListener(listener);
  return completer.future;
}

Future<Image> process(img.Image image) async {
  List<List<List<double>>> processedTensor = preprocess(image);
  List<List<double>> normalizedImage = processedTensor[0];

// 2. Масштабируем значения к диапазону 0-255
  double minVal = normalizedImage
      .expand((row) => row)
      .reduce((a, b) => a < b ? a : b);

  double maxVal = normalizedImage
      .expand((row) => row)
      .reduce((a, b) => a > b ? a : b);

  List<List<int>> scaledImage = normalizedImage.map((row) => row.map((v) {
    // Линейное масштабирование
    int scaledValue = ((v - minVal) / (maxVal - minVal) * 255).clamp(0, 255).toInt();
    return scaledValue;
  }).toList()).toList();

// 3. Конвертируем в объект Image
  img.Image outputImage = img.Image(width: 128, height: 128);

  for (int y = 0; y < 128; y++) {
    for (int x = 0; x < 128; x++) {
      int pixelValue = scaledImage[y][x];
      outputImage.setPixel(x, y, img.ColorRgb8(pixelValue, pixelValue, pixelValue));
    }
  }

// 4. Конвертируем в PNG для отображения во Flutter
  List<int> pngBytes = img.encodePng(outputImage);
  Uint8List imageBytes = Uint8List.fromList(pngBytes);

// Во Flutter-виджете
  return Image.memory(imageBytes);
}


