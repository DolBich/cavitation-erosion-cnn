import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/app_bloc.dart';
import '../functions/file_picker.dart';
import '../widgets/train_unit.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listenWhen: (p, c) => p.failureOrSuccessOption != c.failureOrSuccessOption && c.failureOrSuccessOption != null || c.trainingEnded,
      listener: (context, state) {
        state.failureOrSuccessOption?.fold(
              (f) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Ошибка: ${f.error}"),
                  duration: const Duration(seconds: 5),
                )
            );
          },
              (_) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Успех")));
          },
        );
      },
      builder: (context, state) {
        final bloc = context.read<AppBloc>();
        final data = state.testData;
        return Scaffold(
          appBar: AppBar(
            title: const Center(child: Text("Экран тестирования")),
            backgroundColor: Colors.black12,
            actions: [
              IconButton(
                  onPressed: () async {
                    final res = await pickTestFiles();
                    bloc.add(AppEvent.pickTestData(res));
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
                  result: (state.testResults.elementAtOrNull(i) ?? "").toString(),
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
              final List<double> results = [];
              for(final data in state.getTestData) {
                results.add(state.perceptron.process(data).single);
              }
              bloc.add(AppEvent.testDone(results));
            },
            label: const Text("Тестирование"),
            icon: const Icon(Icons.play_arrow),
          ),
        );
      }
    );
  }
}
