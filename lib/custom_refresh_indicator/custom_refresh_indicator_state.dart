import 'dart:developer';

import 'package:custom_indicator/custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:custom_indicator/custom_refresh_indicator/custom_refresh_indicator_controller.dart';
import 'package:custom_indicator/custom_refresh_indicator/delegates/indicator_builder_delegate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide RefreshIndicatorState;
import 'package:monkey_lib/utils/pretty_json.dart';
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
  late IndicatorEdge _triggerEdge;
  late IndicatorStateChangeCallback? _onStateChange;
  late CustomRefreshIndicatorCallback? _onRefresh;
  late double _dragOffset;
  double? _offsetToArmed;
  late bool _controllerProvided;

  ///
  /// Indicate the indicator currently stopping drag.
  ///
  /// if [true] user can not able to perform any action.
  ///
  late bool _isStopDrag;

  @override
  void initState() {
    super.initState();
    _controllerProvided = widget.controller != null;
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
    _triggerEdge = IndicatorEdge.leading;
    _controller.indicatorTriggerEdge = _triggerEdge;
    _isStopDrag = false;
    _onRefresh = null;
    _dragOffset = 0.0;
    _offsetToArmed = widget.offsetToArmed;
    _onStateChange = widget.onStateChange;
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (!_controllerProvided) {
      _controller.dispose();
    }
    super.dispose();
  }

  bool _handelOverScrollIndicator(
      OverscrollIndicatorNotification notification) {
    if (notification.depth != 0) {
      return false;
    }
    if (notification.leading && !_leadingScrollIndicatorVisible) {
      notification.disallowIndicator();
    }
    if (!notification.leading && !_trailingScrollIndicatorVisible) {
      notification.disallowIndicator();
    }
    return true;
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
      _dragOffset = 0.0;
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
    _controller.indicatorTriggerEdge = _triggerEdge;
  }

  bool _handelScrollUpdateNotification(
      ScrollUpdateNotification scrollNotification) {
    return false;
  }

  double? _calculateDragOffset(double viewportDimension) {
    if (_controller.state.isCancelingState ||
        _controller.state.isRelizingState ||
        _controller.state.isLoadingState) return null;
    final offsetToArmed = _offsetToArmed;
    double newValue = 0.0;
    if (offsetToArmed == null) {
      final double extendPercentageToArmed =
          widget.extendContainerPercentageToArmed ??
              kExtendContainerPercentageToArmed;
      newValue = _dragOffset / (viewportDimension * extendPercentageToArmed);
    }
    if (offsetToArmed != null) {
      newValue = _dragOffset / offsetToArmed;
    }
    return newValue;
  }

  bool _handelOverscrollNotification(
      OverscrollNotification scrollNotification) {
    if (_controller.indicatorTriggerEdge == IndicatorEdge.leading) {
      _dragOffset -= scrollNotification.overscroll;
    }
    if (_controller.indicatorTriggerEdge == IndicatorEdge.trailing) {
      _dragOffset += scrollNotification.overscroll;
    }
    double? newValue =
        _calculateDragOffset(scrollNotification.metrics.viewportDimension);
    if (newValue != null) {
      if (newValue > kInitialValue &&
          newValue < kArmedFromValue &&
          !_controller.state.isDraggingState) {
        setIndicationState(RefreshDraggingState());
      }
      if (newValue >= kArmedFromValue && !_controller.state.isArmingState) {
        setIndicationState(RefreshArmingState());
      }
      _animationController.value =
          newValue.clamp(kInitialValue, kPositionLimit);
    }
    return false;
  }

  bool _handelScrollEndNotification(ScrollEndNotification scrollNotification) {
    if (_controller.state.isArmingState) {
      _startRefreshProgress();
      return false;
    }
    _hideIndicator();
    return false;
  }

  bool _handelUserScrollNotification(
      UserScrollNotification scrollNotification) {
    _controller.scrollDirection = scrollNotification.direction;
    // Logger.w(
    //     "Handle User Scroll Notification: state.isIdleState: ${_controller.state.isIdleState}, _controller.isScrollingForward: ${_controller.isScrollingForward}, _controller.currentEdge: ${_controller.currentEdge}   ");

    ///
    /// When refresh indicator can be trigger by user scrool at the leading of scrollable widget
    ///
    if (_controller.state.isIdleState &&
        _controller.isScrollingForward &&
        _controller.currentEdge == IndicatorEdge.leading) {
      // Logger.w("set state to RefreshDraggingState");
      _controller.state = RefreshDraggingState();

      return false;
    }

    ///
    /// When refresh indicator can be trigger by user scrool at the trailing of scrollable widget
    ///
    if (_controller.state.isIdleState &&
        _controller.isScrollingReverse &&
        _controller.currentEdge == IndicatorEdge.trailing) {
      _controller.state = RefreshDraggingState();

      return false;
    }

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
    _controller.indicatorTriggerEdge = _triggerEdge;
    setIndicationState(RefreshIdleState());
  }

  void checkCurrentEdge(ScrollNotification scrollNotification) {
    if (scrollNotification.metrics.extentBefore == 0) {
      _controller.currentEdge = IndicatorEdge.leading;
      return;
    }
    if (scrollNotification.metrics.extentAfter == 0) {
      _controller.currentEdge = IndicatorEdge.trailing;
      return;
    }
    _controller.currentEdge = IndicatorEdge.none;
  }

  bool _handelScrollStartNotification(
      ScrollStartNotification scrollNotification) {
    if (!_controller.isScrollingIdle) return false;
    return false;
  }

// RefreshIndicator
  bool _handelScrollIndicatorNotification(
      ScrollNotification scrollNotification) {
    if (!notificationPredicate(scrollNotification)) return false;
    checkCurrentEdge(scrollNotification);

    switch (scrollNotification.runtimeType) {
      case ScrollStartNotification:
        return _handelScrollStartNotification(
            scrollNotification as ScrollStartNotification);

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
