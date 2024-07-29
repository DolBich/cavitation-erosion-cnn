import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  const OptionButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.text,
  });

  final void Function() onTap;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
          elevation: 2,
          clipBehavior: Clip.hardEdge,
          child: Container(
            width: 150,
            height: 200,
            // padding: padding,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F1EA),
              boxShadow: [
                BoxShadow(
                    offset: Offset(2, 4),
                    color: Color.fromRGBO(50, 50, 50, 0.3),
                    blurRadius: 4)
              ],
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                onHover: (_){},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(icon, size: 64,),
                    Text(text, textAlign: TextAlign.center,style: const TextStyle(fontSize: 20),),
                  ]
                ),
              ),
            ),
          ),
        );
  }
}
