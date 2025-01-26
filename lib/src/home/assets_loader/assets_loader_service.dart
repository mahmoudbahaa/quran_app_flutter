import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../models/enums.dart';
import '../../util/file_utils.dart';

class AssetsLoaderService {
  const AssetsLoaderService();

  final _maxRetries = 5;
  final _codeFontBaseUrl = const [
    'https://quran.com/fonts/quran/hafs/v1/ttf/p',
    'https://quran.com/fonts/quran/hafs/v2/ttf/p',
    'https://quran.com/fonts/quran/hafs/v4/colrv1/ttf/p',
    // 'https://quran.com/fonts/quran/hafs/v4/ot-svg/sepia/ttf/p',
  ];

  String _getVerseDataUrl(int pageNumber, int mushafId,
          TextRepresentation textRepresentation, String codeVersion) =>
      'https://quran.com/api/proxy/content/api/qdc/verses/by_page/$pageNumber?per_page=all&mushaf=$mushafId&words=true&word_fields=$codeVersion,text_uthmani_simple,text_imlaei,text_imlaei_simple';

  String _getPageImageUrl(int pageNumber) =>
      'https://github.com/mahmoudbahaa/quran_app_flutter/raw/refs/heads/main/assets/images/hollow/$pageNumber.png';

  Future<bool> loadFont(int pageNumber, String fontPrefix,
      TextRepresentation textRepresentation, bool cacheOnly) async {
    final fontName = '${fontPrefix}page$pageNumber';
    final fontBaseUrl = _codeFontBaseUrl[textRepresentation.index];
    final fontUrl = '$fontBaseUrl$pageNumber.ttf';
    Uint8List? bytes = await FileUtils.getFontFile(
        fontName: fontName, url: fontUrl, cacheOnly: cacheOnly);
    if (bytes == null) return false;

    final fontLoader = FontLoader(fontName);
    fontLoader.addFont(Future.value(ByteData.sublistView(bytes)));
    await fontLoader.load();
    return true;
  }

  dynamic getWordsData(int pageNumber, TextRepresentation textRepresentation,
      bool cacheOnly, String codeVersion) async {
    final int mushafId = mushafIds[textRepresentation.index];
    String url =
        _getVerseDataUrl(pageNumber, mushafId, textRepresentation, codeVersion);

    String? jsonString = await FileUtils.getMushafModel(
        mushafId: mushafId,
        pageNumber: pageNumber,
        url: url,
        cacheOnly: cacheOnly);

    if (jsonString == null) return null;

    return await json.decode(jsonString);
  }

  Future<File?> getPageImageFile(int pageNumber) async {
    return await FileUtils.getBackgroundImage(
        pageNumber: pageNumber, url: '', cacheOnly: true);
  }

  Future<String?> loadImage(int pageNumber, cacheOnly) async {
    String url = _getPageImageUrl(pageNumber);
    File? file = await FileUtils.getBackgroundImage(
        pageNumber: pageNumber, url: url, cacheOnly: cacheOnly);
    if (file != null && file.existsSync()) {
      return file.path;
    }

    if (file == null) {
      return url;
    }

    if (cacheOnly) return null;
    for (int i = 0; i < _maxRetries; i++) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode != 200) continue;
        file.createSync(recursive: true);
        file.writeAsBytesSync(response.bodyBytes);
        return file.path;
      } catch (e) {
        //Do nothing
      }
    }

    return null;
  }
}
