import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:quran_app_flutter/src/util/quran_player_global_state.dart';

// The PlayerWidget is a copy of "/lib/components/player_widget.dart".
//#region PlayerWidget
class DownloadWidget extends StatefulWidget {
  final String downloadUrl;
  final String filePath;
  final QuranPlayerGlobalState state;

  const DownloadWidget({
    super.key,
    required this.downloadUrl,
    required this.filePath,
    required this.state,
  });

  @override
  State<StatefulWidget> createState() {
    return _DownloadWidgetState();
  }
}

class _DownloadWidgetState extends State<DownloadWidget> {
  ValueNotifier downloadProgressNotifier = ValueNotifier(0);

  String get downloadUrl => widget.downloadUrl;
  String get filePath => widget.filePath;
  double? actualBytes;
  double? totalBytes;

  @override
  void initState() {
    super.initState();

    Dio().download(downloadUrl, filePath,
        onReceiveProgress: (actualBytes, int totalBytes) {
      if ( actualBytes == totalBytes) widget.state.downloaded.value = true;
      this.actualBytes = actualBytes / 1024 / 1024;
      this.totalBytes = totalBytes / 1024 / 1024;
      downloadProgressNotifier.value = (actualBytes / totalBytes * 100).floor();
    });
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
                // const Text(
                //   'Downloading',
                //   style: TextStyle(fontSize: 20),
                // ),
                // const SizedBox(
                //   height: 32,
                // ),
                CircularPercentIndicator(
                  radius: 50.0,
                  lineWidth: 10.0,
                  // animation: true,
                  percent: downloadProgressNotifier.value / 100,
                  center: Text(
                    "${downloadProgressNotifier.value}%",
                    style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  backgroundColor: Colors.grey.shade300,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.blueAccent,
                ),
                const SizedBox(
                  height: 32,
                ),
                // const Text(
                //   'Linear Progress Indicator',
                //   style: TextStyle(fontSize: 20),
                // ),
                // const SizedBox(
                //   height: 32,
                // ),
                // LinearPercentIndicator(
                //   // animation: true,
                //   barRadius: const Radius.circular(10),
                //   // animationDuration: 400,
                //   lineHeight: 15.0,
                //   percent: downloadProgressNotifier.value / 100,
                //   backgroundColor: Colors.grey.shade300,
                //   progressColor: Colors.blue,
                // ),
                // const SizedBox(
                //   height: 15,
                // ),
                Text(
                  textDirection: TextDirection.ltr,
                  "${actualBytes == null ? '0.0' : actualBytes!.toStringAsFixed(1)} MB/${totalBytes == null ? '0.0' : totalBytes!.toStringAsFixed(1)} MB",
                  style: const TextStyle(
                      fontSize: 20.0,
                      // fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ],
            );
          }),
    );
  }
}

//#endregion