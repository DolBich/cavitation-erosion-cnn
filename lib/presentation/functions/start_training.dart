import 'dart:math';

import 'package:diplom/application/app_bloc.dart';
import 'package:diplom/cnn/erosion_net.dart';
import 'package:diplom/cnn/training.dart';
import 'package:diplom/domain/training.dart';
import 'package:diplom/main.dart';
import 'package:diplom/presentation/entities/config_modes.dart';
import 'package:diplom/presentation/entities/failure.dart';
import 'package:image/image.dart';

void startTraining(AppBloc bloc, TrainingConfig config) async {
  final state = bloc.state;
  final samples = state.trainingData;
  bloc.add(AppEvent.trainStarted(config));
  await Future.delayed(const Duration(milliseconds: 300));

  bool isTraining = true;

  final model = state.cnn;
  model.printDebugInfo();

  final trainer = Trainer(model, learningRate: TRAIN_SPEED);

  model.setTrainMode(true);

  bloc.stream.listen((state) {
    if (!state.isTraining) {
      isTraining = false;
    }
  });

  if(config.mode != ConfigModes.error) {
    for (int epoch = 0; epoch < (config.value ?? double.infinity) && isTraining; epoch++) {
      await _train(bloc: bloc, samples: samples, isTraining: isTraining, trainer: trainer, model: model, epoch: epoch);
      await Future.delayed(const Duration(milliseconds: 100));
      }
  } else {
    double totalError = double.maxFinite;
    for (int epoch = 0; (totalError / samples.length) > (config.value ?? double.infinity) && isTraining; epoch++) {
     await _train(bloc: bloc, samples: samples, isTraining: isTraining, trainer: trainer, model: model, epoch: epoch);
     await Future.delayed(const Duration(milliseconds: 100));
    }
  }
  model.setTrainMode(false);

  ErosionNet.saveToFile(model, DEFAULT_FILE_NAME);
  bloc.add(const AppEvent.trainingEnded());
}


Future<void> _train({
  required AppBloc bloc,
  required List<TrainingSample> samples,
  required bool isTraining,
  required Trainer trainer,
  required ErosionNet model,
  required int epoch,
}) async {
  bloc.stream.listen((state) {
    if (!state.isTraining) {
      isTraining = false;
    }
  });

  double totalLoss = 0.0;

  print('\n=== Epoch ${epoch+1} ===');
  model.printDebugInfo();

  for (var sample in samples) {
    if (!isTraining) break;

    // 1. Загрузка и препроцессинг изображения
    Image? image = decodeImage(sample.image);
    if (image == null) {
      bloc.add(AppEvent.stopTraining(
        withFailure: Failure('Image of ${sample.name} wasn\'t found'),
      ));
      return;
    }

    // 3. Выполняем шаг обучения через Trainer
    trainer.trainStep(image, sample.trueCoefficient);

    // 4. Получаем предсказание и ошибку
    double prediction = model.lastActivatedOutput![0]; // Учитываем сигмоиду и масштабирование
    double error = prediction - sample.trueCoefficient;
    totalLoss += pow(error, 2);

    print('Sample = ${sample.name}: $error|${(error / sample.trueCoefficient).abs()* 100}%');
    // 5. Обновление UI
    bloc.add(AppEvent.updateTrainingSample(
      id: sample.id,
      predictedCoefficient: prediction,
      error: error,
    ));

    await Future.delayed(const Duration(milliseconds: 100));
  }

  print('Epoch ${epoch+1} results:');
  model.printDebugInfo();
  print('Loss: ${totalLoss / samples.length}');

  if (epoch % 5 == 0) {
    model.printWeightDistribution();
    model.printActivationHistogram();
  }

  // print('Epoch = $epoch: ${totalLoss / samples.length}');
  // 6. Обновление статистики эпохи
  bloc.add(const AppEvent.epochDone());
  bloc.add(AppEvent.updateTotalError(totalLoss / samples.length));

  return;
}