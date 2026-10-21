import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app_flutter/src/db/drift/database.dart';

void main() {
  test('cached fonts survive reopening with the upgraded SQLite runtime', () async {
    final directory = await Directory.systemTemp.createTemp('quran_database_');
    final file = File('${directory.path}/quran.sqlite');
    final bytes = Uint8List.fromList([1, 2, 3, 4]);
    var database = AppDatabase(NativeDatabase(file));
    try {
      await database.into(database.fontFiles).insert(
            FontFilesCompanion.insert(code: 1, page: 175, font: bytes),
          );
      await database.close();
      database = AppDatabase(NativeDatabase(file));
      final font = await database.select(database.fontFiles).getSingle();
      expect(font.code, 1);
      expect(font.page, 175);
      expect(font.font, bytes);
      final integrity = await database.customSelect('PRAGMA integrity_check').getSingle();
      expect(integrity.read<String>('integrity_check'), 'ok');
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });
}
