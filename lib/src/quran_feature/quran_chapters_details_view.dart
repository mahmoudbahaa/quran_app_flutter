import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/quran_feature/page_builder.dart';
import 'package:quran_app_flutter/src/util/page_transition.dart';
import 'package:quran_app_flutter/src/util/text_representation.dart';

import '../settings/settings_controller.dart';
import '../util/quran_fonts_loader.dart';
import '../util/quran_player_global_state.dart';
import '../util/swipe_to.dart';
import 'quran_player.dart';

/// Displays detailed information about a SampleItem.
class QuranChapterDetailsView extends StatelessWidget {
  const QuranChapterDetailsView({super.key, required this.settingsController});

  static const routeName = '/chapter_details';
  final SettingsController settingsController;
  final double defaultFontSize = 36;
  final double _fontSize = 500;
  final PageBuilder pageBuilder = const PageBuilder();

  List<Widget> buildPages(QuranPlayerGlobalState state) {
    List<Widget> pages = <Widget>[];

    int numPages = settingsController.numPages;
    for (int i = 0; i < numPages; i++) {
      int pageNum =
          i + 1 + ((state.pageNumber.value - 1) / numPages).floor() * numPages;
      if (pageNum > 604) break;
      if (i > 0) {
        // pages.add(SizedBox(width: 5));
        // pages.add(VerticalDivider(
        //     color: Colors.green,
        //     thickness: 5,
        //     width: 20));
        // pages.add(SizedBox(width: 5));
      }

      final constraint = BoxConstraints(
        minHeight: 5.0,
        minWidth: 5.0,
        maxHeight: numPages == 4
            ? 700.0
            : numPages == 3
                ? 930
                : 1200,
        maxWidth: numPages == 4
            ? 475.0
            : numPages == 3
                ? 630
                : 700,
      );

      // final padding = settingsController.textRepresentation ==
      //         TextRepresentation.codeV2Colored
      //     ? 43.0
      //     : 28.0;
      final Widget child = ConstrainedBox(
        constraints: constraint,
        child: Stack(children: [
          DecoratedBox(
            // BoxDecoration takes the image
            decoration: BoxDecoration(
              // Image set to background of the body
              image: DecorationImage(
                  image: AssetImage('assets/images/hollow/bg.png'),
                  fit: BoxFit.contain),
            ),
            child: (Get.theme.brightness == Brightness.dark &&
                    settingsController.textRepresentation ==
                        TextRepresentation.codeV4)
                ? Container(color: Colors.transparent)
                : SizedBox.shrink(),
          ),
          DecoratedBox(
            // BoxDecoration takes the image
            decoration: BoxDecoration(
                // Image set to background of the body
                image: DecorationImage(
                    invertColors: false, //Get.isDarkMode,
                    image: AssetImage('assets/images/hollow/$pageNum.png'),
                    fit: BoxFit.contain)),
            child: Align(
              alignment: Alignment.center,
              child: Builder(builder: (context) {
                final aspectRatio = 700 / 475;
                double width = context.mediaQuery.size.width / numPages;
                double height = context.mediaQuery.size.height - 50;
                if (width * aspectRatio > height) {
                  width = height / aspectRatio;
                } else {
                  height = width * aspectRatio;
                }
                return Padding(
                  padding:
                      EdgeInsets.only(top: pageNum < 3 ? height * 0.15 : 0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: pageNum < 3 ? width * 0.46 : width * 0.85,
                        maxWidth: pageNum < 3 ? width * 0.46 : width * 0.85,
                        minHeight: pageNum < 3 ? height * 0.3 : height * 0.87,
                        maxHeight: pageNum < 3 ? height * 0.3 : height * 0.87),
                    child: AutoSizeText.rich(
                      TextSpan(
                          children: pageBuilder.buildPage(
                              state,
                              i,
                              numPages,
                              settingsController.textRepresentation,
                              settingsController.flowMode)),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: _fontSize),
                      maxLines: pageNum == 1 ? 8 : 15,
                      stepGranularity: 0.1,
                      minFontSize: 1,
                      maxFontSize: numPages == 4 ? 28 : 500,
                    ),
                  ),
                );
              }),
            ),
          ),
        ]),
      );

