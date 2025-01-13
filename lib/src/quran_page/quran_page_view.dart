import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/common/app_top_bar.dart';
import 'package:quran_app_flutter/src/util/arabic_number.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

import '../common/quran_info_controller.dart';
import '../home/assets_loader/assets_loader_controller.dart';
import '../models/enums.dart';
import '../settings/settings_controller.dart';
import '../util/quran_player_global_state.dart';
import 'page_builder.dart';
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
  bool showPlayer = false;
  bool showAppBar = false;
  int get startPageNum =>
      ((state.pageNumber - 1) / widget.settingsController.numPages).floor() *
          widget.settingsController.numPages +
      1;
  _QuranChapterDetailsView();

  final PageBuilder pageBuilder = const PageBuilder();
  QuranPlayerGlobalState get state => widget.state;

  final QuranInfoController controller = const QuranInfoController();
  SettingsController get settingsController => widget.settingsController;
  late AssetsLoaderController assetsLoaderController;

  int getNumPages(Orientation orientation) {
    if (Platform.isAndroid && orientation == Orientation.portrait) return 1;
    return settingsController.numPages;
  }

  @override
  void initState() {
    super.initState();
    assetsLoaderController =
        AssetsLoaderController(settingsController: settingsController);
  }

  List<Widget> buildPages(BuildContext context, Orientation orientation) {
    List<Widget> pages = <Widget>[];

    int numPages = getNumPages(orientation);

    for (int i = 0; i < numPages; i++) {
      int pageNum = startPageNum + i;
      if (pageNum > quran.totalPagesCount) break;

      final Widget child = Stack(children: [
        DecoratedBox(
          // BoxDecoration takes the image
          decoration: BoxDecoration(
            // Image set to background of the body
            image: DecorationImage(
                image: AssetImage('assets/images/hollow/bg.png'),
                fit: BoxFit.fill),
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

              final child = AutoSizeText.rich(
                TextSpan(
                    children: pageBuilder
                        .buildPage(state, i, numPages, settingsController, () {
                  if (mounted) setState(() => {});
                })),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: _fontSize),
                maxLines: pageNum < 3 ? 7 : 15,
                stepGranularity: 0.1,
                minFontSize: 5,
                maxFontSize: numPages == 4 ? 28 : 98,
              );

              if (numPages == 1 &&
                  Get.mediaQuery.orientation == Orientation.landscape &&
                  Platform.isAndroid) {
                return Padding(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    child: SingleChildScrollView(child: child));
              }

              return child;
            }),
          );

          return child;
        }),
      ]);

      pages.add(Expanded(child: child));
    }

    return pages;
  }

  late Offset horizontalStartPosition;
  late Offset verticalUpperHalfStartPosition;
  late Offset verticalLowerHalfStartPosition;

  double epsilon = 0.0;

  @override
  Widget build(BuildContext context) {
    if (state.surahNumber == -1) {
      state.surahNumber = quran.getPageData(state.pageNumber).first['surah'];
    }

    return Scaffold(
      appBar: showAppBar
          ? AppTopBar(settingsController: settingsController, state: state)
          : null,
      body: Stack(children: [
        CallbackShortcuts(
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
                    includeRepeats: false):
                () => setState(
                    () => controller.goNextPage(settingsController, state)),
            const SingleActivator(LogicalKeyboardKey.arrowRight,
                    includeRepeats: false):
                () => setState(
                    () => controller.goPreviousPage(settingsController, state)),
          },
          child: Builder(builder: (context) {
            Orientation orientation = MediaQuery.of(context).orientation;
            double pageAspectRatio = 0.5;
            Size size = MediaQuery.of(context).size;
            double fontSize =
                (size.width > size.height ? size.width : size.height) / 100;
            int numPages = getNumPages(orientation);
            double widthForPage = size.width / numPages;
            double pageWidth = pageAspectRatio * size.height;
            double padding = (widthForPage - pageWidth) / 2;
            if (padding < 0) {
              padding = 0;
            }
            final List<Widget> headerChildren = [];
            final List<Widget> footerChildren = [];
            int end = startPageNum + numPages;
            for (int i = end - 1; i >= startPageNum; i--) {
              headerChildren.add(
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: padding, right: padding),
                    child: Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        Text(
                            controller.getSurahName(
                                context,
                                state.surahNumber <= 0
                                    ? 0
                                    : state.surahNumber - 1),
                            style: TextStyle(fontSize: fontSize)),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Text(
                                controller.getRubHizbInfo(
                                    state.surahNumber, i, context),
                                style: TextStyle(fontSize: fontSize)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            for (int i = startPageNum; i < end; i++) {
              footerChildren.add(
                Expanded(
                  child: Center(
                    child: Text(ArabicNumber().convertToLocaleNumber(i),
                        style: TextStyle(fontSize: fontSize)),
                  ),
                ),
              );
            }

            return Column(spacing: 0, children: [
              Row(textDirection: TextDirection.ltr, children: headerChildren),
              Expanded(
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: buildPages(context, orientation),
                ),
              ),
              Row(textDirection: TextDirection.rtl, children: footerChildren),
              Visibility(
                maintainState: true,
                visible: showPlayer,
                child: QuranPlayer(
                  recitationId: settingsController.recitationId,
                  state: state,
                  update: () => setState(() {}),
                ),
              ),
            ]);
          }),
        ),
        Visibility(
          maintainState: true,
          maintainAnimation: true,
          maintainSize: true,
          maintainInteractivity: true,
          visible: false,
          child: Column(
            children: [
              Expanded(
                child: Image(
                    image: AssetImage('assets/images/hollow/bg.png'),
                    fit: BoxFit.fill),
              ),
              Expanded(
                child: SimpleGestureDetector(
                  swipeConfig: SimpleSwipeConfig(
                      swipeDetectionBehavior: SwipeDetectionBehavior.singular),
                  onHorizontalSwipe: (direction) {
                    if (direction == SwipeDirection.left) {
                      setState(() =>
                          controller.goPreviousPage(settingsController, state));
                    } else if (direction == SwipeDirection.right) {
                      setState(() =>
                          controller.goNextPage(settingsController, state));
                    } else {
                      print('Error Error Error Error Error Error');
                    }
                  },
                  onVerticalSwipe: (direction) {
                    if (direction == SwipeDirection.down) {
                      setState(() => showPlayer = false);
                    } else if (direction == SwipeDirection.up) {
                      setState(() => showPlayer = true);
                    } else {
                      print('Error Error Error Error Error Error');
                    }
                  },
                  child: Image(
                      image: AssetImage('assets/images/hollow/bg.png'),
                      fit: BoxFit.fill),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
