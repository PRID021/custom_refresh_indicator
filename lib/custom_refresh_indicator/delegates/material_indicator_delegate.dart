import 'package:flutter/material.dart';
import 'package:monkey_lib/utils/pretty_json.dart';
import 'dart:math' as math;

import '../constraint/enums/indicator_side.dart';
import '../constraint/types/type.dart';
import '../custom_refresh_indicator_controller.dart';
import 'indicator_builder_delegate.dart';
import '../extension/index.dart';

typedef MaterialIndicatorBuilder = Widget Function(
  BuildContext context,
  CustomRefreshIndicatorController controller,
);

/// Builds a container that behaves similarly to the material refresh indicator
class MaterialIndicatorDelegate extends IndicatorBuilderDelegate {
  /// The distance from the child's top or bottom [edgeOffset] where
  /// the refresh indicator will settle. During the drag that exposes the refresh
  /// indicator, its actual displacement may significantly exceed this value.
  ///
  /// In most cases, [displacement] distance starts counting from the parent's
  /// edges. However, if [edgeOffset] is larger than zero then the [displacement]
  /// value is calculated from that offset instead of the parent's edge.
  final double displacement;

  /// The offset where indicator starts to appear on drag start.
  ///
  /// Depending whether the indicator is showing on the top or bottom, the value
  /// of this variable controls how far from the parent's edge the progress
  /// indicator starts to appear. This may come in handy when, for example, the
  /// UI contains a top [Widget] which covers the parent's edge where the progress
  /// indicator would otherwise appear.
  ///
  /// By default, the edge offset is set to 0.
  final double edgeOffset;

  /// The indicator background color
  final Color? backgroundColor;

  /// Builds the content for the indicator container
  final MaterialIndicatorBuilder builder;

  /// Builds the scrollable.
  final IndicatorBuilder scrollableBuilder;

  /// When set to *true*, the indicator will rotate in the [IndicatorState.loading] state.
  final bool withRotation;

  MaterialIndicatorDelegate({
    required this.builder,
    this.scrollableBuilder = _defaultBuilder,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.withRotation = true,
  });

  static Widget _defaultBuilder(
    BuildContext context,
    Widget child,
    CustomRefreshIndicatorController controller,
  ) =>
      child;

  @override
  Widget build(
    BuildContext context,
    Widget child,
    CustomRefreshIndicatorController controller,
  ) {
    final Color backgroundColor = this.backgroundColor ??
        ProgressIndicatorTheme.of(context).refreshBackgroundColor ??
        Theme.of(context).canvasColor;

    return Stack(
      children: <Widget>[
        scrollableBuilder(context, child, controller),
        _PositionedIndicatorContainer(
          edgeOffset: edgeOffset,
          displacement: displacement,
          controller: controller,
          child: Transform.scale(
            scale: controller.value.clamp(0.0, 1.0),
            child: Container(
              width: 41,
              height: 41,
              margin: const EdgeInsets.all(4.0),
              child: Material(
                type: MaterialType.circle,
                color: backgroundColor,
                elevation: 2.0,
                child: _InfiniteRotation(
                  running: controller.state.isSettlingState ||
                      controller.state.isLoadingState,
                  child: builder(context, controller),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Card(
              child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "State : ${controller.state}",
                ),
                Text(
                  "Value : ${controller.value}",
                ),
                Text(
                  "Edge : ${controller.currentEdge}",
                ),
                Text(
                  "TriggerEdge : ${controller.indicatorTriggerEdge}",
                ),
                Text(
                  "EdgeOffset : ${edgeOffset}",
                ),
                Text(
                  "displacement : ${displacement}",
                ),
                Text(
                  "scale: ${controller.value.clamp(0.0, 1.0)}",
                ),
                Text(
                  "DragOverOffser : ${controller.dragOverOffset}",
                ),
              ],
            ),
          )),
        ),
      ],
    );
  }

  @override
  bool get autoRebuild => true;
}

class _PositionedIndicatorContainer extends StatelessWidget {
  final CustomRefreshIndicatorController controller;
  final double displacement;
  final Widget child;
  final double edgeOffset;

  /// Position child widget in a similar way
  /// to the built-in [RefreshIndicator] widget.
  const _PositionedIndicatorContainer({
    Key? key,
    required this.child,
    required this.controller,
    required this.displacement,
    required this.edgeOffset,
  }) : super(key: key);

  Alignment _getAlignement(IndicatorSide side) {
    switch (side) {
      case IndicatorSide.left:
        return Alignment.centerLeft;
      case IndicatorSide.top:
        return Alignment.topCenter;
      case IndicatorSide.right:
        return Alignment.centerRight;
      case IndicatorSide.bottom:
        return Alignment.bottomCenter;
      case IndicatorSide.none:
        throw UnsupportedError('Cannot get alignement for "none" side.');
    }
  }

  EdgeInsets _getEdgeInsets(IndicatorSide side) {
    switch (side) {
      case IndicatorSide.left:
        return EdgeInsets.only(left: displacement);
      case IndicatorSide.top:
        return EdgeInsets.only(top: displacement);
      case IndicatorSide.right:
        return EdgeInsets.only(right: displacement);
      case IndicatorSide.bottom:
        return EdgeInsets.only(bottom: displacement);
      case IndicatorSide.none:
        throw UnsupportedError('Cannot get edge insets for "none" side.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (controller.side.isNone)
    //   return const SizedBox(
    //     child: Text("controller.side.isNone"),
    //   );

    final isVerticalAxis = controller.side.isTop || controller.side.isBottom;
    final isHorizontalAxis = controller.side.isLeft || controller.side.isRight;

    final AlignmentDirectional alignment = isVerticalAxis
        ? AlignmentDirectional(-1.0, controller.side.isTop ? 1.0 : -1.0)
        : AlignmentDirectional(controller.side.isLeft ? 1.0 : -1.0, -1.0);

    final double value =
        controller.state.isRelizingState ? 1.0 : controller.value;

    Logger.w("value: $value");

    return Positioned(
      top: isHorizontalAxis
          ? 0
          : controller.side.isTop
              ? edgeOffset
              : null,
      bottom: isHorizontalAxis
          ? 0
          : controller.side.isBottom
              ? edgeOffset
              : null,
      left: isVerticalAxis
          ? 0
          : controller.side.isLeft
              ? edgeOffset
              : null,
      right: isVerticalAxis
          ? 0
          : controller.side.isRight
              ? edgeOffset
              : null,
      child: ClipRRect(
        child: Align(
          alignment: alignment,
          heightFactor: isVerticalAxis ? math.max(value, 0.0) : null,
          widthFactor: isHorizontalAxis ? math.max(value, 0.0) : null,
          child: Container(
            padding: _getEdgeInsets(controller.side),
            alignment: _getAlignement(controller.side),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _InfiniteRotation extends StatefulWidget {
  final Widget? child;
  final bool running;

  const _InfiniteRotation({
    required this.child,
    required this.running,
    Key? key,
  }) : super(key: key);
  @override
  _InfiniteRotationState createState() => _InfiniteRotationState();
}

class _InfiniteRotationState extends State<_InfiniteRotation>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void didUpdateWidget(_InfiniteRotation oldWidget) {
    if (oldWidget.running != widget.running) {
      if (widget.running) {
        _startAnimation();
      } else {
        _rotationController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 50),
        );
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );

    if (widget.running) {
      _startAnimation();
    }

    super.initState();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _rotationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    Logger.w("build RotationTransition wtith running: ${widget.running}");
    return RotationTransition(turns: _rotationController, child: widget.child);
  }
}
