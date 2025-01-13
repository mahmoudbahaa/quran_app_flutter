import 'package:flutter/material.dart';
import 'package:quran_app_flutter/src/util/arabic_number.dart';

import '../localization/app_localizations.dart';
import '../models/enums.dart';
import '../models/recitations.dart';
import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;
  final double labelWidth = 200;
  final double dropDownWidth = 330;
  final double dividerHeight = 10;
  final double dividerThickness = 5;

  @override
  Widget build(BuildContext context) {
    final recitationsItems = <DropdownMenuItem<int>>[];

    for (int i = 0; i < recitations.length; i++) {
      dynamic recitation = recitations[i];
      String style = '';
      if (recitation['style'] != null) {
        style = ' (${recitation['style']})';
      }
      String recitationName =
          Localizations.localeOf(context).languageCode == 'ar'
              ? recitation['translated_name']['name']
              : recitation['reciter_name'];
      recitationsItems.add(DropdownMenuItem(
        value: recitation['id'] as int,
        child: Text('$recitationName$style'),
      ));
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settings),
        ),
        body: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Divider(thickness: dividerThickness, height: dividerHeight),
            Text(AppLocalizations.of(context)!.theme),
            DropdownButton<ThemeMode>(
              // Read the selected themeMode from the controller
              value: controller.themeMode,
              // Call the updateThemeMode method any time the user selects a theme.
              onChanged: controller.updateThemeMode,
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(AppLocalizations.of(context)!.system),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(AppLocalizations.of(context)!.light),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(AppLocalizations.of(context)!.dark),
                ),
              ],
            ),
            Divider(thickness: dividerThickness, height: dividerHeight),
            Text(AppLocalizations.of(context)!.loadAtStartupStyle),
            DropdownButton<bool>(
              // Read the selected themeMode from the controller
              value: controller.loadCachedOnly,
              // Call the updateThemeMode method any time the user selects a theme.
              onChanged: controller.updateLoadCachedOnly,
              items: [
                DropdownMenuItem(
                  value: true,
                  child: Text(AppLocalizations.of(context)!.cachedOnly),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text(AppLocalizations.of(context)!.all),
                ),
              ],
            ),
            Divider(thickness: dividerThickness, height: dividerHeight),
            Text(AppLocalizations.of(context)!.quranTextRepresentation),
            DropdownButton<TextRepresentation>(
              // Read the selected themeMode from the controller
              value: controller.textRepresentation,
              // Call the updateThemeMode method any time the user selects a theme.
              onChanged: controller.updateTextRepresentation,
              items: [
                DropdownMenuItem(
                  value: TextRepresentation.codeV1,
                  child: Text(AppLocalizations.of(context)!.version1),
                ),
                DropdownMenuItem(
                  value: TextRepresentation.codeV2,
                  child: Text(AppLocalizations.of(context)!.version2),
                ),
                DropdownMenuItem(
                  value: TextRepresentation.codeV4,
                  child: Text(AppLocalizations.of(context)!.tagweed),
                ),
              ],
            ),
            Divider(thickness: dividerThickness, height: dividerHeight),
            Text(AppLocalizations.of(context)!.numberOfPagesOnScreen),
            DropdownButton<int>(
              // Read the selected themeMode from the controller
              value: controller.numPages,
              // Call the updateThemeMode method any time the user selects a theme.
              onChanged: controller.updateNumPages,
              items: [
                DropdownMenuItem(
                  value: 1,
                  child: Text(ArabicNumber().convertToLocaleNumber(1)),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text(ArabicNumber().convertToLocaleNumber(2)),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text(ArabicNumber().convertToLocaleNumber(3)),
                ),
                DropdownMenuItem(
                  value: 4,
                  child: Text(ArabicNumber().convertToLocaleNumber(4)),
                ),
              ],
            ),
            Divider(thickness: dividerThickness, height: dividerHeight),
            Text(AppLocalizations.of(context)!.recitation),
            DropdownButton<int>(
              // Read the selected themeMode from the controller
              value: controller.recitationId,
              // Call the updateThemeMode method any time the user selects a theme.
              onChanged: controller.updateRecitationId,
              items: recitationsItems,
            ),
            Divider(thickness: dividerThickness, height: dividerHeight),
          ]),
        ),
      ),
    );
  }
}
