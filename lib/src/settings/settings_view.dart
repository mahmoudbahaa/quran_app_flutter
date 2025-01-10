import 'package:flutter/material.dart';
import '../util/text_representation.dart';

import 'settings_controller.dart';
import '../data/recitations.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final recitationsItems = <DropdownMenuItem<int>>[];

    for (int i = 0; i < recitations.length; i++) {
      dynamic recitation = recitations[i];
      String style = '';
      if (recitation['style'] != null) {
        style = ' (${recitation['style']})';
      }
      recitationsItems.add(DropdownMenuItem(
        value: recitation['id'] as int,
        child: Text('${recitation['translated_name']['name']}$style'),
      ));
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) => Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Column(children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              // Glue the SettingsController to the theme selection DropdownButton.
              //
              // When a user selects a theme from the dropdown list, the
              // SettingsController is updated, which rebuilds the MaterialApp.
              child: GridView.count(
                // primary: false,
                crossAxisCount: 2,
                // crossAxisSpacing: 10,
                // mainAxisSpacing: 10,
                childAspectRatio: (1 / .2),
                // shrinkWrap: true,
                children: [
                  const Text('Theme'),
                  DropdownButton<ThemeMode>(
                    // Read the selected themeMode from the controller
                    value: controller.themeMode,
                    // Call the updateThemeMode method any time the user selects a theme.
                    onChanged: controller.updateThemeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark Theme'),
                      ),
                    ],
                  ),
                  const Text('Text Representation'),
                  DropdownButton<TextRepresentation>(
                    // Read the selected themeMode from the controller
                    value: controller.textRepresentation,
                    // Call the updateThemeMode method any time the user selects a theme.
                    onChanged: controller.updateTextRepresentation,
                    items: const [
                      DropdownMenuItem(
                        value: TextRepresentation.codeV1,
                        child: Text('version 1'),
                      ),
                      DropdownMenuItem(
                        value: TextRepresentation.codeV2,
                        child: Text('version 2'),
                      ),
                      DropdownMenuItem(
                        value: TextRepresentation.codeV4,
                        child: Text('Tajweed'),
                      ),
                    ],
                  ),
                  const Text('Flow Mode'),
                  DropdownButton<bool>(
                    // Read the selected themeMode from the controller
                    value: controller.flowMode,
                    // Call the updateThemeMode method any time the user selects a theme.
                    onChanged: controller.updateFlowMode,
                    items: const [
                      DropdownMenuItem(
                        value: false,
                        child: Text('Off (Fixed Width)'),
                      ),
                      DropdownMenuItem(
                        value: true,
                        child: Text('On'),
                      ),
                    ],
                  ),
                  const Text('Number of Pages'),
                  DropdownButton<int>(
                    // Read the selected themeMode from the controller
                    value: controller.numPages,
                    // Call the updateThemeMode method any time the user selects a theme.
                    onChanged: controller.updateNumPages,
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text('1'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('2'),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text('3'),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: Text('4'),
                      ),
                    ],
                  ),
                  const Text('Recitation'),
                  DropdownButton<int>(
                    // Read the selected themeMode from the controller
                    value: controller.recitationId,
                    // Call the updateThemeMode method any time the user selects a theme.
                    onChanged: controller.updateRecitationId,
                    items: recitationsItems,
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
