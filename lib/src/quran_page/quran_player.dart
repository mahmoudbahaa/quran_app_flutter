import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:quran/quran.dart' as quran;
import 'package:universal_io/io.dart';

import '../settings/settings_controller.dart';
import '../util/download_widget.dart';
import '../util/file_utils.dart';
import '../util/player_widget.dart';
import '../util/quran_player_global_state.dart';
import 'quran_page_view.dart';

class QuranPlayer extends StatefulWidget {
  const QuranPlayer(
      {super.key,
      required this.settingsController,
      required this.state,
      required this.parent});

  final SettingsController settingsController;
  final QuranPlayerGlobalState state;
  final State<QuranChapterDetailsView> parent;

  @override
  State<StatefulWidget> createState() => QuranPlayerState();
}

class QuranPlayerState extends State<QuranPlayer> {
  Player get player => Player();
  int? surahNumber;
  int? recitationId;
  int verseNumber = -1;
  int wordNumber = -1;
  String? filePath;
  String? downloadUrl;
  QuranPlayerGlobalState get state => widget.state;
  SettingsController get settingsController => widget.settingsController;
  State<QuranChapterDetailsView> get parent => widget.parent;

  //late bool _update =  update;

  Future<void> setSource() async {
    if (filePath == null) return;
    await player.stop();
    // await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
    // await player.open(AudioSource.file(filePath));
    await player.open(Media(filePath!));
  }

  Future<void> seek(bool play) async {
    if (surahNumber != state.surahNumber ||
        verseNumber != state.verseNumber ||
        wordNumber != state.wordNumber) {
      verseNumber = state.verseNumber;
      wordNumber = state.wordNumber;
      if (verseNumber > 1) {
        dynamic verseTiming = state.verseTimings[verseNumber - 1];
        int startPoint = verseTiming['timestamp_from'];
        if (state.wordNumber > 1) {
          dynamic segments = verseTiming['segments'];
          for (int i = 0; i < segments.length; i++) {
            if (segments[i][0] == state.wordNumber) {
              startPoint = segments[i][1].floor();
              break;
            }
          }
        }

        await player.seek(Duration(milliseconds: startPoint));
      }
    }

    if (play) {
      state.playing = true;
      await player.play();
    } else {
      await player.pause();
    }
  }

  Future<void> changeSource(bool play) async {
    if (surahNumber != state.surahNumber ||
        recitationId != settingsController.recitationId) {
      surahNumber = state.surahNumber;
      recitationId = settingsController.recitationId;
      await player.pause();
      dynamic surahInfo = await makeGetRequest(
          getUrl(state.surahNumber, settingsController.recitationId));
      state.verseTimings = surahInfo['audio_files'][0]['verse_timings'];
      downloadUrl = surahInfo['audio_files'][0]['audio_url'];
      String fileName =
          downloadUrl!.substring(downloadUrl!.lastIndexOf('/') + 1);

      if (kIsWeb) {
        filePath = downloadUrl;
      } else {
        File file = (await FileUtils()
            .getFile('${settingsController.recitationId}_$fileName'))!;
        if (!file.existsSync()) {
          parent.setState(() => state.downloading = true);
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

    // ambiguate(WidgetsBinding.instance)!.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
    player.stream.position.listen((duration) async {
      if (!mounted) return;
      dynamic verseTimings = state.verseTimings;
      if (verseTimings == null || !state.playing) return;
      int surahNumber = state.surahNumber;
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
            state.verseNumber = verse + 1;
            state.wordNumber = word;
            state.pageNumber =
                quran.getPageNumber(surahNumber, state.verseNumber);
            parent.setState(() {});
            return;
          }
        }
      }

      if (player.state.completed) {
        if (surahNumber == 114) return;
        // state.updateSurahNumber(state.surahNumber + 1);
        if (!state.playing) return;
        state.playing = false;
        state.surahNumber++;
        state.verseNumber = 1;
        state.wordNumber = -1;
        state.pageNumber =
            quran.getPageNumber(surahNumber + 1, state.verseNumber);
        parent.setState(() {});
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

  // Future<void> preBuild() async {
  //   if (state.pause) {
  //     state.pause = false;
  //     await player.pause();
  //   } else if (!state.playing) {
  //     await changeSource(true);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (state.downloading && downloadUrl != null && filePath != null) {
      return DownloadWidget(
          downloadUrl: downloadUrl!,
          filePath: filePath!,
          state: state,
          parent: this);
    } else {
      // preBuild();
      return PlayerWidget(
          state: state,
          player: player,
          update: () async {
            await changeSource(true);
          });
    }
  }
}
