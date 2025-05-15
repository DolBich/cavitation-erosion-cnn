import 'package:collection/collection.dart';
import 'package:diplom/application/app_bloc.dart';
import 'package:diplom/domain/testing.dart';
import 'package:diplom/presentation/functions/predict_test_samples.dart';
import 'package:diplom/presentation/widgets/train_unit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  void _listener(BuildContext context, AppState state) {
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

  Widget _pickFiles(BuildContext context) {
    return IconButton(
      onPressed: () {
        final bloc = context.read<AppBloc>();
        bloc.add(const AppEvent.pickTestData());
      },
      tooltip: "Выбрать файлы для тестирования",
      icon: const Icon(Icons.download_outlined),
    );
  }

  Widget get _pickFilesText {
    return const Text(
      "Выберите файлы для тестирования",
      style: TextStyle(fontSize: 76, color: Colors.black12),
      textAlign: TextAlign.center,
    );
  }

  List<Widget> _samples(List<TestingSample> data) {
    return List.generate(data.length, (i) {
      final id = data[i].id;
      return BlocBuilder<AppBloc, AppState>(
        buildWhen: (p, c) =>
            (p.testData.firstWhereOrNull((e) => e.id == id) != c.testData.firstWhereOrNull((e) => e.id == id)),
        builder: (context, state) {
          final sample = state.testData.firstWhere((e) => e.id == id);
          return TrainUnit(
            image: Image.memory(sample.image),

          );
        },
      );
    });
  }

  Widget _samplesList(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (p, c) => p.testData != c.testData,
      builder: (context, state) {
        final data = state.testData;
        return ListView(
          itemExtent: 400,
          children: data.isNotEmpty ? _samples(data) : [_pickFilesText],
        );
      },
    );
  }

  Widget _floatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        final bloc = context.read<AppBloc>();
        predictTestSamples(bloc, bloc.state.testData);
      },
      label: const Text("Тестирование"),
      icon: const Icon(Icons.play_arrow),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (p, c) => p.failureOrSuccessOption != c.failureOrSuccessOption && c.failureOrSuccessOption != null,
      listener: (context, state) => _listener(context, state),
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("Экран тестирования")),
          backgroundColor: Colors.black12,
          actions: [_pickFiles(context)],
        ),
        body: _samplesList(context),
        floatingActionButton: _floatingActionButton(context),
      ),
    );
  }
}
