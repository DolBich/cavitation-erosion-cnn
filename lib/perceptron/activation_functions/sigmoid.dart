import 'dart:math';
class Sigmoid {
  double derivative(double param) => process(param) * (1 - process(param));

  double process(double param) => 1 / (1 + exp(-param));
}
