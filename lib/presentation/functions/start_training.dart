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

  bool isTraining = true;

  final model = state.cnn;

  bloc.stream.listen((state) {
    if (!state.isTraining) {
      isTraining = false;
    }
  });

  if(config.mode != ConfigModes.error) {
    for (int epoch = 0; epoch < (config.value ?? double.infinity) && isTraining; epoch++) {
      double totalLoss = 0;

      for (var sample in samples) {
        // 1. Загрузка и препроцессинг изображения
        Image? image = decodeImage(sample.image);
        if (image == null) {
          bloc.add(AppEvent.stopTraining(
            withFailure: Failure('Image of ${sample.name} wasn\'t found'),
          ));
          return;
        }

        // 2. Прямой проход
        double prediction = model.forward(image);

        // 3. Расчет ошибки
        double error = prediction - sample.trueCoefficient;
        totalLoss += pow(error, 2);

        // 4. Обновление UI
        bloc.add(AppEvent.updateTrainingSample(
          id: sample.id,
          predictedCoefficient: prediction,
          error: error,
        ));

        // 5. Обратное распространение
        var gradients = calculateGradients(model, error);
        updateWeights(model, gradients, 0.0001);

        print('Epoch ${epoch + 1}: ${sample.name} = $prediction|${(error/sample.trueCoefficient) * 100}');
        if(!isTraining) break;
        await Future.delayed(const Duration(milliseconds: 100)); // Для обновления UI
      }

      bloc.add(const AppEvent.epochDone());
      bloc.add(AppEvent.updateTotalError(totalLoss / samples.length));
      print('Epoch ${epoch + 1}, Loss: ${totalLoss / samples.length}');
    }
  } else {
    double totalError = double.maxFinite;
    for (int epoch = 0; (totalError / samples.length) > (config.value ?? double.infinity) && isTraining; epoch++) {
      totalError = 0;
      for (var sample in samples) {
        // 1. Загрузка и препроцессинг изображения
        Image? image = decodeImage(sample.image);
        if (image == null) {
          bloc.add(AppEvent.stopTraining(
            withFailure: Failure('Image of ${sample.name} wasn\'t found'),
          ));
          return;
        }

        // 2. Прямой проход
        double prediction = model.forward(image);

        // 3. Расчет ошибки
        double error = (prediction - sample.trueCoefficient).abs();
        totalError += pow(error, 2);

        // 4. Обновление UI
        bloc.add(AppEvent.updateTrainingSample(
          id: sample.id,
          predictedCoefficient: prediction,
          error: error,
        ));

        // 5. Обратное распространение
        var gradients = calculateGradients(model, error);
        updateWeights(model, gradients, TRAIN_SPEED);

        print('Epoch ${epoch + 1}: ${sample.name} = $prediction|${(error/sample.trueCoefficient) * 100}');
        if(!isTraining) break;
        await Future.delayed(const Duration(milliseconds: 100)); // Для обновления UI
      }

      bloc.add(const AppEvent.epochDone());
      bloc.add(AppEvent.updateTotalError(totalError / samples.length));
      print('Epoch ${epoch + 1}, Error: ${totalError / samples.length}');
    }
  }


  ErosionNet.saveToFile(model, DEFAULT_FILE_NAME);
  bloc.add(const AppEvent.trainingEnded());
}
