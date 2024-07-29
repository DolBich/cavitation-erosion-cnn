import 'activation_functions/sigmoid.dart';
import 'activation_functions/training_neuron_description.dart';

class Neuron {

  final int layer;
  final int number;
  final bool isCorrector;

  final prevLayerValues = <TrainingNeuronDescription>[];

  double _value = 0;
  double get value => _value;

  double _unsealedValue = 0;
  double get unsealedValue => _unsealedValue;

  double _error = 0;
  double get error => _error;

  Sigmoid sigmoid;

  Neuron({required this.layer, required this.number, required this.sigmoid, this.isCorrector = false});

  void initNeuron() {
    _value = isCorrector? 1 : 0;
    _error = 0;
    _unsealedValue = 0;
    prevLayerValues.clear();
  }

  void setExplicitValue(double value) {
    _value = value;
  }

  void addErrorValue(double value) {
    _error += value;
  }

  void addWeightedValue(TrainingNeuronDescription description) {
    _value += description.neuronValue * description.synapseWeight;
    prevLayerValues.add(description);
  }
  void sealValue() {
    _unsealedValue = value;
    _value = sigmoid.process(_value);
  }
}