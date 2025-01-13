import 'package:queue/queue.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/home/assets_loader/assets_loader_service.dart';
import 'package:quran_app_flutter/src/settings/settings_controller.dart';

class AssetsLoaderController {
  const AssetsLoaderController({required this.settingsController});

  final SettingsController settingsController;
  static final Map _fontsLoaded = {};
  static final Map<String, dynamic> _versesDataLoaded = {};
  final AssetsLoaderService _assetsLoaderService = const AssetsLoaderService();

  final _codeFontPrefix = const ['', 'v2_', 'v4_'];
  final List<String> _codeVersion = const ['code_v1', 'code_v2', 'code_v2'];
  final int _parallelism = 8;

  Future<void> loadAssets(Function update) async {
    final queue = Queue(parallel: _parallelism);
    for (int i = 1; i <= quran.totalPagesCount; i++) {
      queue.add(() async => await _loadPageFonts(i, update));
      queue.add(() async => await _loadVerseWordsData(i, update));
    }

    queue.onComplete;
  }

  Future<void> _loadAsset(
      int pageNumber, Function assetFunc, Function update) async {
    await assetFunc(pageNumber);

    update();
  }

  Future<void> _loadPageFonts(int pageNumber, Function update) async {
    await _loadAsset(pageNumber, loadPageFont, update);
  }

  Future<void> _loadVerseWordsData(int pageNumber, Function update) async {
    await _loadAsset(pageNumber, loadVersesWordsData, update);
  }

  bool isFontLoaded(int pageNumber) {
    final fontPrefix =
        _codeFontPrefix[settingsController.textRepresentation.index];
    final fontName = '${fontPrefix}page$pageNumber';

    if (fontName == 'page175') return true;
    return _fontsLoaded[fontName] != null;
  }

  Future<void> loadPageFont(int pageNumber) async {
    final fontPrefix =
        _codeFontPrefix[settingsController.textRepresentation.index];
    final fontName = '${fontPrefix}page$pageNumber';
    if (isFontLoaded(pageNumber)) return;
    bool loaded = await _assetsLoaderService.loadFont(
        pageNumber,
        fontPrefix,
        settingsController.textRepresentation,
        settingsController.loadCachedOnly);
    if (loaded) _fontsLoaded[fontName] = true;
  }

  dynamic getCachedVersesWordsData(int pageNumber) {
    String key = '${pageNumber}_${settingsController.textRepresentation.index}';
    return _versesDataLoaded[key];
  }

  Future<void> loadVersesWordsData(int pageNumber,
      {bool cacheOnly = false}) async {
    dynamic cachedVerseWordsData = getCachedVersesWordsData(pageNumber);
    if (cachedVerseWordsData != null) return;

    dynamic data = await _assetsLoaderService.getWordsData(
        pageNumber,
        settingsController.textRepresentation,
        cacheOnly,
        _codeVersion[settingsController.textRepresentation.index]);

    if (data != null) {
      String key =
          '${pageNumber}_${settingsController.textRepresentation.index}';
      _versesDataLoaded[key] = data;
    }
  }
}
