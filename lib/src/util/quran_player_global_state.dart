import 'package:media_kit/media_kit.dart';
import 'package:quran_app_flutter/src/util/page_transition.dart';

class QuranPlayerGlobalState {
  dynamic verseTimings;

  final Player player = Player();

  bool pause = true;

  bool downloading = false;

  bool playing = false;

  int pageNumber = -1;

  int surahNumber = -1;

  int verseNumber = -1;

  int wordNumber = -1;

  PageTransition pageTransition = PageTransition.noChange;

  bool loadingPage = false;
}
