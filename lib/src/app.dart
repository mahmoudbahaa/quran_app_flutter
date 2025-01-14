import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

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

  ThemeData _buildTheme(Brightness brightness, String languageCode) {
    ThemeData baseTheme;
    if (brightness == Brightness.light) {
      baseTheme = ThemeData.light(useMaterial3: true);
    } else {
      baseTheme = ThemeData.dark(useMaterial3: true);
    }

    TextTheme textTheme;
    if (languageCode == 'ar') {
      textTheme = GoogleFonts.notoNaskhArabicTextTheme(baseTheme.textTheme);
    } else {
      textTheme = GoogleFonts.notoSansTextTheme(baseTheme.textTheme);
    }

    if (settingsController.mainColor == Colors.white ||
        settingsController.mainColor == Colors.black) {
      baseTheme = baseTheme.copyWith(
        brightness: brightness,
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          elevation: 4,
        ),
        bottomAppBarTheme: BottomAppBarTheme(),
      );
    } else {
      final colorScheme = ColorScheme.fromSeed(
          seedColor: settingsController.mainColor, brightness: brightness);

      baseTheme = baseTheme.copyWith(
        brightness: brightness,
        textTheme: textTheme,
        colorScheme: colorScheme,
        appBarTheme: AppBarTheme(
          elevation: 4,
          backgroundColor: colorScheme.inversePrimary,
          shadowColor: colorScheme.shadow,
        ),
        bottomAppBarTheme: BottomAppBarTheme(
          // elevation: 4,
          color: colorScheme.inversePrimary,
        ),
      );
    }

    return baseTheme;
  }

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
        listenable: settingsController,
        builder: (BuildContext context, Widget? child) => MaterialApp(
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
              theme: _buildTheme(
                  Brightness.light, settingsController.appLocale.name),
              darkTheme: _buildTheme(
                  Brightness.dark, settingsController.appLocale.name),
              themeMode: settingsController.themeMode,
              debugShowCheckedModeBanner: false,
            ));
  }
}
