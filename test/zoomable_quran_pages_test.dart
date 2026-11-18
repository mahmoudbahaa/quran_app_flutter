import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:quran_app_flutter/src/common/desktop_page_scroll.dart';
import 'package:quran_app_flutter/src/util/quran_player_global_state.dart';
import 'package:quran_app_flutter/src/quran_page/zoomable_quran_pages.dart';

void main() {
  Future<void> mount(
    WidgetTester tester, {
    ValueChanged<int>? onPageChanged,
  }) async {
    final zoom = QuranZoomController();
    addTearDown(zoom.dispose);
    final pages = PageController();
    addTearDown(pages.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(actions: [QuranZoomControls(controller: zoom)]),
          body: ZoomableQuranPages(
            controller: zoom,
            pageIdentity: 1,
            builder: (context, navigationEnabled) => DesktopPageScroll(
              enabled: navigationEnabled,
              controller: pages,
              itemCount: 2,
              numPages: 1,
              state: QuranPlayerGlobalState()..pageNumber = 1,
              update: () {},
              child: Focus(
                autofocus: true,
                child: PageView(
                  controller: pages,
                  physics: navigationEnabled
                      ? const PageScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  onPageChanged: onPageChanged,
                  children: const [
                    Center(child: Text('Page one')),
                    Center(child: Text('Page two')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  TransformationController controller(WidgetTester tester) => tester
      .widget<InteractiveViewer>(find.byType(InteractiveViewer))
      .transformationController!;

  testWidgets('page swipes work at normal zoom', (tester) async {
    var page = 0;
    await mount(tester, onPageChanged: (value) => page = value);
    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(page, 1);
  });

  testWidgets('zoom controls clamp scale and reset restores page navigation', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.byTooltip('Zoom in'));
    await tester.pump();
    expect(controller(tester).value.getMaxScaleOnAxis(), closeTo(1.25, 0.001));
    expect(
      tester.widget<PageView>(find.byType(PageView)).physics,
      isA<NeverScrollableScrollPhysics>(),
    );
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byTooltip('Zoom in'));
      await tester.pump();
    }
    expect(controller(tester).value.getMaxScaleOnAxis(), 4);
    await tester.tap(find.byTooltip('Reset zoom'));
    await tester.pump();
    expect(controller(tester).value.getMaxScaleOnAxis(), 1);
    expect(
      tester.widget<PageView>(find.byType(PageView)).physics,
      isA<PageScrollPhysics>(),
    );
    await tester.tap(find.byTooltip('Zoom out'));
    await tester.pump();
    expect(controller(tester).value.getMaxScaleOnAxis(), 1);
  });

  testWidgets(
    'pinch zooms; dragging while enlarged pans without turning pages',
    (tester) async {
      var page = 0;
      await mount(tester, onPageChanged: (value) => page = value);
      final first = await tester.startGesture(
        const Offset(300, 250),
        pointer: 1,
      );
      final second = await tester.startGesture(
        const Offset(450, 250),
        pointer: 2,
      );
      await tester.pump();
      await first.moveTo(const Offset(250, 250));
      await second.moveTo(const Offset(500, 250));
      await tester.pump();
      await first.moveTo(const Offset(200, 250));
      await second.moveTo(const Offset(550, 250));
      await tester.pump();
      await first.up();
      await second.up();
      await tester.pumpAndSettle();
      expect(controller(tester).value.getMaxScaleOnAxis(), greaterThan(1));
      expect(page, 0);
      await tester.drag(find.byType(InteractiveViewer), const Offset(-150, 0));
      await tester.pumpAndSettle();
      expect(page, 0);
      expect(controller(tester).value.getTranslation().x, lessThan(0));
    },
  );

  testWidgets(
    'desktop page shortcuts pause while zoomed and resume after reset',
    (tester) async {
      var page = 0;
      await mount(tester, onPageChanged: (value) => page = value);
      await tester.tap(find.byTooltip('Zoom in'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(page, 0);
      await tester.tap(find.byTooltip('Reset zoom'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(page, 1);
    },
  );

  testWidgets(
    'zooming out at a panned edge keeps the page inside the viewport',
    (tester) async {
      await mount(tester);
      final size = tester.getSize(find.byType(InteractiveViewer));
      controller(tester).value = Matrix4.diagonal3Values(4, 4, 1)
        ..setTranslationRaw(-3 * size.width, -3 * size.height, 0);
      await tester.pump();
      await tester.tap(find.byTooltip('Zoom out'));
      await tester.pump();
      final matrix = controller(tester).value;
      final scale = matrix.getMaxScaleOnAxis();
      final offset = matrix.getTranslation();
      expect(offset.x, greaterThanOrEqualTo(size.width * (1 - scale)));
      expect(offset.y, greaterThanOrEqualTo(size.height * (1 - scale)));
      expect(offset.x, lessThanOrEqualTo(0));
      expect(offset.y, lessThanOrEqualTo(0));
    },
  );

  testWidgets('changing page identity resets zoom', (tester) async {
    final zoom = QuranZoomController();
    addTearDown(zoom.dispose);
    final identity = ValueNotifier<int>(1);
    addTearDown(identity.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(actions: [QuranZoomControls(controller: zoom)]),
          body: ValueListenableBuilder<int>(
            valueListenable: identity,
            builder: (context, value, _) => ZoomableQuranPages(
              controller: zoom,
              pageIdentity: value,
              builder: (_, _) => const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Zoom in'));
    await tester.pump();
    identity.value = 2;
    await tester.pump();
    expect(controller(tester).value.getMaxScaleOnAxis(), 1);
  });
}
