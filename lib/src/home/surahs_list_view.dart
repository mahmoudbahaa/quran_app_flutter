import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

import '../common/quran_info_controller.dart';
import '../api/content_catalog.dart';
import '../settings/settings_controller.dart';
import '../util/number_utils.dart';
import '../util/quran_player_global_state.dart';

class SurahsListView extends StatelessWidget {
  const SurahsListView({
    super.key,
    required this.settingsController,
    required this.state,
  });

  final QuranPlayerGlobalState state;
  final SettingsController settingsController;
  final QuranInfoController controller = const QuranInfoController();

  @override
  Widget build(BuildContext context) {
    final chapterIds =
        ContentCatalog.chapterIds ??
        List.generate(quran.totalSurahCount, (index) => index + 1);
    return ListView.builder(
      // Providing a restorationId allows the ListView to restore the
      // scroll position when a user leaves and returns to the app after it
      // has been killed while running in the background.
      restorationId: 'sampleItemListView',
      itemCount: chapterIds.length,
      itemBuilder: (BuildContext context, int index) {
        int surahNum = chapterIds[index];
        return ListTile(
          title: Text(
            controller.getSurahNameWithTranslation(surahNum, context),
          ),
          leading: CircleAvatar(
            // Display the Flutter Logo image asset.
            // foregroundImage: const AssetImage('assets/images/flutter_logo.png'),
            child: Text(NumberUtils.convertToLocaleNumber(surahNum, context)),
          ),
          onTap: () => controller.goToPage(
            quran.getPageNumber(surahNum, 1),
            surahNum,
            context,
            settingsController,
            state,
          ),
        );
      },
    );
  }
}
