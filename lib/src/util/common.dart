import 'package:flutter/material.dart';

import 'number_utils.dart';

void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  String valueSuffix = '',
  required double value,
  required Stream<double> stream,
  required ValueChanged<double> onChanged,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => SizedBox(
          height: 100.0,
          child: Column(
            children: [
              Text('${(snapshot.data ?? value).toStringAsFixed(1)}$valueSuffix',
                  style: const TextStyle(
                      fontFamily: 'Fixed',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
              Slider(
                divisions: divisions,
                min: min,
                max: max,
                value: snapshot.data ?? value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void showNumberSelectDialog({
  required BuildContext context,
  required String title,
  required int min,
  required int max,
  String valueSuffix = '',
  required int initialValue,
  required ValueChanged<Object?> onChanged,
}) {
  List<DropdownMenuItem<int>>? pages = [];
  for (int i = min; i <= max; i++) {
    pages.add(
      DropdownMenuItem(
        value: i,
        child: Text(NumberUtils.convertToLocaleNumber(i, context)),
      ),
    );
  }

  int? value = initialValue;
  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: DropdownButton<int>(
          onChanged: (newValue) {
            Navigator.of(context, rootNavigator: true).pop();
            // Navigator.pop(context);
            onChanged(newValue);
            setState(() => value = newValue);
          },
          value: value ?? initialValue,
          items: pages,
        ),
      ),
    ),
  );
}

T? ambiguate<T>(T? value) => value;
