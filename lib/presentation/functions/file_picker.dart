import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:diplom/domain/testing.dart';
import 'package:diplom/domain/training.dart';
import 'package:diplom/presentation/entities/failure.dart';
import 'package:excel/excel.dart';
import 'package:filepicker_windows/filepicker_windows.dart';

Future<Either<Failure, List<TrainingSample>>?> pickTrainFiles() async {
  final List<TrainingSample> data = [];

  final String? path;
  try {
    path = DirectoryPicker().getDirectory()?.path;
  } catch (e) {
    return left(Failure(e.toString()));
  }

  if (path == null) {
    return null;
  }

  final result = Directory(path);

  final files = result.listSync();
  final List<File> newFiles = [];
  bool xlsxCheck = false;
  for (final file in files) {
    if (file.path.contains("~")) continue;

    if (file.statSync().type != FileSystemEntityType.file) {
      return left(const Failure("Директория должна содержать один файл формата xlsx и файлы формата pdf"));
    }

    final newFile = File.fromUri(file.uri);
    if (newFile.uri.toString().endsWith(".xlsx")) {
      if (xlsxCheck) {
        return left(const Failure("Директория содержит больше одного файла формата excel"));
      }
      xlsxCheck = true;
    }
    newFiles.add(newFile);
  }

  if (!xlsxCheck) {
    return left(const Failure("Директория не содержит файла формата excel")); // нет  excel файла
  }

  final bytes = await newFiles.firstWhere((e) => e.uri.toString().endsWith(".xlsx")).readAsBytes();

  final excel = Excel.decodeBytes(bytes.toList());
  final sheets = excel.sheets;

  if (sheets.length != 1) {
    return left(const Failure("Файл excel должен содержать только один лист"));
  }

  for (final sheetRow in sheets.entries.single.value.rows) {
    final name = sheetRow.elementAt(0)?.value.toString();
    final value = sheetRow.elementAt(1)?.value.toString();
    if (name == null || value == null) continue;
    final Uint8List imageBytes;
    try {
      imageBytes = await newFiles.firstWhere((e) => e.uri.toString().endsWith("$name.png")).readAsBytes();
    } catch (_) {
      continue;
    }

    data.add(TrainingSample(
      name: name,
      trueCoefficient: double.parse(value),
      image: imageBytes,
    ));
  }

  return right(data);
}

Future<Either<Failure, List<TestingSample>>?> pickTestFiles() async {
  final List<TestingSample> data = [];

  final String? path;
  try {
    path = DirectoryPicker().getDirectory()?.path;
  } catch (e) {
    return left(Failure(e.toString()));
  }

  if (path == null) {
    return null;
  }

  final result = Directory(path);

  final files = result.listSync();

  for (final file in files) {
    if (file.uri.toString().endsWith(".png")) {
      final newFile = File.fromUri(file.uri);
      final String name = file.uri.path.split("/").last.split(".").first;
      final dynamic imageBytes;
      try {
        imageBytes = await newFile.readAsBytes();
      } catch (_) {
        continue;
      }
      data.add(TestingSample(
        name: name,
        image: imageBytes,
      ));
    }
  }

  return right(data);
}
