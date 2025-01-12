import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'home/home_view.dart';
import 'localization/app_localizations.dart';
import 'settings/settings_controller.dart';
import 'util/quran_player_global_state.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp(
      {super.key, required this.settingsController, required this.state});

  final SettingsController settingsController;
  final QuranPlayerGlobalState state;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
        listenable: settingsController,
        builder: (BuildContext context, Widget? child) => GetMaterialApp(
              home: QuranChaptersListView(
                  controller: settingsController, state: state),
              // Provide the generated AppLocalizations to the MaterialApp. This
              // allows descendant Widgets to display the correct translations
              // depending on the user's locale.
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,

              locale: Locale(settingsController.appLocale.name, ''),
              // Use AppLocalizations to configure the correct application title
              // depending on the user's locale.
              //
              // The appTitle is defined in .arb files found in the localization
              // directory.
              onGenerateTitle: (BuildContext context) =>
                  AppLocalizations.of(context)!.appTitle,

              // Define a light and dark color theme. Then, read the user's
              // preferred ThemeMode (light, dark, or system default) from the
              // SettingsController to display the correct theme.
              theme: ThemeData(
                useMaterial3: true,
                fontFamily:
                    rtlLanguages.contains(settingsController.appLocale.name)
                        ? 'uthmanic'
                        : DefaultTextStyle.of(context).style.fontFamily,
                brightness: Brightness.light,
                // colorSchemeSeed: Colors.blueGrey,
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                fontFamily:
                    rtlLanguages.contains(settingsController.appLocale.name)
                        ? 'uthmanic'
                        : DefaultTextStyle.of(context).style.fontFamily,
                // colorSchemeSeed: Colors.blue,
                brightness: Brightness.dark,
              ),
              themeMode: settingsController.themeMode,
              debugShowCheckedModeBanner: false,
            ));
  }
}
