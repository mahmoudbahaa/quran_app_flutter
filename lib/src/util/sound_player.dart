import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:media_kit/media_kit.dart';

abstract class SoundPlayer {
  static SoundPlayer? _instance;

  static SoundPlayer _actualInit({required bool isMediaKit}) {
    if (isMediaKit) {
      MediaKit.ensureInitialized();
      _instance = _MediaKitPlayer();
    } else {
      _instance = _JustSoundPlayer();
    }

    return _instance!;
  }

  static SoundPlayer _init() {
    bool isMediaKit;
    if (kIsWeb) {
      isMediaKit = true;
    } else if (Platform.isIOS) {
      isMediaKit = true;
    } else if (Platform.isAndroid) {
      isMediaKit = true;
    } else if (Platform.isMacOS) {
      isMediaKit = true;
    } else if (Platform.isWindows) {
      isMediaKit = true;
    } else if (Platform.isLinux) {
      isMediaKit = true;
    } else {
      isMediaKit = true;
    }

    return _actualInit(isMediaKit: isMediaKit);
  }

  static SoundPlayer instance() {
    if (_instance == null) {
      return _init();
    }

    return _instance!;
  }

  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration duration);
  Future<void> setVolume(double volume);
  Future<void> setSpeed(double speed);
  Future<void> setFileSource(String filePath);
  Future<void> setUrlSource(String url);
  SoundPlayerStream get stream;
  SoundPlayerState get state;
}

class _MediaKitPlayer implements SoundPlayer {
  final Player player;
  _MediaKitPlayer() : player = Player();

  @override
  Future<void> play() async => await player.play();

  @override
  Future<void> pause() async => await player.pause();

  @override
  Future<void> stop() async => await player.stop();

  @override
  Future<void> seek(Duration duration) async {
    await player.seek(duration);
  }

  @override
  Future<void> setVolume(double volume) async => await player.setVolume(volume);

  @override
  Future<void> setSpeed(double speed) async => await player.setRate(speed);

  @override
  Future<void> setFileSource(String filePath) async =>
      await player.open(Media(filePath));

  @override
  Future<void> setUrlSource(String url) async => await player.open(Media(url));

  @override
  SoundPlayerStream get stream => SoundPlayerStream(
        duration: player.stream.duration,
        position: player.stream.position,
        volume: player.stream.volume,
        speed: player.stream.rate,
        completed: player.stream.completed,
      );

  @override
  SoundPlayerState get state => SoundPlayerState(
        playing: player.state.playing,
        duration: player.state.duration,
        speed: player.state.rate,
        volume: player.state.volume,
        position: player.state.position,
      );
}

class _JustSoundPlayer implements SoundPlayer {
  final AudioPlayer player;

  _JustSoundPlayer() : player = AudioPlayer();

  @override
  Future<void> play() async {
    await player.play();
  }

  @override
  Future<void> pause() async {
    await player.pause();
  }

  @override
  Future<void> stop() async {
    await player.stop();
  }

  @override
  Future<void> seek(Duration duration) async {
    await player.seek(duration);
  }

  @override
  Future<void> setVolume(double volume) async => await player.setVolume(volume);

  @override
  Future<void> setSpeed(double speed) async => await player.setSpeed(speed);

  @override
  Future<void> setFileSource(String filePath) async =>
      await player.setAudioSource(AudioSource.file(filePath));

  @override
  Future<void> setUrlSource(String url) async =>
      await player.setAudioSource(AudioSource.uri(Uri.parse(url)));

  @override
  SoundPlayerStream get stream => SoundPlayerStream(
        duration: player.durationStream,
        position: player.positionStream,
        volume: player.volumeStream,
        speed: player.speedStream,
        completed: player.processingStateStream
            .map((event) => event == ProcessingState.completed),
      );

  @override
  SoundPlayerState get state => SoundPlayerState(
        duration: player.duration,
        playing: player.playing,
        position: player.position,
        volume: player.volume,
        speed: player.speed,
      );
}

class SoundPlayerStream {
  final Stream<Duration> position;
  final Stream<Duration?> duration;
  final Stream<double> volume;
  final Stream<double> speed;
  final Stream<bool> completed;

  const SoundPlayerStream({
    required this.completed,
    required this.position,
    required this.duration,
    required this.volume,
    required this.speed,
  });
}

class SoundPlayerState {
  final bool playing;
  final Duration? duration;
  final Duration position;
  final double volume;
  final double speed;

  const SoundPlayerState({
    required this.playing,
    required this.position,
    required this.duration,
    required this.volume,
    required this.speed,
  });
}
