import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:universal_io/io.dart';

import '../settings/settings_controller.dart';
import '../util/download_widget.dart';
import '../util/player_widget.dart';
import '../util/quran_player_global_state.dart';

class QuranPlayer extends StatefulWidget {
  const QuranPlayer({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  State<StatefulWidget> createState() => _QuranPlayerState();
}

class _QuranPlayerState extends State<QuranPlayer> {
  Player get player => PlayerWidget.player;
  int? surahNumber;
  int? recitationId;
  int verseNumber = -1;
  int wordNumber = -1;
  String? filePath;
  String? downloadUrl;

  //late bool _update =  update;

  Future<void> setSource() async {
    await player.stop();
    // await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
    // await player.open(AudioSource.file(filePath));
    await player.open(Media(filePath!));
  }

  Future<void> seek(bool play) async {
    QuranPlayerGlobalState state = Get.find();
    if (surahNumber != state.surahNumber.value ||
        verseNumber != state.verseNumber.value ||
        wordNumber != state.wordNumber.value) {
      verseNumber = state.verseNumber.value;
      wordNumber = state.wordNumber.value;
      if (verseNumber > 1) {
        dynamic verseTiming = state.verseTimings[verseNumber - 1];
        int startPoint = verseTiming['timestamp_from'];
        if (state.wordNumber.value > 1) {
          dynamic segments = verseTiming['segments'];
          for (int i = 0; i < segments.length; i++) {
            if (segments[i][0] == state.wordNumber.value) {
              startPoint = segments[i][1].floor();
              break;
            }
          }
        }

        await player.seek(Duration(milliseconds: startPoint));
      }
    }

    if (play) {
      state.playing.value = true;
      await player.play();
    } else {
      await player.pause();
    }
  }

  Future<void> changeSource(bool play) async {
    QuranPlayerGlobalState state = Get.find();

    if (surahNumber != state.surahNumber.value ||
        recitationId != widget.settingsController.recitationId) {
      surahNumber = state.surahNumber.value;
      recitationId = widget.settingsController.recitationId;
      await player.pause();
      dynamic surahInfo = await makeGetRequest(getUrl(
          state.surahNumber.value, widget.settingsController.recitationId));
      state.verseTimings = surahInfo['audio_files'][0]['verse_timings'];
      downloadUrl = surahInfo['audio_files'][0]['audio_url'];
      String fileName =
          downloadUrl!.substring(downloadUrl!.lastIndexOf('/') + 1);

      if (kIsWeb) {
        filePath = downloadUrl;
      } else {
        Directory directory;
        if (Platform.isAndroid) {
          directory = (await getExternalStorageDirectory())!;
        } else {
          directory = (await getApplicationDocumentsDirectory());
        }

        filePath =
            '${directory.path}/${widget.settingsController.recitationId}_$fileName';
        bool exists = File(filePath!).existsSync();
        if (!exists) {
          state.downloading.value = true;
          return;
        }
      }

      setSource();
    }

    seek(play);
  }

  @override
  void initState() {
    super.initState();

    QuranPlayerGlobalState state = Get.find();
    // ambiguate(WidgetsBinding.instance)!.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
    player.stream.position.listen((duration) {
      if (!mounted) return;
      dynamic verseTimings = state.verseTimings;
      if (verseTimings == null || !state.playing.value) return;
      int surahNumber = state.surahNumber.value;
      int verse = -1;
      while (verse < verseTimings.length - 1) {
        verse++;
        dynamic segments = verseTimings[verse]['segments'];
        int word = -1;
        for (int segment = 0; segment < segments.length; segment++) {
          if (segments[segment].length < 3) continue;
          word = segments[segment][0];
          if (duration.inMilliseconds >= segments[segment][1] &&
              duration.inMilliseconds < segments[segment][2]) {
            state.verseNumber.value = verse + 1;
            state.wordNumber.value = word;
            state.pageNumber.value =
                quran.getPageNumber(surahNumber, state.verseNumber.value);
            state.update();
            return;
          }
        }
      }

      if (player.state.completed) {
        if (surahNumber == 114) return;
        // state.updateSurahNumber(state.surahNumber.value + 1);
        if (!state.playing.value) return;
        state.playing.value = false;
        state.surahNumber.value++;
        state.verseNumber.value = 1;
        state.wordNumber.value = -1;
        state.pageNumber.value =
            quran.getPageNumber(surahNumber + 1, state.verseNumber.value);
        state.update();
        changeSource(true);
      }
    });
  }

  dynamic makeGetRequest(String url) async {
    var response = await http.get(Uri.parse(url));
    return jsonDecode(response.body);
  }

  String getUrl(int surahNumber, int recitationId) {
    return 'https://quran.com/api/proxy/content/api/qdc/audio/reciters/$recitationId/audio_files?chapter=$surahNumber&segments=true';
  }

  int getSurahNumber(int pageNumber) {
    int surahNumber = 1;
    while (pageNumber >
        quran.getPageNumber(surahNumber, quran.getVerseCount(surahNumber))) {
      surahNumber++;
    }
    return surahNumber;
  }

  int getVerseNumber(int surahNumber, int pageNumber) {
    int currentPageNumber;
    for (int i = 1; i < quran.getVerseCount(surahNumber); i++) {
      currentPageNumber = quran.getPageNumber(surahNumber, i + 1);
      if (pageNumber == currentPageNumber) return i;
    }

    return -1;
  }

  void _init() async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    // Listen to errors during playback.
    // player.playbackEventStream.listen((event) {},
    //     onError: (Object e, StackTrace stackTrace) {
    //   print('A stream error occurred: $e');
    // });
  }

  @override
  void dispose() {
    // ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    // if (state == AppLifecycleState.paused) {
    // Release the player's resources when not in use. We use "stop" so that
    // if the app resumes later, it will still remember what position to
    // resume from.
    player.stop();
    // player.dispose();
    // }
    super.dispose();
  }

  Future<void> preBuild() async {
    QuranPlayerGlobalState state = Get.put(Get.find());

    if (state.downloaded.value) {
      state.downloading.value = false;
      state.downloaded.value = false;
      await setSource();
      await seek(true);
    }

    if (state.pause.value) {
      state.pause.value = false;
      await player.pause();
    } else if (!state.playing.value) {
      await changeSource(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    QuranPlayerGlobalState state = Get.put(Get.find());
    return GetX<QuranPlayerGlobalState>(builder: (c) {
      state.pageNumber.value;
      if (state.downloading.value && downloadUrl != null && filePath != null) {
        return DownloadWidget(
            downloadUrl: downloadUrl!, filePath: filePath!, state: state);
      } else {
        preBuild();
        return PlayerWidget(
            state: state,
            update: () async {
              await changeSource(true);
            });
      }
    });
  }
}
