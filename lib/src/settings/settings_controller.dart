import 'package:flutter/material.dart';

import '../models/enums.dart';
import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late ThemeMode _themeMode;
  late TextRepresentation _textRepresentation;
  late bool _loadCachedOnly;
  late bool _selectableViews;
  late int _numPages;
  late int _recitationId;
  late AppLocale _appLocale;
  late Color _mainColor;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => _themeMode;
  TextRepresentation get textRepresentation => _textRepresentation;
  bool get loadCachedOnly => _loadCachedOnly;
  bool get selectableViews => _selectableViews;
  int get numPages => _numPages;
  int get recitationId => _recitationId;
  AppLocale get appLocale => _appLocale;
  Color get mainColor => _mainColor;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _textRepresentation = await _settingsService.textRepresentation();
    _loadCachedOnly = await _settingsService.loadCachedOnly();
    _numPages = await _settingsService.numPages();
    _recitationId = await _settingsService.recitationId();
    _appLocale = await _settingsService.appLocale();
    _mainColor = await _settingsService.mainColor();
    _selectableViews = await _settingsService.selectableViews();

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  Future<void> updateAppLocale(AppLocale? appLocale) async {
    if (appLocale == null) return;
    if (appLocale == _appLocale) return;
    _appLocale = appLocale;
    notifyListeners();
    await _settingsService.updateLocalization(appLocale);
    // Get.updateLocale(Locale(appLocale.name));
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateMainColor(Color? newMainColor) async {
    if (newMainColor == null) return;
    if (newMainColor == _mainColor) return;
    _mainColor = newMainColor;
    notifyListeners();
    await _settingsService.updateMainColor(newMainColor);
  }

  /// Update and persist the TextRepresentation based on the user's selection.
  Future<void> updateTextRepresentation(
      TextRepresentation? newTextRepresentation) async {
    if (newTextRepresentation == null) return;
    if (newTextRepresentation == _textRepresentation) return;
    _textRepresentation = newTextRepresentation;
    notifyListeners();
    await _settingsService.updateTextRepresentation(newTextRepresentation);
  }

  Future<void> updateLoadCachedOnly(bool? newLoadCachedOnly) async {
    if (newLoadCachedOnly == null) return;
    if (newLoadCachedOnly == _loadCachedOnly) return;
    _loadCachedOnly = newLoadCachedOnly;
    notifyListeners();
    await _settingsService.updateLoadCachedOnly(newLoadCachedOnly);
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateNumPages(int? numPages) async {
    if (numPages == null) return;
    if (numPages == _numPages) return;
    _numPages = numPages;
    notifyListeners();
    await _settingsService.updateNumPages(numPages);
  }

  Future<void> updateRecitationId(int? recitationId) async {
    if (recitationId == null) return;
    if (recitationId == _recitationId) return;
    _recitationId = recitationId;
    notifyListeners();
    await _settingsService.updateRecitationId(recitationId);
  }

  Future<void> updateSelectableViews(bool? selectableViews) async {
    if (selectableViews == null) return;
    if (selectableViews == _selectableViews) return;
    _selectableViews = selectableViews;
    notifyListeners();
    await _settingsService.updateSelectableViews(selectableViews);
  }
}
