import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quran_app_flutter/src/home/surahs_list_view.dart';

import '../common/app_drawer.dart';
import '../common/app_top_bar.dart';
import '../localization/app_localizations.dart';
import '../settings/settings_controller.dart';
import '../util/quran_player_global_state.dart';
import 'assets_loader/assets_loader_widget.dart';
import 'juzs_list_view.dart';

/// Displays a list of SampleItems.
class QuranChaptersListView extends StatefulWidget {
  const QuranChaptersListView(
      {super.key, required this.controller, required this.state});

  final SettingsController controller;
  final QuranPlayerGlobalState state;

  @override
  State<StatefulWidget> createState() {
    return _QuranChaptersListViewState();
  }
}

class _QuranChaptersListViewState extends State<QuranChaptersListView> {
  SettingsController get settingsController => widget.controller;
  QuranPlayerGlobalState get state => widget.state;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final maxVerseWords = 5;
  final fontSize = 20.0;
  bool showAppBar = true;
  final double _iconsSize = 32;

  @override
  void initState() {
    super.initState();
    state.loading = true;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: scaffoldKey,
        appBar: showAppBar
            ? AppTopBar(
                state: state,
                settingsController: settingsController,
                hasNotch: false,
                iconsSize: _iconsSize,
                scaffoldKey: scaffoldKey,
                tabs: [
                    SizedBox(
                      height: 30,
                      child: Tab(text: AppLocalizations.of(context)!.chapters),
                    ),
                    SizedBox(
                      height: 30,
                      child: Tab(text: AppLocalizations.of(context)!.hizb),
                    ),
                  ])
            : null,

        // To work with lists that may contain a large number of items, it’s best
        // to use the ListView.builder constructor.
        //
        // In contrast to the default ListView constructor, which requires
        // building all Widgets up front, the ListView.builder constructor lazily
        // builds Widgets as they’re scrolled into view.
        body: Builder(builder: (context) {
          if (state.loading) {
            return AssetsLoaderWidget(
                settingsController: settingsController,
                state: state,
                update: () => setState(() {}));
          } else {
            return TabBarView(children: [
              SurahsListView(
                  settingsController: settingsController, state: state),
              JuzsListView(
                  settingsController: settingsController, state: state),
            ]);
          }
        }),

        endDrawer:
            AppDrawer(state: state, settingsController: settingsController),
      ),
    );
  }
}

class CircleGraphWidget {}
