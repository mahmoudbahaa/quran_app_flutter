import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

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
  final Player player;

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

  bool get _isPlaying => player.state.playing;

  bool get _isPaused => !player.state.playing;

  String get _totalDuration =>
      player.state.duration.toString().split('.').first;

  String get _durationText => _duration?.toString().split('.').first ?? '';

  String get _positionText => _position?.toString().split('.').first ?? '';

  Player get player => widget.player;

  @override
  void initState() {
    super.initState();
    // Use initial values from player
    setState(() => _duration = player.state.duration);
    setState(() => _position = player.state.position);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 0,
      mainAxisSize: MainAxisSize.min,
      // mainAxisAlignment: MainAxisAlignment.start, // <-- alignments
      children: [
        // Opens volume slider dialog
        IconButton(
          icon: const Icon(Icons.volume_up),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          iconSize: 24.0,
          onPressed: () {
            showSliderDialog(
              context: context,
              title: 'Adjust volume',
              divisions: 10,
              min: 0.0,
              max: 100.0,
              value: player.state.volume,
              stream: player.stream.volume,
              onChanged: player.setVolume,
            );
          },
        ),
        IconButton(
          key: const Key('play_pause_button'),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          onPressed: _play,
          iconSize: 24.0,
          icon: _isPlaying
              ? const Icon(Icons.pause)
              : const Icon(Icons.play_arrow),
        ),
        // Opens speed slider dialog
        StreamBuilder<double>(
          stream: player.stream.rate,
          builder: (context, snapshot) => IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: Text('${player.state.rate.toStringAsFixed(1)}x',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            iconSize: 32.0,
            onPressed: () {
              showSliderDialog(
                context: context,
                title: 'Adjust speed',
                divisions: 5,
                min: 0.8,
                max: 1.3,
                value: player.state.rate,
                stream: player.stream.rate,
                onChanged: player.setRate,
              );
            },
          ),
        ),
        Text(
          _position != null
              ? '$_positionText/$_totalDuration'
              : _duration != null
                  ? '$_durationText/$_totalDuration'
                  : '',
          style: const TextStyle(fontSize: 16.0),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                left: rtlLanguages
                        .contains(AppLocalizations.of(context)?.localeName)
                    ? 60
                    : 0,
                right: rtlLanguages
                        .contains(AppLocalizations.of(context)?.localeName)
                    ? 0
                    : 60),
            child: Slider(
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
            ),
          ),
        ),
      ],
    );
  }

  void _initStreams() {
    _durationSubscription = player.stream.duration.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.stream.position.listen(
      (p) => setState(() => _position = p),
    );
  }

  Future<void> _play() async {
    if (_isPaused) {
      widget.update();
    } else {
      await player.playOrPause();
    }
  }
}

//#endregion
