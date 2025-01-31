import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../exposed_models.dart' as exposed;
import 'connection/connection.dart' as impl;
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  // Languages,
  // Recitations,
  // TranslatedRecitationNames,
  // Surahs,
  Verses,
  VerseInfos,
  // RubHizbs,
  // RubHizbsInfos,
  Words,
  WordInfos,
  AudioFiles,
  VersesTimings,
  FontFiles
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(
          e ??
              driftDatabase(
                name: 'quran_app',
                native: const DriftNativeOptions(
                  databaseDirectory: getApplicationSupportDirectory,
                ),
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                  onResult: (result) {
                    if (result.missingFeatures.isNotEmpty) {
                      debugPrint(
                        'Using ${result.chosenImplementation} due to unsupported '
                        'browser features: ${result.missingFeatures}',
                      );
                    }
                  },
                ),
              ),
        );

  AppDatabase.forTesting(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        // Make sure that foreign keys are enabled
        await customStatement('PRAGMA foreign_keys = ON');
        // This follows the recommendation to validate that the database schema
        // matches what drift expects (https://drift.simonbinder.eu/docs/advanced-features/migrations/#verifying-a-database-schema-at-runtime).
        // It allows catching bugs in the migration logic early.
        await impl.validateDatabaseSchema(this);
      },
    );
  }

  Future<List<FontFile>> getFonts(int code) =>
      (select(fontFiles)..where((tbl) => tbl.code.equals(code))).get();

  Future<FontFile?> getFont(int code, int page) => (select(fontFiles)
        ..where((tbl) => tbl.code.equals(code) & tbl.page.equals(page)))
      .getSingleOrNull();

  Future<void> insertFont(int code, int page, Uint8List font) =>
      into(fontFiles).insert(FontFilesCompanion(
          code: Value(code), page: Value(page), font: Value(font)));

  Future<List<int?>> getWordsInfoLoaded(int code) {
    final query = selectOnly(wordInfos)
      ..addColumns([wordInfos.codeVersion, wordInfos.pageNumber])
      ..where(wordInfos.codeVersion.equals(code))
      ..groupBy([wordInfos.code, wordInfos.pageNumber]);

    return query.map((row) => row.read(wordInfos.pageNumber)).get();
  }

  Future<void> loadWordsInfo(int code, int page, dynamic data) async {
    transaction(() async {
      final versesData = data['verses'];
      for (int i = 0; i < versesData.length; i++) {
        final verseData = versesData[i];
        await into(verses).insertOnConflictUpdate(VersesCompanion(
          id: Value(verseData['verse_key']),
          juz: Value(verseData['juz_number']),
          hizb: Value(verseData['hizb_number']),
          rub: Value(verseData['rub_el_hizb_number']),
        ));

        assert(verseData['page_number'] == page);

        await into(verseInfos).insert(VerseInfosCompanion(
          verse: Value(verseData['verse_key']),
          code: Value(code),
          page: Value(page),
        ));

        final wordsData = verseData['words'];
        for (int j = 0; j < wordsData.length; j++) {
          final wordData = wordsData[j];
          await into(words).insertOnConflictUpdate(WordsCompanion(
            verse: Value(verseData['verse_key']),
            position: Value(wordData['position']),
            textUthmaniSimple: Value(wordData['text_uthmani_simple']),
            textImlaei: Value(wordData['text_imlaei']),
            textImlaeiSimple: Value(wordData['text_imlaei_simple']),
          ));

          await into(wordInfos).insert(WordInfosCompanion(
            verse: Value(verseData['verse_key']),
            position: Value(wordData['position']),
            codeVersion: Value(code),
            code: Value(wordData['code_v$code']),
            pageNumber: Value(wordData['page_number']),
            lineNumber: Value(wordData['line_number']),
          ));
        }
      }
    });
  }

  Future<List<exposed.WordInfo>> getLinesWords(int code, int page) {
    final query = (select(wordInfos)
          ..where(
              (wi) => wi.codeVersion.equals(code) & wi.pageNumber.equals(page))
          ..orderBy([(row) => OrderingTerm(expression: row.lineNumber)]))
        .join([
      innerJoin(
          words,
          wordInfos.verse.equalsExp(words.verse) &
              wordInfos.position.equalsExp(words.position))
    ]);

    return query.map((row) {
      final wi = row.readTable(wordInfos);
      final w = row.readTable(words);
      final word = exposed.Word(
          surah: int.parse(w.verse.split(':').first),
          verse: int.parse(w.verse.split(':').last),
          position: w.position,
          textUthmaniSimple: w.textUthmaniSimple,
          textImlaei: w.textImlaei,
          textImlaeiSimple: w.textImlaeiSimple);
      return exposed.WordInfo(
          codeVersion: wi.codeVersion,
          code: wi.code,
          line: wi.lineNumber,
          page: wi.pageNumber,
          word: word);
    }).get();
  }

  Future<AudioFile?> getVersesInfo(int surahNumber, int recitationId) {
    final query = select(audioFiles)
      ..where((tbl) =>
          tbl.surah.equals(surahNumber) & tbl.recitation.equals(recitationId));

    return query.getSingleOrNull();
  }

  Future<void> loadVerseInfo(
      int surahNumber, int recitationId, dynamic data) async {
    transaction(() async {
      final audioFileData = data['audio_files'][0];
      await into(audioFiles).insertOnConflictUpdate(AudioFilesCompanion(
        url: Value(audioFileData['audio_url']),
        surah: Value(audioFileData['chapter_id']),
        recitation: Value(recitationId),
        duration: Value(audioFileData['duration'].toDouble()),
        fileSize: Value(audioFileData['file_size']),
      ));

      final verseTimings = audioFileData['verse_timings'];
      for (int i = 0; i < verseTimings.length; i++) {
        final verseData = verseTimings[i];
        final segments = verseData['segments'];

        for (int j = 0; j < segments.length; j++) {
          if (segments[j].length != 3) continue;
          await into(versesTimings).insert(VersesTimingsCompanion(
            surah: Value(surahNumber),
            verse: Value(verseData['verse_key']),
            wordPosition: Value(segments[j][0]),
            from: Value(segments[j][1].floor()),
            to: Value(segments[j][2].floor()),
            recitation: Value(recitationId),
          ));
        }
      }
    });
  }

  Future<VerseTimings?> getCurrentSegment(int recitationId, int surah, int ms) {
    final query = select(versesTimings)
      ..where((tbl) =>
          tbl.recitation.equals(recitationId) &
          tbl.surah.equals(surah) &
          tbl.from.isSmallerOrEqualValue(ms) &
          tbl.to.isBiggerThanValue(ms));

    return query.getSingleOrNull();
  }

  Future<VerseTimings?> getSegment(
      int recitationId, int surah, int verse, int word) {
    final query = select(versesTimings)
      ..where((tbl) =>
          tbl.surah.equals(surah) &
          tbl.recitation.equals(recitationId) &
          tbl.verse.equals('$surah:$verse') &
          tbl.wordPosition.equals(word));

    return query.getSingleOrNull();
  }
}

class WordWithInfo {
  WordWithInfo(this.word, this.wordInfo);

  // The classes are generated by drift for each of the tables involved in the
  // join.
  final Word word;
  final WordInfo wordInfo;
}
