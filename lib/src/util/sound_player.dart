// import 'dart:io';
//
// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/foundation.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:media_kit/media_kit.dart';
//
// abstract class SoundPlayer extends BaseAudioHandler
//     with QueueHandler, SeekHandler {
//   static SoundPlayer? _instance;
//
//   // SoundPlayer() {
//   // playbackState. = PlaybackState(
//   //   controls: [
//   //     MediaControl.rewind,
//   //     if (state.playing) MediaControl.pause else MediaControl.play,
//   //     MediaControl.stop,
//   //     MediaControl.fastForward,
//   //   ],
//   //   systemActions: const {
//   //     MediaAction.seek,
//   //     MediaAction.seekForward,
//   //     MediaAction.seekBackward,
//   //   },
//   //   androidCompactActionIndices: const [0, 1, 3],
//   //   processingState: state.playing ? AudioProcessingState.ready : AudioProcessingState.idle,
//   //   playing: state.playing,
//   //   updatePosition: state.position,
//   //   bufferedPosition: state.bufferedPosition,
//   //   speed: state.speed,
//   //   queueIndex: 0,
//   //   // queueIndex: state.currentIndex,
//   // );
//   // }
//
//   static Future<void> _actualInit({required bool isMediaKit}) async {
//     SoundPlayer innerInstance;
//     if (isMediaKit) {
//       MediaKit.ensureInitialized();
//       innerInstance = _MediaKitPlayer();
//     } else {
//       innerInstance = _JustSoundPlayer();
//     }
//
//     _instance = await AudioService.init(
//       builder: () => innerInstance,
//       config: AudioServiceConfig(
//         androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
//         androidNotificationChannelName: 'Audio playback',
//         androidNotificationOngoing: true,
//       ),
//     );
//
//     _instance!.playbackState.add(
//       PlaybackState(
//         controls: [
//           MediaControl.rewind,
//           MediaControl.play,
//           MediaControl.stop,
//           MediaControl.fastForward,
//         ],
//         systemActions: const {
//           MediaAction.seek,
//           MediaAction.seekForward,
//           MediaAction.seekBackward,
//         },
//         androidCompactActionIndices: const [0, 1, 3],
//         processingState: AudioProcessingState.idle,
//         playing: false,
//         // updatePosition: Duration.zero,
//         // bufferedPosition: Duration.zero,
//         speed: 1.0,
//         // queueIndex: state.currentIndex,
//       ),
//     );
//   }
//
//   static Future<void> init() async {
//     bool isMediaKit;
//     if (kIsWeb) {
//       isMediaKit = true;
//     } else if (Platform.isIOS) {
//       isMediaKit = true;
//     } else if (Platform.isAndroid) {
//       isMediaKit = false;
//     } else if (Platform.isMacOS) {
//       isMediaKit = true;
//     } else if (Platform.isWindows) {
//       isMediaKit = true;
//     } else if (Platform.isLinux) {
//       isMediaKit = true;
//     } else {
//       isMediaKit = true;
//     }
//
//     await _actualInit(isMediaKit: isMediaKit);
//   }
//
//   static SoundPlayer instance() {
//     return _instance!;
//   }
//
//   Future<void> setVolume(double volume);
//   Future<void> setUrlSource(String url);
//   SoundPlayerStream get stream;
//   SoundPlayerState get state;
//
//   Future<void> setFileSource(String filePath);
//
//   PlaybackState _transformEvent() {
//     // AudioProcessingState.idle,
//     // AudioProcessingState.loading,
//     // AudioProcessingState.buffering,
//     // AudioProcessingState.ready,
//     // AudioProcessingState.completed,
//     return PlaybackState(
//       controls: [
//         MediaControl.rewind,
//         if (state.playing) MediaControl.pause else MediaControl.play,
//         MediaControl.stop,
//         MediaControl.fastForward,
//       ],
//       systemActions: const {
//         MediaAction.seek,
//         MediaAction.seekForward,
//         MediaAction.seekBackward,
//       },
//       androidCompactActionIndices: const [0, 1, 3],
//       processingState: state.playing
//           ? AudioProcessingState.ready
//           : AudioProcessingState.idle,
//       playing: state.playing,
//       updatePosition: state.position,
//       bufferedPosition: state.bufferedPosition,
//       speed: state.speed,
//       queueIndex: 0,
//       // queueIndex: state.currentIndex,
//     );
//   }
// }
//
// class _MediaKitPlayer extends SoundPlayer {
//   final Player player;
//   _MediaKitPlayer() : player = Player();
//
//   @override
//   Future<void> play() async {
//     playbackState.add(playbackState.value.copyWith(playing: true));
//     await player.play();
//   }
//
//   @override
//   Future<void> pause() async => await player.pause();
//
//   @override
//   Future<void> stop() async => await player.stop();
//
//   @override
//   Future<void> seek(Duration duration) async {
//     await player.seek(duration);
//   }
//
//   @override
//   Future<void> setVolume(double volume) async => await player.setVolume(volume);
//
//   @override
//   Future<void> setSpeed(double speed) async => await player.setRate(speed);
//
//   @override
//   Future<void> setFileSource(String filePath) async =>
//       await player.open(Media(filePath));
//
//   @override
//   Future<void> setUrlSource(String url) async => await player.open(Media(url));
//
//   @override
//   SoundPlayerStream get stream => SoundPlayerStream(
//         duration: player.stream.duration,
//         position: player.stream.position,
//         volume: player.stream.volume,
//         speed: player.stream.rate,
//         completed: player.stream.completed,
//       );
//
//   @override
//   SoundPlayerState get state => SoundPlayerState(
//         playing: player.state.playing,
//         duration: player.state.duration,
//         speed: player.state.rate,
//         volume: player.state.volume,
//         position: player.state.position,
//         bufferedPosition: player.state.buffer,
//
//         // AudioProcessingState.idle,
//         // // AudioProcessingState.loading,
//         // // AudioProcessingState.buffering,
//         // // AudioProcessingState.ready,
//         // // AudioProcessingState.completed,
//       );
// }
//
// class _JustSoundPlayer extends SoundPlayer {
//   final AudioPlayer player;
//
//   _JustSoundPlayer() : player = AudioPlayer();
//
//   @override
//   Future<void> play() async {
//     await player.play();
//   }
//
//   @override
//   Future<void> pause() async {
//     await player.pause();
//   }
//
//   @override
//   Future<void> stop() async {
//     await player.stop();
//   }
//
//   @override
//   Future<void> seek(Duration duration) async {
//     await player.seek(duration);
//   }
//
//   @override
//   Future<void> setVolume(double volume) async => await player.setVolume(volume);
//
//   @override
//   Future<void> setSpeed(double speed) async => await player.setSpeed(speed);
//
//   @override
//   Future<void> setFileSource(String filePath) async =>
//       await player.setAudioSource(AudioSource.file(filePath));
//
//   @override
//   Future<void> setUrlSource(String url) async =>
//       await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
//
//   @override
//   SoundPlayerStream get stream => SoundPlayerStream(
//         duration: player.durationStream,
//         position: player.positionStream,
//         volume: player.volumeStream,
//         speed: player.speedStream,
//         completed: player.processingStateStream
//             .map((event) => event == ProcessingState.completed),
//       );
//
//   @override
//   SoundPlayerState get state => SoundPlayerState(
//         duration: player.duration,
//         playing: player.playing,
//         position: player.position,
//         volume: player.volume,
//         speed: player.speed,
//         bufferedPosition: player.bufferedPosition,
//       );
// }
//
// class SoundPlayerStream {
//   final Stream<Duration> position;
//   final Stream<Duration?> duration;
//   final Stream<double> volume;
//   final Stream<double> speed;
//   final Stream<bool> completed;
//
//   const SoundPlayerStream({
//     required this.completed,
//     required this.position,
//     required this.duration,
//     required this.volume,
//     required this.speed,
//   });
// }
//
// class SoundPlayerState {
//   final bool playing;
//   final Duration? duration;
//   final Duration position;
//   final double volume;
//   final double speed;
//   final Duration bufferedPosition;
//
//   const SoundPlayerState({
//     required this.playing,
//     required this.position,
//     required this.duration,
//     required this.volume,
//     required this.speed,
//     required this.bufferedPosition,
//   });
// }
