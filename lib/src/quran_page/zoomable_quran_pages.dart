import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

/// Shares zoom actions between the reader viewport and its top bar.
class QuranZoomController {
  final transformation = TransformationController();
  Size viewport = Size.zero;

  double minScale = 0.25;
  double maxScale = 5;
  void zoom(double factor) {
    final scale = (transformation.value.getMaxScaleOnAxis() * factor).clamp(
      minScale,
      maxScale,
    );
    if (scale <= 1.01 && scale >= 0.99) {
      transformation.value = Matrix4.identity();
      return;
    }
    final center = viewport.center(Offset.zero);
    final scene = transformation.toScene(center);
    // InteractiveViewer constrains gestures, but controller changes bypass its
    // boundary checks. Keep button-driven zoom inside the page as well.
    final x = (center.dx - scene.dx * scale).clamp(
      viewport.width * (1 - scale),
      0.0,
    );
    final y = (center.dy - scene.dy * scale).clamp(
      viewport.height * (1 - scale),
      0.0,
    );
    transformation.value = Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(x, y, 0);

    // // Get the current transformation matrix
    // final Matrix4 currentMatrix = transformation.value;
    //
    // // Extract current scale level from the matrix (using the X-axis scaling factor)
    // final double currentScale = currentMatrix.getMaxScaleOnAxis();
    //
    // // Calculate target scale and clamp it within limits
    // double targetScale = (currentScale * factor).clamp(minScale, maxScale);
    //
    // // Calculate how much we need to scale the current matrix to reach the target
    // final double scaleChange = targetScale / currentScale;

    // setState(() {
      // Scale the matrix from its center point
      // transformation.value = currentMatrix.clone()..scale(scaleChange);
    // });
  }

  void reset() => transformation.value = Matrix4.identity();

  void dispose() => transformation.dispose();
}

class QuranZoomControls extends StatelessWidget {
  const QuranZoomControls({super.key, required this.controller});

  final QuranZoomController controller;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: AppLocalizations.of(context)?.zoomOut ?? 'Zoom out',
        onPressed: () => controller.zoom(1.0 / 1.25),
        icon: const Icon(Icons.remove),
      ),
      ValueListenableBuilder<Matrix4>(
        valueListenable: controller.transformation,
        builder: (context, matrix, _) => Text(
          '${(matrix.getMaxScaleOnAxis() * 100).round()}%',
          textDirection: TextDirection.ltr,
        ),
      ),
      IconButton(
        tooltip: AppLocalizations.of(context)?.resetZoom ?? 'Reset zoom',
        onPressed: controller.reset,
        icon: const Icon(Icons.fit_screen),
      ),
      IconButton(
        tooltip: AppLocalizations.of(context)?.zoomIn ?? 'Zoom in',
        onPressed: () => controller.zoom(1.25),
        icon: const Icon(Icons.add),
      ),
    ],
  );
}

/// Zooms a page spread while leaving reader chrome and audio controls fixed.
class ZoomableQuranPages extends StatefulWidget {
  const ZoomableQuranPages({
    super.key,
    required this.builder,
    required this.pageIdentity,
    this.controller,
  });

  final Widget Function(BuildContext context, bool navigationEnabled) builder;
  final Object pageIdentity;
  final QuranZoomController? controller;

  @override
  State<ZoomableQuranPages> createState() => _ZoomableQuranPagesState();
}

class _ZoomableQuranPagesState extends State<ZoomableQuranPages> {
  late final QuranZoomController _controller;
  TransformationController get _transformation => _controller.transformation;
  final _pointers = <int>{};
  bool _navigationEnabled = true;

  void _updateNavigation() {
    final enabled =
        _pointers.length < 2 &&
        _transformation.value.getMaxScaleOnAxis() <= 1.01 &&
        _transformation.value.getMaxScaleOnAxis() >= 0.99;
    if (enabled != _navigationEnabled) {
      setState(() => _navigationEnabled = enabled);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? QuranZoomController();
    _controller.reset();
    _transformation.addListener(_updateNavigation);
  }

  @override
  void didUpdateWidget(covariant ZoomableQuranPages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageIdentity != widget.pageIdentity) {
      _pointers.clear();
      _transformation.value = Matrix4.identity();
      _updateNavigation();
    }
  }

  @override
  void dispose() {
    _transformation.removeListener(_updateNavigation);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _controller.viewport = constraints.biggest;
        return Listener(
          onPointerDown: (event) {
            _pointers.add(event.pointer);
            _updateNavigation();
          },
          onPointerUp: (event) {
            _pointers.remove(event.pointer);
            _updateNavigation();
          },
          onPointerCancel: (event) {
            _pointers.remove(event.pointer);
            _updateNavigation();
          },
          child: InteractiveViewer(
            key: const ValueKey('quran-zoom-viewport'),
            transformationController: _transformation,
            boundaryMargin: EdgeInsets.all(7680),
            minScale: 0.25,
            maxScale: 5,
            panEnabled: !_navigationEnabled,
            trackpadScrollCausesScale: true,
            child: widget.builder(context, _navigationEnabled),
          ),
        );
      },
    );
  }
}
