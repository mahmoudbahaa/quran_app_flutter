import 'package:drift/drift.dart';

import 'database.dart' as d;

// class Languages extends Table {
//   TextColumn get languageCode => text().withLength(min: 2, max: 4)();
//   TextColumn get languageName => text().withLength(min: 2, max: 32)();
//
//   @override
//   Set<Column<Object>> get primaryKey => {languageCode};
// }
//
// class Recitations extends Table {
//   IntColumn get id => integer()();
//   TextColumn get reciterName => text().withLength(min: 6, max: 128)();
//   TextColumn get style => text().withLength(min: 6, max: 32)();
//
//   @override
//   Set<Column<Object>> get primaryKey => {id};
// }
//
// class TranslatedRecitationNames extends Table {
//   IntColumn get recitation => integer().references(Recitations, #id)();
//   TextColumn get name => text().withLength(min: 6, max: 128)();
//   TextColumn get language => text().references(Languages, #languageCode)();
//
//   @override
//   Set<Column<Object>> get primaryKey => {name, language};
// }
//
// class Surahs extends Table {
//   IntColumn get number => integer()();
//   TextColumn get language => text().references(Languages, #languageCode)();
//   TextColumn get name => text()();
//   TextColumn get translation => text().nullable()();
//
//   @override
//   Set<Column<Object>> get primaryKey => {number, language};
// }

class Verses extends Table {
  TextColumn get id => text().withLength(max: 8)(); //Surah:verseNumber
  IntColumn get juz => integer()();
  IntColumn get hizb => integer()();
  IntColumn get rub => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class VerseInfos extends Table {
  TextColumn get verse => text().references(Verses, #id)();
  IntColumn get code => integer()();
  IntColumn get page => integer()();

  @override
  Set<Column<Object>> get primaryKey => {verse, code};
}

// class RubHizbs extends Table {
//   IntColumn get id => integer()();
//   IntColumn get juz => integer()();
//   IntColumn get rub => integer()();
//
//   @override
//   Set<Column<Object>> get primaryKey => {id};
// }

// class RubHizbsInfos extends Table {
//   IntColumn get rubHizb => integer().references(RubHizbs, #id)();
//   TextColumn get startingVerse => text().references(Verses, #id)();
//
//   @override
//   Set<Column<Object>> get primaryKey => {rubHizb};
// }

class Words extends Table {
  TextColumn get verse => text().references(Verses, #id)();
  IntColumn get position => integer()();
  TextColumn get textUthmaniSimple => text()();
  TextColumn get textImlaei => text()();
  TextColumn get textImlaeiSimple => text()();

  @override
  Set<Column<Object>> get primaryKey => {verse, position};
}

class WordInfos extends Table {
  TextColumn get verse => text()();
  IntColumn get position => integer()();
  IntColumn get codeVersion => integer()();
  TextColumn get code => text()();
  IntColumn get pageNumber => integer()();
  IntColumn get lineNumber => integer()();

  @override
  Set<Column<Object>> get primaryKey => {verse, position, codeVersion};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY("verse", "position") REFERENCES "words" ("verse", "position") ON DELETE CASCADE ON UPDATE NO ACTION'
      ];
}

class AudioFiles extends Table {
  // IntColumn get recitation => integer().references(Recitations, #id)();
  // IntColumn get surah => integer().references(Surahs, #number)();
  IntColumn get recitation => integer()();
  IntColumn get surah => integer()();
  RealColumn get fileSize => real()();
  RealColumn get duration => real()();
  TextColumn get url => text()();

  @override
  Set<Column<Object>> get primaryKey => {recitation, surah};
}

@DataClassName('VerseTimings')
class VersesTimings extends Table {
  // IntColumn get recitation => integer().references(Recitations, #id)();
  // IntColumn get surah => integer().references(Surahs, #number)();
  IntColumn get recitation => integer()();
  IntColumn get surah => integer()();
  TextColumn get verse => text()();
  IntColumn get wordPosition => integer()();
  IntColumn get from => integer()();
  IntColumn get to => integer()();

  // @override
  // List<String> get customConstraints => [
  //       'FOREIGN KEY("verse", "word_position") REFERENCES "words" ("verse", "position") ON DELETE CASCADE ON UPDATE NO ACTION'
  //     ];
}

class FontFiles extends Table {
  IntColumn get code => integer()();
  IntColumn get page => integer()();
  BlobColumn get font => blob()();

  @override
  Set<Column<Object>> get primaryKey => {code, page};
}

class FontFile extends d.FontFile {
  FontFile({required super.code, required super.page, required super.font});

  @override
  int get code;
  @override
  int get page;
  @override
  Uint8List get font;
}
