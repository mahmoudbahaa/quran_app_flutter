import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:quran_app_flutter/src/db/drift/database.dart';
import 'package:quran_app_flutter/src/api/quran_api_client.dart';
import 'package:quran_app_flutter/src/api/chapter_audio.dart';

void main() {
  test(
    'live Worker serves chapters, chapter reciters, and v4 timed audio',
    () async {
      final client = QuranApiClient.instance;
      final chapters = await client.chapters();
      expect(chapters.any((item) => item['id'] == 1), true);
      final reciters = await client.chapterReciters();
      expect(reciters.any((item) => item['id'] == 7), true);
      final response = await client.getJson(client.chapterAudioUri(7, 1));
      final audio = ChapterAudio.fromJson(response, 1);
      expect(audio.chapter, 1);
      expect(audio.url, startsWith('https://'));
      expect(audio.timings, isNotEmpty);
      expect(audio.durationMs, greaterThan(0));
    },
    skip: !const bool.fromEnvironment('QURAN_LIVE_TEST'),
  );
  test('production page layouts persist for every supported mushaf', () async {
    final client = QuranApiClient.instance;
    expect((await client.chapters()).length, 114);
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    for (final layout in [
      (1, 2, 1),
      (1, 1, 2),
      (1, 19, 2),
      (175, 2, 1),
      (604, 2, 1),
    ]) {
      final (page, mushaf, code) = layout;
      final data = await client.pageWords(page, mushaf, code);
      await database.loadWordsInfo(code, page, mushaf, data);
      final words = await database.getLinesWords(code, page, mushaf);
      expect(words, isNotEmpty, reason: 'page $page, mushaf $mushaf');
      expect(
        words.every((word) => word.code.isNotEmpty && word.page == page),
        true,
      );
      expect(await database.getWordsInfoLoaded(code, mushaf), contains(page));
    }
  }, skip: !const bool.fromEnvironment('QURAN_PRODUCTION_TEST'));
}
