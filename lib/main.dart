import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

import 'src/app.dart';
import 'src/db/db_utils/db_utils_exporter.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/util/quran_player_global_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await DesktopWindow.setMinWindowSize(Size(400, 600));
  }

  await initDbUtils();
  // File file = File('${dir.path}/quran_app.sqlite');
  // if (file.existsSync()) file.deleteSync();

  // store this in a singleton
  // await SoundPlayer.init();

  // by default, windows and linux are enabled
  JustAudioMediaKit.ensureInitialized();

// or, if you want to manually configure enabled platforms instead:
// make sure to include the required dependency in pubspec.yaml for
// each enabled platform!
//   JustAudioMediaKit.ensureInitialized(
//     linux: true, // default: true  - dependency: media_kit_libs_linux
//     windows: true, // default: true  - dependency: media_kit_libs_windows_audio
//     android: true, // default: false - dependency: media_kit_libs_android_audio
//     iOS: true, // default: false - dependency: media_kit_libs_ios_audio
//     macOS: true, // default: false - dependency: media_kit_libs_macos_audio
//   );

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  QuranPlayerGlobalState state = QuranPlayerGlobalState();
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController, state: state));

  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
}
