import 'package:diplom/presentation/widgets/option_button.dart';
import 'package:flutter/material.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 200,
          width: 350,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OptionButton(onTap: (){Navigator.pushNamed(context, '/test');}, icon: Icons.photo_outlined, text: "Test"),
              OptionButton(onTap: (){Navigator.pushNamed(context, '/train');}, icon: Icons.nat_outlined, text: "Training"),
            ],
          ),
        ),
      )
    );
  }
}
