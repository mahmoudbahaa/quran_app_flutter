import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quran_app_flutter/src/api/quran_api_client.dart';
import 'package:quran_app_flutter/src/api/chapter_audio.dart';

void main() {
  test('decodes numeric glyph references without changing raw glyphs', () {
    expect(
      decodeGlyphCodes('&#xfb51;&#64338;'),
      String.fromCharCodes([0xfb51, 64338]),
    );
    expect(decodeGlyphCodes('بسم'), 'بسم');
  });
  test(
    'fetches every page with the selected mushaf and no credentials',
    () async {
      final requests = <Uri>[];
      final client = QuranApiClient(
        baseUrl: 'https://backend.example',
        client: MockClient((request) async {
          requests.add(request.url);
          expect(request.headers.containsKey('x-auth-token'), false);
          expect(request.headers.containsKey('authorization'), false);
          expect(request.url.queryParameters['mushaf'], '19');
          expect(request.url.queryParameters['per_page'], '50');
          final page = int.parse(request.url.queryParameters['page']!);
          return http.Response(
            jsonEncode({
              'verses': [
                {'verse_key': '1:$page'},
              ],
              'pagination': {'next_page': page == 1 ? 2 : null},
            }),
            200,
          );
        }),
      );
      final data = await client.pageWords(1, 19, 2);
      expect((data['verses'] as List).length, 2);
      expect(requests.length, 2);
    },
  );

  test('empty prelive layouts and looping pagination are errors', () async {
    for (final response in [
      {
        'verses': [],
        'pagination': {'next_page': null},
      },
      {
        'verses': [
          {'verse_key': '1:1'},
        ],
        'pagination': {'next_page': 1},
      },
    ]) {
      final client = QuranApiClient(
        client: MockClient(
          (_) async => http.Response(jsonEncode(response), 200),
        ),
      );
      await expectLater(
        client.pageWords(1, 2, 1),
        throwsA(isA<QuranApiException>()),
      );
    }
  });

  test('does not retry 403 and respects long Retry-After windows', () async {
    for (final status in [403, 429]) {
      var calls = 0;
      final client = QuranApiClient(
        client: MockClient((_) async {
          calls++;
          return http.Response('{}', status, headers: {'retry-after': '60'});
        }),
        delay: (_) async {},
      );
      await expectLater(client.chapters(), throwsA(isA<QuranApiException>()));
      expect(calls, 1);
    }
  });

  test('retries transient server failures with a bound', () async {
    var calls = 0;
    final client = QuranApiClient(
      client: MockClient((_) async {
        calls++;
        return http.Response(
          calls < 3 ? '{}' : '{"chapters": [{"id": 1}]}',
          calls < 3 ? 503 : 200,
        );
      }),
      delay: (_) async {},
    );
    expect((await client.chapters()).single['id'], 1);
    expect(calls, 3);
  });

  test('isolates caches by backend and rejects arbitrary hosts', () async {
    final a = QuranApiClient(baseUrl: 'https://prelive.example');
    final b = QuranApiClient(baseUrl: 'https://production.example');
    expect(a.cacheNamespace, isNot(b.cacheNamespace));
    await expectLater(
      a.getJson(Uri.parse('https://other.example/content/api/v4/chapters')),
      throwsArgumentError,
    );
    expect(
      () => QuranApiClient(baseUrl: 'http://backend.example'),
      throwsArgumentError,
    );
  });

  test('parses v4 audio with null segments and legacy marker entries', () {
    final parsed = ChapterAudio.fromJson({
      'audio_file': {
        'chapter_id': 1,
        'audio_url': 'https://audio.example/1.mp3',
        'file_size': 100,
        'timestamps': [
          {
            'verse_key': '1:1',
            'timestamp_to': 2000,
            'duration': -2000,
            'segments': [
              [1, 0, 1000],
              [1],
              [1, 0, 1000],
              [2, 1000, 1900],
            ],
          },
          {'verse_key': '1:2', 'timestamp_to': 3000, 'segments': null},
        ],
      },
    }, 1);
    expect(parsed.durationMs, 3000);
    expect(parsed.timings.length, 2);
    expect(parsed.fileSize, 100.0);
    final withoutTimings = ChapterAudio.fromJson({
      'audio_file': {
        'chapter_id': 1,
        'audio_url': 'https://audio.example/1.mp3',
        'file_size': 100,
      },
    }, 1);
    expect(withoutTimings.durationMs, 0);
    expect(withoutTimings.timings, isEmpty);
  });
}
