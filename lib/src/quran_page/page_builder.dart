import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app_flutter/src/home/assets_loader/assets_loader_controller.dart';
import 'package:quran_app_flutter/src/settings/settings_controller.dart';

import '../models/enums.dart';
import '../util/quran_player_global_state.dart';

class PageBuilder {
  const PageBuilder();

  final prefixes = const ['', 'v2_', 'v4_'];
  final codeKeys = const ['code_v1', 'code_v2', 'code_v2'];

  TextSpan getText(
      String element,
      String fontFamily,
      TextType type,
      QuranPlayerGlobalState state,
      QuranPlayerGlobalState newState,
      TextRepresentation textRepresentation,
      Function update) {
    final pageNumber = newState.pageNumber;
    final surahNumber = newState.surahNumber;
    final verseNumber = newState.verseNumber;
    final wordNumber = newState.wordNumber;
    if (type == TextType.verse) {
      return TextSpan(
        text: element,
        style: TextStyle(
          fontFamily: fontFamily,
          height: 1.7,
        ),
        recognizer: LongPressGestureRecognizer()
          ..onLongPress = () {
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
        style: TextStyle(
          backgroundColor: Get.theme.colorScheme.inversePrimary,
          fontFamily: fontFamily,
          height: 1.7,
        ),
      );
    } else if (type == TextType.surahName) {
      return TextSpan(
        text: element,
        style: TextStyle(
          fontFamily: fontFamily,
          height: 1.7,
        ),
      );
    } else {
      return TextSpan(
        text: element,
        style: TextStyle(
          height: 1.7,
        ),
      );
    }
  }

  List<TextSpan> buildPage(QuranPlayerGlobalState state, int offset,
      int numPages, SettingsController settingsController, Function update) {
    final AssetsLoaderController assetsLoaderController =
        AssetsLoaderController(settingsController: settingsController);
    final List<TextSpan> children = List.empty(growable: true);
    int pageNumber =
        offset + 1 + ((state.pageNumber - 1) / numPages).floor() * numPages;

    if (!AssetsLoaderController(settingsController: settingsController)
        .isFontLoaded(pageNumber)) {
      children.add(TextSpan(
          text: 'جاري تحميل الصفحة, برجاء الإنتظار',
          style: TextStyle(
            height: 1.7,
            // fontSize: loadingFontSize,
          )));
      AssetsLoaderController(settingsController: settingsController)
          .loadPageFont(pageNumber)
          .then((value) => update());
      return children;
    }

    int highlightSurah = state.surahNumber - 1;
    int highlightVerse = state.verseNumber - 1;
    int highlightWord = state.wordNumber - 1;

    int lineNumber = -1;
    int curLineNumber = -1;
    int surahNumber = -1;
    // int surahNumber = quran.getPageData(pageNumber)[0]['surah'];

    final data = assetsLoaderController.getCachedVersesWordsData(pageNumber);
    if (data == null) {
      children.add(TextSpan(
          text: 'جاري تحميل الصفحة, برجاء الإنتظار',
          style: TextStyle(
            height: 1.7,
            // fontSize: loadingFontSize,
          )));
      assetsLoaderController
          .loadVersesWordsData(pageNumber)
          .then((_) => update());
      return children;
    }

    final versesData = data['verses'];
    String surahSep = '';
    for (int i = 0; i < versesData.length; i++) {
      final verseData = versesData[i];
      final wordsData = verseData['words'];

      String verseKey = verseData['verse_key'];
      surahNumber = int.parse(verseKey.split(':').first);
      int verseNumber = int.parse(verseKey.split(':')[1]);
      int startingLineNumber = wordsData[0]['line_number'];

      QuranPlayerGlobalState newState = QuranPlayerGlobalState();
      newState
        ..pageNumber = pageNumber
        ..surahNumber = surahNumber;

      if (verseNumber == 1) {
        newState
          ..verseNumber = 1
          ..wordNumber = 1;
        if (surahNumber > 2 && (startingLineNumber != 2 || surahNumber == 9)) {
          String surahCode =
              '$surahSep${surahNumber.toString().padLeft(3, '0')}surah\n';
          children.add(getText(surahCode, 'surahNames', TextType.surahName,
              state, newState, settingsController.textRepresentation, update));
        }

        String sep = (startingLineNumber < 4 || pageNumber == 2) ? '\n' : '';
        if (surahNumber != 1 && surahNumber != 9) {
          children.add(getText('﷽$sep', 'uthmanic', TextType.bismallah, state,
              newState, settingsController.textRepresentation, update));
        }
      }

      newState.verseNumber = verseNumber;
      int wordsCount = wordsData.length;
      for (int j = 0; j < wordsCount; j++) {
        final wordData = wordsData[j];
        curLineNumber = wordData['line_number'];
        String sep = '';
        if (lineNumber == -1) {
          lineNumber = curLineNumber;
        } else if (lineNumber != curLineNumber) {
          lineNumber = curLineNumber;
          sep = '\n';
        }

        TextType type = (highlightSurah == surahNumber - 1 &&
                highlightVerse == verseNumber - 1 &&
                j == highlightWord)
            ? TextType.highlightedVerse
            : TextType.verse;

        String key = codeKeys[settingsController.textRepresentation.index];
        String prefix = prefixes[settingsController.textRepresentation.index];
        final suffix = (curLineNumber == 1 || i == 0) &&
                j == 0 &&
                settingsController.textRepresentation !=
                    TextRepresentation.codeV1
            ? ' '
            : '';

        final wordCode = '$sep${wordData[key]}$suffix';
        // final wordCode = '$sep\u0021';
        final font = '${prefix}page$pageNumber';
        newState.wordNumber = j + 1;
        TextSpan wordSpan = getText(wordCode, font, type, state, newState,
            settingsController.textRepresentation, update);
        children.add(wordSpan);
      }

      surahSep = '\n';
    }

    if (curLineNumber == 14) {
      surahNumber++;
      QuranPlayerGlobalState newState = QuranPlayerGlobalState();
      newState
        ..pageNumber = pageNumber
        ..surahNumber = surahNumber
        ..verseNumber = 1
        ..wordNumber = 1;

      String surahCode =
          '$surahSep${surahNumber.toString().padLeft(3, '0')}surah\n';
      children.add(getText(surahCode, 'surahNames', TextType.surahName, state,
          newState, settingsController.textRepresentation, update));
    }

    return children;
  }
}
