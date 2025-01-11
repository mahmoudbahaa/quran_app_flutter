import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/enums.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  final Future<SharedPreferencesWithCache> _prefs =
      SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions());

  Future<dynamic> getValue(String key, dynamic defaultValue) async {
    final SharedPreferencesWithCache prefs = await _prefs;
    Object? value = prefs.get(key);
    if (value == null) return defaultValue;
    return value;
  }

  Future<void> setValue(String key, dynamic value) async {
    final SharedPreferencesWithCache prefs = await _prefs;
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    }
  }

  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<AppLocale> appLocale() async =>
      AppLocale.values[await getValue('localization', 0)];

  Future<ThemeMode> themeMode() async =>
      ThemeMode.values[await getValue('themeMode', 0)];

  Future<TextRepresentation> textRepresentation() async =>
      TextRepresentation.values[await getValue('textRepresentation', 0)];

  Future<int> numPages() async => await getValue('numPages', 1);

  Future<int> recitationId() async => await getValue('recitationId', 7);

  Future<void> updateLocalization(AppLocale localization) async =>
      await setValue('localization', localization.index);

  Future<void> updateThemeMode(ThemeMode theme) async =>
      await setValue('themeMode', theme.index);

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateTextRepresentation(
          TextRepresentation textRepresentation) async =>
      await setValue('textRepresentation', textRepresentation.index);

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateFlowMode(bool flowMode) async =>
      await setValue('flowMode', flowMode);

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateNumPages(int numPages) async =>
      await setValue('numPages', numPages);

  Future<void> updateRecitationId(int recitationId) async =>
      await setValue('recitationId', recitationId);
}
