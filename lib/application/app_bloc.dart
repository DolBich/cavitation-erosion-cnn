import 'package:dartz/dartz.dart';
import 'package:diplom/cnn/erosion_net.dart';
import 'package:diplom/domain/testing.dart';
import 'package:diplom/domain/training.dart';
import 'package:diplom/presentation/entities/failure.dart';
import 'package:diplom/presentation/functions/file_picker.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/v1.dart';
import 'package:uuid/v4.dart';

part 'app_event.dart';

part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState.initial()) {
    on<_PickTrainData>(_pickTrainData);
    on<_PickTestData>(_pickTestData);
    on<_StopTraining>(_stopTraining);
    on<_TrainingEnded>(_trainingEnded);
    on<_ResetCNN>(_resetCNN);
    on<_Train>(_train);
    on<_TestDone>(_testDone);
    on<_TrainingStarted>(_trainStarted);
    on<_UpdateSample>(_updateSample);
    on<_EpochDone>(_epochDone);
    on<_FailureInTest>(_failureInTest);
    add(const AppEvent.resetCNN());
  }

  Future _failureInTest(_FailureInTest event, Emitter<AppState> emit) async {
    emit(state.copyWith(
      failureOrSuccessOption: left(event.withFailure),
    ));
  }

  Future _epochDone(_EpochDone event, Emitter<AppState> emit) async {
    emit(state.copyWith(
      iteration: state.iteration + 1,
    ));
  }

  Future _updateSample(_UpdateSample event, Emitter<AppState> emit) async {
    final List<TrainingSample> samples = List.from(state.trainingData);
    final index = samples.indexWhere((e) => e.id == event.id);
    samples[index] = samples[index].copyWith(
      predictedCoefficient: event.predictedCoefficient,
      error: event.error,
    );
    emit(state.copyWith(
      trainingData: samples,
    ));
  }

  Future _stopTraining(_StopTraining event, Emitter<AppState> emit) async {
    emit(
      state.copyWith(isTraining: false),
    );
  }

  void _trainStarted(_TrainingStarted event, Emitter<AppState> emit) {
    emit(
      state.copyWith(
        iteration: 0,
        isTraining: true,
        trainingConfig: event.config,
      ),
    );
  }

  Future _pickTrainData(_PickTrainData event, Emitter<AppState> emit) async {
    final data = await pickTrainFiles();
    if (data == null) {
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
      ));
    });
  }

  Future _pickTestData(_PickTestData event, Emitter<AppState> emit) async {
    final data = await pickTestFiles();
    if (data == null) {
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
      ));
    });
  }

  Future _trainingEnded(_TrainingEnded event, Emitter<AppState> emit) async {
    emit(state.copyWith(
      isTraining: false,
    ));
  }

  Future _resetCNN(_ResetCNN event, Emitter<AppState> emit) async {
    emit(state.copyWith(
      cnn: ErosionNet(),
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
