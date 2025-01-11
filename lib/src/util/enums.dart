enum AppLocale { ar, en }

const List<String> appLocales = ['العربية', 'English'];
const List<String> rtlLanguages = <String>[
  'ar', // Arabic
  'fa', // Farsi
  'he', // Hebrew
  'ps', // Pashto
  'ur', // Urdu
];

enum TextType {
  surahName,
  bismallah,
  verse,
  highlightedVerse,
}

enum TextRepresentation {
  codeV1,
  codeV2,
  codeV4,
}

final mushafIds = [2, 1, 19];

enum PageTransition {
  nextPage,
  previousPage,
  noChange,
}
