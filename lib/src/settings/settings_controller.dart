import 'package:flutter/material.dart';

import 'settings_service.dart';
import '../util/text_representation.dart';

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
  late int _numPages;
  late bool _flowMode;
  late int _recitationId;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => _themeMode;
  TextRepresentation get textRepresentation => _textRepresentation;
  bool get flowMode => _flowMode;
  int get numPages => _numPages;
  int get recitationId => _recitationId;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _flowMode = await _settingsService.flowMode();
    _textRepresentation = await _settingsService.textRepresentation();
    _numPages = await _settingsService.numPages();
    _recitationId = await _settingsService.recitationId();

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  /// Update and persist the TextRepresentation based on the user's selection.
  Future<void> updateTextRepresentation(TextRepresentation? newTextRepresentation) async {
    if (newTextRepresentation == null) return;
    if (newTextRepresentation == _textRepresentation) return;
    _textRepresentation = newTextRepresentation;
    notifyListeners();
    await _settingsService.updateTextRepresentation(newTextRepresentation);
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateFlowMode(bool? flowMode) async {
    if (flowMode == null) return;
    if (flowMode == _flowMode) return;
    _flowMode = flowMode;
    notifyListeners();
    await _settingsService.updateFlowMode(flowMode);
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
}