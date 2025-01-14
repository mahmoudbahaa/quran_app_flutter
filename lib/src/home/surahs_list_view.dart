import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

import '../common/quran_info_controller.dart';
import '../settings/settings_controller.dart';
import '../util/arabic_number.dart';
import '../util/quran_player_global_state.dart';

class SurahsListView extends StatelessWidget {
  const SurahsListView(
      {super.key, required this.settingsController, required this.state});

  final QuranPlayerGlobalState state;
  final SettingsController settingsController;
  final QuranInfoController controller = const QuranInfoController();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Providing a restorationId allows the ListView to restore the
      // scroll position when a user leaves and returns to the app after it
      // has been killed while running in the background.
      restorationId: 'sampleItemListView',
      itemCount: quran.totalSurahCount,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            title: Text(controller.getSurahNameWithTranslation(index, context)),
            leading: CircleAvatar(
              // Display the Flutter Logo image asset.
              // foregroundImage: const AssetImage('assets/images/flutter_logo.png'),
              child: Text(
                  ArabicNumber().convertToLocaleNumber(index + 1, context)),
            ),
            onTap: () => controller.goToPage(quran.getPageNumber(index + 1, 1),
                index + 1, context, settingsController, state));
      },
    );
  }
}
