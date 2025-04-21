import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/common/quran_info_controller.dart';
import 'package:quran_app_flutter/src/localization/app_localizations.dart';
import 'package:quran_app_flutter/src/settings/settings_controller.dart';
import 'package:universal_io/io.dart';

import '../db/db_utils/db_utils.dart';
import '../db/exposed_models.dart';
import '../util/download_widget.dart';
import '../util/player_widget.dart';
import '../util/quran_player_global_state.dart';

class QuranPlayer extends StatefulWidget {
  const QuranPlayer(
      {super.key,
      required this.state,
      required this.update,
      required this.settingsController});

  final QuranPlayerGlobalState state;
  final VoidCallback update;
  final SettingsController settingsController;

  @override
  State<StatefulWidget> createState() => QuranPlayerState();
}

class QuranPlayerState extends State<QuranPlayer> {
  AudioPlayer player = AudioPlayer();
  int surahNumber = -1;
  int get recitationId => widget.settingsController.recitationId;
  int? lastRecitationId;
  int verseNumber = -1;
  int wordNumber = -1;
  int pageNumber = -1;
  String? downloadFilePath;
  AudioFile? audioFile;
  QuranPlayerGlobalState get state => widget.state;
  final int maxHttpRequestRetries = 5;
  List<UriAudioSource> queue = [];

  Future<void> setSource(AudioFile? audioFile, String filePath) async {
    if (audioFile == null) return;

    await player.seek(Duration.zero, index: state.surahNumber - 1);
    await player.play();
    // await player.stop();
    // await player.play();
    // addMediaItem(surahNumber!, recitationId, filePath, true);
    setState(() {});
  }

  Future<void> downloadNext(
      {required int surahNumber,
      required int recitationId,
      required bool showDownloadBar,
      required bool append,
      required bool forward}) async {
    if (surahNumber < 1 || surahNumber > quran.totalSurahCount) return;

    String url = getUrl(surahNumber, recitationId);
    AudioFile? audioFile = await DBUtils.loadVersesData(
        recitationId: recitationId, surahNumber: surahNumber, url: url);
    if (audioFile == null) {
      //TODO: communicate error to user
      if (kDebugMode) debugPrint('verse Info is null');
      return;
    }

    final String downloadUrl = audioFile.url;

    String? filePath;
    int startIndex = downloadUrl.lastIndexOf('/') + 1;
    String fileName = downloadUrl.substring(startIndex);

    File file = await DBUtils.getMp3File(recitationId, fileName);
    filePath = file.path;
    if (!file.existsSync()) {
      file.parent.createSync(recursive: true);

      if (showDownloadBar) {
        this.audioFile = audioFile;
        downloadFilePath = filePath;
        state.downloading = true;
        widget.update();
        return;
      }

      await Dio().download(downloadUrl, filePath);
    }

    await addMediaItem(audioFile, filePath, append);
    if (showDownloadBar) {
      await player.setAudioSource(ConcatenatingAudioSource(children: queue));
      await player.seek(Duration.zero, index: state.surahNumber - 1);
      await player.play();
    }

    if (forward) {
      downloadNext(
          surahNumber: surahNumber + 1,
          recitationId: recitationId,
          showDownloadBar: false,
          append: true,
          forward: forward);
    } else {
      downloadNext(
          surahNumber: surahNumber - 1,
          recitationId: recitationId,
          showDownloadBar: false,
          append: false,
          forward: forward);
    }
  }

  UriAudioSource getMediaRecord(AudioFile audioFile, String filePath) {
    String title = '';
    String artist = '';
    String album = '';
    if (mounted) {
      title = QuranInfoController().getSurahName(context, audioFile.surah);
      artist =
          QuranInfoController().getRecitation(context, audioFile.recitation);
      album = AppLocalizations.of(context)!.album;
    }

    return AudioSource.file(filePath,
        tag: MediaItem(
          id: '${recitationId}_$surahNumber',
          title: title,
          artist: artist,
          album: album,
          displaySubtitle: 'hi',
          duration: Duration(milliseconds: audioFile.duration.floor()),
        ));
  }

