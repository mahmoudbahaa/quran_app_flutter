import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../db/db_utils/db_utils.dart';
import '../../models/enums.dart';

class AssetsLoaderService {
  AssetsLoaderService();

  // final Queue fontQueue = Queue(parallel: 1);
  final _maxRetries = 5;
  final _codeFontBaseUrl = const [
    'https://quran.com/fonts/quran/hafs/v1/ttf/p',
    'https://quran.com/fonts/quran/hafs/v2/ttf/p',
    'https://quran.com/fonts/quran/hafs/v4/colrv1/ttf/p',
    // 'https://quran.com/fonts/quran/hafs/v4/colrv1/woff2/p',
    // 'https://quran.com/fonts/quran/hafs/v4/ot-svg/sepia/ttf/p',
  ];

  final _codeFontSuffix = const [
    '.ttf',
    '.ttf',
    '.ttf',
    // '.woff2',
    // 'https://quran.com/fonts/quran/hafs/v4/ot-svg/sepia/ttf/p',
  ];

  String _getVerseDataUrl(int pageNumber, int mushafId,
          TextRepresentation textRepresentation, int codeVersion) =>
      'https://quran.com/api/proxy/content/api/qdc/verses/by_page/$pageNumber?per_page=all&mushaf=$mushafId&words=true&word_fields=code_v$codeVersion,text_uthmani_simple,text_imlaei,text_imlaei_simple';

  String _getPageImageUrl(int pageNumber) =>
      'https://github.com/mahmoudbahaa/quran_app_flutter/raw/refs/heads/main/assets/images/hollow/$pageNumber.png';

  Map<int, Uint8List> fonts = {};

  Future<bool> loadFont(int page, int code,
      TextRepresentation textRepresentation, bool dark, bool cacheOnly) async {
    final fontBaseUrl = _codeFontBaseUrl[textRepresentation.index];
    final fontSuffix = _codeFontSuffix[textRepresentation.index];
    final fontUrl = '$fontBaseUrl$page$fontSuffix';
    Uint8List? font = await DBUtils.getFontFile(
        code: code, page: page, url: fontUrl, dark: dark, cacheOnly: cacheOnly);
    if (font == null) return false;

    final fontName = '${code}_$page${dark ? '_dark' : ''}';

    final fontLoader = FontLoader(fontName);
    fontLoader.addFont(Future.value(ByteData.sublistView(font)));
    await Future.delayed(Duration(milliseconds: 50), fontLoader.load);

    return true;
  }

  Future<void> loadWordsData(
      int pageNumber,
      TextRepresentation textRepresentation,
      bool cacheOnly,
      int codeVersion) async {
    final int mushafId = mushafIds[textRepresentation.index];
    String url =
        _getVerseDataUrl(pageNumber, mushafId, textRepresentation, codeVersion);

    return await DBUtils.loadWordsData(
        code: codeVersion, page: pageNumber, url: url, cacheOnly: cacheOnly);
  }

  Future<File?> getPageImageFile(int pageNumber) async {
    return await DBUtils.getBackgroundImage(
        pageNumber: pageNumber, url: '', cacheOnly: true);
  }

  Future<String?> loadImage(int pageNumber, cacheOnly) async {
    String url = _getPageImageUrl(pageNumber);
    File? file = await DBUtils.getBackgroundImage(
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
