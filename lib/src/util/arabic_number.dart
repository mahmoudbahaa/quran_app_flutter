import 'package:flutter/cupertino.dart';

class ArabicNumber {
  const ArabicNumber();

  String convertToLocaleNumber(int number, BuildContext context) {
    String langCode = Localizations.localeOf(context).languageCode;
    if (langCode != 'ar') return number.toString();

    String res = '';
    String num = number.toString();

    final arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < num.length; i++) {
      res += arabicNumbers[int.parse(num[i])];
    }

    return res;
  }
}
