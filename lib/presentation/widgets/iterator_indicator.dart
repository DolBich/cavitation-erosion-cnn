import 'package:diplom/presentation/entities/config_modes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/app_bloc.dart';
import '../screens/train_screen.dart';

// class IteratorIndicator extends StatefulWidget {
//   final ConfigModes mode;
//   final String? value;
//   const IteratorIndicator({super.key, required this.mode, required this.value});
//
//   @override
//   State<IteratorIndicator> createState() => _IteratorIndicatorState();
// }

class IteratorIndicator extends StatelessWidget {
  final ConfigModes mode;
  final String? value;
  const IteratorIndicator({super.key, required this.mode, required this.value});
  // int iteration = 0;
  @override
  Widget build(BuildContext context) {

      return BlocBuilder<AppBloc, AppState>(
        buildWhen: (p, c) => p.iteration != c.iteration,
        builder: (context, state) {
          if (mode == ConfigModes.iterator) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Выполнено ${state.iteration}/$value"),
                  ),
                  LinearProgressIndicator(
                    value: state.iteration/double.parse(value ?? '1'),
                  )
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("Выполнено ${state.iteration} итераций"),
          );
        },
      );

  }
}
