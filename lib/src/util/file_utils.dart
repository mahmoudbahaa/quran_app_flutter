import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileUtils {
  const FileUtils();

  Future<Directory> _getDownloadsDirectory() async {
    Directory directory;
    if (Platform.isAndroid) {
      directory = (await getExternalStorageDirectory())!;
    } else {
      directory = (await getApplicationCacheDirectory());
    }

    return directory;
  }

  Future<File> getFile(String filePath) async {
    Directory directory = await _getDownloadsDirectory();
    return File('${directory.path}/$filePath');
  }

  dynamic readJson(File jsonFile) async {
    String jsonString = await jsonFile.readAsString();
    return await json.decode(jsonString);
  }
}
