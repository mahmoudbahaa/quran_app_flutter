import 'package:flutter/foundation.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/home/assets_loader/assets_loader_service.dart';
import 'package:quran_app_flutter/src/models/enums.dart';
import 'package:quran_app_flutter/src/settings/settings_controller.dart';

class AssetsLoaderController {
  AssetsLoaderController({required this.settingsController});

  final SettingsController settingsController;
  static final Map _fontsLoaded = {};
  final AssetsLoaderService _assetsLoaderService = AssetsLoaderService();

  // final _codeFontPrefix = const ['', 'v2_', 'v4_'];
  // final List<String> _codeVersion = const ['code_v1', 'code_v2', 'code_v2'];
  // final _codeFontPrefix = const ['', 'v2_', 'v4_'];
  final List<int> _codeVersion = const [1, 2, 2];
  final List<int> _fontVersion = const [1, 2, 4];
  // final int _parallelism = kIsWeb ? 3 : 12;
  // final fontsQueue = Queue(parallel: kIsWeb ? 1 : 12);
  // final fontsQueue = Queue();
  // final versesWordsQueue = Queue(parallel: kIsWeb ? 8 : 12);

  Future<void> loadAssets(VoidCallback update) {
    return _loadPageFonts(1, update);
    // for (int i = 1; i <= quran.totalPagesCount; i++) {
    //   fontsQueue.add(() async => await _loadPageFonts(i, update));
    // versesWordsQueue.add(() async => await _loadVerseWordsData(i, update));
    // }

    // await fontsQueue.onComplete;
    // await versesWordsQueue.onComplete;
    // fontsQueue.dispose();
    // versesWordsQueue.dispose();
  }

  Future<void> _loadPageFonts(int pageNumber, VoidCallback update) async {
    if (pageNumber > quran.totalPagesCount) return;
    await loadPageFont(pageNumber);
    if (settingsController.textRepresentation == TextRepresentation.codeV4) {
      await loadPageFont(pageNumber, dark: true);
    }

    update();

    _loadPageFonts(pageNumber + 1, update);
  }

  Future<void> _loadVerseWordsData(int pageNumber, VoidCallback update) async {
    if (pageNumber > quran.totalPagesCount) return;
    await loadWordsData(pageNumber);
    update();
  }

  String _getFontName(int pageNumber, bool dark) {
    final codeVersion =
        _fontVersion[settingsController.textRepresentation.index];
    return '${codeVersion}_$pageNumber${dark ? '_dark' : ''}';
  }

  bool isFontLoaded(int pageNumber, bool dark) {
    final codeVersion =
        _fontVersion[settingsController.textRepresentation.index];
    if (codeVersion == 1 && pageNumber == 175) return true;
    return _fontsLoaded[_getFontName(pageNumber, dark)] != null;
  }

  Future<void> loadPageFont(int pageNumber,
      {bool dark = false, bool? cacheOnly}) async {
    if (isFontLoaded(pageNumber, dark)) return;

    final codeVersion =
        _fontVersion[settingsController.textRepresentation.index];
    bool loaded = await _assetsLoaderService.loadFont(
        pageNumber,
        codeVersion,
        settingsController.textRepresentation,
        dark,
        cacheOnly ?? settingsController.loadCachedOnly);
    if (loaded) _fontsLoaded[_getFontName(pageNumber, dark)] = true;
  }

  Future<void> loadWordsData(int pageNumber, {bool? cacheOnly}) async {
    return await _assetsLoaderService.loadWordsData(
        pageNumber,
        settingsController.textRepresentation,
        cacheOnly ?? settingsController.loadCachedOnly,
        _codeVersion[settingsController.textRepresentation.index]);
  }
}
