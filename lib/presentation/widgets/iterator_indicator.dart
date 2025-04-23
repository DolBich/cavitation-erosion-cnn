import 'package:diplom/application/app_bloc.dart';
import 'package:diplom/presentation/entities/config_modes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IteratorIndicator extends StatelessWidget {

  const IteratorIndicator({super.key});
  @override
  Widget build(BuildContext context) {

      return BlocBuilder<AppBloc, AppState>(
        buildWhen: (p, c) => p.iteration != c.iteration || p.trainingConfig != c.trainingConfig,
        builder: (context, state) {
          final mode = state.trainingConfig?.mode;
          final value = state.trainingConfig?.value;
          if(mode == null) {
            return const SizedBox();
          }
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
                    value: state.iteration/ (value ?? 1),
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
