import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  const FileUtils();

  Future<Directory?> _getDownloadsDirectory() async {
    if (kIsWeb) return null;

    Directory directory;
    if (!kIsWeb && Platform.isAndroid) {
      directory = (await getExternalStorageDirectory())!;
    } else {
      directory = (await getApplicationCacheDirectory());
    }

    return directory;
  }

  Future<File?> getFile(String filePath) async {
    Directory? directory = await _getDownloadsDirectory();
    if (directory == null) return null;
    return File('${directory.path}/$filePath');
  }

  dynamic readJson(File jsonFile) async {
    String jsonString = await jsonFile.readAsString();
    return await json.decode(jsonString);
  }
}
