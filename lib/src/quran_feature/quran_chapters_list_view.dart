import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/settings/settings_controller.dart';
import 'package:quran_app_flutter/src/util/arabic_number.dart';

import '../settings/settings_view.dart';
import '../data/surah_names.dart';
import '../util/quran_player_global_state.dart';
import 'quran_chapters_details_view.dart';

/// Displays a list of SampleItems.
class QuranChaptersListView extends StatelessWidget {
  const QuranChaptersListView({
    super.key,
    required this.controller,
  });

  final SettingsController controller;
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final QuranPlayerGlobalState state = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Chapters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => SettingsView(controller: controller)),
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
          return ListTile(
            title: Text('$surahPrefix${surahNames[index]}',
                style: TextStyle(fontFamily: 'uthmanic3')),
            leading: CircleAvatar(
              // Display the Flutter Logo image asset.
              // foregroundImage: const AssetImage('assets/images/flutter_logo.png'),
              child: Text(ArabicNumber().convertToArabicNumber(index + 1), style: TextStyle(fontFamily: 'uthmanic')),
            ),
            onTap: () {
              state.surahNumber.value = index + 1;
              state.pageNumber.value =
                  quran.getPageNumber(state.surahNumber.value, 1);
              // dynamic pageData = quran.getPageData(state.pageNumber).first;
              state.verseNumber.value = 1;
              state.wordNumber.value = -1;
              Get.to(() => QuranChapterDetailsView(settingsController: controller));
            }
          );
        },
      ),
    );
  }
}