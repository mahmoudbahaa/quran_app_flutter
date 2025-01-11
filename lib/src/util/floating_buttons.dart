import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;

import 'common.dart';
import 'quran_player_global_state.dart';

class FloatingButtons extends StatelessWidget {
  const FloatingButtons({super.key, required this.state, required this.update});

  final QuranPlayerGlobalState state;
  final Function update;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(ConstrainedBox(
      constraints: BoxConstraints(minWidth: 50, maxWidth: 50),
      child: FittedBox(
        child: FloatingActionButton(
            heroTag: 'go_back',
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
            child: const Icon(Icons.navigate_before)),
      ),
    ));

    children.add(SizedBox(height: 5));

    children.add(ConstrainedBox(
      constraints: BoxConstraints(minWidth: 50, maxWidth: 50),
      child: FittedBox(
        child: FloatingActionButton(
            heroTag: 'go_to',
            tooltip: 'Go to certain page',
            onPressed: () => showNumberSelectDialog(
                context: context,
                title: 'Page Number',
                min: 1,
                max: quran.totalPagesCount,
                initialValue: state.pageNumber < 1 ? 1 : state.pageNumber,
                onChanged: (value) {
                  state.pageNumber = value as int;
                  update();
                }),
            child: Text('Go To')),
      ),
    ));

    return Container(
      padding: EdgeInsets.only(left: 30, right: 30, bottom: 30),
      alignment:
          rtlLanguages.contains(Localizations.localeOf(context).languageCode)
              ? Alignment.bottomRight
              : Alignment.bottomLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: children,
      ),
    );
  }
}
