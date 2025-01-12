import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/home/assets_loader/assets_loader_controller.dart';
import 'package:quran_app_flutter/src/quran_page/quran_page_controller.dart';

import '../models/enums.dart';
import '../settings/settings_controller.dart';
import '../util/floating_buttons.dart';
import '../util/quran_player_global_state.dart';
import '../util/swipe_to.dart';
import 'page_builder.dart';

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

  final QuranPageController controller = const QuranPageController();
  SettingsController get settingsController => widget.settingsController;
  late AssetsLoaderController assetsLoaderController;

  @override
  void initState() {
    super.initState();
    assetsLoaderController =
        AssetsLoaderController(settingsController: settingsController);
  }

  void _update() {
    setState(() {});
  }

  List<Widget> buildPages() {
    List<Widget> pages = <Widget>[];

    int numPages = settingsController.numPages;
    for (int i = 0; i < numPages; i++) {
      int pageNum =
          i + 1 + ((state.pageNumber - 1) / numPages).floor() * numPages;
      if (pageNum > quran.totalPagesCount) break;

      String? imagePath = assetsLoaderController.getImagePath(pageNum);
      if (imagePath == null) {
        assetsLoaderController.loadImage(pageNum).then((_) {
          if (mounted) setState(() {});
        });
      }

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
              return
                  // Padding(
                  // padding: EdgeInsets.only(top: pageNum < 3 ? height * 0.15 : 0),
                  // child:
                  //   ConstrainedBox(
                  // constraints: BoxConstraints(
                  //     minWidth: pageNum < 3 ? width * 0.46 : width * 1.2,
                  //     maxWidth: pageNum < 3 ? width * 0.46 : width * 1.2,
                  //     minHeight: pageNum < 3 ? height * 0.3 : height * 1.2,
                  //     maxHeight: pageNum < 3 ? height * 0.3 : height * 1.2),
                  // child:
                  AutoSizeText.rich(
                TextSpan(
                    children: pageBuilder
                        .buildPage(state, i, numPages, settingsController, () {
                  if (mounted) setState(() => {});
                })),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: _fontSize),
                maxLines: pageNum == 1 ? 8 : 15,
                stepGranularity: 1,
                minFontSize: 5,
                maxFontSize: numPages == 4 ? 28 : 98,
                // ),
                // ),
              );
            }),
          );

          if (imagePath == null || imagePath.startsWith('http')) return child;

          double imageAspectRatio = 700 / 450;
          double deviceAspectRatio =
              Get.mediaQuery.size.height / Get.mediaQuery.size.width;
          bool isLandScape =
              Get.mediaQuery.orientation == Orientation.landscape;

          return child;
          // return DecoratedBox(
          //   // BoxDecoration takes the image
          //   decoration: BoxDecoration(
          //     // Image set to background of the body
          //     image: DecorationImage(
          //         image: imagePath.startsWith('http')
          //             ? NetworkImage(imagePath)
          //             : FileImage(File(imagePath)),
          //         fit: (deviceAspectRatio > imageAspectRatio && !isLandScape)
          //             ? BoxFit.fill
          //             : BoxFit.fitHeight),
          //   ),
          //   child: child,
          // );
        }),
      ]);

      pages.add(Expanded(child: child));
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnimatedOpacity(
          opacity: state.pageTransition != PageTransition.noChange ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 500),
          onEnd: () {
            if (state.pageTransition == PageTransition.nextPage) {
              setState(() {
                state.pageTransition = PageTransition.noChange;
                controller.goNextPage(settingsController, state);
              });
            } else if (state.pageTransition == PageTransition.previousPage) {
              setState(() {
                state.pageTransition = PageTransition.noChange;
                controller.goPreviousPage(settingsController, state);
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
                        includeRepeats: false):
                    () => setState(
                        () => controller.goNextPage(settingsController, state)),
                const SingleActivator(LogicalKeyboardKey.arrowRight,
                    includeRepeats:
                        false): () => setState(
                    () => controller.goPreviousPage(settingsController, state)),
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
                // QuranPlayer(
                //   settingsController: settingsController,
                //   state: state,
                //   parent: this,
                // ),
              ]),
            ),
          ),
        ),
        floatingActionButton: FloatingButtons(state: state, update: _update));
  }
}
