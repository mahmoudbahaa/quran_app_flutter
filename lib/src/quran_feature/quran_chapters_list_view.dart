import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;

import '../data/rub_hizb_info.dart';
import '../data/surah_names.dart';
import '../settings/language_selection_view.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_view.dart';
import '../util/arabic_number.dart';
import '../util/circular_precent.dart';
import '../util/common.dart';
import '../util/quran_player_global_state.dart';
import 'quran_chapters_details_view.dart';

/// Displays a list of SampleItems.
class QuranChaptersListView extends StatelessWidget {
  const QuranChaptersListView(
      {super.key, required this.controller, required this.state});

  final SettingsController controller;
  final QuranPlayerGlobalState state;
  final maxVerseWords = 5;
  final fontSize = 20.0;

  void _update() {
    goToPage(state.pageNumber, state.surahNumber);
  }

  int _getPageNumber(int hizbNumber, int quarterNumber) {
    final int key = (hizbNumber - 1) * 4 + (quarterNumber - 1);
    return rubHizbInfo[key]['page_number'] as int;
  }

  int _getSurahNumber(int hizbNumber, int quarterNumber) {
    final int key = (hizbNumber - 1) * 4 + (quarterNumber - 1);
    final String verseKey = rubHizbInfo[key]['verse_key'] as String;
    return int.parse(verseKey.split(':')[0]);
  }

  List<Widget> _getRubHizbVerseReview(
      int hizbNumber, int quarterNumber, BuildContext context) {
    final int key = (hizbNumber - 1) * 4 + (quarterNumber - 1);
    final String verseKey = rubHizbInfo[key]['verse_key'] as String;
    final int pageNumber = _getPageNumber(hizbNumber, quarterNumber);
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

    String verseInfo =
        '${_getSurahName(context, surahNumber - 1)} ${AppLocalizations.of(context)!.verse} ';
    List<Widget> widgets = [];
    widgets.add(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(versePreview,
          textDirection: TextDirection.rtl,
          style: TextStyle(fontFamily: 'uthmanic', fontSize: fontSize - 3)),
      Row(children: <Widget>[
        Text(verseInfo, style: TextStyle(fontSize: fontSize - 3)),
        ArabicNumber()
            .convertToLocaleNumber(verseNumber, fontSize: fontSize - 3),
      ])
    ]));
    widgets.add(Expanded(
      // mainAxisAlignment: MainAxisAlignment.end,
      child: Align(
          alignment: rtlLanguages
                  .contains(Localizations.localeOf(context).languageCode)
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: ArabicNumber()
              .convertToLocaleNumber(pageNumber, fontSize: fontSize)),
    ));

    return widgets;
  }

  void goToPage(int pageNumber, int surahNumber) {
    state.surahNumber = surahNumber;
    state.pageNumber = pageNumber;
    state.verseNumber = 1;
    state.wordNumber = -1;
    Get.to(() =>
        QuranChapterDetailsView(settingsController: controller, state: state));
  }

  List<Widget> _buildRubHizbList(BuildContext context) {
    List<Widget> children = [];

    for (int i = 1; i <= quran.totalJuzCount; i++) {
      children.add(
        GestureDetector(
          onTap: () => goToPage(
              _getPageNumber(i * 2 - 1, 1), _getSurahNumber(i * 2 - 1, 1)),
          child: DecoratedBox(
            decoration: BoxDecoration(color: Theme.of(context).disabledColor),
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Row(children: [
                Text('جزء ', style: TextStyle(fontSize: fontSize)),
                ArabicNumber().convertToLocaleNumber(i, fontSize: fontSize),
              ]),
            ),
          ),
        ),
      );

      children.add(Divider(height: 1));

      for (int hizbNumber = i * 2 - 1; hizbNumber <= i * 2; hizbNumber++) {
        for (int quarterNumber = 1; quarterNumber <= 4; quarterNumber++) {
          Widget circle;
          if (quarterNumber == 1) {
            circle = CircleAvatar(
                child: ArabicNumber().convertToLocaleNumber(hizbNumber));
          } else {
            circle = CustomPaint(
              painter: CircularPercent(
                  percentage: (quarterNumber - 1) * 0.25,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary),
              child: SizedBox(width: 35, height: 35),
            );
          }

          List<Widget> widgets =
              _getRubHizbVerseReview(hizbNumber, quarterNumber, context);
          children.add(GestureDetector(
              onTap: () => goToPage(_getPageNumber(hizbNumber, quarterNumber),
                  _getSurahNumber(hizbNumber, quarterNumber)),
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    circle,
                    SizedBox(width: 20),
                    widgets.first,
                    widgets.last,
                  ],
                ),
              )));
          children.add(Divider(height: 1));
        }
      }
    }

    return children;
  }

  String _getSurahName(BuildContext context, int index) {
    String surahPrefix = AppLocalizations.of(context)!.surahPrefix;
    String surahName = surahNames[Get.locale?.languageCode][index];
    return '$surahPrefix$surahName';
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
                  Get.to(() => SettingsView(controller: controller)),
            ),
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: () =>
                  Get.to(() => LanguageSelectionView(controller: controller)),
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
        body: TabBarView(children: [
          ListView.builder(
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
                  title:
                      Text('${_getSurahName(context, index)}$surahTranslation'),
                  leading: CircleAvatar(
                    // Display the Flutter Logo image asset.
                    // foregroundImage: const AssetImage('assets/images/flutter_logo.png'),
                    child: ArabicNumber().convertToLocaleNumber(index + 1),
                  ),
                  onTap: () => goToPage(
                      quran.getPageNumber(state.surahNumber, 1),
                      state.surahNumber));
            },
          ),
          Builder(
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: Column(
                  spacing: 8,
                  children: _buildRubHizbList(context),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }
}

class CircleGraphWidget {}
