import 'dart:convert';
import 'dart:math';

import 'package:diplom/perceptron/synapse.dart';
import 'package:diplom/perceptron/training_data.dart';
import 'package:memoize/memoize.dart';


import 'activation_functions/sigmoid.dart';
import 'activation_functions/training_neuron_description.dart';
import 'neuron.dart';

class Perceptron {

  final alpha;

  final _neurons = <Neuron>[];
  final _synapses = <Synapse>[];
  final _synapseByContest = <int, Synapse>{};
  final _neuronByContest = <int, Neuron>{};

  late List<int> netConfiguration;
  // ActivationFunctionType _activationFunctionType;
  late Sigmoid _sigmoid;

  Perceptron(List<int> layers, this.alpha) {
    _init(layers);
  }

  Perceptron.fromJson(String json, [this.alpha=1]) {
    final Map<String, dynamic> loaded = jsonDecode(json);
    final layers = List<int>.from(loaded['netConfiguration']);
    final synapses = <Synapse>[];
    (loaded['synapses'] as List).forEach((next) =>
      synapses.add(Synapse(
        synapseLayer: next['layer'],
        originNeuron: next['origin'],
        destinationNeuron: next['destination'],
        weight: next['weight'],
      )));
    _init(layers, synapses);
  }

  void _init(List<int> layers, [List<Synapse>? initialSynapses]) {
    assert(layers.length == 3, 'This code must have only 3 layers');
    // _sigmoid = activationFunctionType;
    final function = Sigmoid();
    netConfiguration = layers;
    for (var i=0; i<layers.length; i++) {
      assert(layers[i] > 0, 'Neuron number in each layer should be positive');
      for (var j=0; j<layers[i]; j++) {
        _neurons.add(Neuron(layer: i, number: j, sigmoid: function));
      }
      if (i != layers.length-1) {
        _neurons.add(Neuron(layer: i, number: layers[i], sigmoid: function, isCorrector: true));
      }
    }
    if (initialSynapses == null) {
      int count = 0;
      for (var i = 0; i < layers.length - 1; i++) {
        for (var j = 0; j <= layers[i]; j++) {
          for (var k = 0; k < layers[i + 1]; k++) {
            print("synapse: $count");
            count++;
            _synapses.add(Synapse(
                synapseLayer: i,
                originNeuron: j,
                destinationNeuron: k,
                weight: Random().nextDouble() - 0.5
            ));
          }
        }
      }
    }
    else {
      _synapses.addAll(initialSynapses);
    }
  }

  List<double> process(List<double> input) {
    final stopwatch = Stopwatch();
    stopwatch.start();
    _neurons.forEach((n) => n.initNeuron());
    for (var i=0; i<netConfiguration.first; i++) {
      _getNeuronCached(0, i).setExplicitValue(input[i]);
    }
    for (var i=0; i<netConfiguration.length-1; i++) {
      _processSynapseLayer(i);
    }
    final res = <double>[];
    for (var i=0; i<netConfiguration.last; i++) {
      res.add(_getNeuronCached(netConfiguration.length-1, i).value);
    }
    stopwatch.stop();
    //print('processed in ${stopwatch.elapsedMilliseconds / 1000} sec');
    return res;
  }

  Map<String, List<double>> train(List<TrainingData> trainData) {
    final List<double> errors = [];
    List<double> results = [];
    for (var next in trainData) {
      if (next.inputData.length != netConfiguration.first) {
        print('Data for training should have the same number of inputs as the neurons number of entry layer of the network, skipping');
        continue;
      }
      if (next.outputData.length != netConfiguration.last) {
        print('Data for training should have the same number of outputs as the neurons number of exit layer of the network, skipping');
        continue;
      }
      final res = process(next.inputData);
      results.add(res.single); //TODO: Пока выход будет иметь только одно хначение, если сделаю так, чтобы обраюатывалось по блокам, то будет результат для каждого блока по порядку
      var errorValue = 0.0;
      for (var i=0; i<netConfiguration.last; i++) {
        errorValue += (next.outputData[i] - res[i]) * (next.outputData[i] - res[i]);
      }

      errors.add(errorValue/netConfiguration.last);

      for (var i=0; i<netConfiguration.last; i++) {
        final neuron = _getNeuronCached(netConfiguration.length-1, i);
        final sigma =
            (next.outputData[i] - neuron.value) * neuron.sigmoid.derivative(neuron.unsealedValue);
        for (var prevNeuron in neuron.prevLayerValues) {
          final deltaWeight = alpha * sigma * prevNeuron.neuronValue;
          _getSynapseCached(1, prevNeuron.neuronNumber, i).addWeight(deltaWeight);
          _getNeuronCached(1, prevNeuron.neuronNumber).addErrorValue(sigma * prevNeuron.synapseWeight);
        }
      }
      for (var i=0; i<netConfiguration[1]; i++) {
        final neuron = _getNeuronCached(netConfiguration.length-2, i);
        final sigma =
            neuron.error * neuron.sigmoid.derivative(neuron.unsealedValue);
        for (var prevNeuron in neuron.prevLayerValues) {
          final deltaWeight = alpha * sigma * prevNeuron.neuronValue;
          _getSynapseCached(0, prevNeuron.neuronNumber, i).addWeight(deltaWeight);
        }
      }
      print("index: ${trainData.indexOf(next)}, error : ${errors[trainData.indexOf(next)]}, results : ${results[trainData.indexOf(next)]}");
    }
    return {"errors" : errors, "results" : results};
  }

