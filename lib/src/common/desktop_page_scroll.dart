import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_app_flutter/src/util/quran_player_global_state.dart';

class DesktopPageScroll extends StatelessWidget {
  const DesktopPageScroll(
      {super.key,
      required this.child,
      required this.controller,
      required this.itemCount,
      required this.state});

  final Widget child;
  final PageController controller;
  final int itemCount;
  final QuranPlayerGlobalState state;

  void goNextPage() {
    if (controller.page != null && controller.page! < itemCount - 1) {
      state.curPageInPageView++;
      controller.nextPage(
          duration: Duration(milliseconds: 400), curve: Curves.ease);
    }
  }

  void goPreviousPage() {
    if (controller.page != null && controller.page! > 0.0) {
      state.curPageInPageView--;
      controller.previousPage(
          duration: Duration(milliseconds: 400), curve: Curves.ease);
    }
  }

  bool? _turnPage(DragUpdateDetails details, bool? isForward) {
    if (details.delta.dx < 0.0) {
      return false;
    } else if (details.delta.dx > 0.2) {
      return true;
    } else {
      return null;
    }
  }

  bool? _onDragFinish(bool? isForward) {
    if (isForward == null) return null;

    if (isForward == true) {
      goNextPage();
    } else {
      goPreviousPage();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    bool? isForward;

    return GestureDetector(
      onHorizontalDragUpdate: (details) =>
          isForward = _turnPage(details, isForward),
      onHorizontalDragEnd: (details) => isForward = _onDragFinish(isForward),
      child: CallbackShortcuts(bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          goNextPage();
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          goPreviousPage();
        },
      }, child: child),
    );
  }
}
