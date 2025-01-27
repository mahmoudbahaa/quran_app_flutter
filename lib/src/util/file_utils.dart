import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FileUtils {
  FileUtils() {
    throw UnsupportedError('Can\'t initialize File Utils class');
  }

  static final int maxHttpRequestRetries = 5;

  static Future<Directory?> _getDownloadsDirectory() async {
    if (kIsWeb) return null;

    Directory directory;
    if (!kIsWeb && Platform.isAndroid) {
      directory = (await getExternalStorageDirectory())!;
    } else {
      directory = (await getApplicationCacheDirectory());
    }

    return directory;
  }

  static Future<File?> _getFile(String filePath) async {
    Directory? directory = await _getDownloadsDirectory();
    if (directory == null) return null;
    return File('${directory.path}/$filePath');
  }

  static dynamic readJson(File jsonFile) async {
    String jsonString = await jsonFile.readAsString();
    return await json.decode(jsonString);
  }

  static Future<Uint8List?> getFontFile(
      {required String fontName,
      required String url,
      required bool cacheOnly}) async {
    File? file = await _getFile('fonts/$fontName');
    return await _downloadIfNotExistBytes(
        file: file, url: url, cacheOnly: cacheOnly);
  }

  static Future<String?> getMushafModel(
      {required int mushafId,
      required int pageNumber,
      required String url,
      required bool cacheOnly}) async {
    File? file = await _getFile('models/${mushafId}_$pageNumber.json');
    return await _downloadIfNotExistString(
        file: file, url: url, cacheOnly: cacheOnly);
  }

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

  static Future<String?> getVersesInfoFile(
      {required int surahNumber,
      required int recitationId,
      required String url}) async {
    File? file = await _getFile('versesInfo/${recitationId}_$surahNumber');
    return await _downloadIfNotExistString(
        file: file, url: url, cacheOnly: false);
  }

  static Future<File?> _downloadIfNotExist(
      {required File? file, required String url, required cacheOnly}) async {
    try {
      if (file != null && file.existsSync()) {
        return file;
      }

      if (cacheOnly) return null;
      http.Response? response = await _downloadFile(file, url);
      if (response == null) return null;
      return file;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<String?> _downloadIfNotExistString(
      {required File? file, required String url, required cacheOnly}) async {
    try {
      if (file != null && file.existsSync()) {
        return file.readAsStringSync();
      }

      if (cacheOnly) return null;
      http.Response? response = await _downloadFile(file, url);
      if (response == null) return null;
      return response.body;
    } catch (e) {
      return null;
    }
  }

  static Future<Uint8List?> _downloadIfNotExistBytes(
      {required File? file,
      required String url,
      bool cacheOnly = false}) async {
    try {
      if (file != null && file.existsSync()) {
        return file.readAsBytesSync();
      }

      if (cacheOnly) return null;
      http.Response? response = await _downloadFile(file, url);
      if (response == null) return null;
      return response.bodyBytes;
    } catch (e) {
      return null;
    }
  }

  static Future<http.Response?> _downloadFile(File? file, String url) async {
    int retries = 0;
    while (retries < maxHttpRequestRetries) {
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          if (file != null) {
            file.createSync(recursive: true);
            file.writeAsBytesSync(response.bodyBytes);
          }

          return response;
        }

        retries++;
      } catch (e) {
        print(e);
        retries++;
      }
    }

    return null;
  }
}
