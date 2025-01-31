import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

import '../exposed_models.dart';

DBUtils dbUtils() => DBUtils.instance;
Future<void> initDbUtils() async {
  DBUtils.actualInstance = DBUtils();
}

class DBUtils {
  @protected
  static DBUtils? actualInstance;
  static final Lock _lock = Lock();

  static DBUtils get instance {
    if (actualInstance == null) throw UnsupportedError('not supported');
    return actualInstance!;
  }

  static final int _maxHttpRequestRetries = 5;

  @protected
  Future<FontFile?> getFont(int code, int page) async => null;
  @protected
  Future<List<FontFile>> getFonts(int code) async => [];
  @protected
  Future<void> insertFont(int code, int page, Uint8List font) async {}
  @protected
  Future<List<int?>> getWordsInfoLoaded(int code, int page) async => [];
  @protected
  Future<void> loadWordsInfo(int code, int page, dynamic data) async {}
  @protected
  Future<List<WordInfo>> getActualLinesWords(
          int code, int page, int line) async =>
      [];

  @protected
  Future<AudioFile?> getVersesInfo(int surahNumber, int recitationId) async =>
      null;
  @protected
  Future<void> loadVersesInfo(int surahNumber, int recitationId, data) async {}
  @protected
  Future<VerseTimings?> actualGetCurrentSegment(
          int recitationId, int surahNumber, int ms) async =>
      null;
  @protected
  Future<VerseTimings?> actualGetSegment(int recitationId, int surahNumber,
          int verseNumber, int wordNumber) async =>
      null;

  static Future<Directory?> _getAppRootDirectory() async {
    if (kIsWeb) return null;

    return (await getApplicationSupportDirectory());
  }

  static Future<String?> _getFilePath(String filePath) async {
    Directory? directory = await _getAppRootDirectory();
    if (directory == null) return null;
    return '${directory.path}/$filePath';
  }

  static Future<File?> _getFile(String filePath) async {
    String? resolvedFilePath = await _getFilePath(filePath);
    if (resolvedFilePath == null) return null;
    return File(resolvedFilePath);
  }

  static Map<int, Map<String, Uint8List>> fonts = {};

  static Future<void> _extractArchive(archivePath) async {
    final byteData = await rootBundle.load(archivePath);
    Uint8List xz = XZDecoder().decodeBytes(Uint8List.sublistView(byteData));
    final archive = TarDecoder().decodeBytes(xz);
    for (final entry in archive) {
      if (entry.isFile) {
        String? filePath = await _getFilePath(entry.name);
        if (filePath == null) break;
        OutputStream os = OutputFileStream(filePath);
        entry.writeContent(os);
        os.closeSync();
      }
    }
  }

  static Future<Uint8List?> getFontFile(
      {required int code,
      required int page,
      required String url,
      required bool dark,
      required bool cacheOnly}) async {
    String suffix = dark ? '_dark' : '';
    if (fonts[code] == null) {
      await _lock.synchronized(() async {
        if (fonts[code] == null) {
          List<FontFile> codeFonts = await instance.getFonts(code);
          final Map<String, Uint8List> loaded = {};
          for (FontFile codeFont in codeFonts) {
            loaded['${codeFont.page}'] = codeFont.font;
          }

          fonts[code] = loaded;
        }
      });
    }

    Uint8List? font = fonts[code]!['$page$suffix'];
    if (font != null) return font;
    if (cacheOnly) return null;
    if (dark) {
      File? file = await _getFile('ttf/4_${page}_dark.ttf');
      if (file == null) return null;
      if (!file.existsSync()) {
        await _extractArchive('assets/fonts/quran/tagweed-dark/ttf.tar.xz');
      }

      if (!file.existsSync()) return null;
      font = file.readAsBytesSync();
    } else {
      font = await _downloadIfNotExistBytes(url);
    }

    if (font == null) return null;

    if (!dark) await instance.insertFont(code, page, font);
    fonts[code]!['$page$suffix'] = font;
    return font;
  }

  static Map<int, List<int?>> wordsData = {};

  static Future<void> loadWordsData(
      {required int code,
      required int page,
      required String url,
      required bool cacheOnly}) async {
    if (wordsData[code] == null) {
      await _lock.synchronized(() async {
        if (wordsData[code] == null) {
          wordsData[code] = await instance.getWordsInfoLoaded(code, page);
        }
      });
    }

    if (cacheOnly) return;
    bool isLoaded = wordsData[code]!.contains(page);
    if (isLoaded) return;
    String? jsonString = await _downloadIfNotExistString(url);
    if (jsonString == null) return;

    dynamic data = await json.decode(jsonString);

    await instance.loadWordsInfo(code, page, data);
    wordsData[code]!.add(page);
  }

  static Future<List<WordInfo>> getLinesWords(
          {required int code, required int page, required int line}) async =>
      instance.getActualLinesWords(code, page, line);

  static Future<File?> getBackgroundImage(
      {required int pageNumber,
      required String url,
      required bool cacheOnly}) async {
    File? file = await _getFile('images/background/$pageNumber.png');
    return await _downloadIfNotExist(
        file: file, url: url, cacheOnly: cacheOnly);
  }

  static Future<File?> getMp3File(int recitationId, String fileName) async {
    return await _getFile('mp3/${recitationId}_$fileName');
  }

  static Future<AudioFile?> loadVersesData(
      {required int surahNumber,
      required int recitationId,
      required String url}) async {
    AudioFile? audioFile =
        await instance.getVersesInfo(surahNumber, recitationId);
    if (audioFile != null) return audioFile;

    String? jsonString = await _downloadIfNotExistString(url);
    if (jsonString == null) return null;
    dynamic data = jsonDecode(jsonString);
    await instance.loadVersesInfo(surahNumber, recitationId, data);

    return await instance.getVersesInfo(surahNumber, recitationId);
  }

  static Future<VerseTimings?> getCurrentSegment(
      int recitationId, int surahNumber, int ms) async {
    return await instance.actualGetCurrentSegment(
        recitationId, surahNumber, ms);
  }

  static Future<VerseTimings?> getSegment(int recitationId, int surahNumber,
      int verseNumber, int wordNumber) async {
    return await instance.actualGetSegment(
        recitationId, surahNumber, verseNumber, wordNumber);
  }

  static Future<File?> _downloadIfNotExist(
      {required File? file, required String url, required cacheOnly}) async {
    try {
      if (file != null && file.existsSync()) {
        return file;
      }

      if (cacheOnly) return null;
      http.Response? response = await _downloadFile(url);
      if (response == null) return null;
      return file;
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      return null;
    }
  }

  static Future<String?> _downloadIfNotExistString(String url) async {
    try {
      http.Response? response = await _downloadFile(url);
      if (response == null) return null;
      return response.body;
    } catch (e) {
      return null;
    }
  }

  static Future<Uint8List?> _downloadIfNotExistBytes(String url) async {
    try {
      http.Response? response = await _downloadFile(url);
      if (response == null) return null;
      return response.bodyBytes;
    } catch (e) {
      return null;
    }
  }

  static Future<http.Response?> _downloadFile(String url) async {
    int retries = 0;
    while (retries < _maxHttpRequestRetries) {
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) return response;
        retries++;
      } catch (e) {
        if (kDebugMode) debugPrint(e.toString());
        retries++;
      }
    }

    return null;
  }
}
