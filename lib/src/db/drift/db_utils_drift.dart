import 'dart:typed_data';

import '../db_utils/db_utils.dart';
import '../exposed_models.dart' as exposed;
import 'database.dart';

DBUtils dbUtils() => DBUtils.instance;
Future<void> initDbUtils() async => DbUtilsDrift.init();

class DbUtilsDrift extends DBUtils {
  static late final AppDatabase _database;

  static Future<void> init() async {
    _database = AppDatabase();
    DBUtils.actualInstance = DbUtilsDrift();
  }

  @override
  Future<FontFile?> getFont(int code, int page) =>
      _database.getFont(code, page);

  @override
  Future<List<FontFile>> getFonts(int code) => _database.getFonts(code);

  @override
  Future<void> insertFont(int code, int page, Uint8List font) =>
      _database.insertFont(code, page, font);

  @override
  Future<List<int?>> getWordsInfoLoaded(int code, int page) =>
      _database.getWordsInfoLoaded(code);

  @override
  Future<void> loadWordsInfo(int code, int page, data) =>
      _database.loadWordsInfo(code, page, data);

  static final Map<String, List<exposed.WordInfo>> _cache =
      <String, List<exposed.WordInfo>>{};

  @override
  Future<List<exposed.WordInfo>> getActualLinesWords(
      int code, int page, int line) async {
    String cacheKey = '$code:$page';
    if (_cache[cacheKey] == null) {
      _cache[cacheKey] = await _database.getLinesWords(code, page);
    }

    return _cache[cacheKey]!.where((element) => element.line == line).toList();
  }

  @override
  Future<AudioFile?> getVersesInfo(int surahNumber, int recitationId) =>
      _database.getVersesInfo(surahNumber, recitationId);

  @override
  Future<void> loadVersesInfo(int surahNumber, int recitationId, data) =>
      _database.loadVerseInfo(surahNumber, recitationId, data);

  @override
  Future<VerseTimings?> actualGetCurrentSegment(
          int recitationId, int surahNumber, int ms) =>
      _database.getCurrentSegment(recitationId, surahNumber, ms);

  @override
  Future<VerseTimings?> actualGetSegment(
          int recitationId, int surahNumber, int verseNumber, int wordNumber) =>
      _database.getSegment(recitationId, surahNumber, verseNumber, wordNumber);
}
