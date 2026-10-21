import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/common/quran_info_controller.dart';
import 'package:quran_app_flutter/src/localization/app_localizations.dart';
import 'package:quran_app_flutter/src/settings/settings_controller.dart';
import 'package:universal_io/io.dart';

import '../db/db_utils/db_utils.dart';
import '../api/quran_api_client.dart';
import '../api/content_catalog.dart';

import 'package:synchronized/synchronized.dart';

import '../db/exposed_models.dart';
import '../util/download_widget.dart';
import '../util/player_widget.dart';
import '../util/quran_player_global_state.dart';

class QuranPlayer extends StatefulWidget {
  const QuranPlayer({
    super.key,
    required this.state,
    required this.update,
    required this.settingsController,
  });

  final QuranPlayerGlobalState state;
  final VoidCallback update;
  final SettingsController settingsController;

  @override
  State<StatefulWidget> createState() => QuranPlayerState();
}

class QuranPlayerState extends State<QuranPlayer> {
  final AudioPlayer player = AudioPlayer();
  int surahNumber = -1;
  int get recitationId => widget.settingsController.recitationId;
  int? lastRecitationId;
  int verseNumber = -1;
  int wordNumber = -1;
  int pageNumber = -1;
  String? downloadFilePath;
  AudioFile? audioFile;
  QuranPlayerGlobalState get state => widget.state;
  final Lock _sourceLock = Lock();
  int? _loadedChapter;
  int? _loadedReciter;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  Future<void> setSource(AudioFile? audioFile, String filePath) async {
    if (audioFile == null) return;

    await player.seek(Duration.zero, index: 0);
    await player.play();
    // await player.stop();
    // await player.play();
    // addMediaItem(surahNumber!, recitationId, filePath, true);
    // setState(() {});
  }

  StreamAudioSource getMediaRecord(
    AudioFile audioFile,
    String filePath,
    String url,
  ) {
    String title = '';
    String artist = '';
    String album = '';
    if (mounted) {
      title = QuranInfoController().getSurahName(context, audioFile.surah);
      artist = QuranInfoController().getRecitation(
        context,
        audioFile.recitation,
      );
      album = AppLocalizations.of(context)!.album;
    }

    return LockCachingAudioSource(
      Uri.parse(url),
      cacheFile: File(filePath),
      tag: MediaItem(
        id: '${audioFile.recitation}_${audioFile.surah}',
        title: title,
        artist: artist,
        album: album,
        displaySubtitle: 'hi',
        duration: audioFile.duration > 0
            ? Duration(milliseconds: audioFile.duration.floor())
            : null,
      ),
    );

    // return AudioSource.file(filePath,
    //     tag: MediaItem(
    //       id: '${recitationId}_$surahNumber',
    //       title: title,
    //       artist: artist,
    //       album: album,
    //       displaySubtitle: 'hi',
    //       duration: Duration(milliseconds: audioFile.duration.floor()),
    //     ));
  }

