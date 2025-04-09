import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';

import 'media_record.dart';

const eMessage =
    'You forgot to initialize Vinyl\nCall "Vinyl.init()" in main.dart';

enum ButtonState {
  paused,
  playing,
  loading,
}

class ProgressBarState {
  const ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });

  final Duration current;
  final Duration buffered;
  final Duration total;

  ProgressBarState copyWith({
    Duration? current,
    Duration? buffered,
    Duration? total,
  }) {
    return ProgressBarState(
      current: current ?? this.current,
      buffered: buffered ?? this.buffered,
      total: total ?? this.total,
    );
  }
}

/// Define default metadata to display
/// e.g. default image or title
class DefaultMetadata {
  DefaultMetadata({required this.defaultImage, required this.defaultTitle});

  final String defaultImage;
  final String defaultTitle;
}

abstract class PlayerInterface {
  final isStopped = ValueNotifier(true);
  final currentSongTitle = ValueNotifier('');
  final currentImage = ValueNotifier('');
  final playbackSpeed = ValueNotifier<double>(1);

// final currentIndex = ValueNotifier('');
  final progressState = ValueNotifier(
    const ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  final isFirstSong = ValueNotifier(true);
  final isLastSong = ValueNotifier(true);
  final playButton = ValueNotifier(ButtonState.paused);

// final isShuffleModeEnabled = ValueNotifier(false);

  PlayerStream get stream;

  PlayerState get state;

  ///Use this to load your data in
  Future<void> open(MediaRecord input);

  Future<void> appendToQueue(MediaRecord input);

  Future<void> prependToQueue(MediaRecord input);

  Future<void> play();

  Future<void> pause();

  Future<void> next();

  Future<void> previous();

  Future<void> setSpeed();

  Future<void> setVolume(double volume);

  Future<void> setPlaybackRate(double rate);

  Future<void> seek(Duration position);

  Future<void> skipToTrack({
    Duration position = Duration.zero,
    int trackIndex = 0,
  });

  Future<void> seekForward(Duration positionOffset);

  Future<void> seekBackward(Duration positionOffset);

  Future<void> stop();

  Future<void> dispose();
}
