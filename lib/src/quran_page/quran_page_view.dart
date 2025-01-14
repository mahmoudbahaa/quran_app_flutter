import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/models/enums.dart';

import '../common/app_drawer.dart';
import '../common/app_top_bar.dart';
import '../common/custom_text.dart' as customText;
import '../common/desktop_page_scroll.dart';
import '../common/quran_info_controller.dart';
import '../home/assets_loader/assets_loader_controller.dart';
import '../settings/settings_controller.dart';
import '../util/arabic_number.dart';
import '../util/quran_player_global_state.dart';
import 'page_builder.dart';
import 'quran_player.dart';

class QuranPageView extends StatefulWidget {
  const QuranPageView(
      {super.key, required this.settingsController, required this.state});

  final SettingsController settingsController;
  final QuranPlayerGlobalState state;
  static double iconsSize = Platform.isAndroid || Platform.isIOS ? 40 : 32;

  @override
  State<QuranPageView> createState() {
    return _QuranPageViewState();
  }
}

class _QuranPageViewState extends State<QuranPageView> {
  final double defaultFontSize = 2;

  static bool showPlayer = false;
  static bool showAppBar = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int widthFactor = 20;
  int heightFactor = 20;

  int getStartPageNum(Orientation orientation) {
    int numPages = getNumPages(orientation);
    return ((state.curPageInPageView - 1) / numPages).floor() * numPages + 1;
  }

  double getMainFontSize(Orientation orientation) {
    Size size = MediaQuery.sizeOf(context);
    double width = size.width / getNumPages(orientation);
    double height = size.height;
    return (width < height ? width / 16 : height / 25);
  }

  bool _initialized = false;

  late PageBuilder pageBuilder;
  QuranPlayerGlobalState get state => widget.state;

  final QuranInfoController controller = const QuranInfoController();
  SettingsController get settingsController => widget.settingsController;
  late AssetsLoaderController assetsLoaderController;
  PageController _pageController = PageController();
  // final _controller = GlobalKey<PageFlipWidgetState>();

  Orientation? _lastOrientation;

  int getNumPagesNoCheck(Orientation orientation) {
    if (orientation == Orientation.portrait) return 1;
    return settingsController.numPages;
  }

  int getNumPages(Orientation orientation) {
    if (_lastOrientation == orientation) {
      return getNumPagesNoCheck(orientation);
    }

    if (_lastOrientation == null) {
      _lastOrientation = orientation;
      return getNumPagesNoCheck(orientation);
    }

    int oldNumPages = getNumPagesNoCheck(_lastOrientation!);
    int newNumPages = getNumPagesNoCheck(orientation);
    state.curPageInPageView =
        (state.curPageInPageView * oldNumPages / newNumPages).floor();

    _lastOrientation = orientation;

    // _controller.currentState!.goToPage(state.curPageInPageView);
    _pageController.jumpToPage(state.curPageInPageView);
    return newNumPages;
  }

  @override
  void initState() {
    super.initState();
    pageBuilder = PageBuilder(
        context: context,
        textRepresentation: settingsController.textRepresentation);
    _pageController = PageController(initialPage: state.curPageInPageView);
    assetsLoaderController =
        AssetsLoaderController(settingsController: settingsController);
  }

  bool forceLightMode() {
    return (Theme.of(context).brightness == Brightness.dark &&
        settingsController.textRepresentation == TextRepresentation.codeV4);
  }

  void update() {
    if (mounted) setState(() => {});
  }