      // if (numPages == 1) {
      //   pages.add(Expanded(child: SingleChildScrollView(child: child)));
      // } else {
      pages.add(Expanded(child: child));
      // }
    }

    return pages;
  }

  Future<void> goNextPage(QuranPlayerGlobalState state) async {
    if (state.pageNumber >=
        (quran.totalPagesCount - settingsController.numPages)) return;

    if (settingsController.numPages == 1) {
      state.pageNumber.value = state.pageNumber.value + 1;
    } else {
      state.pageNumber.value =
          ((state.pageNumber.value / settingsController.numPages).floor() + 1) *
                  settingsController.numPages +
              1;
    }

    for (int i = 0; i < settingsController.numPages; i++) {
      await QuranFontsLoader().loadPageFont(
          state.pageNumber.value + i, settingsController.textRepresentation);
    }

    dynamic pageData = quran.getPageData(state.pageNumber.value).first;
    state.surahNumber.value = pageData['surah'];
    state.verseNumber.value = pageData['start'];
    state.wordNumber.value = -1;
    state.pause.value = true;
    state.update();
  }

  Future<void> goPreviousPage(QuranPlayerGlobalState state) async {
    if (state.pageNumber <= settingsController.numPages) return;

    if (settingsController.numPages == 1) {
      state.pageNumber.value = state.pageNumber.value - 1;
    } else {
      state.pageNumber.value =
          ((state.pageNumber.value / settingsController.numPages).floor() - 1) *
                  settingsController.numPages +
              1;
    }

    for (int i = 0; i < settingsController.numPages; i++) {
      await QuranFontsLoader().loadPageFont(
          state.pageNumber.value + i, settingsController.textRepresentation);
    }

    dynamic pageData = quran.getPageData(state.pageNumber.value).first;
    state.surahNumber.value = pageData['surah'];
    state.verseNumber.value = pageData['start'];
    state.wordNumber.value = -1;
    state.pause.value = true;
    state.update();
  }

  @override
  Widget build(BuildContext context) {
    QuranPlayerGlobalState state = Get.find();

    return GetX<QuranPlayerGlobalState>(
        builder: (_) => Scaffold(
              // appBar: AppBar(
              //   title: Text(
              //       '${quran.getSurahNameArabic(state.surahNumber)} (${state.pageNumber})'),
              //   actions: [
              //     IconButton(
              //       icon: const Icon(Icons.settings),
              //       onPressed: () {
              //         // Navigate to the settings page. If the user leaves and returns
              //         // to the app after it has been killed while running in the
              //         // background, the navigation stack is restored.
              //         Navigator.restorablePushNamed(context, SettingsView.routeName);
              //       },
              //     ),
              //   ],
              // ),
              body: AnimatedOpacity(
                opacity: state.pageTransition.value != PageTransition.noChange
                    ? 0.0
                    : 1.0,
                duration: const Duration(milliseconds: 1000),
                onEnd: () {
                  if (state.pageTransition.value == PageTransition.nextPage) {
                    goNextPage(state).then((value) {
                      state.loadingPage.value = !state.loadingPage.value;
                      state.update();
                    });
                    state.pageTransition.value = PageTransition.noChange;
                  } else if (state.pageTransition.value ==
                      PageTransition.previousPage) {
                    goPreviousPage(state).then((value) {
                      state.loadingPage.value = !state.loadingPage.value;
                      state.update();
                    });
                    state.pageTransition.value = PageTransition.noChange;
                  }
                },
                child: SwipeTo(
                  animationDuration: Duration(milliseconds: 0),
                  onRightSwipe: (details) {
                    state.pageTransition.value = PageTransition.nextPage;
                    state.update();
                  },
                  onLeftSwipe: (details) {
                    state.pageTransition.value = PageTransition.previousPage;
                    state.update();
                  },
                  child: CallbackShortcuts(
                    bindings: <ShortcutActivator, VoidCallback>{
                      // const SingleActivator(LogicalKeyboardKey.equal, control: true):
                      //     () {
                      //   setState(
                      //       () => _fontSize < 200 ? _fontSize += 1 : _fontSize += 0);
                      // },
                      // const SingleActivator(LogicalKeyboardKey.minus, control: true):
                      //     () {
                      //   setState(
                      //       () => _fontSize > 20 ? _fontSize -= 1 : _fontSize += 0);
                      // },
                      // const SingleActivator(LogicalKeyboardKey.digit0, control: true):
                      //     () {
                      //   setState(() => _fontSize = defaultFontSize);
                      // },
                      const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                          goNextPage(state),
                      const SingleActivator(LogicalKeyboardKey.arrowRight):
                          () => goPreviousPage(state),
                    },
                    child: Column(children: [
                      Expanded(child: Row(children: buildPages(state))),
                      QuranPlayer(settingsController: settingsController),
                    ]),
                  ),
                ),
              ),
              floatingActionButton: FittedBox(
                child: FloatingActionButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.navigate_before)),
              ),
            ));
  }
}
