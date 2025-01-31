import 'package:flutter/foundation.dart';
import 'package:queue/queue.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app_flutter/src/home/assets_loader/assets_loader_service.dart';
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
  final queue = Queue(parallel: kIsWeb ? 16 : 12);

  Future<void> loadAssets(Function update) async {
    for (int i = 1; i <= quran.totalPagesCount; i++) {
      queue.add(() async => await _loadPageFonts(i, update));
      queue.add(() async => await _loadVerseWordsData(i, update));
    }

    await queue.onComplete;
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
    await _loadAsset(pageNumber, loadWordsData, update);
  }

  bool isFontLoaded(int pageNumber) {
    final codeVersion =
        _codeVersion[settingsController.textRepresentation.index];
    if (codeVersion == 1 && pageNumber == 175) return true;
    return _fontsLoaded['${codeVersion}_$pageNumber'] != null;
  }

  Future<void> loadPageFont(int pageNumber, {bool? cacheOnly}) async {
    if (isFontLoaded(pageNumber)) return;

    final codeVersion =
        _fontVersion[settingsController.textRepresentation.index];
    final fontName = '${codeVersion}_$pageNumber';
    bool loaded = await _assetsLoaderService.loadFont(
        pageNumber,
        codeVersion,
        settingsController.textRepresentation,
        cacheOnly ?? settingsController.loadCachedOnly);
    if (loaded) _fontsLoaded[fontName] = true;
  }

  Future<void> loadWordsData(int pageNumber, {bool? cacheOnly}) async {
    return await _assetsLoaderService.loadWordsData(
        pageNumber,
        settingsController.textRepresentation,
        cacheOnly ?? settingsController.loadCachedOnly,
        _codeVersion[settingsController.textRepresentation.index]);
  }
}
