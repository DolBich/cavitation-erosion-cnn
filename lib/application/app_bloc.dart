import 'package:dartz/dartz.dart';
import 'package:diplom/cnn/erosion_net.dart';
import 'package:diplom/domain/testing.dart';
import 'package:diplom/domain/training.dart';
import 'package:diplom/presentation/entities/failure.dart';
import 'package:diplom/presentation/functions/file_picker.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/v4.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc(ErosionNet? initialNet) : super(AppState.initial(initialNet)) {
    on<_PickTrainData>(_pickTrainData);
    on<_PickTestData>(_pickTestData);
    on<_StopTraining>(_stopTraining);
    on<_TrainingEnded>(_trainingEnded);
    on<_ResetCNN>(_resetCNN);
    on<_TrainingStarted>(_trainStarted);
    on<_UpdateTrainingSample>(_updateTrainingSample);
    on<_UpdateTestingSample>(_updateTestingSample);
    on<_EpochDone>(_epochDone);
    on<_Failure>(_failureInTest);
    on<_UpdateTotalError>(_updateTotalError);
  }

  Future _updateTotalError(_UpdateTotalError event, Emitter<AppState> emit) async {
    emit(state.copyWith(
      totalError: event.error,
    ));
  }

  Future _failureInTest(_Failure event, Emitter<AppState> emit) async {
    emit(state.copyWith(
      failureOrSuccessOption: left(event.failure),
    ));
  }

  Future _epochDone(_EpochDone event, Emitter<AppState> emit) async {
    emit(state.copyWith(
      iteration: state.iteration + 1,
    ));
  }

  Future _updateTrainingSample(_UpdateTrainingSample event, Emitter<AppState> emit) async {
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

  Future _updateTestingSample(_UpdateTestingSample event, Emitter<AppState> emit) async {
    final List<TestingSample> samples = List.from(state.testData);
    final index = samples.indexWhere((e) => e.id == event.id);
    samples[index] = samples[index].copyWith(
      predictedCoefficient: event.predictedCoefficient,
    );
    emit(state.copyWith(
      testData: samples,
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
        totalError: double.maxFinite
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
    final cnn = event.net ?? ErosionNet();
    emit(state.copyWith(
      cnn: cnn,
    ));
  }
}
