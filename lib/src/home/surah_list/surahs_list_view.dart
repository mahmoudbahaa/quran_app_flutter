import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;

import '../../localization/app_localizations.dart';
import '../../models/surah_names.dart';
import '../../settings/settings_controller.dart';
import '../../util/arabic_number.dart';
import '../../util/quran_player_global_state.dart';
import '../../view/quran_chapters_details_view.dart';

class SurahsListView extends StatelessWidget {
  const SurahsListView(
      {super.key, required this.settingsController, required this.state});

  final QuranPlayerGlobalState state;
  final SettingsController settingsController;

  String _getSurahName(BuildContext context, int index) {
    String surahPrefix = AppLocalizations.of(context)!.surahPrefix;
    String surahName = surahNames[Get.locale?.languageCode][index];
    return '$surahPrefix$surahName';
  }

  void goToPage(int pageNumber, int surahNumber) {
    state.surahNumber = surahNumber;
    state.pageNumber = pageNumber;
    state.verseNumber = 1;
    state.wordNumber = -1;
    Get.to(() => QuranChapterDetailsView(
        settingsController: settingsController, state: state));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'sampleItemListView',
        itemCount: quran.totalSurahCount,
        itemBuilder: (BuildContext context, int index) {
          String surahTranslation = Get.locale?.languageCode == 'ar'
              ? ''
              : ' (${surahTranslations[Get.locale?.languageCode][index]})';
          return ListTile(
            title: Text('${_getSurahName(context, index)}$surahTranslation'),
            leading: CircleAvatar(
              // Display the Flutter Logo image asset.
              // foregroundImage: const AssetImage('assets/images/flutter_logo.png'),
              child: ArabicNumber().convertToLocaleNumber(index + 1),
            ),
            onTap: () {
              state.surahNumber = index + 1;
              goToPage(
                  quran.getPageNumber(state.surahNumber, 1), state.surahNumber);
            },
          );
        });
  }
}
