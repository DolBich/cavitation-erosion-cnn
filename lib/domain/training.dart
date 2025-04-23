import 'dart:typed_data';

import 'package:diplom/presentation/entities/config_modes.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/v4.dart';

class TrainingSample with EquatableMixin {
  final UuidV4 id;
  final Uint8List image;
  final String name;
  final double trueCoefficient;
  final double predictedCoefficient;
  final double error;

  TrainingSample copyWith({
    Uint8List? image,
    String? name,
    double? trueCoefficient,
    double? predictedCoefficient,
    double? error,
  }) {
    return TrainingSample(
      image: image ?? this.image,
      name: name ?? this.name,
      trueCoefficient: trueCoefficient ?? this.trueCoefficient,
      predictedCoefficient: predictedCoefficient ?? this.predictedCoefficient,
      error: error ?? this.error,
    );
  }

  TrainingSample({
    required this.image,
    required this.name,
    required this.trueCoefficient,
    this.predictedCoefficient = 0.0,
    this.error = 0.0,
  }) : id = const UuidV4();

  @override
  List<Object?> get props => [
        image,
        name,
        trueCoefficient,
        predictedCoefficient,
        error,
      ];
}

class TrainingConfig with EquatableMixin {
  final ConfigModes mode;
  final double? value;

  const TrainingConfig({
    required this.mode,
    required this.value,
  });

  @override
  List<Object?> get props => [
        mode,
        value,
      ];
}
