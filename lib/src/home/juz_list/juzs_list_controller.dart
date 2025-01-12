import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;

import '../../localization/app_localizations.dart';
import '../../models/rub_hizb_info.dart';
import '../../models/surah_names.dart';
import '../common/surah_info_list_controller.dart';

class JuzsListController extends SurahInfoListController {
  const JuzsListController();

  final maxVerseWords = 4;

  int getSurahNumber(int hizbNumber, int quarterNumber) {
    final int key = (hizbNumber - 1) * 4 + (quarterNumber - 1);
    final String verseKey = rubHizbInfo[key]['verse_key'] as String;
    return int.parse(verseKey.split(':')[0]);
  }

  int getPageNumber(int hizbNumber, int quarterNumber) {
    final int key = (hizbNumber - 1) * 4 + (quarterNumber - 1);
    return rubHizbInfo[key]['page_number'] as int;
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
      String surahName = surahNames[Get.locale?.languageCode][index];
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
