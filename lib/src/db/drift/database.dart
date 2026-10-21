import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../exposed_models.dart' as exposed;
import '../../api/quran_api_client.dart';
import '../../api/chapter_audio.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
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
    FontFiles,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
    : super(
        e ??
            driftDatabase(
              name:
                  'quran_content_v4_${QuranApiClient.instance.cacheNamespace}',
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.alterTable(
            TableMigration(wordInfos, newColumns: [wordInfos.mushafId]),
          );
        }
      },
      beforeOpen: (details) async {
        // Make sure that foreign keys are enabled
        await customStatement('PRAGMA foreign_keys = ON');
        // This follows the recommendation to validate that the database schema
        // matches what drift expects (https://drift.simonbinder.eu/docs/advanced-features/migrations/#verifying-a-database-schema-at-runtime).
        // It allows catching bugs in the migration logic early.

        if (kDebugMode) {
          await validateDatabaseSchema();
        }
      },
    );
  }

  Future<List<FontFile>> getFonts(int code) =>
      (select(fontFiles)..where((tbl) => tbl.code.equals(code))).get();

  Future<FontFile?> getFont(int code, int page) =>
      (select(fontFiles)
            ..where((tbl) => tbl.code.equals(code) & tbl.page.equals(page)))
          .getSingleOrNull();

  Future<void> insertFont(int code, int page, Uint8List font) => into(fontFiles)
      .insertOnConflictUpdate(
        FontFilesCompanion(
          code: Value(code),
          page: Value(page),
          font: Value(font),
        ),
      );

  Future<List<int?>> getWordsInfoLoaded(int code, int mushaf) {
    final query = selectOnly(wordInfos)
      ..addColumns([wordInfos.codeVersion, wordInfos.pageNumber])
      ..where(
        wordInfos.codeVersion.equals(code) & wordInfos.mushafId.equals(mushaf),
      )
      ..groupBy([wordInfos.pageNumber]);

    return query.map((row) => row.read(wordInfos.pageNumber)).get();
  }

  Future<void> loadWordsInfo(
    int code,
    int page,
    int mushaf,
    dynamic data,
  ) async {
    await transaction(() async {
      var loadedWords = 0;
      final versesData = data['verses'];
      if (versesData is! List || versesData.isEmpty) {
        throw const FormatException('Empty page');
      }
      await (delete(wordInfos)..where(
            (row) =>
                row.codeVersion.equals(code) &
                row.mushafId.equals(mushaf) &
                row.pageNumber.equals(page),
          ))
          .go();
      for (int i = 0; i < versesData.length; i++) {
        final verseData = versesData[i];
        await into(verses).insertOnConflictUpdate(
          VersesCompanion(
            id: Value(verseData['verse_key']),
            juz: Value(verseData['juz_number']),
            hizb: Value(verseData['hizb_number']),
            rub: Value(verseData['rub_el_hizb_number']),
          ),
        );

        await into(verseInfos).insertOnConflictUpdate(
          VerseInfosCompanion(
            verse: Value(verseData['verse_key']),
            code: Value(code),
            page: Value(page),
          ),
        );

        final wordsData = verseData['words'];
        if (wordsData is! List || wordsData.isEmpty) {
          throw const FormatException('Missing page words');
        }
        for (int j = 0; j < wordsData.length; j++) {
          final wordData = wordsData[j];
          if (wordData['page_number'] is! int) {
            throw const FormatException('Missing word page');
          }
          if (wordData['page_number'] != page) continue;
          if (wordData['code_v$code'] is! String ||
              wordData['line_number'] is! int) {
            throw const FormatException('Missing Quran layout data');
          }
          loadedWords++;
          await into(words).insertOnConflictUpdate(
            WordsCompanion(
              verse: Value(verseData['verse_key']),
              position: Value(wordData['position']),
              textUthmaniSimple: Value(wordData['text_uthmani_simple'] ?? ''),
              textImlaei: Value(wordData['text_imlaei'] ?? ''),
              textImlaeiSimple: Value(wordData['text_imlaei_simple'] ?? ''),
            ),
          );

          await into(wordInfos).insertOnConflictUpdate(
            WordInfosCompanion(
              mushafId: Value(mushaf),
              verse: Value(verseData['verse_key']),
              position: Value(wordData['position']),
              codeVersion: Value(code),
              code: Value(decodeGlyphCodes(wordData['code_v$code'] as String)),
              pageNumber: Value(wordData['page_number']),
              lineNumber: Value(wordData['line_number']),
            ),
          );
        }
      }
      if (loadedWords == 0) {
        throw const FormatException('Page contains no layout words');
      }
    });
  }

  Future<List<exposed.WordInfo>> getLinesWords(int code, int page, int mushaf) {
    final query =
        (select(wordInfos)
              ..where(
                (wi) =>
                    wi.codeVersion.equals(code) &
                    wi.pageNumber.equals(page) &
                    wi.mushafId.equals(mushaf),
              )
              ..orderBy([(row) => OrderingTerm(expression: row.lineNumber)]))
            .join([
              innerJoin(
                words,
                wordInfos.verse.equalsExp(words.verse) &
                    wordInfos.position.equalsExp(words.position),
              ),
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
        textImlaeiSimple: w.textImlaeiSimple,
      );
      return exposed.WordInfo(
        codeVersion: wi.codeVersion,
        code: wi.code,
        line: wi.lineNumber,
        page: wi.pageNumber,
        word: word,
      );
    }).get();
  }

  Future<AudioFile?> getVersesInfo(int surahNumber, int recitationId) {
    final query = select(audioFiles)
      ..where(
        (tbl) =>
            tbl.surah.equals(surahNumber) & tbl.recitation.equals(recitationId),
      );

    return query.getSingleOrNull();
  }

  Future<void> loadVerseInfo(
    int surahNumber,
    int recitationId,
    dynamic data,
  ) async {
    final audio = ChapterAudio.fromJson(
      Map<String, dynamic>.from(data as Map),
      surahNumber,
    );
    await transaction(() async {
      await into(audioFiles).insertOnConflictUpdate(
        AudioFilesCompanion(
          url: Value(audio.url),
          surah: Value(surahNumber),
          recitation: Value(recitationId),
          duration: Value(audio.durationMs.toDouble()),
          fileSize: Value(audio.fileSize),
        ),
      );
      await (delete(versesTimings)..where(
            (row) =>
                row.surah.equals(surahNumber) &
                row.recitation.equals(recitationId),
          ))
          .go();
      await batch((batch) {
        batch.insertAll(
          versesTimings,
          audio.timings
              .map(
                (timing) => VersesTimingsCompanion.insert(
                  surah: surahNumber,
                  verse: timing.verse,
                  wordPosition: timing.word,
                  from: timing.from,
                  to: timing.to,
                  recitation: recitationId,
                ),
              )
              .toList(),
        );
      });
    });
  }

  Future<VerseTimings?> getCurrentSegment(int recitationId, int surah, int ms) {
    final query = select(versesTimings)
      ..where(
        (tbl) =>
            tbl.recitation.equals(recitationId) &
            tbl.surah.equals(surah) &
            tbl.from.isSmallerOrEqualValue(ms) &
            tbl.to.isBiggerThanValue(ms),
      );

    query.orderBy([(row) => OrderingTerm.desc(row.from)]);
    query.limit(1);
    return query.getSingleOrNull();
  }

  Future<VerseTimings?> getSegment(
    int recitationId,
    int surah,
    int verse,
    int word,
  ) {
    final query = select(versesTimings)
      ..where(
        (tbl) =>
            tbl.surah.equals(surah) &
            tbl.recitation.equals(recitationId) &
            tbl.verse.equals('$surah:$verse') &
            tbl.wordPosition.equals(word),
      );

    query.orderBy([(row) => OrderingTerm.asc(row.from)]);
    query.limit(1);
    return query.getSingleOrNull();
  }
}

class WordWithInfo {
  WordWithInfo(this.word, this.wordInfo);

  // The classes are generated by drift for each of the tables involved in the
  // join.
  final DatabaseWord word;
  final DatabaseWordInfo wordInfo;
}
