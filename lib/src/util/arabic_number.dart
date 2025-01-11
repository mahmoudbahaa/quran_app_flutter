import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArabicNumber {
  const ArabicNumber();

  Text convertToLocaleNumber(int number, {double fontSize = -1}) {
    if (Get.locale?.languageCode != 'ar') return Text('$number');
    String res = '';
    String num = number.toString();

    final arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < num.length; i++) {
      res += arabicNumbers[int.parse(num[i])];
    }

    if (fontSize < 0) return Text(res, style: TextStyle(fontFamily: 'Roboto'));
    return Text(res,
        style: TextStyle(fontFamily: 'Roboto', fontSize: fontSize));
  }
}
