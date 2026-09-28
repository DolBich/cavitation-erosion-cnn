# Diplom

A Flutter application demonstrating a custom convolutional neural network implemented from scratch in Dart.

## Overview

This project combines a Flutter application with a custom neural network implementation.

Instead of relying on a machine learning framework for the model itself, the project implements the core neural network operations directly in Dart, including convolutional layers, batch normalization, pooling, dense layers, forward propagation, backpropagation, and weight updates.

The application provides a UI for preparing training samples, running training, inspecting predictions, and saving/loading trained models.

## Neural Network

The model is implemented as `ErosionNet` and consists of:

* 3 convolutional blocks
* Batch normalization
* LeakyReLU activation
* Max pooling
* 2 fully connected layers
* Sigmoid output activation

The network supports both forward and backward propagation and updates its parameters during training.

## Training

The application provides a training workflow for working with image samples.

Training samples store:

* Input image
* Expected coefficient
* Predicted coefficient
* Prediction error

The training process can be started and stopped from the application UI.

## Model Persistence

The neural network architecture and learned parameters can be serialized to JSON and restored later.

This allows trained models to be saved and reused without retraining from scratch.

## Architecture

The project separates the neural network implementation from the application layer.

```text id="t7c1r4"
lib/
├── application/
├── cnn/
├── domain/
└── presentation/
```

The `cnn` layer contains the neural network implementation, while the application and presentation layers handle training workflows and user interaction.

## Tech Stack

* Flutter / Dart
* Flutter BLoC
* Custom CNN implementation
* Batch normalization
* Backpropagation
* Image processing
* File Picker
* JSON model serialization

## Project Status

This is a research/academic project demonstrating the implementation of a neural network and a training workflow in Dart/Flutter.

The repository is kept public as a technical showcase of algorithmic and machine learning related work.