  void addPage(
      List<Widget> pages, int pageNumber, int numPages, double fontSize) {
    final Widget child = Builder(builder: (context) {
      final surahNumber = quran.getPageData(pageNumber)[0]['surah'];
      final surahName = controller.getSurahName(context, surahNumber - 1);

      final hizbInfo =
          controller.getRubHizbInfo(state.surahNumber, pageNumber, context);

      final header = Row(children: [
        Expanded(
            child: Text(hizbInfo, style: TextStyle(fontSize: fontSize * 0.5))),
        Text(surahName,
            style: TextStyle(fontSize: fontSize * 0.5),
            textDirection: TextDirection.ltr),
      ]);

      final footer = Align(
        alignment: Alignment.center,
        child: Text(ArabicNumber().convertToLocaleNumber(pageNumber, context),
            style: TextStyle(fontSize: fontSize * 0.5)),
      );

      Widget child;
      if (settingsController.selectableViews) {
        final children = pageBuilder.buildPage(
            state, pageNumber, settingsController, update, fontSize);

        child = IntrinsicWidth(
          child: Column(children: [
            header,
            SelectionArea(
                child: customText.Text.rich(
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color),
              TextSpan(children: children),
              textAlign: TextAlign.center,
              maxLines: 15,
            )),
            footer
          ]),
        );
      } else {
        final children2 = pageBuilder.buildPage2(
            state, pageNumber, settingsController, update, fontSize);

        children2.insert(0, header);
        children2.add(footer);

        child = IntrinsicWidth(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Column(children: children2),
          ),
        );
      }

      Size size = MediaQuery.sizeOf(context);

      if (numPages == 1 &&
          size.width > size.height &&
          (Platform.isAndroid || Platform.isIOS)) {
        child = SingleChildScrollView(
            child: FittedBox(fit: BoxFit.fitWidth, child: child));
      } else {
        child = FittedBox(fit: BoxFit.fitHeight, child: child);
      }

      return Localizations.override(
          context: context, locale: Locale('ar'), child: child);
    });

    pages.add(
      Expanded(
        child: child,
      ),
    );
  }

  Widget buildPages(BuildContext context, Orientation orientation, int index) {
    final pages = <Widget>[];
    int numPages = getNumPages(orientation);

    double fontSize = getMainFontSize(orientation);
    int startPageNum = index + 1;
    List<Widget> pageNums = [];

    for (int i = 0; i < numPages; i++) {
      int pageNumber = startPageNum + i;
      addPage(pages, pageNumber, numPages, fontSize);
    }

    List<Widget> children = [];
    children.add(VerticalDivider(width: 3, thickness: 3));
    children.add(SizedBox(width: 3));
    for (int i = 0; i < pages.length; i++) {
      children.add(pages[i]);
      children.add(VerticalDivider(width: 3, thickness: 3));
    }

    children.add(SizedBox(width: 3));

    Widget child = Row(children: children);

    if (numPages != 1) {
      child = IntrinsicHeight(child: child);
    }

    // return child;
    return Column(children: [
      Expanded(
        child: Align(
          alignment: Alignment.center,
          child: child,
        ),
      ),
      Row(children: pageNums),
    ]);
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

    Size size = MediaQuery.sizeOf(context);
    double width = size.width;
    double height = size.height;
    double aspectRatio = 2;

    return OrientationBuilder(builder: (context, orientation) {
      if (MediaQuery.orientationOf(context) == Orientation.landscape) {
        double temp = height;
        height = width;
        width = temp;
      }

      if (width * aspectRatio > height) {
        width = height / aspectRatio;
      }

      final int numPages = getNumPages(orientation);
      if (state.curPageInPageView == -1) {
        state.curPageInPageView = ((state.pageNumber - 1) / numPages).floor();
      }

      if (_initialized) {
        _pageController.jumpToPage(state.curPageInPageView);
      } else {
        _pageController.dispose();
        _pageController = PageController(initialPage: state.curPageInPageView);
        _initialized = true;
      }

      Widget body = DesktopPageScroll(
        controller: _pageController,
        itemCount: (quran.totalPagesCount / numPages).floor(),
        state: state,
        child: Focus(
          autofocus: true,
          child: PageView.builder(
            onPageChanged: (value) => state.curPageInPageView = value,
            scrollDirection: Axis.horizontal,
            controller: _pageController,
            scrollBehavior:
                ScrollConfiguration.of(context).copyWith(dragDevices: {
              PointerDeviceKind.touch,
            }),
            itemCount: (quran.totalPagesCount / numPages).floor(),
            reverse: !isRtl(context),
            itemBuilder: (context, index) =>
                buildPages(context, orientation, index * numPages),
            physics: BouncingScrollPhysics(),
          ),
        ),
      );

      if (forceLightMode()) {
        body = ColoredBox(color: Colors.white, child: body);
      }

      List<Widget> stackChildren = [
        body,
        Align(
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: Offset(
                0,
                -1 * QuranPageView.iconsSize / 2 +
                    ((Platform.isIOS || Platform.isAndroid) ? -4 : 0)),
            child: MaterialButton(
              shape: CircleBorder(),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () => setState(() => showAppBar = !showAppBar),
              child: showAppBar
                  ? Icon(Icons.arrow_drop_up_rounded,
                      size: QuranPageView.iconsSize)
                  : Icon(Icons.arrow_drop_down_rounded,
                      size: QuranPageView.iconsSize),
            ),
          ),
        )
      ];

      double playerHeight =
          MediaQuery.orientationOf(context) == Orientation.landscape
              ? QuranPageView.iconsSize * 1.8
              : QuranPageView.iconsSize * 2.6;

      return Scaffold(
        key: scaffoldKey,
        endDrawer:
            AppDrawer(state: state, settingsController: settingsController),
        appBar: showAppBar
            ? AppTopBar(
                scaffoldKey: scaffoldKey,
                settingsController: settingsController,
                state: state,
                hasNotch: true,
                iconsSize: QuranPageView.iconsSize)
            : null,
        body: Padding(
            padding: EdgeInsets.only(bottom: QuranPageView.iconsSize / 2 - 4),
            child: Stack(children: stackChildren)),
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
              offset: Offset(
                  0,
                  showPlayer
                      ? QuranPageView.iconsSize / 2 -
                          playerHeight +
                          ((Platform.isIOS || Platform.isAndroid) ? 4 : 0)
                      : QuranPageView.iconsSize / 2 +
                          ((Platform.isIOS || Platform.isAndroid) ? 4 : 0)),
              child: MaterialButton(
                  shape: CircleBorder(),
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () => setState(() => showPlayer = !showPlayer),
                  child: !showPlayer
                      ? Icon(Icons.arrow_drop_up_rounded,
                          size: QuranPageView.iconsSize)
                      : Icon(Icons.arrow_drop_down_rounded,
                          size: QuranPageView.iconsSize))),
        ),
        bottomNavigationBar: showPlayer
            ? ClipPath(
                clipper: NotchedAppBarClipper(
                    iconsSize: QuranPageView.iconsSize, top: false),
                child: BottomAppBar(
                  height: playerHeight,
                  child: QuranPlayer(
                      recitationId: settingsController.recitationId,
                      state: state,
                      update: update),
                ),
              )
            : null,
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
      );
    });
  }
}
