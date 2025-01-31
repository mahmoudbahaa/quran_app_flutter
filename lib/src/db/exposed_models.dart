export 'drift/database.dart' show AudioFile, VerseTimings, FontFile;

class Word {
  Word(
      {required this.verse,
      required this.position,
      required this.surah,
      required this.textUthmaniSimple,
      required this.textImlaei,
      required this.textImlaeiSimple});

  final int surah;
  final int verse;
  final int position;
  final String textUthmaniSimple;
  final String textImlaei;
  final String textImlaeiSimple;
}

class WordInfo {
  WordInfo(
      {required this.codeVersion,
      required this.page,
      required this.line,
      required this.code,
      required this.word});

  final int codeVersion;
  final int page;
  final int line;
  final String code;
  final Word word;
}
//
// abstract class AudioFile {
//   int get recitation;
//   int get surah;
//   double get fileSize;
//   double get duration;
//   String get url;
//   List<VerseTimings> get verseTimings;
// }
//
// abstract class VerseTimings {
//   String? verse;
//   int? wordPosition;
//   double? from;
//   double? to;
// }
//
// abstract class FontFile {
//   int get code;
//   int get page;
//   Uint8List get font;
// }
