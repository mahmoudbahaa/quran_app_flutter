import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/common/pointer_up.dart';
import 'package:quran_app_flutter/src/util/quran_player_global_state.dart';

import '../localization/app_localizations.dart';
import '../quran_page/quran_page_view.dart';
import '../settings/language_selection_view.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_view.dart';
import '../util/common.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer(
      {super.key, required this.state, required this.settingsController});

  final QuranPlayerGlobalState state;
  final SettingsController settingsController;

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int screenIndex = 0;
  List<Destination>? destinations;
  QuranPlayerGlobalState get state => widget.state;
  SettingsController get settingsController => widget.settingsController;

  void goToPage(int pageNumber, int surahNumber) {
    state.surahNumber = surahNumber;
    state.pageNumber = pageNumber;
    state.verseNumber = 1;
    state.wordNumber = -1;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => QuranPageView(
              settingsController: settingsController, state: state)),
    );
  }

  void handleGoToPage() {
    showNumberSelectDialog(
        context: context,
        title: AppLocalizations.of(context)!.pageNumber,
        min: 1,
        max: quran.totalPagesCount,
        initialValue: state.pageNumber < 1 ? 1 : state.pageNumber,
        onChanged: (value) {
          state.pageNumber = value as int;
          goToPage(state.pageNumber, state.surahNumber);
        });
  }

  void handleSettingsPage() => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SettingsView(controller: settingsController)));
  void handleLanguagePage() => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LanguageSelectionView(controller: settingsController)));

  void handleScreenChanged(int selectedScreen) {
    destinations?[selectedScreen].callback();
  }

  @override
  Widget build(BuildContext context) {
    destinations ??= <Destination>[
      Destination('Go to certain page', Icon(PointerUp.pointerUp),
          Icon(PointerUp.pointerUp), handleGoToPage),
      Destination('Language', Icon(Icons.language_outlined),
          Icon(Icons.language), handleLanguagePage),
      Destination('Settings', Icon(Icons.settings_outlined),
          Icon(Icons.settings), handleSettingsPage),
    ];
    return NavigationDrawer(
      onDestinationSelected: handleScreenChanged,
      selectedIndex: screenIndex,
      children: <Widget>[
        SizedBox(height: 20),
        ...?destinations?.map(
          (Destination destination) {
            return NavigationDrawerDestination(
              label: Text(destination.label),
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
            );
          },
        ),
      ],
    );
  }
}

class Destination {
  const Destination(this.label, this.icon, this.selectedIcon, this.callback);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
  final VoidCallback callback;
}
