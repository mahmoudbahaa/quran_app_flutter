import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/localization/app_localizations.dart';
import 'package:quran_app_flutter/src/models/enums.dart';

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
          '${rubHizbVerseInfo.verseInfo}${ArabicNumber().convertToLocaleNumber(rubHizbVerseInfo.verseNumber, context)}',
          // style: TextStyle(fontSize: fontSize - 6),
        ),
      ])
    ]));
    widgets.add(Expanded(
      // mainAxisAlignment: MainAxisAlignment.end,
      child: Align(
        alignment:
            isRtl(context) ? Alignment.centerLeft : Alignment.centerRight,
        child: Text(
            ArabicNumber()
                .convertToLocaleNumber(rubHizbVerseInfo.pageNumber, context),
            style: TextStyle(fontSize: fontSize)),
      ),
    ));

    return widgets;
  }

  Widget _buildRubHizbListItem(BuildContext context, int index) {
    int juzNumber = (index / 9).floor() + 1;
    int hizbNumber = (juzNumber - 1) * 2 + (((index % 9) - 1) / 4).floor() + 1;
    int quarterNumber = (index % 9 - 1) % 4 + 1;
    if (index % 9 == 0) {
      return GestureDetector(
        onTap: () {
          controller.goToPage(
              controller.getPageNumber(hizbNumber, 1),
              controller.getSurahNumber(hizbNumber, 1),
              context,
              settingsController,
              state);
        },
        child: Column(children: [
          DecoratedBox(
            decoration: BoxDecoration(color: Theme.of(context).disabledColor),
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Row(children: [
                Text(
                    '${AppLocalizations.of(context)!.juz} ${ArabicNumber().convertToLocaleNumber((index / 9).floor() + 1, context)}',
                    style: TextStyle(fontSize: fontSize)),
                Expanded(
                  child: Align(
                    alignment: isRtl(context)
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Text(
                        ArabicNumber().convertToLocaleNumber(
                            quran.getPageNumber(
                                controller.getSurahNumber(
                                    (juzNumber - 1) * 2 + 1, 1),
                                1),
                            context),
                        style: TextStyle(fontSize: fontSize)),
                  ),
                ),
              ]),
            ),
          ),
          Divider(height: 10),
        ]),
      );
    }

    Widget circle;
    if (quarterNumber == 1) {
      circle = CircleAvatar(
          child:
              Text(ArabicNumber().convertToLocaleNumber(hizbNumber, context)));
    } else {
      circle = CustomPaint(
        painter: CircularPercent(
            percentage: (quarterNumber - 1) * 0.25,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary),
        child: SizedBox(width: 35, height: 35),
      );
    }

    List<Widget> widgets =
        _getRubHizbVerseReview(hizbNumber, quarterNumber, context);

    return GestureDetector(
      onTap: () => controller.goToPage(
          controller.getPageNumber(hizbNumber, quarterNumber),
          controller.getSurahNumber(hizbNumber, quarterNumber),
          context,
          settingsController,
          state),
      child: Column(children: [
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: [
              circle,
              SizedBox(width: 20),
              widgets.first,
              widgets.last,
            ],
          ),
        ),
        // Divider(height: 10, thickness: 5),
        Divider(
            height: 10,
            thickness: (quarterNumber == 4 && hizbNumber % 2 == 0) ? 0 : 2.5),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return ListView.builder(
            itemCount: quran.totalJuzCount * 9,
            itemBuilder: (context, index) {
              return _buildRubHizbListItem(context, index);
            });
      },
    );
  }
}
