import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'enums.dart';

class QuranFontsLoader {
  const QuranFontsLoader();

  final codeFontBaseUrl = const [
    'https://github.com/mahmoudbahaa/quran_app_flutter/raw/refs/heads/main/assets/fonts/quran/hafs/v1/ttf/p',
    'https://github.com/mahmoudbahaa/quran_app_flutter/raw/refs/heads/main/assets/fonts/quran/hafs/v2/ttf/p',
    'https://github.com/mahmoudbahaa/quran_app_flutter/raw/refs/heads/main/assets/fonts/quran/hafs/v4/colrv1/ttf/p'
  ];

  final codeFontPrefix = const ['', 'v2_', 'v4_'];

  static Map fontsLoaded = {};

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
      Directory directory;
      if (Platform.isAndroid) {
        directory = (await getExternalStorageDirectory())!;
      } else {
        directory = (await getApplicationCacheDirectory());
      }

      File file = File('${directory.path}/fonts/$fontName');
      bool exists = file.existsSync();
      if (exists) {
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
        // print('Failed to load font: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error loading font: $e');
    }
  }
}
