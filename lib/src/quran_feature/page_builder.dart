import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;

import '../data/verses_v1.dart';
import '../data/verses_v2.dart';
import '../data/verses_v4.dart';
import '../data/words_v1.dart';
import '../data/words_v2.dart';
import '../data/words_v4.dart';
import '../util/enums.dart';
import '../util/quran_fonts_loader.dart';
import '../util/quran_player_global_state.dart';

class PageBuilder {
  const PageBuilder();

  TextSpan getText(
      String element,
      String fontFamily,
      TextType type,
      int surahNumber,
      int verseNumber,
      int wordNumber,
      QuranPlayerGlobalState state,
      TextRepresentation textRepresentation,
      Function setState) {
    if (type == TextType.verse) {
      return TextSpan(
        text: element,
        style: TextStyle(
          fontFamily: fontFamily,
          height: 1.7,
        ),
        recognizer: LongPressGestureRecognizer()
          ..onLongPress = () {
            state.surahNumber = surahNumber;
            state.verseNumber = verseNumber;
            state.wordNumber = wordNumber;
            state.pageNumber =
                getPageNumber(surahNumber, verseNumber, textRepresentation);
            state.playing = false;
            setState(() => {});
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

  List<TextSpan> buildPage(
      QuranPlayerGlobalState state,
      int offset,
      int numPages,
      TextRepresentation textRepresentation,
      bool flowMode,
      Function setState) {
    final List<TextSpan> children = List.empty(growable: true);
    int pageNumber =
        offset + 1 + ((state.pageNumber - 1) / numPages).floor() * numPages;

    if (!QuranFontsLoader().isFontLoaded(pageNumber, textRepresentation)) {
      children.add(TextSpan(
          text: 'جاري تحميل الصفحة, برجاء الإنتظار',
          style: TextStyle(
            fontFamily: 'uthmanic3',
            height: 1.7,
          )));
      return children;
    }

    int highlightSurah = -1;
    int highlightVerse = -1;
    int highlightWord = -1;

    highlightSurah = state.surahNumber - 1;
    highlightVerse = state.verseNumber - 1;
    highlightWord = state.wordNumber - 1;

    int currentPageNumber = -1;
    int lineNumber = -1;
    int curLineNumber = -1;
    int surahNumber = quran.getPageData(pageNumber)[0]['surah'];

    int i = -1;
    String surahSep = '';
    while (true) {
      i++;
      if (i >= quran.getVerseCount(surahNumber)) {
        if (surahNumber < 114 &&
            pageNumber ==
                getPageNumber(surahNumber + 1, 1, textRepresentation)) {
          i = -1;
          surahNumber++;
          lineNumber = -1;
          continue;
        } else {
          break;
        }
      }

      currentPageNumber = getPageNumber(surahNumber, i + 1, textRepresentation);
      if (pageNumber != currentPageNumber) continue;

      final verseWords =
          getVersesWordsData(surahNumber, i + 1, textRepresentation);
      for (int j = 0; j < verseWords.length; j++) {
        curLineNumber = verseWords[j]['line_number'];

        if (i == 0 && j == 0) {
          if ((curLineNumber != 2 || surahNumber == 9) &&
              surahNumber != 1 &&
              surahNumber != 2) {
            String surahCode =
                '$surahSep${surahNumber.toString().padLeft(3, '0')}surah\n';
            children.add(getText(surahCode, 'surahNames', TextType.surahName,
                surahNumber, 1, 1, state, textRepresentation, setState));
          }

          if (surahNumber != 1 && surahNumber != 9) {
            children.add(getText('﷽\n', 'uthmanic3', TextType.bismallah,
                surahNumber, 1, 1, state, textRepresentation, setState));
          }
        }

        String sep = '';
        if (lineNumber == -1) {
          lineNumber = curLineNumber;
        } else if (lineNumber != curLineNumber) {
          lineNumber = curLineNumber;
          if (!flowMode) sep = '\n';
        }

        TextType type = (highlightSurah == surahNumber - 1 &&
                i == highlightVerse &&
                j == highlightWord)
            ? TextType.highlightedVerse
            : TextType.verse;
        String key = textRepresentation == TextRepresentation.codeV1
            ? 'code_v1'
            : 'code_v2';
        String prefix;
        if (textRepresentation == TextRepresentation.codeV1) {
          prefix = '';
        } else if (textRepresentation == TextRepresentation.codeV2) {
          prefix = 'v2_';
        } else {
          prefix = 'v4_';
        }

        final suffix = (curLineNumber == 1 || i == 0) &&
                j == 0 &&
                textRepresentation != TextRepresentation.codeV1
            ? ' '
            : '';

        final wordCode = '$sep${verseWords[j][key]}$suffix';
        final font = '${prefix}page$pageNumber';
        TextSpan wordSpan = getText(wordCode, font, type, surahNumber, i + 1,
            j + 1, state, textRepresentation, setState);
        children.add(wordSpan);
      }

      surahSep = '\n';
    }

    if (lineNumber == 14) {
      String surahCode =
          '$surahSep${surahNumber.toString().padLeft(3, '0')}surah\n';
      children.add(getText(surahCode, 'surahNames', TextType.surahName,
          surahNumber, 1, 1, state, textRepresentation, setState));
    }

    return children;
  }

  int getPageNumber(
      int surahNumber, int verseNumber, TextRepresentation textRepresentation) {
    final dynamic code = textRepresentation == TextRepresentation.codeV1
        ? versesV1
        : textRepresentation == TextRepresentation.codeV2
            ? versesV2
            : versesV4;
    return code[surahNumber - 1]['verses']![verseNumber - 1]['page_number']!;
  }

  getVersesWordsData(
      int surahNumber, int verseNumber, TextRepresentation textRepresentation) {
    final dynamic code = textRepresentation == TextRepresentation.codeV1
        ? wordsV1
        : textRepresentation == TextRepresentation.codeV2
            ? wordsV2
            : wordsV4;

    return code[surahNumber - 1]['verses'][verseNumber - 1]['words'];
  }
}
