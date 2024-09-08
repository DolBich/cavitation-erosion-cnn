import 'package:flutter/material.dart';

class TrainUnit extends StatelessWidget {
  const TrainUnit({
    super.key,
    required this.name,
    required this.image,
    required this.expectedResult,
    required this.result,
    required this.error,
  });

  final String name;
  final ImageProvider image;
  final String? expectedResult;
  final String result;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final expectedResult = this.expectedResult;
    final error = this.error;
    List<String> titles = [];
    List<String> results = [];
    if(expectedResult != null) {
      results.add(expectedResult);
      titles.add("Ожидаемый результат");
    }
    results.add(result);
    titles.add("Получившийся результат");
    if(error != null) {
      results.add(error);
      // titles.add("Среднеквадратичная ошибка");
      titles.add("Ошибка");
    }

    return SizedBox(
      width: 1000,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: const EdgeInsetsDirectional.all(16), child: Text(name),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image(image: image, height: 300, width: 300, fit: BoxFit.fill,),
              SizedBox(
                width: 500,
                child: Table(
                  border: TableBorder.all(),
                  children: List.generate(2, (index) {
                    return TableRow(
                      children: List.generate(results.length, (i) {
                        return TableCell(child: Center(child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(index == 0 ? titles[i] : results[i]),
                        )));
                      })
                    );
                  }),
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}


