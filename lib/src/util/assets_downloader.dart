import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'enums.dart';
import 'file_utils.dart';

class AssetsDownloader {
  const AssetsDownloader();

  // final site = 'github.com/mahmoudbahaa/quran_app_flutter/raw/refs/heads/main/assets';
  final site = 'quran.com';
  final codeFontBaseUrl = const [
    'https://quran.com/fonts/quran/hafs/v1/ttf/p',
    'https://quran.com/fonts/quran/hafs/v2/ttf/p',
    'https://quran.com/fonts/quran/hafs/v4/colrv1/ttf/p',
    // 'https://quran.com/fonts/quran/hafs/v4/ot-svg/sepia/ttf/p',
  ];

  final codeFontPrefix = const ['', 'v2_', 'v4_'];
  final List<String> codeVersion = const ['code_v1', 'code_v2', 'code_v2'];
  static Map fontsLoaded = {};
  static Map imagesLoaded = {};

  String _getUrl(int pageNumber, int mushafId,
          TextRepresentation textRepresentation) =>
      'https://quran.com/api/proxy/content/api/qdc/verses/by_page/$pageNumber?per_page=all&mushaf=$mushafId&words=true&word_fields=${codeVersion[textRepresentation.index]}';

  bool isFontLoaded(int pageNumber, TextRepresentation textRepresentation) {
    final fontPrefix = codeFontPrefix[textRepresentation.index];
    final fontName = '${fontPrefix}page$pageNumber';

    return fontsLoaded[fontName] != null;
  }

  Future<void> loadPageFont(
      int pageNumber, TextRepresentation textRepresentation) async {
    final fontBaseUrl = codeFontBaseUrl[textRepresentation.index];
    final fontPrefix = codeFontPrefix[textRepresentation.index];
    final fontUrl = '$fontBaseUrl$pageNumber.ttf';
    final fontName = '${fontPrefix}page$pageNumber';

    if (isFontLoaded(pageNumber, textRepresentation)) return;
    await _loadFont(fontUrl, fontName);
    fontsLoaded[fontName] = true;
  }

  Future<void> _loadFont(String fontUrl, String fontName) async {
    try {
      File file = await FileUtils().getFile('fonts/$fontName');
      if (file.existsSync()) {
        final fontLoader = FontLoader(fontName);
        fontLoader.addFont(
            Future.value(ByteData.sublistView(file.readAsBytesSync())));
        await fontLoader.load();
        return;
      }

      // Download the font file
      final response = await http.get(Uri.parse(fontUrl));

      if (response.statusCode == 200) {
        file.createSync(recursive: true);
        file.writeAsBytesSync(response.bodyBytes);

        final fontLoader = FontLoader(fontName);

        fontLoader
            .addFont(Future.value(ByteData.sublistView(response.bodyBytes)));

        // Load the font into Flutter
        await fontLoader.load();
      } else {
        print('Failed to load font: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading font: $e');
    }
  }

  dynamic getWordsData(
      int pageNumber, TextRepresentation textRepresentation) async {
    final int mushafId = mushafIds[textRepresentation.index];
    File file = await FileUtils().getFile('data/${mushafId}_$pageNumber.json');
    if (file.existsSync()) return FileUtils().readJson(file);

    String url = _getUrl(pageNumber, mushafId, textRepresentation);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) return null;

    String jsonString = response.body;
    file.createSync(recursive: true);
    file.writeAsString(jsonString);
    return await json.decode(jsonString);
  }

  String? getImagePath(int pageNumber) {
    String key = 'background_$pageNumber';
    return imagesLoaded[key];
  }

  Future<void> loadImage(int pageNumber) async {
    String url =
        'https://github.com/mahmoudbahaa/quran_app_flutter/raw/refs/heads/main/assets/images/hollow/$pageNumber.png';
    String key = 'background_$pageNumber';
    File file = await FileUtils().getFile('images/background/$pageNumber.png');
    if (file.existsSync()) {
      imagesLoaded[key] = file.path;
      return;
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) return;
    file.createSync(recursive: true);
    file.writeAsBytesSync(response.bodyBytes);
    imagesLoaded[key] = file.path;
  }
}