  //do not use this method - very special case is handled here
  // void trainForPic(List<TrainingData> trainData) {
  //   var counter = 0;
  //   for (var data in trainData) {
  //     if (data.inputData.length != netConfiguration.first) {
  //       print('Data for training should have the same number of inputs as the neurons number of entry layer of the network, skipping');
  //       continue;
  //     }
  //     if (data.outputData.length != netConfiguration.last) {
  //       print('Data for training should have the same number of outputs as the neurons number of exit layer of the network, skipping');
  //       continue;
  //     }
  //     final res = process(data.inputData);
  //     final output = data.outputData;
  //     if (output[3] == 0) {
  //       output[0] = res[0];
  //       output[1] = res[1];
  //       output[2] = res[2];
  //     }
  //     var errorValue = 0.0;
  //     for (var i=0; i<netConfiguration.last; i++) {
  //       errorValue += (output[i] - res[i]) * (output[i] - res[i]);
  //     }
  //     if (counter % 10 == 0) {
  //       print('err function: $errorValue');
  //     }
  //     for (var i=0; i<netConfiguration.last; i++) {
  //       final neuron = _getNeuronCached(netConfiguration.length-1, i);
  //       final sigma =
  //           (output[i] - neuron.value) * neuron.sigmoid.derivative(neuron.unsealedValue);
  //       for (var prevNeuron in neuron.prevLayerValues) {
  //         final deltaWeight = alpha * sigma * prevNeuron.neuronValue;
  //         _getSynapseCached(1, prevNeuron.neuronNumber, i).addWeight(deltaWeight);
  //         _getNeuronCached(1, prevNeuron.neuronNumber).addErrorValue(sigma * prevNeuron.synapseWeight);
  //       }
  //     }
  //     for (var i=0; i<netConfiguration[1]; i++) {
  //       final neuron = _getNeuronCached(netConfiguration.length-2, i);
  //       final sigma =
  //           neuron.error * neuron.sigmoid.derivative(neuron.unsealedValue);
  //       for (var prevNeuron in neuron.prevLayerValues) {
  //         final deltaWeight = alpha * sigma * prevNeuron.neuronValue;
  //         _getSynapseCached(0, prevNeuron.neuronNumber, i).addWeight(deltaWeight);
  //       }
  //     }
  //     counter++;
  //     if (counter % 100 == 0) {
  //       print('Trained cases: $counter');
  //     }
  //   }
  // }

  void _processSynapseLayer(int layer) {
    final sw = Stopwatch();
    sw.start();
    for (var i=0; i<=netConfiguration[layer]; i++) {
      final origin = _getNeuronCached(layer, i);
      for (var j=0; j<netConfiguration[layer+1]; j++) {
        final destination = _getNeuronCached(layer+1, j);
        final synapse = _getSynapseCached(layer, i, j);
        destination.addWeightedValue(
          TrainingNeuronDescription(neuronValue: origin.value, synapseWeight: synapse.weight, neuronNumber: i)
        );
      }
    }
    sw.stop();
    //print('cached = ${sw.elapsedMicroseconds} microsec');
    sw.reset();
    _neurons.where((n) => n.layer == layer + 1).forEach((f) => f.sealValue());
  }

  final _getNeuron = memo3((List<Neuron> neurons, int layer, int number) => neurons.singleWhere((n) => n.layer == layer && n.number == number));
  final _getSynapse = memo4((List<Synapse> synapses, int layer, int origin, int destination) =>
      synapses.singleWhere((s) => s.synapseLayer == layer && s.originNeuron == origin && s.destinationNeuron == destination));

  Neuron _getNeuronCached(int layer, int number) { // Сортировка нейронов по слоям и по местам в слое
    final index = layer*6000+number;

    final res = _neuronByContest[index];
    if (res != null) {
      return res;
    }
    final data = _getNeuron(_neurons, layer,number);
    _neuronByContest[index] = data;
    return data;
  }

  Synapse _getSynapseCached(int layer, int origin, int destination) {
    final index = layer*10000000+origin*1000+destination;
    final res = _synapseByContest[index];
    if (res != null) {
      return res;
    }
    final data = _getSynapse(_synapses, layer, origin, destination);
    _synapseByContest[index] = data;
    return data;
  }

  String toJson() {
    final map = <String, Object>{};
    map['netConfiguration'] = netConfiguration;
    map['activationFunction'] = _sigmoid;
    map['synapses'] = _synapses.map((s) => s.toJson()).toList();
    return jsonEncode(map);
  }
}
