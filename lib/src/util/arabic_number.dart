

class ArabicNumber {
  const ArabicNumber();

  String convertToArabicNumber(int number) {
    String res = '';
    String num = number.toString();

    final arabics = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < num.length; i++) {
      res += arabics[int.parse(num[i])];
    }

    return res;
  }
}