import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/util/arabic_number.dart';

import '../home/assets_loader/assets_loader_controller.dart';
import '../localization/app_localizations.dart';
import '../models/rub_hizb_info.dart';
import '../models/surah_names.dart';
import '../quran_page/quran_page_view.dart';
import '../settings/settings_controller.dart';
import '../util/quran_player_global_state.dart';

class QuranInfoController {
  const QuranInfoController();

  void goToPage(int pageNumber, int surahNumber, BuildContext context,
      SettingsController settingsController, QuranPlayerGlobalState state) {
    state.surahNumber = surahNumber;
    state.pageNumber = pageNumber;
    state.verseNumber = 1;
    state.wordNumber = -1;

    context.pushTransition(
      type: PageTransitionType.leftToRight,
      duration: Duration(milliseconds: 1000),
      childBuilder: (context) =>
          QuranPageView(settingsController: settingsController, state: state),
    );

    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => QuranPageView(
    //             settingsController: settingsController, state: state)));
  }

  void goNextPage(
      SettingsController settingsController, QuranPlayerGlobalState state) {
    if (!AssetsLoaderController(settingsController: settingsController)
            .isFontLoaded(state.pageNumber) ||
        state.pageNumber >=
            (quran.totalPagesCount - settingsController.numPages)) {
      return;
    }

    if (settingsController.numPages == 1) {
      state.pageNumber = state.pageNumber + 1;
    } else {
      state.pageNumber =
          ((state.pageNumber / settingsController.numPages).floor() + 1) *
                  settingsController.numPages +
              1;
    }

    state.surahNumber = -1;
    state.verseNumber = -1;
    state.wordNumber = -1;
    state.pause = true;
  }

  void goPreviousPage(
      SettingsController settingsController, QuranPlayerGlobalState state) {
    if (!AssetsLoaderController(settingsController: settingsController)
            .isFontLoaded(state.pageNumber) ||
        state.pageNumber <= settingsController.numPages) {
      return;
    }

    if (settingsController.numPages == 1) {
      state.pageNumber = state.pageNumber - 1;
    } else {
      state.pageNumber =
          ((state.pageNumber / settingsController.numPages).floor() - 1) *
                  settingsController.numPages +
              1;
    }

    state.surahNumber = -1;
    state.verseNumber = -1;
    state.wordNumber = -1;
    state.pause = true;
  }

  final maxVerseWords = 4;

  int getSurahNumber(int hizbNumber, int quarterNumber) {
    final int key = (hizbNumber - 1) * 4 + (quarterNumber - 1);
    final String verseKey = rubHizbInfo[key]['verse_key'] as String;
    return int.parse(verseKey.split(':')[0]);
  }

  String getRubHizbInfo(int surahNumber, int pageNumber, BuildContext context) {
    int juzNumber = quran.getJuzNumber(surahNumber, 1);
    String juz = AppLocalizations.of(context)!.juz;
    for (int i = 0; i < rubHizbInfo.length; i++) {
      int pageNum = rubHizbInfo[i]['page_number'] as int;
      if (pageNumber == pageNum) {
        String prefix = '';
        switch (i % 4) {
          case 0:
            prefix = '';
            break;
          case 1:
            prefix = '${AppLocalizations.of(context)!.quarter} ';
            break;
          case 2:
            prefix = '${AppLocalizations.of(context)!.half} ';
            break;
          case 3:
            prefix = '${AppLocalizations.of(context)!.quarter3} ';
            break;
        }

        String hizb = AppLocalizations.of(context)!.hizb;
        int hizbNumber = (i / 4 + 1).floor();
        String juz = AppLocalizations.of(context)!.juz;
        int juzNumber = (i / 8 + 1).floor();
        String comma = AppLocalizations.of(context)!.comma;
        return '$juz ${ArabicNumber().convertToLocaleNumber(juzNumber, context)}$comma $prefix $hizb ${ArabicNumber().convertToLocaleNumber(hizbNumber, context)}';
      }
    }
    return '$juz ${ArabicNumber().convertToLocaleNumber(juzNumber, context)}';
  }

  int getPageNumber(int hizbNumber, int quarterNumber) {
    final int key = (hizbNumber - 1) * 4 + (quarterNumber - 1);
    return rubHizbInfo[key]['page_number'] as int;
  }

  String getSurahName(BuildContext context, int index) {
    String surahPrefix = AppLocalizations.of(context)!.surahPrefix;
    String surahName =
        surahNames[Localizations.localeOf(context).languageCode][index];
    return '$surahPrefix$surahName';
  }

  String getSurahNameWithTranslation(int surahIndex, BuildContext context) {
    String langCode = Localizations.localeOf(context).languageCode;
    String surahTranslation =
        langCode == 'ar' ? '' : ' (${surahTranslations[langCode][surahIndex]})';

    return '${getSurahName(context, surahIndex)}$surahTranslation';
  }

  RubHizbVerseInfo getRubHizbPreview(
      int hizbNumber, int quarterNumber, BuildContext context) {
    final int key = (hizbNumber - 1) * 4 + (quarterNumber - 1);
    final String verseKey = rubHizbInfo[key]['verse_key'] as String;
    final int pageNumber = getPageNumber(hizbNumber, quarterNumber);
    final int surahNumber = int.parse(verseKey.split(':')[0]);
    final int verseNumber = int.parse(verseKey.split(':')[1]);
    final String verse = quran.getVerse(surahNumber, verseNumber);
    final List<String> words = verse.split(' ');
    String versePreview = '';
    if (words.length <= maxVerseWords) {
      versePreview = verse;
    } else {
      String sep = '';
      for (int i = 0; i < maxVerseWords; i++) {
        versePreview = '$versePreview$sep${words[i]}';
        sep = ' ';
      }

      versePreview = '$versePreview ﮳﮳﮳';
    }

    String getSurahName(BuildContext context, int index) {
      String surahPrefix = AppLocalizations.of(context)!.surahPrefix;
      String surahName =
          surahNames[Localizations.localeOf(context).languageCode][index];
      return '$surahPrefix$surahName';
    }

    String verseInfo =
        '${getSurahName(context, surahNumber - 1)} ${AppLocalizations.of(context)!.verse} ';
    return RubHizbVerseInfo(
        verseInfo: verseInfo,
        versePreview: versePreview,
        verseNumber: verseNumber,
        pageNumber: pageNumber);
  }
}

class RubHizbVerseInfo {
  const RubHizbVerseInfo(
      {required this.verseInfo,
      required this.versePreview,
      required this.verseNumber,
      required this.pageNumber});

  final String verseInfo;
  final String versePreview;
  final int verseNumber;
  final int pageNumber;
}
