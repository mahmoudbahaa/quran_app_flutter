import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/models/enums.dart';

import '../common/app_drawer.dart';
import '../common/app_top_bar.dart';
import '../common/custom_text.dart' as custom_text;
import '../common/desktop_page_scroll.dart';
import '../common/quran_info_controller.dart';
import '../home/assets_loader/assets_loader_controller.dart';
import '../settings/settings_controller.dart';
import '../util/number_utils.dart';
import '../util/quran_player_global_state.dart';
import 'page_builder.dart';
import 'quran_player.dart';

class QuranPageView extends StatefulWidget {
  const QuranPageView(
      {super.key, required this.settingsController, required this.state});

  final SettingsController settingsController;
  final QuranPlayerGlobalState state;
  static double iconsSize =
      kIsWeb || Platform.isAndroid || Platform.isIOS ? 40 : 32;

  @override
  State<QuranPageView> createState() {
    return _QuranPageViewState();
  }
}

class _QuranPageViewState extends State<QuranPageView> {
  final double defaultFontSize = 2;

  static bool showPlayer = false;
  static bool showAppBar = false;
  double spacing = 15.0;
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
    return (width < height ? width / 10 : height / 25);
  }

  bool _initialized = false;

  late PageBuilder pageBuilder;
  QuranPlayerGlobalState get state => widget.state;

  final QuranInfoController controller = const QuranInfoController();
  SettingsController get settingsController => widget.settingsController;
  late AssetsLoaderController assetsLoaderController;
  PageController _pageController = PageController();

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

    return newNumPages;
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: state.curPageInPageView);
    assetsLoaderController =
        AssetsLoaderController(settingsController: settingsController);
  }

  bool forceLightMode() {
    return (Theme.of(context).brightness == Brightness.dark &&
        settingsController.textRepresentation == TextRepresentation.codeV4);
  }

  void update() {
    setState(() => {});
  }

  void addPage(
      List<Widget> pages, int pageNumber, int numPages, double fontSize) {
    Size size = MediaQuery.sizeOf(context);

    final Widget child = Builder(builder: (context) {
      final surahNumber = quran.getPageData(pageNumber)[0]['surah'];
      final surahName = controller.getSurahName(context, surahNumber);

      final hizbInfo =
          controller.getRubHizbInfo(surahNumber, pageNumber, context);

      final header = Row(children: [
        Expanded(
            child: Text(hizbInfo, style: TextStyle(fontSize: fontSize * 0.5))),
        Text(surahName,
            style: TextStyle(fontSize: fontSize * 0.5),
            textDirection: TextDirection.ltr),
      ]);

      final footer = Align(
        alignment: Alignment.center,
        child: Text(NumberUtils.convertToLocaleNumber(pageNumber, context),
            style: TextStyle(fontSize: fontSize * 0.5)),
      );

      Widget child;

      final children = pageBuilder.buildPage(pageNumber, settingsController);

      child = custom_text.Text.rich(
        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color),
        TextSpan(children: children),
        textAlign: TextAlign.center,
        maxLines: 15,
      );

      if (settingsController.selectableViews) {
        child = SelectionArea(child: child);
      }

      child = IntrinsicWidth(
        child: Column(children: [header, child, footer]),
      );

      if (numPages == 1 &&
          size.width > size.height &&
          (kIsWeb || Platform.isAndroid || Platform.isIOS)) {
        child = SingleChildScrollView(
            child: FittedBox(fit: BoxFit.fitWidth, child: child));
      } else {
        child = FittedBox(fit: BoxFit.contain, child: child);
      }

      return child;
    });

    pages.add(
      Expanded(
        child: IntrinsicHeight(
          child: SizedBox(
              height: ((size.width / numPages - spacing * 2) * 2),
              child: child),
        ),
      ),
    );
  }

  Widget buildPages(BuildContext context, Orientation orientation, int index) {
    final pages = <Widget>[];
    int numPages = getNumPages(orientation);

    double fontSize = getMainFontSize(orientation);
    int startPageNum = index + 1;

    for (int i = 0; i < numPages; i++) {
      int pageNumber = startPageNum + i;
      if (pageNumber > quran.totalPagesCount) break;
      addPage(pages, pageNumber, numPages, fontSize);
    }

    List<Widget> children = [];
    children.add(VerticalDivider(width: spacing / 3, thickness: spacing / 3));
    for (int i = 0; i < pages.length; i++) {
      children.add(SizedBox(width: spacing / 3));
      children.add(pages[i]);
      children.add(SizedBox(width: spacing / 3));
      children.add(VerticalDivider(width: spacing / 3, thickness: spacing / 3));
    }

    Widget child = IntrinsicHeight(child: Row(children: children));

    return Localizations.override(
      context: context,
      locale: Locale('ar'),
      child: Column(children: [
        Expanded(child: Align(alignment: Alignment.center, child: child)),
      ]),
    );
  }

  late Offset horizontalStartPosition;
  late Offset verticalUpperHalfStartPosition;
  late Offset verticalLowerHalfStartPosition;

  double epsilon = 0.0;

  @override
  Widget build(BuildContext context) {
    pageBuilder = PageBuilder(
        context: context,
        state: state,
        update: update,
        fontSize: getMainFontSize(MediaQuery.orientationOf(context)),
        textRepresentation: settingsController.textRepresentation);

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
      state.curPageInPageView = ((state.pageNumber - 1) / numPages).floor();

      if (_initialized) {
        _pageController.jumpToPage(state.curPageInPageView);
      } else {
        _pageController.dispose();
        _pageController = PageController(initialPage: state.curPageInPageView);
        _initialized = true;
      }

      Widget body = DesktopPageScroll(
        controller: _pageController,
        itemCount: (quran.totalPagesCount / numPages).ceil(),
        numPages: numPages,
        state: state,
        update: update,
        child: Focus(
          autofocus: true,
          child: PageView.builder(
            onPageChanged: (value) => state.curPageInPageView = value,
            scrollDirection: Axis.horizontal,
            controller: _pageController,
            scrollBehavior: ScrollConfiguration.of(context)
                .copyWith(scrollbars: true, dragDevices: {
              PointerDeviceKind.touch,
            }),
            itemCount: (quran.totalPagesCount / numPages).ceil(),
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
                    ((kIsWeb || Platform.isIOS || Platform.isAndroid)
                        ? -4
                        : 0)),
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
              ? QuranPageView.iconsSize * 1.6
              : QuranPageView.iconsSize * 2.0;

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
                          ((!kIsWeb && (Platform.isIOS || Platform.isAndroid))
                              ? 4
                              : 0)
                      : QuranPageView.iconsSize / 2 +
                          ((!kIsWeb && (Platform.isIOS || Platform.isAndroid))
                              ? 4
                              : 0)),
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
        bottomNavigationBar: Visibility(
          visible: showPlayer,
          maintainState: true,
          child: ClipPath(
            clipper: NotchedAppBarClipper(
                iconsSize: QuranPageView.iconsSize, top: false),
            child: BottomAppBar(
              padding: EdgeInsets.zero,
              height: playerHeight,
              child: QuranPlayer(
                  settingsController: settingsController,
                  state: state,
                  update: update),
            ),
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
      );
    });
  }
}
