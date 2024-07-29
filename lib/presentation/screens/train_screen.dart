import 'dart:async';

import 'package:diplom/presentation/functions/start_training.dart';
import 'package:diplom/presentation/widgets/train_unit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/app_bloc.dart';
import '../../perceptron/training_data.dart';
import '../entities/config_modes.dart';
import '../functions/file_picker.dart';
import '../functions/reset.dart';
import '../functions/show_success_dialog.dart';
import '../functions/show_train_config_dialog.dart';
import '../widgets/iterator_indicator.dart';

// class TrainScreen extends StatefulWidget {
//   const TrainScreen({super.key});
//
//   @override
//   State<TrainScreen> createState() => _TrainScreenState();
// }

class TrainScreen extends StatelessWidget {
  // bool isRunning = false;
  // List<Map<String, dynamic>> data = [];
  // Map<String, dynamic> start = {};
  // final AppBloc bloc;

  const TrainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      // bloc: bloc,
      listenWhen: (p, c) => p.failureOrSuccessOption != c.failureOrSuccessOption && c.failureOrSuccessOption != null || c.trainingEnded,
      listener: (context, state) {
        if (state.trainingEnded) showSuccessDialog(context);
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
      buildWhen: (p, c) => p.trainingData != c.trainingData ||
          p.errors != c.errors ||
          p.results != c.results ||
      p.isTraining != c.isTraining ||
      p.mode != c.mode ||
      p.modeValue != c.modeValue,

      builder: (context, state) {
        final bloc = context.read<AppBloc>();
        // final Map<String, dynamic> start = {
        //   "mode" : state.mode,
        //   "value" : state.modeValue
        // };
        final mode = state.mode;
        return Scaffold(
          appBar: AppBar(
            title: const Center(child: Text("Тренировочный экран")),
            backgroundColor: Colors.black12,
            actions: [
              IconButton(
                  onPressed: () async {
                    final res = await pickTrainFiles();
                    bloc.add(AppEvent.pickTrainData(res));
                  },
                  tooltip: "Выбрать файлы для тренировки",
                  icon: const Icon(Icons.download_outlined)),
              IconButton(
                  onPressed: () async {
                    await reset();
                    bloc.add(const AppEvent.pickTrainData(null));
                  },
                  tooltip: "Сбросить",
                  icon: const Icon(Icons.restart_alt))
            ],
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (mode != null)
                IteratorIndicator(
                  mode: mode,
                  value: state.modeValue,
                ),

              SizedBox(
                height: 500,
                child: ListWheelScrollView(
                  itemExtent: 400,
                  children: state.trainingData.isNotEmpty
                      ? List.generate(state.trainingData.length, (i) {
                    return TrainUnit(
                        name: "${state.trainingData[i]["name"]}",
                        image: Image.memory(state.trainingData[i]["image"]).image,
                        expectedResult: "${state.trainingData[i]["value"]}",
                        result: (state.results.elementAtOrNull(i) ?? "").toString(),
                        error: (state.errors.elementAtOrNull(i) ?? "").toString());
                  })
                      : [
                    const Text(
                      "Выберите файлы для тренировки",
                      style: TextStyle(fontSize: 76, color: Colors.black12),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              if (state.isTraining) {
                bloc.add(const AppEvent.stopTraining());

              } else {
                final start = await showTrainConfigDialog(context);
                // await Future.delayed(Duration(seconds: 1));

                  // Navigator.
                  if (start.isNotEmpty && state.trainingData.isNotEmpty) {
                    bloc.add(const AppEvent.startTraining());
                    bloc.add(AppEvent.setTrainingConfig(start));

                    startTraining(
                        mode: start["mode"],
                        endCondition: start["value"],
                        bloc: bloc
                    );
                  }

              }
            },
            label: state.isTraining
                ? const Text("Остановить тренировку")
                : const Text("Начать тренировку"),
            icon: state.isTraining ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
          ),
        );
      },
    );
  }
}


extension ListX<E> on List<E> {
  E? elementAtOrNull(int i) {
    try{
      return this[i];
    } catch (_) {
      return null;
    }
  }
}