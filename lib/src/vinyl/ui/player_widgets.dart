import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../vinyl.dart';

class MultiListenable<A, B> extends StatelessWidget {
  const MultiListenable({
    required this.first,
    required this.second,
    required this.builder,
    this.child,
    super.key,
  });

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<A>(
        valueListenable: first,
        builder: (_, a, __) {
          return ValueListenableBuilder<B>(
            valueListenable: second,
            builder: (context, b, __) {
              return builder(context, a, b, child);
            },
          );
        },
      );
}

class CurrentImageCover extends StatelessWidget {
  const CurrentImageCover({
    required this.defaultBookCover,
    this.imageHeight = double.infinity,
    this.imageWidth = double.infinity,
    super.key,
  });

  final double imageHeight;
  final double imageWidth;
  final Widget defaultBookCover;

  @override
  Widget build(BuildContext context) {
    final currentImageNotifier = vinyl.player.currentImage;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: imageHeight,
        maxWidth: imageWidth,
      ),
      child: ValueListenableBuilder(
        valueListenable: currentImageNotifier,
        builder: (context, value, child) => value.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: value,
                placeholder: (context, url) => defaultBookCover,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            : defaultBookCover,
      ),
    );
  }
}

class CurrentSongTitle extends StatelessWidget {
  const CurrentSongTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final titleNotifier = vinyl.player.currentSongTitle;
    return ValueListenableBuilder(
      valueListenable: titleNotifier,
      builder: (context, value, child) => Text(
        value,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
}

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({
    this.labelType = TimeLabelType.totalTime,
    this.timeLocation = TimeLabelLocation.sides,
    super.key,
  });

  final TimeLabelLocation timeLocation;
  final TimeLabelType labelType;

  @override
  Widget build(BuildContext context) {
    final controller = vinyl.player;

    return MultiListenable<bool, ProgressBarState>(
      first: controller.isStopped,
      second: controller.progressState,
      builder: (_, isStopped, b, __) {
        return ProgressBar(
          progress: b.current,
          buffered: b.buffered,
          total: b.total,
          onSeek: isStopped ? null : controller.seek,
          timeLabelType: labelType,
          timeLabelLocation: timeLocation,
        );
      },
    );
  }
}

class MiniProgressBar extends StatelessWidget {
  const MiniProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = vinyl.player.progressState;
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: ProgressBar(
        progress: progress.value.current,
        buffered: progress.value.buffered,
        total: progress.value.total,
        onSeek: (duration) {},
      ),
    );
  }
}

class PlaybackSpeedButton extends StatelessWidget {
  const PlaybackSpeedButton({
    required this.speeds,
    super.key,
  });

  final List<double> speeds;

  @override
  Widget build(BuildContext context) {
    final controller = vinyl.player;
    return ValueListenableBuilder(
      valueListenable: controller.isStopped,
      builder: (context, isStopped, child) => PopupMenuButton(
        icon: const Icon(Icons.speed),
        onSelected: (value) {
          controller.playbackSpeed.value = value;
          controller.setSpeed();
        },
        enabled: !isStopped,
        itemBuilder: (context) {
          return speeds
              .map(
                (speed) => CheckedPopupMenuItem(
                  value: speed,
                  checked: controller.playbackSpeed.value == speed,
                  child: Text(speed.toString()),
                ),
              )
              .toList();
        },
      ),
    );
  }
}

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = vinyl.player;
    return MultiListenable<bool, ButtonState>(
      first: controller.isStopped,
      second: controller.playButton,
      builder: (context, a, b, child) {
        switch (b) {
          case ButtonState.loading:
            return Container(
              margin: const EdgeInsets.all(8),
              width: 32,
              height: 32,
              child: const CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: const Icon(Icons.play_arrow),
              iconSize: 32,
              onPressed: a ? null : controller.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: const Icon(Icons.pause),
              iconSize: 32,
              onPressed: a ? null : controller.pause,
            );
        }
      },
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = vinyl.player;
    return MultiListenable<bool, bool>(
      first: controller.isStopped,
      second: controller.isFirstSong,
      builder: (context, stopped, b, child) => IconButton(
        icon: const Icon(
          Icons.skip_previous,
          color: Colors.white,
        ),
        onPressed: b || stopped
            ? null
            : () async {
                await controller.previous();
              },
      ),
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = vinyl.player;
    return MultiListenable<bool, bool>(
      first: controller.isStopped,
      second: controller.isLastSong,
      builder: (context, stopped, b, child) => IconButton(
        icon: const Icon(
          Icons.skip_next,
          color: Colors.white,
        ),
        onPressed: b || stopped
            ? null
            : () async {
                await controller.next();
              },
      ),
    );
  }
}

class SeekForwardButton extends StatelessWidget {
  const SeekForwardButton({
    required this.seekValue,
    super.key,
  });

  final Duration seekValue;

  @override
  Widget build(BuildContext context) {
    final controller = vinyl.player;
    return ValueListenableBuilder(
      valueListenable: controller.isStopped,
      builder: (_, value, __) {
        return ElevatedButton(
          onPressed: value
              ? null
              : () async {
                  await controller.seekForward(seekValue);
                },
          child: Text('${seekValue.inSeconds}s'),
        );
      },
    );
  }
}

class SeekBackwardButton extends StatelessWidget {
  const SeekBackwardButton({
    required this.seekValue,
    super.key,
  });

  final Duration seekValue;

  @override
  Widget build(BuildContext context) {
    final controller = vinyl.player;
    return ValueListenableBuilder(
      valueListenable: controller.isStopped,
      builder: (context, value, child) => ElevatedButton(
        onPressed: value
            ? null
            : () async {
                await controller.seekBackward(seekValue);
              },
        child: Text('${seekValue.inSeconds}s'),
      ),
    );
  }
}

class StopButton extends StatelessWidget {
  const StopButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = vinyl.player;
    return IconButton(
      icon: const Icon(Icons.stop),
      onPressed: controller.stop,
    );
  }
}
