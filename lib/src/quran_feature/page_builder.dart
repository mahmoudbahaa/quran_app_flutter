import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../util/assets_downloader.dart';
import '../util/enums.dart';
import '../util/quran_player_global_state.dart';

class PageBuilder {
  const PageBuilder();

  static Map<String, dynamic> allData = {};

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
          backgroundColor: Get.theme.colorScheme.primary,
          fontFamily: fontFamily,
          height: 1.7,
        ),
      );
    } else {
      return TextSpan(
        text: element,
        style: TextStyle(
          fontFamily: fontFamily,
          height: 1.7,
        ),
      );
    }
  }

  List<TextSpan> buildPage(QuranPlayerGlobalState state, int offset,
      int numPages, TextRepresentation textRepresentation, Function update) {
    final List<TextSpan> children = List.empty(growable: true);
    int pageNumber =
        offset + 1 + ((state.pageNumber - 1) / numPages).floor() * numPages;

    if (!AssetsDownloader().isFontLoaded(pageNumber, textRepresentation)) {
      children.add(TextSpan(
          text: 'جاري تحميل الصفحة, برجاء الإنتظار',
          style: TextStyle(
            height: 1.7,
          )));
      AssetsDownloader()
          .loadPageFont(pageNumber, textRepresentation)
          .then((value) => update());
      return children;
    }

    int highlightSurah = state.surahNumber - 1;
    int highlightVerse = state.verseNumber - 1;
    int highlightWord = state.wordNumber - 1;

    int lineNumber = -1;
    // int curLineNumber = -1;
    // int surahNumber = quran.getPageData(pageNumber)[0]['surah'];

    final data = getCachedVersesWordsData(pageNumber, textRepresentation);
    if (data == null) {
      children.add(TextSpan(
          text: 'جاري تحميل الصفحة, برجاء الإنتظار',
          style: TextStyle(
            height: 1.7,
          )));
      loadVersesWordsData(pageNumber, textRepresentation).then((_) => update());
      return children;
    }

    final versesData = data['verses'];
    String surahSep = '';
    for (int i = 0; i < versesData.length; i++) {
      final verseData = versesData[i];
      String verseKey = verseData['verse_key'];
      int surahNumber = int.parse(verseKey.split(':').first);
      int verseNumber = int.parse(verseKey.split(':')[1]);

      QuranPlayerGlobalState newState = QuranPlayerGlobalState();
      newState
        ..pageNumber = pageNumber
        ..surahNumber = surahNumber
        ..verseNumber = 1
        ..wordNumber = 1;

      if (verseNumber == 1) {
        if (surahNumber > 2) {
          String surahCode =
              '$surahSep${surahNumber.toString().padLeft(3, '0')}surah\n';
          children.add(getText(surahCode, 'surahNames', TextType.surahName,
              state, newState, textRepresentation, update));
        }

        if (surahNumber != 1 && surahNumber != 9) {
          children.add(getText('﷽\n', 'uthmanic', TextType.bismallah, state,
              newState, textRepresentation, update));
        }
      }

      final wordsData = verseData['words'];

      newState.verseNumber = i + 1;
      for (int j = 0; j < wordsData.length; j++) {
        final wordData = wordsData[j];
        final curLineNumber = wordData['line_number'];
        String sep = '';
        if (lineNumber == -1) {
          lineNumber = curLineNumber;
        } else if (lineNumber != curLineNumber) {
          lineNumber = curLineNumber;
          sep = '\n';
        }

        TextType type = (highlightSurah == surahNumber - 1 &&
                i == highlightVerse &&
                j == highlightWord)
            ? TextType.highlightedVerse
            : TextType.verse;

        String key = codeKeys[textRepresentation.index];
        String prefix = prefixes[textRepresentation.index];
        final suffix = (curLineNumber == 1 || i == 0) &&
                j == 0 &&
                textRepresentation != TextRepresentation.codeV1
            ? ' '
            : '';

        final wordCode = '$sep${wordData[key]}$suffix';
        final font = '${prefix}page$pageNumber';
        newState.wordNumber = j + 1;
        TextSpan wordSpan = getText(
            wordCode, font, type, state, newState, textRepresentation, update);
        children.add(wordSpan);
      }

      surahSep = '\n';
    }

    return children;
  }

  dynamic getCachedVersesWordsData(
      int pageNumber, TextRepresentation textRepresentation) {
    String key = '${pageNumber}_${textRepresentation.index}';
    return allData[key];
  }

  Future<void> loadVersesWordsData(
      int pageNumber, TextRepresentation textRepresentation) async {
    dynamic data =
        await AssetsDownloader().getWordsData(pageNumber, textRepresentation);
    String key = '${pageNumber}_${textRepresentation.index}';
    allData[key] = data;
  }
}
