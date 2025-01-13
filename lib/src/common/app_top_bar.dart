import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;

import '../common/quran_info_controller.dart';
import '../localization/app_localizations.dart';
import '../quran_page/quran_page_view.dart';
import '../settings/language_selection_view.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_view.dart';
import '../util/common.dart';
import '../util/quran_player_global_state.dart';

class AppTopBar extends AppBar {
  AppTopBar({super.key, required this.settingsController, required this.state});

  final QuranPlayerGlobalState state;
  final SettingsController settingsController;

  @override
  State<AppTopBar> createState() {
    return _AppTopBarState();
  }
}

class _AppTopBarState extends State<AppTopBar> {
  final fontSize = 18.0;
  final QuranInfoController controller = const QuranInfoController();
  QuranPlayerGlobalState get state => widget.state;
  SettingsController get settingsController => widget.settingsController;

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
    return AppBar(
      title: Text(AppLocalizations.of(context)!.appTitle),
      actions: [
        IconButton(
          constraints: BoxConstraints(minWidth: 100),
          tooltip: 'Go to certain page',
          onPressed: () => showNumberSelectDialog(
              context: context,
              title: AppLocalizations.of(context)!.pageNumber,
              min: 1,
              max: quran.totalPagesCount,
              initialValue: state.pageNumber < 1 ? 1 : state.pageNumber,
              onChanged: (value) {
                state.pageNumber = value as int;
                goToPage(state.pageNumber, state.surahNumber);
              }),
          icon: Text(AppLocalizations.of(context)!.goToPage),
          // child: Text('Go To'),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () =>
              Get.to(() => SettingsView(controller: settingsController)),
        ),
        IconButton(
          icon: const Icon(Icons.language),
          onPressed: () => Get.to(
              () => LanguageSelectionView(controller: settingsController)),
        ),
      ],
    );
  }
}
