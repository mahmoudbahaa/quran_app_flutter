import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/enums.dart';

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
    try {
      final SharedPreferencesWithCache prefs = await _prefs;
      dynamic value;
      if (defaultValue is bool) {
        value = prefs.getBool(key);
      } else if (defaultValue is int) {
        value = prefs.getInt(key);
      } else if (defaultValue is double) {
        value = prefs.getDouble(key);
      } else if (defaultValue is String) {
        value = prefs.getString(key);
      } else if (defaultValue is List<String>) {
        value = prefs.getStringList(key);
      }

      if (value == null) return defaultValue;
      return value;
    } catch (e) {
      return defaultValue;
    }
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

  Future<Color> mainColor() async {
    String colorHex = await getValue('mainColor', 'FF443A49');
    if (colorHex == 'FF443A49') {
      return Color(0xFF443A49);
    } else {
      return colorHex.toColor() ?? Color(0xFF443A49);
    }
  }

  Future<TextRepresentation> textRepresentation() async =>
      TextRepresentation.values[await getValue('textRepresentation', 0)];

  Future<bool> loadCachedOnly() async =>
      true; // await getValue('loadCachedOnly', true);

  Future<bool> selectableViews() async =>
      await getValue('selectableViews', false);

  Future<int> numPages() async => await getValue('numPages', 1);

  Future<int> recitationId() async => await getValue('recitationId', 7);

  Future<void> updateLocalization(AppLocale localization) async =>
      await setValue('localization', localization.index);

  Future<void> updateThemeMode(ThemeMode theme) async =>
      await setValue('themeMode', theme.index);

  Future<void> updateMainColor(Color mainColor) async =>
      await setValue('mainColor', mainColor.toHexString());

  Future<void> updateTextRepresentation(
          TextRepresentation textRepresentation) async =>
      await setValue('textRepresentation', textRepresentation.index);

  Future<void> updateLoadCachedOnly(bool loadCachedOnly) async =>
      await setValue('loadCachedOnly', loadCachedOnly);

  Future<void> updateFlowMode(bool flowMode) async =>
      await setValue('flowMode', flowMode);

  Future<void> updateNumPages(int numPages) async =>
      await setValue('numPages', numPages);

  Future<void> updateRecitationId(int recitationId) async =>
      await setValue('recitationId', recitationId);

  Future<void> updateSelectableViews(bool selectableViews) async =>
      await setValue('selectableViews', selectableViews);
}
