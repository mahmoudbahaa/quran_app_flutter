import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recitations.dart';
import 'quran_api_client.dart';

/// Chapter reciter IDs are distinct from ayah-by-ayah recitation IDs.
class ContentCatalog {
  static List<int>? chapterIds;
  static Future<void> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_key);
    if (cached != null) {
      try {
        _apply(jsonDecode(cached) as Map<String, dynamic>);
      } on FormatException {
        /* Fetch a fresh catalog below. */
      } on TypeError {
        /* Ignore old or invalid cache formats. */
      }
    }
  }

  static String get _key =>
      'qf_content_catalog_${QuranApiClient.instance.cacheNamespace}';

  static Future<void> refresh() async {
    final client = QuranApiClient.instance;
    final results = await Future.wait([
      client.chapters(),
      client.chapterReciters(),
    ]);
    final data = {'chapters': results[0], 'reciters': results[1]};
    _apply(data);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  static void _apply(Map<String, dynamic> data) {
    final chapters = (data['chapters'] as List).cast<Map<String, dynamic>>();
    final rawReciters = (data['reciters'] as List).cast<Map<String, dynamic>>();
    if (chapters.isEmpty || rawReciters.isEmpty) {
      throw const FormatException('Empty catalog');
    }
    final ids = chapters.map((item) => item['id'] as int).toList();
    final normalized = rawReciters.map((item) {
      final style = item['style'];
      final translated = item['translated_name'];
      return <String, dynamic>{
        'id': item['id'] as int,
        'reciter_name': item['name'] as String,
        'style': style is Map ? style['name'] : style,
        'translated_name': translated is Map
            ? translated
            : {'name': item['name']},
      };
    }).toList();
    recitations
      ..clear()
      ..addAll(normalized);
    chapterIds = ids;
  }
}
