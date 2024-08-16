
import 'package:diplom/perceptron/perceptron.dart';
import 'package:diplom/presentation/screens/initial_screen.dart';
import 'package:diplom/presentation/screens/test_screen.dart';
import 'package:diplom/presentation/screens/train_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'application/app_bloc.dart';

void main() {
  runApp(
      BlocProvider<AppBloc>(
          create: (_) => AppBloc(),
          child:
      const MyApp()));
}

final Perceptron appPerceptron = Perceptron([6000, 10, 1], 1);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const InitialScreen(),
        '/train': (context) => const TrainScreen(),
        '/test': (context) => const TestScreen(),
      },
      initialRoute: '/',
    );
  }
}

