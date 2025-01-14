import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/home/assets_loader/assets_loader_controller.dart';
import 'package:quran_app_flutter/src/settings/settings_controller.dart';

import '../../localization/app_localizations.dart';
import '../../util/quran_player_global_state.dart';

class AssetsLoaderWidget extends StatefulWidget {
  const AssetsLoaderWidget(
      {super.key,
      required this.settingsController,
      required this.state,
      required this.update});

  final SettingsController settingsController;
  final QuranPlayerGlobalState state;
  final Function update;

  @override
  State<StatefulWidget> createState() {
    return _AssetsDownloaderWidget();
  }
}

class _AssetsDownloaderWidget extends State<AssetsLoaderWidget> {
  final ValueNotifier<double> downloadProgressNotifier = ValueNotifier(0);

  int startTime = DateTime.now().millisecondsSinceEpoch;
  int assetsLoaded = 0;
  int totalAssets = quran.totalPagesCount * 2; //Platform.isAndroid
  // ? quran.totalPagesCount * 2
  // : quran.totalPagesCount * 3;

  int get secs =>
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000).floor();
  String get elapsed {
    int seconds = secs;
    int minutes = 0;
    int hours = 0;
    if (seconds > 60) {
      minutes = (seconds / 60).floor();
      seconds = seconds % 60;
      if (minutes > 60) {
        hours = (minutes / 60).floor();
        minutes = hours % 60;
      }
    }

    return '${hours > 0 ? '$hours hours' : ''} ${minutes > 0 ? '$minutes minutes' : ''} $seconds seconds';
  }

  int get remaining {
    return (secs *
            (100 - downloadProgressNotifier.value) /
            (downloadProgressNotifier.value == 0
                ? 1
                : downloadProgressNotifier.value))
        .floor();
  }

  void update() {
    assetsLoaded++;
    if (assetsLoaded >= totalAssets) {
      setState(() => widget.state.loading = false);
      widget.update();
    }
    setState(() => downloadProgressNotifier.value =
        double.parse(((assetsLoaded / totalAssets) * 100).toStringAsFixed(2)));
  }

  @override
  void initState() {
    super.initState();
    AssetsLoaderController(settingsController: widget.settingsController)
        .loadAssets(update);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder(
          valueListenable: downloadProgressNotifier,
          builder: (context, value, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.loading,
                  style: TextStyle(fontSize: 40),
                ),
                const SizedBox(
                  height: 32,
                ),
                CircularPercentIndicator(
                  radius: 75.0,
                  lineWidth: 15.0,
                  // animation: true,
                  percent: downloadProgressNotifier.value / 100,
                  center: Text(
                    '${downloadProgressNotifier.value}%',
                    style: const TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.w600),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(
                  height: 32,
                ),
                Text(
                  textDirection: TextDirection.ltr,
                  '$assetsLoaded/$totalAssets',
                  style: const TextStyle(fontSize: 24.0),
                ),
                Text(
                  textDirection: TextDirection.ltr,
                  'Elapsed: $elapsed',
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  textDirection: TextDirection.ltr,
                  'Estimated Remaining: $remaining seconds',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            );
          }),
    );
  }
}
