import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class TestingSample with EquatableMixin{
  final Uint8List image;
  final String name;
  final double predictedCoefficient;

  TestingSample copyWith({
    Uint8List? image,
    String? name,
    double? trueCoefficient,
    double? predictedCoefficient,
    double? error,
  }) {
    return TestingSample(
      image: image ?? this.image,
      name: name ?? this.name,
      predictedCoefficient: predictedCoefficient ?? this.predictedCoefficient,
    );
  }

  const TestingSample({
    required this.image,
    required this.name,
    this.predictedCoefficient = 0.0,
  });

  @override
  List<Object?> get props => [
    image,
    name,
    predictedCoefficient,
  ];
}