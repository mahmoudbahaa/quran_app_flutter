import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:quran_app_flutter/src/util/page_transition.dart';

class QuranPlayerGlobalState extends GetxController {
  dynamic verseTimings;

  final Player player = Player();

  final Rx<bool> pause = true.obs;

  final Rx<bool> downloading = false.obs;

  final Rx<bool> downloaded = false.obs;

  final Rx<bool> playing = false.obs;
  // updatePlaying(bool playing) => this.playing.value = playing;

  final Rx<int> pageNumber = (-1).obs;
  // updatePageNumber(int pageNumber) => this.pageNumber = pageNumber;

  final Rx<int> surahNumber = (-1).obs;
  // updateSurahNumber(int surahNumber) => this.surahNumber.value = surahNumber;

  final Rx<int> verseNumber = (-1).obs;
  // updateVerseNumber(int verseNumber) => this.verseNumber = verseNumber;

  final Rx<int> wordNumber = (-1).obs;
  // updateWordNumber(int wordNumber) => this.wordNumber = wordNumber;

  final Rx<PageTransition> pageTransition = PageTransition.noChange.obs;

  final Rx<bool> loadingPage = false.obs;
}
