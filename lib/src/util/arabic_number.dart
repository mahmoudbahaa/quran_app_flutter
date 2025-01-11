import 'package:get/get.dart';

class ArabicNumber {
  const ArabicNumber();

  String convertToLocaleNumber(int number) {
    if (Get.locale?.languageCode == 'en') return '$number';
    String res = '';
    String num = number.toString();

    final arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < num.length; i++) {
      res += arabicNumbers[int.parse(num[i])];
    }

    return res;
  }
}
