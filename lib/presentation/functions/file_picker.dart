import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:excel/excel.dart';
import 'package:filepicker_windows/filepicker_windows.dart';

import '../entities/failure.dart';

Future<Either<Failure, List<Map<String, dynamic>>>> pickTrainFiles() async {
  final List<Map<String, dynamic>> data = [];
  
  final String? path;
  try{
    path = DirectoryPicker().getDirectory()?.path;
  } catch (e) {
    return left(Failure(e.toString()));
  }

  if(path == null) {
    return left(const Failure("Пользователь отменил выбор файлов"));
  }


  final result = Directory(path);

  final files = result.listSync();
  final List<File> newFiles = [];
  bool xlsxCheck = false;
  for(final file in files){
    if(file.path.contains("~")) continue;
    if(file.statSync().type != FileSystemEntityType.file) return left(const Failure("Директория должна содержать один файл формата xlsx и файлы формата pdf"));
    final newFile = File.fromUri(file.uri);
    if (newFile.uri.toString().endsWith(".xlsx")) {
      if (xlsxCheck) return left(const Failure("Директория содержит больше одного файла формата excel")); // если excel файл не один, то ошибка
      xlsxCheck = true;
    }
    newFiles.add(newFile);
  }
  if(!xlsxCheck) return left(const Failure("Директория не содержит файла формата excel")); // нет  excel файла
  
  final bytes = await newFiles.firstWhere((e) => e.uri.toString().endsWith(".xlsx")).readAsBytes();

  final excel = Excel.decodeBytes(bytes.toList());
  final sheets = excel.sheets;

  if (sheets.length != 1) {
    return left(const Failure("Файл excel должен содержать только один лист"));
  }


  for (final sheetRow in sheets.entries.single.value.rows) {
    final name = sheetRow.elementAt(0)?.value.toString();
    final value = sheetRow.elementAt(1)?.value.toString();
    if(name == null || value == null) continue;
    final Uint8List imageBytes;
    try{
      imageBytes = await newFiles.firstWhere((e) => e.uri.toString().endsWith("$name.png")).readAsBytes();
    } catch (_) {
      continue;
    }

    
    data.add({"name": name, "value" : value, "image": imageBytes});
  }

  return right(data);
}

Future<Either<Failure, List<Map<String, dynamic>>>> pickTestFiles() async {
  final List<Map<String, dynamic>> data = [];

  final String? path;
  try{
    path = DirectoryPicker().getDirectory()?.path;
  } catch (e) {
    return left(Failure(e.toString()));
  }

  if(path == null) {
    return left(const Failure("Пользователь отменил выбор файлов"));
  }


  final result = Directory(path);

  final files = result.listSync();

  for (final file in files) {
    if (file.uri.toString().endsWith(".png")) {
      final newFile = File.fromUri(file.uri);
      final String name = file.uri.path.split("/").last.split(".").first;
      final dynamic imageBytes;
      try{
        imageBytes = await newFile.readAsBytes();
      } catch (_) {
        continue;
      }
      data.add({"name": name, "image": imageBytes});
    }
  }

  return right(data);
}