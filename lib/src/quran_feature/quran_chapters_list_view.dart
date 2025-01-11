import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;

import '../data/surah_names.dart';
import '../settings/language_selection_view.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_view.dart';
import '../util/arabic_number.dart';
import '../util/quran_fonts_loader.dart';
import '../util/quran_player_global_state.dart';
import 'quran_chapters_details_view.dart';

/// Displays a list of SampleItems.
class QuranChaptersListView extends StatelessWidget {
  const QuranChaptersListView(
      {super.key, required this.controller, required this.state});

  final SettingsController controller;
  final QuranPlayerGlobalState state;
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => SettingsView(controller: controller)),
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () =>
                Get.to(() => LanguageSelectionView(controller: controller)),
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'sampleItemListView',
        itemCount: quran.totalSurahCount,
        itemBuilder: (BuildContext context, int index) {
          String surahPrefix = AppLocalizations.of(context)!.surahPrefix;
          String surahName = surahNames[Get.locale?.languageCode][index];
          String surahTranslation = Get.locale?.languageCode == 'ar'
              ? ''
              : ' (${surahTranslations[Get.locale?.languageCode][index]})';
          return ListTile(
              title: Text('$surahPrefix$surahName$surahTranslation'),
              leading: CircleAvatar(
                // Display the Flutter Logo image asset.
                // foregroundImage: const AssetImage('assets/images/flutter_logo.png'),
                child: Text(ArabicNumber().convertToLocaleNumber(index + 1)),
              ),
              onTap: () async {
                state.surahNumber = index + 1;
                state.pageNumber = quran.getPageNumber(state.surahNumber, 1);
                // dynamic pageData = quran.getPageData(state.pageNumber).first;
                state.verseNumber = 1;
                state.wordNumber = -1;
                await QuranFontsLoader().loadPageFont(
                    state.pageNumber, controller.textRepresentation);
                Get.to(() => QuranChapterDetailsView(
                    settingsController: controller, state: state));
              });
        },
      ),
    );
  }
}
