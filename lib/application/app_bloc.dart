
import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:diplom/presentation/entities/config_modes.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../main.dart';
import '../perceptron/perceptron.dart';
import '../perceptron/training_data.dart';
import '../presentation/entities/failure.dart';
import 'package:image/image.dart';

part 'app_state.dart';

part 'app_event.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState.initial()) {
    on<_PickTrainData>(_pickTrainData);
    on<_PickTestData>(_pickTestData);
    on<_StopTraining>(_stopTraining);
    on<_StartTraining>(_startTraining);
    on<_TrainingEnded>(_trainingEnded);
    on<_ResetPerceptron>(_resetPerceptron);
    on<_Train>(_train);
    on<_TestDone>(_testDone);
  }

  Future _stopTraining(_StopTraining event, Emitter<AppState> emit) async {
    emit(state.copyWith(isTraining: false));
  }

  void _startTraining(_StartTraining event, Emitter<AppState> emit) {
    emit(state.copyWith(
        isTraining: true,
        iteration: 0,
        mode: event.config["mode"], modeValue: event.config["value"]
    ));
  }

  Future _pickTrainData(_PickTrainData event, Emitter<AppState> emit) async {
    final data = event.data;
    if (data == null) {
      emit(state
          .copyWith(failureOrSuccessOption: right(unit), trainingData: []));
      return;
    }
    data.fold((f) {
      emit(state.copyWith(
        failureOrSuccessOption: left(f),
      ));
    }, (s) {

      emit(state.copyWith(
          failureOrSuccessOption: right(unit),
          trainingData: s,
          // perceptron: state.perceptron.netConfiguration !=
          //         [
          //           (s.first["image"] as Uint8List).length,
          //           ((s.first["image"] as Uint8List).length + 1) / 2,
          //           1
          //         ]
          //     ? Perceptron([
          //         (s.first["image"] as Uint8List).length,
          //         ((s.first["image"] as Uint8List).length + 1) ~/ 2,
          //         1
          //       ], 1)
          //     : null //TODO: подставить сюда вместо единиц число значений для одной картинки (когда введу разделение на блоки)
          ));
    });
  }

  Future _pickTestData(_PickTestData event, Emitter<AppState> emit) async {
    final data = event.data;
    if (data == null) {
      emit(state
          .copyWith(failureOrSuccessOption: right(unit), trainingData: []));
      return;
    }
    data.fold((f) {
      emit(state.copyWith(
        failureOrSuccessOption: left(f),
      ));
    }, (s) {

      emit(state.copyWith(
        failureOrSuccessOption: right(unit),
        testData: s,
        // perceptron: state.perceptron.netConfiguration !=
        //         [
        //           (s.first["image"] as Uint8List).length,
        //           ((s.first["image"] as Uint8List).length + 1) / 2,
        //           1
        //         ]
        //     ? Perceptron([
        //         (s.first["image"] as Uint8List).length,
        //         ((s.first["image"] as Uint8List).length + 1) ~/ 2,
        //         1
        //       ], 1)
        //     : null //TODO: подставить сюда вместо единиц число значений для одной картинки (когда введу разделение на блоки)
      ));
    });
  }

  Future _trainingEnded(_TrainingEnded event, Emitter<AppState> emit) async {
    emit(state.copyWith(
      trainingEnded: true,
      isTraining: false,
    ));
  }

  Future _resetPerceptron(
      _ResetPerceptron event, Emitter<AppState> emit) async {
    emit(state.copyWith(
      perceptron: Perceptron([6000, 10, 1], 1),
    ));
  }

  void _train(_Train event, Emitter<AppState> emit) {
    emit(state.copyWith(
      errors: event.errors,
      results: event.results,
      iteration: state.iteration + 1,
    ));
  }

  void _testDone(_TestDone event, Emitter<AppState> emit) {
    emit(state.copyWith(
      testResults: event.results,
    ));
  }
}
