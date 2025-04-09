class QuranPlayerGlobalState {
  bool pause = true;

  bool downloading = false;

  bool playing = false;

  bool loading = false;

  int curPageInPageView = -1;

  int pageNumber = -1;

  int _surahNumber = -1;
  int get surahNumber => _surahNumber;
  set surahNumber(int newSurahNumber) {
    _surahNumber = newSurahNumber;
  }

  int verseNumber = -1;

  int wordNumber = -1;
}
