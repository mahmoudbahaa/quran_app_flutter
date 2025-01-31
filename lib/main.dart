import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:vinyl/vinyl.dart';

import 'src/app.dart';
import 'src/db/db_utils/db_utils_exporter.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/util/quran_player_global_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    await DesktopWindow.setMinWindowSize(Size(400, 600));
  }

  await initDbUtils();
  // File file = File('${dir.path}/quran_app.sqlite');
  // if (file.existsSync()) file.deleteSync();

  // store this in a singleton
  // await SoundPlayer.init();

  await vinyl.init(audioConfig: AudioServiceConfig());

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

  if (!kIsWeb && Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
}
