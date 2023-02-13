import 'package:custom_indicator/custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:custom_indicator/custom_refresh_indicator/custom_refresh_indicator_controller.dart';
import 'package:custom_indicator/custom_refresh_indicator/delegates/indicator_builder_delegate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide RefreshIndicatorState;
import 'delegates/default_indicator_builder_delegate.dart';
import 'models/custom_indicator_events/indicator_state_change_event.dart';
import 'models/refresh_indicator_state/index.dart';
import 'extension/index.dart';
import 'constraint/index.dart';

class CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with TickerProviderStateMixin {
  late CustomRefreshIndicatorController _controller;
  late AnimationController _animationController;
  late Widget _child;
  late IndicatorBuilderDelegate _builderDelegate;
  late bool _leadingScrollIndicatorVisible;
  late bool _trailingScrollIndicatorVisible;
  late bool Function(ScrollNotification notification) notificationPredicate;
  late IndicatorEdgeTriggerMode _triggerMode;
  late IndicatorTriggerEdge _triggerEdge;
  late IndicatorStateChangeCallback? _onStateChange;
  late CustomRefreshIndicatorCallback? _onRefresh;
  late double _dragOffset;
  double? _offsetToArmed;

  ///
  /// Indicate the indicator currently stopping drag.
  ///
  /// if [true] user can not able to perform any action.
  ///
  late bool _isStopDrag;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ??
        CustomRefreshIndicatorController(initState: RefreshIdleState());

    _animationController = AnimationController(
      vsync: this,
      value: kInitialValue,
      upperBound: kPositionLimit,
      lowerBound: kInitialValue,
    )..addListener(() {
        _controller.value = _animationController.value;
      });
    _child = widget.child;
    _builderDelegate =
        widget.builderDelegate ?? DefaultIndicatorBuilderDelegate();
    _leadingScrollIndicatorVisible =
        widget.leadingScrollIndicatorVisible ?? false;
    _trailingScrollIndicatorVisible =
        widget.trailingScrollIndicatorVisible ?? false;

