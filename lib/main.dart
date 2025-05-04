import 'package:diplom/application/app_bloc.dart';
import 'package:diplom/cnn/erosion_net.dart';
import 'package:diplom/presentation/screens/initial_screen.dart';
import 'package:diplom/presentation/screens/test_screen.dart';
import 'package:diplom/presentation/screens/train_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



const String DEFAULT_FILE_NAME = 'model.json';
const double TRAIN_SPEED = 0.001;

void main() async {
  final initialNet = await ErosionNet.loadFromFile(DEFAULT_FILE_NAME);
  runApp(
    BlocProvider<AppBloc>(create: (_) => AppBloc(initialNet), child: const MyApp()),
  );
}

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
