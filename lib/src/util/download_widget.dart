import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:quran_app_flutter/src/db/exposed_models.dart';

import '../quran_page/quran_player.dart';
import '../util/quran_player_global_state.dart';

// The PlayerWidget is a copy of "/lib/components/player_widget.dart".
//#region PlayerWidget
class DownloadWidget extends StatefulWidget {
  const DownloadWidget({
    super.key,
    required this.audioFile,
    required this.filePath,
    required this.state,
    required this.parent,
  });

  final AudioFile audioFile;
  final String filePath;
  final QuranPlayerGlobalState state;
  final QuranPlayerState parent;

  @override
  State<StatefulWidget> createState() {
    return _DownloadWidgetState();
  }
}

class _DownloadWidgetState extends State<DownloadWidget> {
  ValueNotifier downloadProgressNotifier = ValueNotifier(0);

  AudioFile get audioFile => widget.audioFile;
  String get filePath => widget.filePath;
  QuranPlayerState get parent => widget.parent;
  double? actualBytes;
  double? totalBytes;

  @override
  void initState() {
    super.initState();

    Dio().download(audioFile.url, filePath,
        onReceiveProgress: (actualBytes, int totalBytes) {
      this.actualBytes = actualBytes / 1024 / 1024;
      this.totalBytes = totalBytes / 1024 / 1024;
      downloadProgressNotifier.value = (actualBytes / totalBytes * 100).floor();
    }).then((value) {
      widget.state.downloading = false;
      parent.setSource(audioFile, filePath).then((value) => parent.seek(true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder(
          valueListenable: downloadProgressNotifier,
          builder: (context, value, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LinearPercentIndicator(
                  percent: downloadProgressNotifier.value / 100,
                  // circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  textDirection: TextDirection.ltr,
                  "${downloadProgressNotifier.value}% (${actualBytes == null ? '0.0' : actualBytes!.toStringAsFixed(1)} MB/${totalBytes == null ? '0.0' : totalBytes!.toStringAsFixed(1)} MB)",
                  style: const TextStyle(fontSize: 12.0),
                ),
              ],
            );
          }),
    );
  }
}

//#endregion
