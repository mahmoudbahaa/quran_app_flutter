import 'package:flutter/material.dart';

import '../common/quran_info_controller.dart';
import '../localization/app_localizations.dart';
import '../settings/settings_controller.dart';
import '../util/quran_player_global_state.dart';

class AppTopBar extends AppBar {
  AppTopBar({
    super.key,
    required this.settingsController,
    required this.state,
    required this.scaffoldKey,
    this.tabs,
    this.hasNotch = false,
    this.iconsSize = 40.0,
  });

  final QuranPlayerGlobalState state;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final SettingsController settingsController;
  final bool hasNotch;
  final double iconsSize;
  final List<Widget>? tabs;

  @override
  State<AppTopBar> createState() {
    return _AppTopBarState();
  }
}

class _AppTopBarState extends State<AppTopBar> {
  final fontSize = 18.0;
  final QuranInfoController controller = const QuranInfoController();
  QuranPlayerGlobalState get state => widget.state;
  SettingsController get settingsController => widget.settingsController;

  @override
  Widget build(BuildContext context) {
    Widget title;

    title = Text(AppLocalizations.of(context)!.appTitle,
        style: TextStyle(fontSize: 14));

    if (widget.tabs != null) {
      title = Row(children: [
        title,
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: TabBar(
              tabs: widget.tabs!,
            ),
          ),
        ),
      ]);
    }

    final appBar = AppBar(titleSpacing: 0.0, bottomOpacity: 0.0, title: title);

    if (!widget.hasNotch) return appBar;

    return ClipPath(
      clipper: NotchedAppBarClipper(iconsSize: widget.iconsSize, top: true),
      child: appBar,
    );
  }
}

class NotchedAppBarClipper extends CustomClipper<Path> {
  NotchedAppBarClipper({required this.iconsSize, required this.top});

  double iconsSize;
  bool top;

  @override
  Path getClip(Size size) {
    if (top) {
      return Path()
        ..lineTo(0, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width / 2 - iconsSize / 2 - 4, size.height)
        ..arcToPoint(Offset(size.width / 2 + iconsSize / 2 + 4, size.height),
            radius: Radius.circular(iconsSize / 2 + 4))
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, 0)
        ..close();
    } else {
      return Path()
        ..lineTo(0, 0)
        // ..lineTo(0, size.height)
        ..lineTo(size.width / 2 - iconsSize / 2 - 4, 0)
        ..arcToPoint(Offset(size.width / 2 + iconsSize / 2 + 4, 0),
            radius: Radius.circular(iconsSize / 2 + 4), clockwise: false)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    }
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
