import 'package:flutter/material.dart';

import '../functions/file_picker.dart';
import '../widgets/train_unit.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<Map<String, dynamic>> data = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Экран тестирования")),
        backgroundColor: Colors.black12,
        actions: [
          IconButton(
              onPressed: () async {
                final res = await pickTestFiles();
                res.fold((l) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Ошибка: ${l.error}"),
                    duration: const Duration(seconds: 5),
                  ));
                }, (r) {
                  setState(() {
                    data = r;
                  });
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Успех")));
                });
              },
              tooltip: "Выбрать файлы для тестирования",
              icon: const Icon(Icons.download_outlined)),
        ],
      ),
      body: ListWheelScrollView(
        itemExtent: 400,
        children: data.isNotEmpty
            ? List.generate(data.length, (i) {
                return TrainUnit(
                    name: "${data[i]["name"]}",
                    image: Image.memory(data[i]["image"]).image,
                    expectedResult: null,
                    result: "${i - 0.2}",
                    error: null);
              })
            : [
                const Text(
                  "Выберите файлы для тестирования",
                  style: TextStyle(fontSize: 76, color: Colors.black12),
                  textAlign: TextAlign.center,
                )
              ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {});
        },
        label: const Text("Тестирование"),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}
