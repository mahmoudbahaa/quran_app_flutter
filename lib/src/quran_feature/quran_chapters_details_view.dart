import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;

import '../quran_feature/page_builder.dart';
import '../settings/settings_controller.dart';
import '../util/assets_downloader.dart';
import '../util/enums.dart';
import '../util/floating_buttons.dart';
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
  late int _pageNumber;

  final PageBuilder pageBuilder = const PageBuilder();
  QuranPlayerGlobalState get state => widget.state;
  SettingsController get settingsController => widget.settingsController;

  @override
  void initState() {
    _pageNumber = state.pageNumber;
    super.initState();
  }

  void _update() {
    setState(() {});
  }

  List<Widget> buildPages() {
    List<Widget> pages = <Widget>[];

    int numPages = settingsController.numPages;
    for (int i = 0; i < numPages; i++) {
      int pageNum = i + 1 + ((_pageNumber - 1) / numPages).floor() * numPages;
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

      String? imagePath = AssetsDownloader().getImagePath(pageNum);
      if (imagePath == null) {
        AssetsDownloader().loadImage(pageNum).then((_) {
          if (mounted) setState(() {});
        });
      }

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
          Builder(builder: (context) {
            final child = Align(
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
                          children: pageBuilder.buildPage(state, i, numPages,
                              settingsController.textRepresentation, () {
                        if (mounted) setState(() => {});
                      })),
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
            );

            if (imagePath == null) return child;

            return DecoratedBox(
              // BoxDecoration takes the image
              decoration: BoxDecoration(
                // Image set to background of the body
                image: DecorationImage(
                    image: FileImage(File(imagePath)), fit: BoxFit.contain),
              ),
              child: child,
            );
          }),
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

  void goNextPage() {
    if (!AssetsDownloader().isFontLoaded(
            state.pageNumber, settingsController.textRepresentation) ||
        state.pageNumber >=
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

    state.surahNumber = -1;
    state.verseNumber = -1;
    state.wordNumber = -1;
    state.pause = true;
  }

  void goPreviousPage() {
    if (!AssetsDownloader().isFontLoaded(
            state.pageNumber, settingsController.textRepresentation) ||
        state.pageNumber <= settingsController.numPages) {
      return;
    }

    if (settingsController.numPages == 1) {
      state.pageNumber = state.pageNumber - 1;
    } else {
      state.pageNumber =
          ((_pageNumber / settingsController.numPages).floor() - 1) *
                  settingsController.numPages +
              1;
    }

    state.surahNumber = -1;
    state.verseNumber = -1;
    state.wordNumber = -1;
    state.pause = true;
  }

  @override
  Widget build(BuildContext context) {
    _pageNumber = state.pageNumber;

    return Scaffold(
        body: AnimatedOpacity(
          opacity: state.pageTransition != PageTransition.noChange ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 500),
          onEnd: () {
            if (state.pageTransition == PageTransition.nextPage) {
              setState(() {
                state.pageTransition = PageTransition.noChange;
                goNextPage();
              });
            } else if (state.pageTransition == PageTransition.previousPage) {
              setState(() {
                state.pageTransition = PageTransition.noChange;
                goPreviousPage();
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
                const SingleActivator(LogicalKeyboardKey.arrowLeft,
                    includeRepeats: false): () => setState(goNextPage),
                const SingleActivator(LogicalKeyboardKey.arrowRight,
                    includeRepeats: false): () => setState(goPreviousPage),
              },
              child: Column(children: [
                Expanded(
                  child: Focus(
                    autofocus: true,
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: buildPages(),
                    ),
                  ),
                ),
                QuranPlayer(
                  settingsController: settingsController,
                  state: state,
                  parent: this,
                ),
              ]),
            ),
          ),
        ),
        floatingActionButton: FloatingButtons(state: state, update: _update));
  }
}
