import 'package:diplom/application/app_bloc.dart';
import 'package:diplom/domain/testing.dart';
import 'package:diplom/presentation/entities/failure.dart';
import 'package:image/image.dart';

Future<void> predictTestSamples(AppBloc bloc, List<TestingSample> samples) async {
  final model = bloc.state.cnn;
  for (var sample in samples) {
    Image? image = decodeImage(sample.image);
    if (image == null) {
      bloc.add(AppEvent.failureInTest(
        withFailure: Failure('Image of ${sample.name} wasn\'t found'),
      ));
      return;
    }

    double coefficient = model.forward(image);

    bloc.add(AppEvent.updateSample(
      id: sample.id,
      predictedCoefficient: coefficient,
    ));
  }
}
