import 'package:flutter/material.dart';
import 'package:quran_app_flutter/src/models/enums.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class LanguageSelectionView extends StatelessWidget {
  const LanguageSelectionView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<AppLocale>> items = [];

    for (int i = 0; i < AppLocale.values.length; i++) {
      items.add(DropdownMenuItem(
          value: AppLocale.values[i], child: Text(appLocales[i])));
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: DropdownButton<AppLocale>(
            // Read the selected themeMode from the controller
            value: controller.appLocale,
            // Call the updateThemeMode method any time the user selects a theme.
            onChanged: controller.updateAppLocale,
            items: items,
          ),
        ),
      ),
    );
  }
}
