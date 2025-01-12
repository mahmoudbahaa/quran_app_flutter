import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app_flutter/src/home/common/surah_info_list_controller.dart';

import '../../localization/app_localizations.dart';
import '../../models/surah_names.dart';

class SurahsListController extends SurahInfoListController {
  const SurahsListController();

  String _getSurahName(BuildContext context, int index) {
    String surahPrefix = AppLocalizations.of(context)!.surahPrefix;
    String surahName = surahNames[Get.locale?.languageCode][index];
    return '$surahPrefix$surahName';
  }

  getSurahNameWithTranslation(int surahIndex, BuildContext context) {
    String surahTranslation = Get.locale?.languageCode == 'ar'
        ? ''
        : ' (${surahTranslations[Get.locale?.languageCode][surahIndex]})';

    return '${_getSurahName(context, surahIndex)}$surahTranslation';
  }
}