  Future<void> seek(bool play) async {
    try {
      await _sourceLock.synchronized(() async {
        if (!mounted || state.surahNumber < 1) return;
        final chapter = state.surahNumber;
        final reciter = recitationId;
        if (_loadedChapter != chapter || _loadedReciter != reciter) {
          await player.pause();
          final sources = <StreamAudioSource>[];
          await addNextSurah(
            surahNumber: chapter,
            recitationId: reciter,
            queue: sources,
          );
          if (!mounted ||
              chapter != state.surahNumber ||
              reciter != recitationId) {
            return;
          }
          if (sources.isEmpty) {
            throw const QuranApiException(
              'Audio is unavailable for this chapter.',
            );
          }
          await player.setAudioSources(sources, preload: false);
          _loadedChapter = chapter;
          _loadedReciter = reciter;
          verseNumber = -1;
          wordNumber = -1;
        }
        surahNumber = chapter;
        if (verseNumber != state.verseNumber ||
            wordNumber != state.wordNumber) {
          verseNumber = state.verseNumber;
          wordNumber = state.wordNumber;
          final timing = await DBUtils.getSegment(
            reciter,
            chapter,
            verseNumber < 1 ? 1 : verseNumber,
            wordNumber < 1 ? 1 : wordNumber,
          );
          await player.seek(
            Duration(milliseconds: timing?.from ?? 0),
            index: 0,
          );
        }
        if (!mounted) return;
        state.playing = play;
        if (play) {
          unawaited(
            player.play().catchError((Object error) => _showError(error)),
          );
        } else {
          await player.pause();
        }
      });
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    state.playing = false;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error.toString())));
    widget.update();
  }

  Future<void> changeSource(bool play) => seek(play);

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  // Fetch metadata only for the selected chapter, instead of 114 startup calls.
  Future<void> preparePlayer() => changeSource(false);

  @override
  void initState() {
    super.initState();

    pageNumber = state.pageNumber;

    // player = SoundPlayer.instance();
    _init();
    _subscriptions.add(
      player.positionStream.listen((duration) async {
        if (!mounted) return;
        if (!state.playing) return;

        final chapter = _loadedChapter;
        final reciter = _loadedReciter;
        if (chapter == null || reciter == null) return;
        VerseTimings? verseTiming = await DBUtils.getCurrentSegment(
          reciter,
          chapter,
          duration.inMilliseconds,
        );
        if (!mounted || chapter != _loadedChapter || reciter != _loadedReciter) {
          return;
        }

        if (verseTiming == null) return;

        String verse = verseTiming.verse;
        state.surahNumber = int.parse(verse.split(':').first);
        state.verseNumber = int.parse(verse.split(':').last);
        state.wordNumber = verseTiming.wordPosition;
        pageNumber = state.pageNumber = quran.getPageNumber(
          state.surahNumber,
          state.verseNumber,
        );
        widget.update();
      }),
    );

    _subscriptions.add(
      player.playerStateStream.listen((playerState) async {
        if (playerState.processingState != ProcessingState.completed) return;

        final next = (_loadedChapter ?? state.surahNumber) + 1;
        if (next > quran.totalSurahCount ||
            (ContentCatalog.chapterIds != null &&
                !ContentCatalog.chapterIds!.contains(next))) {
          state.playing = false;
          if (mounted) widget.update();
          return;
        }
        state.surahNumber = next;
        state.verseNumber = 1;
        state.wordNumber = -1;
        state.pageNumber = quran.getPageNumber(next, 1);
        await changeSource(true);
        if (mounted) widget.update();
      }),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(preparePlayer());
    });
  }

  Future<void> addNextSurah({
    required int surahNumber,
    required int recitationId,
    required List<StreamAudioSource> queue,
  }) async {
    if (surahNumber < 1 || surahNumber > quran.totalSurahCount) return;

    String url = getUrl(surahNumber, recitationId);
    AudioFile? audioFile = await DBUtils.loadVersesData(
      recitationId: recitationId,
      surahNumber: surahNumber,
      url: url,
    );
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
    queue.add(getMediaRecord(audioFile, filePath, downloadUrl));
  }

  Future<void> downloadNextSurah({
    required int surahNumber,
    required int recitationId,
    required bool showDownloadBar,
  }) async {
    if (surahNumber < 1 || surahNumber > quran.totalSurahCount) return;

    String url = getUrl(surahNumber, recitationId);
    AudioFile? audioFile = await DBUtils.loadVersesData(
      recitationId: recitationId,
      surahNumber: surahNumber,
      url: url,
    );
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

    // if (showDownloadBar) return;
    // downloadNextSurah(
    //     surahNumber: surahNumber + 1,
    //     recitationId: recitationId,
    //     showDownloadBar: false);
  }

  String getUrl(int surahNumber, int recitationId) => QuranApiClient.instance
      .chapterAudioUri(recitationId, surahNumber)
      .toString();

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
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(player.dispose());
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
        parent: this,
      );
    } else {
      if (pageNumber != state.pageNumber) {
        pageNumber = state.pageNumber;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(changeSource(state.playing));
        });
      }

      return PlayerWidget(
        state: state,
        player: player,
        update: () async {
          await changeSource(true);
        },
      );
    }
  }
}
