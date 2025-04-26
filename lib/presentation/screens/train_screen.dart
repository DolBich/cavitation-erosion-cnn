import 'package:collection/collection.dart';
import 'package:diplom/application/app_bloc.dart';
import 'package:diplom/domain/training.dart';
import 'package:diplom/presentation/entities/failure.dart';
import 'package:diplom/presentation/functions/file_picker.dart';
import 'package:diplom/presentation/functions/show_success_dialog.dart';
import 'package:diplom/presentation/functions/show_train_config_dialog.dart';
import 'package:diplom/presentation/functions/start_training.dart';
import 'package:diplom/presentation/widgets/iterator_indicator.dart';
import 'package:diplom/presentation/widgets/train_unit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrainScreen extends StatelessWidget {
  const TrainScreen({super.key});

  Widget get _pickFilesText {
    return const Text(
      "Выберите файлы для тренировки",
      style: TextStyle(fontSize: 76, color: Colors.black12),
      textAlign: TextAlign.center,
    );
  }

  List<Widget> _samples(List<TrainingSample> data) {
    return List.generate(data.length, (i) {
      final id = data[i].id;
      return BlocBuilder<AppBloc, AppState>(
        buildWhen: (p, c) =>
            (p.trainingData.firstWhereOrNull((e) => e.id == id) !=
                c.trainingData.firstWhereOrNull((e) => e.id == id)) &&
            c.trainingData.firstWhereOrNull((e) => e.id == id) != null,
        builder: (context, state) {
          final sample = state.trainingData.firstWhere((e) => e.id == id);
          return TrainUnit(
            name: sample.name,
            image: Image.memory(sample.image).image,
            expectedResult: sample.trueCoefficient,
            result: sample.predictedCoefficient,
            error: sample.error,
          );
        },
      );
    });
  }

  Widget get _floatingActionButton {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (p, c) => p.isTraining != c.isTraining || p.trainingData != c.trainingData,
      builder: (context, state) {
        final bloc = context.read<AppBloc>();
        return FloatingActionButton.extended(
          onPressed: !state.isTraining && state.trainingData.isNotEmpty
              ? () async {
                  if (state.isTraining) {
                    bloc.add(const AppEvent.stopTraining());
                  } else {
                    final start = await showTrainConfigDialog(context);
                    if (start != null) {
                      startTraining(bloc, start);
                    }
                  }
                }
              : () async {
                  bloc.add(const AppEvent.failure(
                    failure: Failure('Нельзя начать тренировку без тренировочных экземпляров'),
                  ));
                },
          label: state.isTraining ? const Text("Остановить тренировку") : const Text("Начать тренировку"),
          icon: state.isTraining ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
        );
      },
    );
  }

  Widget _pickFilesButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        final bloc = context.read<AppBloc>();
        bloc.add(const AppEvent.pickTrainData());
      },
      tooltip: "Выбрать файлы для тренировки",
      icon: const Icon(Icons.download_outlined),
    );
  }

  Widget _uploadNet(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final bloc = context.read<AppBloc>();
        final net = await loadModelFromFile(bloc);
        bloc.add(AppEvent.resetCNN(net: net));
      },
      tooltip: "Загрузить модель",
      icon: const Icon(Icons.add_box_outlined),
    );
  }

  Widget _resetNet(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final bloc = context.read<AppBloc>();
        bloc.add(const AppEvent.resetCNN());
      },
      tooltip: "Сбросить модель",
      icon: const Icon(Icons.restart_alt),
    );
  }

  void _listener(BuildContext context, AppState state) {
    if (state.trainingEnded) showSuccessDialog(context);
    final sm = ScaffoldMessenger.of(context);
    state.failureOrSuccessOption?.fold(
      (f) {
        sm.showSnackBar(SnackBar(
          content: Text("Ошибка: ${f.error}"),
          duration: const Duration(seconds: 5),
        ));
      },
      (_) {
        sm.showSnackBar(const SnackBar(content: Text("Успех")));
      },
    );
  }

  Widget _samplesList(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (p, c) => p.trainingData.length != c.trainingData.length,
      builder: (context, state) {
        final data = state.trainingData;
        return SizedBox(
          height: 500,
          child: ListView(
            itemExtent: 400,
            children: data.isNotEmpty ? _samples(data) : [_pickFilesText],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (p, c) {
        return (p.failureOrSuccessOption != c.failureOrSuccessOption && c.failureOrSuccessOption != null) ||
            c.trainingEnded;
      },
      listener: (context, state) => _listener(context, state),
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("Тренировочный экран")),
          backgroundColor: Colors.black12,
          actions: [
            _pickFilesButton(context),
            _uploadNet(context),
            _resetNet(context),
          ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IteratorIndicator(),
            _samplesList(context),
          ],
        ),
        floatingActionButton: _floatingActionButton,
      ),
    );
  }
}
