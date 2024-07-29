import 'package:flutter/material.dart';

Future<void> showSuccessDialog(BuildContext context) async{
  return showDialog(context: context, builder: (context) {
    return const _SuccessDialog();
  });
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text("Тренировка закончилась!", style: TextStyle(fontSize: 54),),
      actions: [
        Center(
          child: TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: const Text("Хорошо")),
        )
      ],
    );
  }
}