  Future<void> addMediaItem(
      AudioFile audioFile, String filePath, bool append) async {
    if (append) {
      // player.sequence?.add(getMediaRecord(audioFile, filePath));
      queue.add(getMediaRecord(audioFile, filePath));
    } else {
      // player.sequence?.insert(0, getMediaRecord(audioFile, filePath));
      queue.insert(0, getMediaRecord(audioFile, filePath));
    }

    // try {
    //   await player.setAudioSource(ConcatenatingAudioSource(children: queue),
    //       preload: false);
    // } catch (e, stackTrace) {
    //   // Catch load errors: 404, invalid url ...
    //   print("Error loading playlist: $e");
    //   print(stackTrace);
    // }
  }

  Future<void> seek(bool play) async {
    if (surahNumber != state.surahNumber ||
        verseNumber != state.verseNumber ||
        wordNumber != state.wordNumber) {
      surahNumber = state.surahNumber;
      verseNumber = state.verseNumber;
      wordNumber = state.wordNumber;
      if (verseNumber > 1) {
        VerseTimings? verseTimings = await DBUtils.getSegment(
            recitationId, surahNumber, verseNumber, wordNumber);

        if (verseTimings != null) {
          int startPoint = verseTimings.from;
          await player.seek(Duration(milliseconds: startPoint));
        }
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
    if (surahNumber != state.surahNumber || lastRecitationId != recitationId) {
      surahNumber = state.surahNumber;
      lastRecitationId = recitationId;
      await player.pause();

      downloadNext(
          surahNumber: surahNumber,
          recitationId: recitationId,
          showDownloadBar: true,
          append: true,
          forward: true);

      downloadNext(
          surahNumber: surahNumber - 1,
          recitationId: recitationId,
          showDownloadBar: false,
          append: false,
          forward: false);
    }

    seek(play);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();

    queue.clear();
    pageNumber = state.pageNumber;

    // player = SoundPlayer.instance();
    _init();
    player.positionStream.listen((duration) async {
      if (!mounted) return;
      if (!state.playing) return;

      VerseTimings? verseTiming = await DBUtils.getCurrentSegment(
          recitationId, player.currentIndex! + 1, duration.inMilliseconds);

      if (verseTiming == null) return;

      String verse = verseTiming.verse;
      state.surahNumber = int.parse(verse.split(':').first);
      state.verseNumber = int.parse(verse.split(':').last);
      state.wordNumber = verseTiming.wordPosition;
      pageNumber = state.pageNumber =
          quran.getPageNumber(state.surahNumber, state.verseNumber);
      widget.update();
    });

    player.playerStateStream.listen((playerState) async {
      if (playerState.processingState != ProcessingState.completed) return;

      if (surahNumber == quran.totalSurahCount) return;

      // state.updateSurahNumber(state.surahNumber + 1);
      state.playing = false;
      surahNumber++;
      state.verseNumber = 1;
      state.wordNumber = -1;
      pageNumber = state.pageNumber =
          quran.getPageNumber(state.surahNumber, state.verseNumber);

      await player.setAudioSource(ConcatenatingAudioSource(children: queue));
      state.surahNumber = surahNumber;
      // await player.seek(Duration.zero, )
      await player.seek(Duration.zero, index: state.surahNumber - 1);
      state.playing = true;
      await player.play();

      widget.update();
    });
  }

  dynamic makeGetRequest(String url) async {
    int retries = 0;
    while (retries < maxHttpRequestRetries) {
      try {
        var response = await http.get(Uri.parse(url));
        return jsonDecode(response.body);
      } catch (e) {
        retries++;
        sleep(Duration(milliseconds: 500));
      }
    }

    return null;
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
    // player.errorStream .listen((onData) => print(onData));
    // WidgetsBinding.instance.addObserver(this);

    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    // Listen to errors during playback.
    // player.platform..listen((event) {},
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
    if (state.downloading && audioFile != null && downloadFilePath != null) {
      return DownloadWidget(
          audioFile: audioFile!,
          filePath: downloadFilePath!,
          state: state,
          parent: this);
    } else {
      if (pageNumber != state.pageNumber) {
        seek(state.playing);
      }

      return PlayerWidget(
          state: state,
          player: player,
          update: () async {
            await changeSource(true);
          });
    }
  }
}
