import 'package:get/get.dart';

import '../../quran_page/quran_page_view.dart';
import '../../settings/settings_controller.dart';
import '../../util/quran_player_global_state.dart';

class SurahInfoListController {
  const SurahInfoListController();

  void goToPage(int pageNumber, int surahNumber,
      SettingsController settingsController, QuranPlayerGlobalState state) {
    state.surahNumber = surahNumber;
    state.pageNumber = pageNumber;
    state.verseNumber = 1;
    state.wordNumber = -1;
    Get.to(() => QuranChapterDetailsView(
        settingsController: settingsController, state: state));
  }
}