    notificationPredicate = (notification) {
      return notification.depth == 0;
    };
    _triggerMode = IndicatorEdgeTriggerMode.onEdge;
    _triggerEdge = IndicatorTriggerEdge.leadingEdge;
    _isStopDrag = false;
    _onRefresh = null;
    _dragOffset = 0.0;
    _offsetToArmed = widget.offsetToArmed;
  }

  bool _handelOverScrollIndicator(
      OverscrollIndicatorNotification notification) {
    if (notification.depth != 0) {
      return false;
    }
    if (notification.leading && !_leadingScrollIndicatorVisible) {
      notification.disallowIndicator();
    }
    if (!_trailingScrollIndicatorVisible) {
      notification.disallowIndicator();
    }
    return true;
  }

  //
  bool _canStart(ScrollNotification notification) {
    final isValidMode = (notification is ScrollStartNotification &&
            notification.dragDetails != null) ||
        (notification is ScrollUpdateNotification &&
            notification.dragDetails != null &&
            _triggerMode == IndicatorEdgeTriggerMode.anyWhere);

    final canStart = isValidMode &&
        _controller.enable &&
        (_controller.state is RefreshIdleState);

    return canStart;
  }

  void setIndicationState(RefreshIndicatorState newState) {
    if (_controller.state == newState) return;

    _onStateChange?.call(IndicatorStateChangeEvent(
        currentstate: _controller.state, nextState: newState));
    _controller.state = newState;
  }

  bool canHandleNotification(ScrollNotification notification) {
    return (_controller.state is RefreshDraggingState ||
            _controller.state is RefreshArmingState) &&
        notification.depth == 0;
  }

  void _startRefreshProgress() async {
    try {
      setIndicationState(RefreshSettlingState());
      await _animationController.animateTo(
        1.0,
        duration: kIndicatorSettlingDuration,
        curve: kCurve,
      );
      setIndicationState(RefreshLoadingState());
      await _onRefresh?.call();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      await _hideAfterRefresh();
    }
  }

  Future _hideAfterRefresh() async {
    assert(_controller.state is RefreshLoadingState);
    if (!mounted) return;
    setIndicationState(RefreshRelizingState());
    await _animationController.animateTo(
      kInitialValue,
      duration: kIndicatorRelizingDuration,
      curve: kCurve,
    );

    setIndicationState(RefreshIdleState());
    _controller.indicatorEdge = null;
  }

  bool _handelScrollUpdateNotification(
      ScrollUpdateNotification scrollNotification) {
    /// RefreshIndicator is on armed state and action not caused by user
    /// the refresh call back should be called.
    if (_controller.state is RefreshArmingState &&
        scrollNotification.dragDetails != null) {
      _startRefreshProgress();
    }

    return false;
  }

  void _calculateDragOffset(double viewportDimension) {
    if (_controller.state.isCancelingState ||
        _controller.state.isRelizingState ||
        _controller.state.isLoadingState) return;
    final offsetToArmed = _offsetToArmed;
    double newValue;
    if (offsetToArmed == null) {
      final double extendPercentageToArmed =
          widget.extendContainerPercentageToArmed ??
              kExtendContainerPercentageToArmed;
      newValue = _dragOffset / (viewportDimension * extendPercentageToArmed);
    }
    if (offsetToArmed != null) {
      newValue = _dragOffset / offsetToArmed;
    }

    if (newValue > kInitialValue && newValue < kArmedFromValue) {}
  }

  bool _handelOverscrollNotification(
      OverscrollNotification scrollNotification) {
    _controller.indicatorEdge ??= scrollNotification.overscroll.isNegative
        ? IndicatorEdge.trailing
        : IndicatorEdge.leading;

    if (_controller.indicatorEdge == IndicatorEdge.leading) {
      _dragOffset -= scrollNotification.overscroll;
    }
    if (_controller.indicatorEdge == IndicatorEdge.trailing) {
      _dragOffset += scrollNotification.overscroll;
    }
    _calculateDragOffset(scrollNotification.metrics.viewportDimension);
    return false;
  }

  bool _handelScrollEndNotification(ScrollNotification scrollNotification) {
    return false;
  }

  bool _handelUserScrollNotification(ScrollNotification scrollNotification) {
    return false;
  }

  Future _hideIndicator() async {
    setIndicationState(RefreshCancelingState());
    await _animationController.animateTo(
      kInitialValue,
      duration: kIndicatorCancelDuration,
      curve: kCurve,
    );
    if (!mounted) return;
    _controller.indicatorEdge = null;
    setIndicationState(RefreshIdleState());
  }

  bool _handelScrollIndicatorNotification(
      ScrollNotification scrollNotification) {
    if (!notificationPredicate(scrollNotification)) {
      return false;
    }

    if (_isStopDrag) {
      _controller.shouldStopDrag = false;
      return false;
    }
    if (_controller.shouldStopDrag) {
      _isStopDrag = true;
      _controller.shouldStopDrag = false;
      _hideIndicator().then((_) {
        _isStopDrag = false;
      });
      return false;
    }

    if (_controller.state is RefreshIdleState) {
      bool canStart = _canStart(scrollNotification);
      if (canStart) {
        _controller.axisDirection = scrollNotification.metrics.axisDirection;
        _controller.indicatorEdge = _triggerEdge.indicatorEdge;
        setIndicationState(RefreshDraggingState());
      }
      return false;
    }

    if (!canHandleNotification(scrollNotification)) {
      return false;
    }

    switch (scrollNotification.runtimeType) {
      case ScrollUpdateNotification:
        return _handelScrollUpdateNotification(
            scrollNotification as ScrollUpdateNotification);
      case OverscrollNotification:
        return _handelOverscrollNotification(
            scrollNotification as OverscrollNotification);
      case ScrollEndNotification:
        return _handelScrollEndNotification(
            scrollNotification as ScrollEndNotification);
      case UserScrollNotification:
        return _handelUserScrollNotification(
            scrollNotification as UserScrollNotification);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final child = NotificationListener<ScrollNotification>(
      onNotification: _handelScrollIndicatorNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handelOverScrollIndicator,
        child: _child,
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return _builderDelegate.build(context, child, _controller);
      },
    );
  }
}
