import 'package:collection/collection.dart';
import 'package:diplom/presentation/entities/config_modes.dart';

import '../../application/app_bloc.dart';

Future<void> startTraining({
  required ConfigModes mode,
  required String? endCondition,
  required AppBloc bloc,
})  async {

  bool endless = mode == ConfigModes.endless;
  late final dynamic value;

  if (mode == ConfigModes.error) {
    value = double.parse(endCondition ?? '0');
  } else {
    value = int.parse(endCondition ?? '0');
  }

  int iteration = 0;
  double error = 0;
  bool trainStopped = false;
  final perceptron = bloc.state.perceptron;
  bloc.stream.listen((state) {
    if (state.isTraining == false) {
      trainStopped = true;
    }
    iteration = state.iteration;
    if(state.errors.isNotEmpty){
      error = state.errors.max;
    }
  });


  Future(() async {
    while((endless || (mode == ConfigModes.iterator ? iteration <= value : error >= value)) && !trainStopped) {
      await Future.delayed(const Duration(milliseconds: 3));
      final train =  perceptron.train(bloc.state.getTrainData);

      await Future((){
        bloc.add(AppEvent.train(errors: train["errors"] ?? [], results: train["results"] ?? []));
      });
    }
    return;
  }).then((_){
    bloc.add(const AppEvent.trainingEnded());
  });

  return;

}