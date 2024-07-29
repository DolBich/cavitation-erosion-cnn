import 'package:collection/collection.dart';
import 'package:diplom/presentation/entities/config_modes.dart';
import 'package:diplom/presentation/screens/train_screen.dart';
import 'package:flutter/foundation.dart';

import '../../application/app_bloc.dart';

Future<void> startTraining({
  required ConfigModes mode,
  required String? endCondition,
  required AppBloc bloc,
})  {

  bool endless = mode == ConfigModes.endless;
  late final dynamic value;

  if (mode == ConfigModes.error) {
    value = double.parse(endCondition ?? '0');
  } else {
    value = int.parse(endCondition ?? '0');
  }

  int iteration = 0;
  double error = double.infinity;
  bool trainStopped = false;
  final perceptron = bloc.state.perceptron;
  bloc.stream.listen((state) {
    if (state.isTraining == false) {
      trainStopped = true;
    }
    iteration = state.iteration;
    error = state.errors.max;
  });


  Future(() async {
    while((endless || (mode == ConfigModes.iterator ? iteration <= value : error >= value)) && !trainStopped) {
      final train =  perceptron.train(bloc.state.getTrainData);
      await Future((){
        bloc.add(AppEvent.train(errors: train["errors"] ?? [], results: train["results"] ?? [], iteration: iteration));
      });
    }
    return;
  }).then((_){
    bloc.add(const AppEvent.trainingEnded());
  });

  return Future((){});

}