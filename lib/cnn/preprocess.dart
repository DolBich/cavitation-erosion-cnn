import 'dart:math';

import 'package:image/image.dart';


List<List<List<double>>> preprocess(Image image) {
  // 1. Конвертация в HSV
  List<List<List<double>>> hsvImage = convertToHSV(image);

  // 2. Фильтрация засветов
  hsvImage = filterHighlights(hsvImage);

  // 3. Нормализация и конвертация в Grayscale
  List<List<double>> grayImage = normalizeAndConvertToGray(hsvImage);

  // 4. Ресайз до 128x128
  List<List<double>> resizedImage = resizeNearestNeighbor(grayImage, 128, 128);

  // 5. Добавление "канала" (преобразование в 3D тензор [1][H][W])
  return [resizedImage];
}

List<List<List<double>>> convertToHSV(Image image) {
  List<List<List<double>>> hsvImage = [];

  for (int y = 0; y < image.height; y++) {
    List<List<double>> row = [];
    for (int x = 0; x < image.width; x++) {
      Pixel pixel = image.getPixel(x, y);

      // Извлекаем RGB (0-255)
      double r = pixel.getChannel(Channel.red) / 255.0;
      double g = pixel.getChannel(Channel.green) / 255.0;
      double b = pixel.getChannel(Channel.blue) / 255.0;

      // Конвертация в HSV (формулы из Wikipedia)
      double cmax = max(r, max(g, b));
      double cmin = min(r, min(g, b));
      double delta = cmax - cmin;

      // Hue
      double h = 0.0;
      if (delta != 0) {
        if (cmax == r) h = 60 * (((g - b) / delta) % 6);
        else if (cmax == g) h = 60 * (((b - r) / delta) + 2);
        else h = 60 * (((r - g) / delta) + 4);
      }

      // Saturation
      double s = cmax == 0 ? 0 : delta / cmax;

      // Value
      double v = cmax;

      row.add([h, s, v]);
    }
    hsvImage.add(row);
  }

  return hsvImage;
}

List<List<double>> normalizeAndConvertToGray(List<List<List<double>>> hsvImage) {
  List<List<double>> grayImage = [];

  for (int y = 0; y < hsvImage.length; y++) {
    List<double> row = [];
    for (int x = 0; x < hsvImage[y].length; x++) {
      // Берем только Value (яркость) из HSV
      double value = hsvImage[y][x][2];
      row.add(value);
    }
    grayImage.add(row);
  }

  return grayImage;
}

List<List<double>> resizeNearestNeighbor(List<List<double>> image, int newWidth, int newHeight) {
  int oldWidth = image[0].length;
  int oldHeight = image.length;

  List<List<double>> resized = [];

  for (int y = 0; y < newHeight; y++) {
    List<double> row = [];
    int srcY = y * oldHeight ~/ newHeight;

    for (int x = 0; x < newWidth; x++) {
      int srcX = x * oldWidth ~/ newWidth;
      row.add(image[srcY][srcX]);
    }

    resized.add(row);
  }

  return resized;
}

List<List<List<double>>> filterHighlights(List<List<List<double>>> hsvImage) {
  for (int y = 0; y < hsvImage.length; y++) {
    for (int x = 0; x < hsvImage[y].length; x++) {
      double h = hsvImage[y][x][0];
      double s = hsvImage[y][x][1];
      double v = hsvImage[y][x][2];

      // Если яркость > 90% и насыщенность < 10% → засвет
      if (v > 0.9 && s < 0.1) {
        hsvImage[y][x] = [0.0, 0.0, 0.0]; // Зануляем пиксель
      }
    }
  }
  return hsvImage;
}