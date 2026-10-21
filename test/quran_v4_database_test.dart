import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app_flutter/src/db/drift/database.dart';

Map<String, dynamic> pageData(String glyph, {int line = 1}) => {
  'verses': [
    {
      'verse_key': '1:1',
      'juz_number': 1,
      'hizb_number': 1,
      'rub_el_hizb_number': 1,
      'page_number': 1,
      'words': [
        {
          'position': 1,
          'text_uthmani_simple': 'بسم',
          'text_imlaei': 'بسم',
          'text_imlaei_simple': 'بسم',
          'code_v2': glyph,
          'page_number': 1,
          'line_number': line,
        },
      ],
    },
  ],
};
Map<String, dynamic> audioData({int to = 1000}) => {
  'audio_file': {
    'chapter_id': 1,
    'audio_url': 'https://audio.example/1.mp3',
    'file_size': 100,
    'timestamps': [
      {
        'verse_key': '1:1',
        'timestamp_to': to,
        'segments': [
          [1, 0, to],
        ],
      },
    ],
  },
};

void main() {
  test('V2 and Tajweed layouts cannot overwrite each other; page writes are atomic', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.loadWordsInfo(2, 1, 1, pageData('v2'));
    await db.loadWordsInfo(2, 1, 19, pageData('tajweed', line: 2));
    expect((await db.getLinesWords(2, 1, 1)).single.code, 'v2');
    expect((await db.getLinesWords(2, 1, 19)).single.code, 'tajweed');
    await db.loadWordsInfo(2, 1, 1, pageData('updated'));
    expect((await db.getLinesWords(2, 1, 1)).single.code, 'updated');
    final invalid = pageData('invalid');
    ((invalid['verses'] as List).first['words'] as List).first.remove(
      'code_v2',
    );
    await expectLater(db.loadWordsInfo(2, 1, 1, invalid), throwsA(anything));
    expect((await db.getLinesWords(2, 1, 1)).single.code, 'updated');
    expect(await db.getWordsInfoLoaded(2, 19), [1]);
  });

  test(
    'refreshing chapter timings replaces rows and completes before returning',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.loadVerseInfo(1, 7, audioData());
      expect((await db.getCurrentSegment(7, 1, 500))!.to, 1000);
      await db.loadVerseInfo(1, 7, audioData(to: 2000));
      expect((await db.select(db.versesTimings).get()).length, 1);
      expect((await db.getSegment(7, 1, 1, 1))!.to, 2000);
    },
  );

  test(
    'schema 1 upgrade preserves fonts and separates legacy layout rows',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'quran_v4_migration_',
      );
      final file = File('${directory.path}/db.sqlite');
      var db = AppDatabase(NativeDatabase(file));
      try {
        await db.insertFont(2, 1, Uint8List.fromList([1, 2, 3]));
        await db.loadWordsInfo(2, 1, 1, pageData('legacy'));
        await db.customStatement('DROP TABLE word_infos');
        await db.customStatement(
          'CREATE TABLE word_infos (verse TEXT NOT NULL, position INTEGER NOT NULL, code_version INTEGER NOT NULL, code TEXT NOT NULL, page_number INTEGER NOT NULL, line_number INTEGER NOT NULL, PRIMARY KEY (verse, position, code_version), FOREIGN KEY(verse, position) REFERENCES words(verse, position) ON DELETE CASCADE ON UPDATE NO ACTION)',
        );
        await db.customStatement(
          "INSERT INTO word_infos VALUES ('1:1', 1, 2, 'legacy', 1, 1)",
        );
        await db.customStatement('PRAGMA user_version = 1');
        await db.close();
        db = AppDatabase(NativeDatabase(file));
        expect((await db.getFont(2, 1))!.font, [1, 2, 3]);
        expect(await db.getWordsInfoLoaded(2, 1), isEmpty);
        await db.loadWordsInfo(2, 1, 19, pageData('tajweed'));
        expect((await db.getLinesWords(2, 1, 19)).single.code, 'tajweed');
      } finally {
        await db.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
