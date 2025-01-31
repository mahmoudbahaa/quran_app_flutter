import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/settings/settings_controller.dart';

import '../db/db_utils/db_utils.dart';
import '../db/exposed_models.dart';
import '../home/assets_loader/assets_loader_controller.dart';
import '../models/enums.dart';
import '../util/quran_player_global_state.dart';

class PageBuilder {
  const PageBuilder(
      {required this.context,
      required this.state,
      required this.update,
      required this.fontSize,
      required this.textRepresentation});

  final BuildContext context;
  final fontCode = const [1, 2, 4];
  final code = const [1, 2, 2];
  final codeKeys = const ['code_v1', 'code_v2', 'code_v2'];
  final double lineHeight = 2.0;
  final QuranPlayerGlobalState state;
  final VoidCallback update;
  final TextRepresentation textRepresentation;
  final double fontSize;

  TextSpan getText(String element, String originalText, String fontFamily,
      TextType type, QuranPlayerGlobalState newState) {
    final pageNumber = newState.pageNumber;
    final surahNumber = newState.surahNumber;
    final verseNumber = newState.verseNumber;
    final wordNumber = newState.wordNumber;
    if (type == TextType.verse) {
      return TextSpan(
        text: element,
        semanticsLabel: originalText,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: fontFamily,
          height: lineHeight,
        ),
        recognizer: DoubleTapGestureRecognizer()
          ..onDoubleTap = () {
            state
              ..pageNumber = pageNumber
              ..surahNumber = surahNumber
              ..verseNumber = verseNumber
              ..wordNumber = wordNumber;
            state.playing = false;
            update();
          },
      );
    } else if (type == TextType.highlightedVerse) {
      return TextSpan(
        text: element,
        semanticsLabel: originalText,
        style: TextStyle(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          fontFamily: fontFamily,
          fontSize: fontSize,
          height: lineHeight,
        ),
      );
    } else if (type == TextType.surahName) {
      return TextSpan(
        text: element,
        semanticsLabel: originalText,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          // height: lineHeight,
        ),
      );
    } else {
      return TextSpan(
        text: element,
        semanticsLabel: element,
        style: TextStyle(
          fontSize: fontSize,
          // height: lineHeight,
        ),
      );
    }
  }

  // Future<List<InlineSpan>> buildPage(
  //     int pageNumber, SettingsController settingsController) async {
  //   final AssetsLoaderController assetsLoaderController =
  //       AssetsLoaderController(settingsController: settingsController);
  //   final List<InlineSpan> children = List.empty(growable: true);
  //
  //   if (!AssetsLoaderController(settingsController: settingsController)
  //       .isFontLoaded(pageNumber)) {
  //     children.add(TextSpan(
  //         text: 'جاري تحميل الصفحة, برجاء الإنتظار',
  //         style: TextStyle(
  //           height: 1.7,
  //           // fontSize: loadingFontSize,
  //         )));
  //     AssetsLoaderController(settingsController: settingsController)
  //         .loadPageFont(pageNumber)
  //         .then((value) => update());
  //     return children;
  //   }
  //
  //   children.add(TextSpan(
  //       text: 'جاري تحميل الصفحة, برجاء الإنتظار',
  //       style: TextStyle(
  //         height: 1.7,
  //         // fontSize: loadingFontSize,
  //       )));
  //
  //   assetsLoaderController.getWordsData(pageNumber).then((data) async =>
  //       await actualBuildPage(data, pageNumber, settingsController));
  //
  //   return children;
  // }

  Future<List<InlineSpan>> buildPage(bool isDark, int pageNumber,
      SettingsController settingsController) async {
    final AssetsLoaderController assetsLoaderController =
        AssetsLoaderController(settingsController: settingsController);
    await assetsLoaderController.loadPageFont(pageNumber,
        cacheOnly: false, dark: isDark);
    await assetsLoaderController.loadWordsData(pageNumber, cacheOnly: false);

    final codeVersion = code[settingsController.textRepresentation.index];
    final List<InlineSpan> children = List.empty(growable: true);

    int highlightSurah = state.surahNumber;
    int highlightVerse = state.verseNumber;
    int highlightWord = state.wordNumber;
    bool addBismallah = false;
    bool addSurahName = false;

    QuranPlayerGlobalState newState = QuranPlayerGlobalState();
    int surahNumber = -1;
    for (int line = 1; line <= 15; line++) {
      List<WordInfo> wordInfos = await DBUtils.getLinesWords(
          code: codeVersion, page: pageNumber, line: line);

      if (wordInfos.isEmpty) {
        if (line == 15) {
          surahNumber++;
          String surahCode = '${surahNumber.toString().padLeft(3, '0')}surah\n';
          String surahName = quran.getSurahNameArabic(surahNumber);
          children.add(getText(surahCode, surahName, 'surahNames',
              TextType.surahName, newState));
        }
        if (addBismallah) {
          addSurahName = true;
        } else {
          addBismallah = true;
        }

        continue;
      }
      for (int i = 0; i < wordInfos.length; i++) {
        WordInfo wordInfo = wordInfos[i];

        surahNumber = wordInfo.word.surah;
        int verseNumber = wordInfo.word.verse;
        int wordNumber = wordInfo.word.position;

        newState = QuranPlayerGlobalState()
          ..pageNumber = pageNumber
          ..surahNumber = surahNumber
          ..verseNumber = verseNumber
          ..wordNumber = wordNumber;

        if (addSurahName || (addBismallah && surahNumber == 9)) {
          String surahCode = '${surahNumber.toString().padLeft(3, '0')}surah\n';
          String surahName = quran.getSurahNameArabic(surahNumber);
          children.add(getText(surahCode, surahName, 'surahNames',
              TextType.surahName, newState));
          addSurahName = false;
        }

        if (addBismallah) {
          if (surahNumber != 1 && surahNumber != 9) {
            children.add(getText(
                '﷽\n', '﷽\n', 'uthmanic', TextType.bismallah, newState));
          }

          addBismallah = false;
        }

        final fontSuffix = isDark ? '_dark' : '';
        final font =
            '${fontCode[textRepresentation.index]}_$pageNumber$fontSuffix';
        final suffix = (line == 1 || i == 0) &&
                wordNumber == 1 &&
                textRepresentation != TextRepresentation.codeV1
            ? ' '
            // ? ''
            : '';

        TextType type = (highlightSurah == surahNumber &&
                highlightVerse == verseNumber &&
                highlightWord == wordNumber)
            ? TextType.highlightedVerse
            : TextType.verse;

        final wordCode = '${wordInfo.code}$suffix';
        final actualText = '${wordInfo.word.textImlaei} ';
        InlineSpan wordSpan =
            getText(wordCode, actualText, font, type, newState);
        children.add(wordSpan);
      }

      children.add(TextSpan(text: '\n', semanticsLabel: '\n'));
    }

    return children;

    // final versesData = data['verses'];
    // String surahSep = '';
    // for (int i = 0; i < versesData.length; i++) {
    //   final verseData = versesData[i];
    //   final wordsData = verseData['words'];
    //
    //   String verseKey = verseData['verse_key'];
    //   surahNumber = int.parse(verseKey.split(':').first);
    //   int verseNumber = int.parse(verseKey.split(':')[1]);
    //   int startingLineNumber = wordsData[0]['line_number'];
    //
    //   if (i == 0 && state.surahNumber == -1) {
    //     state.surahNumber = surahNumber;
    //     state.verseNumber = verseNumber;
    //     state.wordNumber = 1;
    //   }
    //
    //   QuranPlayerGlobalState newState = QuranPlayerGlobalState();
    //   newState
    //       // ..pageNumber = pageNumber
    //       .surahNumber = surahNumber;
    //
    //   if (verseNumber == 1) {
    //     newState
    //       ..verseNumber = 1
    //       ..wordNumber = 1;
    //     if (surahNumber > 2 && (startingLineNumber != 2 || surahNumber == 9)) {
    //       String surahSep = curLineNumber >= 1 ? '\n' : '';
    //       String surahCode =
    //           '$surahSep${surahNumber.toString().padLeft(3, '0')}surah\n';
    //       String surahName = quran.getSurahNameArabic(surahNumber);
    //       children.add(getText(surahCode, surahName, 'surahNames',
    //           TextType.surahName, newState));
    //     }
    //
    //     if (surahNumber != 1 && surahNumber != 9) {
    //       children
    //           .add(getText('﷽', '﷽', 'uthmanic', TextType.bismallah, newState));
    //     }
    //
    //     lineNumber = curLineNumber = 1;
    //   }
    //
    //   newState.verseNumber = verseNumber;
    //   int wordsCount = wordsData.length;
    //   for (int wordNumber = 1; wordNumber <= wordsCount; wordNumber++) {
    //     final wordData = wordsData[wordNumber - 1];
    //     curLineNumber = wordData['line_number'];
    //     String sep = '';
    //     if (lineNumber == -1) {
    //       lineNumber = curLineNumber;
    //     } else if (lineNumber != curLineNumber) {
    //       lineNumber = curLineNumber;
    //       sep = '\n';
    //     }
    //
    //     TextType type = (highlightSurah == surahNumber &&
    //             highlightVerse == verseNumber &&
    //             highlightWord == wordNumber)
    //         ? TextType.highlightedVerse
    //         : TextType.verse;
    //
    //     String key = codeKeys[textRepresentation.index];
    //     final font = '${fontCode[textRepresentation.index]}_$pageNumber';
    //     final suffix = (curLineNumber == 1 || i == 0) &&
    //             wordNumber == 1 &&
    //             textRepresentation != TextRepresentation.codeV1
    //         // ? ' '
    //         ? ''
    //         : '';
    //
    //     if (sep != '') {
    //       children.add(TextSpan(text: '\n', semanticsLabel: '\n'));
    //     }
    //
    //     final wordCode = '${wordData[key]}$suffix';
    //     final actualText = '${wordData['text_imlaei']} ';
    //     // final wordCode = '$sep\u0021';
    //     newState.wordNumber = wordNumber;
    //     InlineSpan wordSpan =
    //         getText(wordCode, actualText, font, type, newState);
    //     children.add(wordSpan);
    //   }
    //
    //   surahSep = '\n';
    // }
    //
    // if (curLineNumber == 14) {
    //   surahNumber++;
    //   QuranPlayerGlobalState newState = QuranPlayerGlobalState();
    //   newState
    //     // ..pageNumber = pageNumber
    //     ..surahNumber = surahNumber
    //     ..verseNumber = 1
    //     ..wordNumber = 1;
    //
    //   String surahCode =
    //       '$surahSep${surahNumber.toString().padLeft(3, '0')}surah\n';
    //   String surahName = quran.getSurahNameArabic(surahNumber);
    //   children.add(getText(
    //       surahCode, surahName, 'surahNames', TextType.surahName, newState));
    // }
    //
    // return children;
  }
}
