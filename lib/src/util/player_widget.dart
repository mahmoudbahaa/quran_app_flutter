import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/enums.dart';
import '../quran_page/quran_page_view.dart';
import 'common.dart';
import 'quran_player_global_state.dart';

// The PlayerWidget is a copy of "/lib/components/player_widget.dart".
//#region PlayerWidget
class PlayerWidget extends StatefulWidget {
  const PlayerWidget({
    super.key,
    required this.state,
    required this.update,
    required this.player,
  });

  final Function update;
  final QuranPlayerGlobalState state;
  final AudioPlayer player;

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => player.playing;

  bool get _isPaused => !player.playing;

  String get _totalDuration =>
      player.duration.toString().split('.').first;

  String get _durationText => _duration?.toString().split('.').first ?? '';

  String get _positionText => _position?.toString().split('.').first ?? '';

  AudioPlayer get player => widget.player;

  @override
  void initState() {
    super.initState();
    // Use initial values from player
    _duration = player.duration;
    _position = player.position;
    _initStreams();
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    player.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandScape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    bool isrtl = isRtl(context);

    Widget durationWidget = Text(
      _position != null
          ? '($_positionText/$_totalDuration)'
          : _duration != null
              ? '($_durationText/$_totalDuration)'
              : '',
      style: const TextStyle(fontSize: 12.0),
    );

    durationWidget = Padding(
        padding: EdgeInsets.only(right: isrtl ? 0 : 20, left: isrtl ? 20 : 0),
        child: durationWidget);
    final children = [
      // Opens volume slider dialog
      IconButton(
        onPressed: () {
          showSliderDialog(
            context: context,
            title: 'Adjust volume',
            divisions: 10,
            min: 0.0,
            max: 100.0,
            value: player.volume,
            stream: player.volumeStream,
            onChanged: player.setVolume,
          );
        },
        icon: const Icon(Icons.volume_up),
      ),
      IconButton(
          onPressed: _play,
          icon: _isPlaying
              ? const Icon(Icons.pause)
              : const Icon(Icons.play_arrow)),
      // Opens speed slider dialog
      StreamBuilder<double>(
        stream: player.speedStream,
        builder: (context, snapshot) => IconButton(
          onPressed: () {
            showSliderDialog(
              context: context,
              title: 'Adjust speed',
              divisions: 5,
              min: 0.8,
              max: 1.3,
              value: player.speed,
              stream: player.speedStream,
              onChanged: player.setSpeed,
            );
          },
          icon: Text('${player.speed.toStringAsFixed(1)}x',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
      isLandScape
          ? durationWidget
          : Expanded(
              child: Align(
                  alignment:
                      isrtl ? Alignment.centerLeft : Alignment.centerRight,
                  child: durationWidget),
            ),
    ];

    final slider = Slider(
      onChanged: (value) {
        final duration = _duration;
        if (duration == null) {
          return;
        }
        final position = value * duration.inMilliseconds;
        player.seek(Duration(milliseconds: position.round()));
      },
      value: (_position != null &&
              _duration != null &&
              _position!.inMilliseconds > 0 &&
              _position!.inMilliseconds < _duration!.inMilliseconds)
          ? _position!.inMilliseconds / _duration!.inMilliseconds
          : 0.0,
    );

    Widget mainWidget;
    if (isLandScape) {
      Widget last = children.removeLast();
      children.add(Expanded(child: slider));
      children.add(last);
      mainWidget = Row(spacing: 10, children: children);
    } else {
      mainWidget = Transform.translate(
        offset: Offset(0, QuranPageView.iconsSize / -2),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 0,
            children: [
              Row(spacing: 0, children: children),
              Container(
                  constraints: BoxConstraints(minHeight: 0, maxHeight: 10),
                  child: slider),
            ],
          ),
        ),
      );
    }

    return mainWidget;
  }

  void _initStreams() {
    _durationSubscription = player.durationStream.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.positionStream.listen(
      (p) => setState(() => _position = p),
    );
  }

  Future<void> _play() async {
    if (_isPaused) {
      widget.update();
    } else {
      await player.pause();
    }
  }
}

//#endregion
