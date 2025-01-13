import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/localization/app_localizations.dart';

import '../common/quran_info_controller.dart';
import '../settings/settings_controller.dart';
import '../util/arabic_number.dart';
import '../util/circular_precent.dart';
import '../util/quran_player_global_state.dart';

class JuzsListView extends StatelessWidget {
  const JuzsListView(
      {super.key, required this.settingsController, required this.state});

  final QuranPlayerGlobalState state;
  final SettingsController settingsController;
  final fontSize = 18.0;
  final QuranInfoController controller = const QuranInfoController();

  List<Widget> _getRubHizbVerseReview(
      int hizbNumber, int quarterNumber, BuildContext context) {
    RubHizbVerseInfo rubHizbVerseInfo =
        controller.getRubHizbPreview(hizbNumber, quarterNumber, context);
    List<Widget> widgets = [];
    widgets.add(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        rubHizbVerseInfo.versePreview,
        textDirection: TextDirection.rtl,
        // style: TextStyle(fontSize: fontSize - 2),
      ),
      Row(children: <Widget>[
        Text(
          '${rubHizbVerseInfo.verseInfo}${ArabicNumber().convertToLocaleNumber(rubHizbVerseInfo.verseNumber)}',
          // style: TextStyle(fontSize: fontSize - 6),
        ),
      ])
    ]));
    widgets.add(Expanded(
      // mainAxisAlignment: MainAxisAlignment.end,
      child: Align(
        alignment:
            rtlLanguages.contains(Localizations.localeOf(context).languageCode)
                ? Alignment.centerLeft
                : Alignment.centerRight,
        child: Text(
            ArabicNumber().convertToLocaleNumber(rubHizbVerseInfo.pageNumber),
            style: TextStyle(fontSize: fontSize)),
      ),
    ));

    return widgets;
  }

  List<Widget> _buildRubHizbList(BuildContext context) {
    List<Widget> children = [];

    for (int i = 1; i <= quran.totalJuzCount; i++) {
      children.add(
        GestureDetector(
          onTap: () => controller.goToPage(
              controller.getPageNumber(i * 2 - 1, 1),
              controller.getSurahNumber(i * 2 - 1, 1),
              settingsController,
              state),
          child: DecoratedBox(
            decoration: BoxDecoration(color: Theme.of(context).disabledColor),
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Text(
                  '${AppLocalizations.of(context)!.juz} ${ArabicNumber().convertToLocaleNumber(i)}',
                  style: TextStyle(fontSize: fontSize)),
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
                child: Text(ArabicNumber().convertToLocaleNumber(hizbNumber)));
          } else {
            circle = CustomPaint(
              painter: CircularPercent(
                  percentage: (quarterNumber - 1) * 0.25,
                  color: Theme.of(context).colorScheme.primary,
                  backgroundColor:
                      Theme.of(context).colorScheme.inversePrimary),
              child: SizedBox(width: 35, height: 35),
            );
          }

          List<Widget> widgets =
              _getRubHizbVerseReview(hizbNumber, quarterNumber, context);
          children.add(GestureDetector(
              onTap: () => controller.goToPage(
                  controller.getPageNumber(hizbNumber, quarterNumber),
                  controller.getSurahNumber(hizbNumber, quarterNumber),
                  settingsController,
                  state),
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
