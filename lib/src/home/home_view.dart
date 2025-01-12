import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/home/surah_list/surahs_list_view.dart';

import '../localization/app_localizations.dart';
import '../quran_page/quran_page_view.dart';
import '../settings/language_selection_view.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_view.dart';
import '../util/common.dart';
import '../util/quran_player_global_state.dart';
import 'assets_loader/assets_loader_widget.dart';
import 'juz_list/juzs_list_view.dart';

/// Displays a list of SampleItems.
class QuranChaptersListView extends StatefulWidget {
  const QuranChaptersListView(
      {super.key, required this.controller, required this.state});

  final SettingsController controller;
  final QuranPlayerGlobalState state;

  @override
  State<StatefulWidget> createState() {
    return _QuranChaptersListViewState();
  }
}

class _QuranChaptersListViewState extends State<QuranChaptersListView> {
  SettingsController get settingsController => widget.controller;
  QuranPlayerGlobalState get state => widget.state;
  final maxVerseWords = 5;
  final fontSize = 20.0;

  @override
  void initState() {
    super.initState();
    state.loading = true;
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.appTitle),
          actions: [
            IconButton(
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
          bottom: TabBar(
            tabs: [
              Tab(text: AppLocalizations.of(context)!.chapters),
              Tab(text: AppLocalizations.of(context)!.juz),
            ],
          ),
        ),

        // To work with lists that may contain a large number of items, it’s best
        // to use the ListView.builder constructor.
        //
        // In contrast to the default ListView constructor, which requires
        // building all Widgets up front, the ListView.builder constructor lazily
        // builds Widgets as they’re scrolled into view.
        body: Builder(builder: (context) {
          if (state.loading) {
            return AssetsLoaderWidget(
                settingsController: settingsController,
                state: state,
                update: () => setState(() {}));
          } else {
            return TabBarView(children: [
              SurahsListView(
                  settingsController: settingsController, state: state),
              JuzsListView(
                  settingsController: settingsController, state: state),
            ]);
          }
        }),
      ),
    );
  }
}

class CircleGraphWidget {}
