import 'package:flutter_test/flutter_test.dart';
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
}
