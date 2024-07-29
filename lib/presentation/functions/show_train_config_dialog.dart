import 'package:diplom/presentation/entities/config_modes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<Map<String, dynamic>> showTrainConfigDialog(BuildContext context)  async {
  return await showDialog<Map<String, dynamic>>(context: context, builder: (context) {
    return const TrainConfigDialog();
  }) ?? {};
}

class TrainConfigDialog extends StatefulWidget {
  const TrainConfigDialog({super.key});

  @override
  State<TrainConfigDialog> createState() => _TrainConfigDialogState();
}

class _TrainConfigDialogState extends State<TrainConfigDialog> {

  static List<ConfigModes> conditionsModes = ConfigModes.values;
  List<Widget> conditions = List.generate(conditionsModes.length, (i){
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Text(conditionsModes[i].title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),),
    );
  });

  List<bool> selectedConfigMode = [true, false, false];

  @override
  Widget build(BuildContext context) {
    final TextEditingController formController = TextEditingController();

    return AlertDialog(
      title: const Center(child: Text("Настройки тренировки")),
      actions: [
        TextButton(onPressed: (){Navigator.pop(context, <String, dynamic>{});}, child: const Text("Отмена")),
        TextButton(onPressed: (){
          if (conditionsModes[selectedConfigMode.indexOf(true)] == ConfigModes.iterator && formController.text == "") {
            Navigator.of(context).pop(<String, dynamic>{});
            return;
          }
          final res = {
            "mode" : conditionsModes[selectedConfigMode.indexOf(true)],
            "value" : formController.text == "" ? null : formController.text,
          };
          Navigator.of(context).pop(res);
          return;
          }, child: const Text("Начать")),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ToggleButtons(
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < selectedConfigMode.length; i++) {
                    selectedConfigMode[i] = i == index;
                  }
                });
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              constraints: const BoxConstraints(
                minHeight: 40.0,
                minWidth: 80.0,
              ),
              isSelected: selectedConfigMode,
              children: conditions,
            ),
          ),
          Center(child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _DialogContent(conditionsModes[selectedConfigMode.indexOf(true)], formController),
          )),
          const Text("Выберите условие, при котором тренировка завершится", style: TextStyle(fontSize: 20, color: Colors.black26),)
        ],
      ),
    );
  }
}

class _DialogContent extends StatelessWidget {
  final ConfigModes mode;
  final TextEditingController controller;
  const _DialogContent(this.mode, this.controller);

  @override
  Widget build(BuildContext context) {
    late RegExp regExpFormat;

    if(mode != ConfigModes.endless) {
      regExpFormat = RegExp(mode.regExpFormat);
      return TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: mode.label,
            hintText: mode.hint,
            border: const OutlineInputBorder()
        ),
        inputFormatters: [
          TextInputFormatter.withFunction((oldValue, newValue){
            final oldValueValid = _isValid(oldValue.text, regExpFormat);
            final newValueValid = _isValid(newValue.text, regExpFormat);
            if (oldValueValid && !newValueValid) {
              return oldValue;
            }
            return newValue;
          }),
        ],
      );
    }

    return Text(mode.hint, style: const TextStyle(fontSize: 24),);

  }
  bool _isValid(String value, RegExp regExp) {
    try {
      final matches = regExp.allMatches(value);
      for (final Match match in matches) {
        if (match.start == 0 && match.end == value.length) {
          return true;
        }
      }
      return false;
    } catch (e) {
      // Invalid regex
      assert(false, e.toString());
      return true;
    }
  }

}

