import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/settings/settings_controller.dart';
import 'package:quran_app_flutter/src/util/quran_player_global_state.dart';

import '../home/assets_loader/assets_loader_controller.dart';

class QuranPageController {
  const QuranPageController();

  void goNextPage(
      SettingsController settingsController, QuranPlayerGlobalState state) {
    if (!AssetsLoaderController(settingsController: settingsController)
            .isFontLoaded(state.pageNumber) ||
        state.pageNumber >=
            (quran.totalPagesCount - settingsController.numPages)) {
      return;
    }

    if (settingsController.numPages == 1) {
      state.pageNumber = state.pageNumber + 1;
    } else {
      state.pageNumber =
          ((state.pageNumber / settingsController.numPages).floor() + 1) *
                  settingsController.numPages +
              1;
    }

    state.surahNumber = -1;
    state.verseNumber = -1;
    state.wordNumber = -1;
    state.pause = true;
  }

  void goPreviousPage(
      SettingsController settingsController, QuranPlayerGlobalState state) {
    if (!AssetsLoaderController(settingsController: settingsController)
            .isFontLoaded(state.pageNumber) ||
        state.pageNumber <= settingsController.numPages) {
      return;
    }

    if (settingsController.numPages == 1) {
      state.pageNumber = state.pageNumber - 1;
    } else {
      state.pageNumber =
          ((state.pageNumber / settingsController.numPages).floor() - 1) *
                  settingsController.numPages +
              1;
    }

    state.surahNumber = -1;
    state.verseNumber = -1;
    state.wordNumber = -1;
    state.pause = true;
  }
}
