import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/home/assets_loader/assets_loader_controller.dart';
import 'package:quran_app_flutter/src/settings/settings_controller.dart';

import '../models/enums.dart';
import '../util/quran_player_global_state.dart';

class PageBuilder {
  const PageBuilder({required this.context, required this.textRepresentation});

  final BuildContext context;
  final prefixes = const ['', 'v2_', 'v4_'];
  final codeKeys = const ['code_v1', 'code_v2', 'code_v2'];
  final double lineHeight = 1.7;
  final TextRepresentation textRepresentation;

  TextSpan getText(
      String element,
      String originalText,
      String fontFamily,
      TextType type,
      QuranPlayerGlobalState state,
      QuranPlayerGlobalState newState,
      Function update,
      double fontSize) {
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
        // recognizer: LongPressGestureRecognizer()
        //   ..onLongPress = () {
        //     state
        //       ..pageNumber = pageNumber
        //       ..surahNumber = surahNumber
        //       ..verseNumber = verseNumber
        //       ..wordNumber = wordNumber;
        //     state.playing = false;
        //     update();
        //   },
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
          height: lineHeight,
        ),
      );
    } else {
      return TextSpan(
        text: element,
        semanticsLabel: element,
        style: TextStyle(
          fontSize: fontSize,
          height: lineHeight,
        ),
      );
    }
  }

  List<InlineSpan> buildPage(QuranPlayerGlobalState state, int pageNumber,
      SettingsController settingsController, Function update, double fontSize) {
    final AssetsLoaderController assetsLoaderController =
        AssetsLoaderController(settingsController: settingsController);
    final List<InlineSpan> children = List.empty(growable: true);

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
        // ..pageNumber = pageNumber
        ..surahNumber = surahNumber;

      if (verseNumber == 1) {
        newState
          ..verseNumber = 1
          ..wordNumber = 1;
        if (surahNumber > 2 && (startingLineNumber != 2 || surahNumber == 9)) {
          String surahSep = curLineNumber > 1 ? '\n' : '';
          String surahCode =
              '$surahSep${surahNumber.toString().padLeft(3, '0')}surah\n';
          String surahName = quran.getSurahNameArabic(surahNumber);
          children.add(getText(surahCode, surahName, 'surahNames',
              TextType.surahName, state, newState, update, fontSize));
        }

        String sep = (startingLineNumber < 15 || pageNumber == 2) ? '\n' : '';
        if (surahNumber != 1 && surahNumber != 9) {
          children.add(getText('﷽$sep', '﷽$sep', 'uthmanic', TextType.bismallah,
              state, newState, update, fontSize));
        }
      }

      newState.verseNumber = verseNumber;
      int wordsCount = wordsData.length;
      for (int wordNumber = 1; wordNumber <= wordsCount; wordNumber++) {
        final wordData = wordsData[wordNumber - 1];
        curLineNumber = wordData['line_number'];
        String sep = '';
        if (lineNumber == -1) {
          lineNumber = curLineNumber;
        } else if (lineNumber != curLineNumber) {
          lineNumber = curLineNumber;
          sep = '\n';
        }

        TextType type = (highlightSurah == surahNumber - 1 &&
                highlightVerse == (verseNumber - 1) &&
                highlightWord == (wordNumber - 1))
            ? TextType.highlightedVerse
            : TextType.verse;

        String key = codeKeys[textRepresentation.index];
        String prefix = prefixes[textRepresentation.index];
        final suffix = (curLineNumber == 1 || i == 0) &&
                wordNumber == 1 &&
                textRepresentation != TextRepresentation.codeV1
            // ? ' '
            ? ''
            : '';

        if (sep != '') {
          children.add(TextSpan(text: '\n', semanticsLabel: '\n'));
        }

        final wordCode = '${wordData[key]}$suffix';
        final actualText = '${wordData['text_imlaei']} ';
        // final wordCode = '$sep\u0021';
        final font = '${prefix}page$pageNumber';
        newState.wordNumber = wordNumber;
        InlineSpan wordSpan = getText(wordCode, actualText, font, type, state,
            newState, update, fontSize);
        children.add(wordSpan);
      }

      surahSep = '\n';
    }

    if (curLineNumber == 14) {
      surahNumber++;
      QuranPlayerGlobalState newState = QuranPlayerGlobalState();
      newState
        // ..pageNumber = pageNumber
        ..surahNumber = surahNumber
        ..verseNumber = 1
        ..wordNumber = 1;

      String surahCode =
          '$surahSep${surahNumber.toString().padLeft(3, '0')}surah\n';
      String surahName = quran.getSurahNameArabic(surahNumber);
      children.add(getText(surahCode, surahName, 'surahNames',
          TextType.surahName, state, newState, update, fontSize));
    }

    // line.add(TextSpan(text: '\n'));
    // children.add(TextSpan(children: line));
    return children;
  }

  Widget getText2(
      String element,
      String originalText,
      String fontFamily,
      TextType type,
      QuranPlayerGlobalState state,
      QuranPlayerGlobalState newState,
      Function update,
      double fontSize) {
    final pageNumber = newState.pageNumber;
    final surahNumber = newState.surahNumber;
    final verseNumber = newState.verseNumber;
    final wordNumber = newState.wordNumber;
    if (type == TextType.verse) {
      return Text(
        element,
        semanticsLabel: originalText,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: fontFamily,
          height: lineHeight,
        ),
        // recognizer: LongPressGestureRecognizer()
        //   ..onLongPress = () {
        //     state
        //       ..pageNumber = pageNumber
        //       ..surahNumber = surahNumber
        //       ..verseNumber = verseNumber
        //       ..wordNumber = wordNumber;
        //     state.playing = false;
        //     update();
        //   },
      );
    } else if (type == TextType.highlightedVerse) {
      return Text(
        element,
        semanticsLabel: originalText,
        style: TextStyle(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          fontFamily: fontFamily,
          fontSize: fontSize,
          height: lineHeight,
        ),
      );
    } else if (type == TextType.surahName) {
      return Text(
        element,
        semanticsLabel: originalText,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          // height: lineHeight,
        ),
      );
    } else {
      return Text(
        element,
        semanticsLabel: originalText,
        style: TextStyle(
          fontSize: fontSize,
          // height: lineHeight,
        ),
      );
    }
  }

  void addToLine(List<Widget> line, Widget text) {
    line.add(text);
  }

  void addLine(List<Widget> lines, List<Widget> line, int pageNumber) {
    if (line.isEmpty) return;
    // lines.addAll(line);
    // double size = Get.mediaQuery.size.width / 4;
    lines.add(Row(
        // mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: pageNumber > 2
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: line));
  }

  List<Widget> buildPage2(QuranPlayerGlobalState state, int pageNumber,
      SettingsController settingsController, Function update, double fontSize) {
    final AssetsLoaderController assetsLoaderController =
        AssetsLoaderController(settingsController: settingsController);
    final List<Widget> lines = List.empty(growable: true);
    List<Widget> line = List.empty(growable: true);

    if (!AssetsLoaderController(settingsController: settingsController)
        .isFontLoaded(pageNumber)) {
      addToLine(
          line,
          Text('جاري تحميل الصفحة, برجاء الإنتظار',
              style: TextStyle(
                height: 1.7,
                // fontSize: loadingFontSize,
              )));
      AssetsLoaderController(settingsController: settingsController)
          .loadPageFont(pageNumber)
          .then((value) => update());
      return line;
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
      addToLine(
          line,
          Text('جاري تحميل الصفحة, برجاء الإنتظار',
              style: TextStyle(
                height: 1.7,
                // fontSize: loadingFontSize,
              )));
      assetsLoaderController
          .loadVersesWordsData(pageNumber)
          .then((_) => update());
      return line;
    }

    final versesData = data['verses'];
    for (int i = 0; i < versesData.length; i++) {
      final verseData = versesData[i];
      final wordsData = verseData['words'];

      String verseKey = verseData['verse_key'];
      surahNumber = int.parse(verseKey.split(':').first);
      int verseNumber = int.parse(verseKey.split(':')[1]);
      int startingLineNumber = wordsData[0]['line_number'];

      QuranPlayerGlobalState newState = QuranPlayerGlobalState();
      newState
        // ..pageNumber = pageNumber
        ..surahNumber = surahNumber;

      if (verseNumber == 1) {
        newState
          ..verseNumber = 1
          ..wordNumber = 1;
        if (surahNumber > 2 && (startingLineNumber != 2 || surahNumber == 9)) {
          String surahCode = '${surahNumber.toString().padLeft(3, '0')}surah\n';
          String surahName = quran.getSurahNameArabic(surahNumber);

          if (line.isNotEmpty) {
            addLine(lines, line, pageNumber);
            line = [];
          }

          addToLine(line, SizedBox(width: 1));
          addToLine(
              line,
              getText2(surahCode, surahName, 'surahNames', TextType.surahName,
                  state, newState, update, fontSize));
          addToLine(line, SizedBox(width: 1));

          addLine(lines, line, pageNumber);
          line = [];
        }

        if (surahNumber != 1 && surahNumber != 9) {
          addToLine(line, SizedBox(width: 1));
          addToLine(
              line,
              getText2('﷽', '﷽', 'uthmanic', TextType.bismallah, state,
                  newState, update, fontSize));
          addToLine(line, SizedBox(width: 1));

          addLine(lines, line, pageNumber);
          line = [];
        }
      }

      newState.verseNumber = verseNumber;
      int wordsCount = wordsData.length;
      for (int wordNumber = 1; wordNumber <= wordsCount; wordNumber++) {
        final wordData = wordsData[wordNumber - 1];
        curLineNumber = wordData['line_number'];
        String sep = '';
        if (lineNumber == -1) {
          lineNumber = curLineNumber;
        } else if (lineNumber != curLineNumber) {
          lineNumber = curLineNumber;
          sep = '\n';
        }

        TextType type = (highlightSurah == surahNumber - 1 &&
                highlightVerse == (verseNumber - 1) &&
                highlightWord == (wordNumber - 1))
            ? TextType.highlightedVerse
            : TextType.verse;

        String key = codeKeys[textRepresentation.index];
        String prefix = prefixes[textRepresentation.index];

        if (sep != '') {
          addLine(lines, line, pageNumber);
          line = [];
        }

        final wordCode = '${wordData[key]}';
        final actualText =
            '${wordData['text_uthmani_simple']}:${wordData['text_imlaei']}:${wordData['text_imlaei_simple']}\$';
        // final wordCode = '$sep\u0021';
        final font = '${prefix}page$pageNumber';
        newState.wordNumber = wordNumber;
        Widget wordSpan = getText2(wordCode, actualText, font, type, state,
            newState, update, fontSize);
        addToLine(line, wordSpan); // SelectableAdapterWidget(child: wordSpan));
      }
    }

    if (curLineNumber == 14) {
      surahNumber++;
      QuranPlayerGlobalState newState = QuranPlayerGlobalState();
      newState
        // ..pageNumber = pageNumber
        ..surahNumber = surahNumber
        ..verseNumber = 1
        ..wordNumber = 1;

      String surahCode = '${surahNumber.toString().padLeft(3, '0')}surah';
      String surahName = quran.getSurahNameArabic(surahNumber);

      if (line.isNotEmpty) {
        addLine(lines, line, pageNumber);
        line = [];
      }

      addToLine(line, SizedBox(width: 1));
      addToLine(
          line,
          getText2(surahCode, surahName, 'surahNames', TextType.surahName,
              state, newState, update, fontSize));
      addToLine(line, SizedBox(width: 1));
    }

    addLine(lines, line, pageNumber);
    line = [];
    return lines;
  }
}
