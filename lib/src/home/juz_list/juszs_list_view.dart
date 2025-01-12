import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;

import '../../localization/app_localizations.dart';
import '../../models/rub_hizb_info.dart';
import '../../models/surah_names.dart';
import '../../settings/settings_controller.dart';
import '../../util/arabic_number.dart';
import '../../util/circular_precent.dart';
import '../../util/quran_player_global_state.dart';
import '../../view/quran_chapters_details_view.dart';

class JuzsListView extends StatelessWidget {
  const JuzsListView(
      {super.key, required this.settingsController, required this.state});

  final QuranPlayerGlobalState state;
  final SettingsController settingsController;
  final maxVerseWords = 5;
  final fontSize = 20.0;

  int _getSurahNumber(int hizbNumber, int quarterNumber) {
    final int key = (hizbNumber - 1) * 4 + (quarterNumber - 1);
    final String verseKey = rubHizbInfo[key]['verse_key'] as String;
    return int.parse(verseKey.split(':')[0]);
  }

  String _getSurahName(BuildContext context, int index) {
    String surahPrefix = AppLocalizations.of(context)!.surahPrefix;
    String surahName = surahNames[Get.locale?.languageCode][index];
    return '$surahPrefix$surahName';
  }

  int _getPageNumber(int hizbNumber, int quarterNumber) {
    final int key = (hizbNumber - 1) * 4 + (quarterNumber - 1);
    return rubHizbInfo[key]['page_number'] as int;
  }

  void goToPage(int pageNumber, int surahNumber) {
    state.surahNumber = surahNumber;
    state.pageNumber = pageNumber;
    state.verseNumber = 1;
    state.wordNumber = -1;
    Get.to(() => QuranChapterDetailsView(
        settingsController: settingsController, state: state));
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

    String getSurahName(BuildContext context, int index) {
      String surahPrefix = AppLocalizations.of(context)!.surahPrefix;
      String surahName = surahNames[Get.locale?.languageCode][index];
      return '$surahPrefix$surahName';
    }

    String verseInfo =
        '${getSurahName(context, surahNumber - 1)} ${AppLocalizations.of(context)!.verse} ';
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

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            spacing: 8,
            children: _buildRubHizbList(context),
          ),
        );
      },
    );
  }
}
