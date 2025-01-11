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
class QuranChapterDetailsView extends StatefulWidget {
  const QuranChapterDetailsView(
      {super.key, required this.settingsController, required this.state});

  final SettingsController settingsController;
  final QuranPlayerGlobalState state;

  @override
  State<QuranChapterDetailsView> createState() {
    return _QuranChapterDetailsView();
  }
}

class _QuranChapterDetailsView extends State<QuranChapterDetailsView> {
  final double defaultFontSize = 36;
  final double _fontSize = 500;
  final PageBuilder pageBuilder = const PageBuilder();
  QuranPlayerGlobalState get state => widget.state;
  SettingsController get settingsController => widget.settingsController;

  List<Widget> buildPages() {
    List<Widget> pages = <Widget>[];

    int numPages = settingsController.numPages;
    for (int i = 0; i < numPages; i++) {
      int pageNum =
          i + 1 + ((state.pageNumber - 1) / numPages).floor() * numPages;
      if (pageNum > quran.totalPagesCount) break;

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
                              settingsController.flowMode,
                              setState)),
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

  Future<void> goNextPage() async {
    if (state.pageNumber >=
        (quran.totalPagesCount - settingsController.numPages)) {
      return;
    }

    if (settingsController.numPages == 1) {
      state.pageNumber = state.pageNumber + 1;
    } else {
      state.pageNumber =
          ((state.pageNumber / settingsController.numPages).floor() + 1) *
                  settingsController.numPages +
              1;
    }

    for (int i = 0; i < settingsController.numPages; i++) {
      await QuranFontsLoader().loadPageFont(
          state.pageNumber + i, settingsController.textRepresentation);
    }

    dynamic pageData = quran.getPageData(state.pageNumber).first;
    state.surahNumber = pageData['surah'];
    state.verseNumber = pageData['start'];
    state.wordNumber = -1;
    state.pause = true;
    setState(() {});
  }

  Future<void> goPreviousPage() async {
    if (state.pageNumber <= settingsController.numPages) return;

    if (settingsController.numPages == 1) {
      state.pageNumber = state.pageNumber - 1;
    } else {
      state.pageNumber =
          ((state.pageNumber / settingsController.numPages).floor() - 1) *
                  settingsController.numPages +
              1;
    }

    for (int i = 0; i < settingsController.numPages; i++) {
      await QuranFontsLoader().loadPageFont(
          state.pageNumber + i, settingsController.textRepresentation);
    }

    dynamic pageData = quran.getPageData(state.pageNumber).first;
    state.surahNumber = pageData['surah'];
    state.verseNumber = pageData['start'];
    state.wordNumber = -1;
    state.pause = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        opacity: state.pageTransition != PageTransition.noChange ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 500),
        onEnd: () {
          if (state.pageTransition == PageTransition.nextPage) {
            setState(() => state.pageTransition = PageTransition.noChange);
            goNextPage().then((value) {
              setState(() {});
            });
          } else if (state.pageTransition == PageTransition.previousPage) {
            setState(() {
              state.pageTransition = PageTransition.noChange;
            });
            goPreviousPage().then((value) {
              setState(() {});
            });
          }
        },
        child: SwipeTo(
          animationDuration: Duration(milliseconds: 0),
          onRightSwipe: (details) {
            setState(() {
              state.pageTransition = PageTransition.nextPage;
            });
          },
          onLeftSwipe: (details) {
            setState(() {
              state.pageTransition = PageTransition.previousPage;
            });
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
                  goNextPage(),
              const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                  goPreviousPage(),
            },
            child: Column(children: [
              Expanded(child: Row(children: buildPages())),
              QuranPlayer(
                settingsController: settingsController,
                state: state,
                parent: this,
              ),
            ]),
          ),
        ),
      ),
      floatingActionButton: FittedBox(
        child: FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            child: const Icon(Icons.navigate_before)),
      ),
    );
  }
}
