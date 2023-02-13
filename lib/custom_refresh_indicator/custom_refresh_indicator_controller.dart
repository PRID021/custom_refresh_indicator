import 'package:custom_indicator/custom_refresh_indicator/constraint/enums/indicator_edge.dart';
import 'package:flutter/widgets.dart';
import 'models/refresh_indicator_state/index.dart';

class CustomRefreshIndicatorController extends ChangeNotifier {
  CustomRefreshIndicatorController(
      {required RefreshIndicatorState initState,
      bool? enable,
      bool? shouldStopDrag}) {
    _state = initState;
    _enable = enable ?? true;
    _shouldStopDrag = shouldStopDrag ?? false;
  }

  /// the value of refresh indicator.
  /// this value is used to calculate the position of refresh indicator.
  ///
  /// this value is between 0 to 1.5
  ///
  late double _value;
  double get value {
    return _value;
  }

  set value(double newValue) {
    assert(
        newValue >= 0 && newValue <= 1.5, 'value should be between 0 to 1.5');
    _value = newValue;
    notifyListeners();
  }

  // variable to store current state of refresh indicator.

  late RefreshIndicatorState _state;

  RefreshIndicatorState get state {
    return _state;
  }

  set state(RefreshIndicatorState newState) {
    _state = newState;
    notifyListeners();
  }

  // variable to check if refresh indicator is availiable.
  late bool _enable;
  bool get enable {
    return _enable;
  }

  set enable(bool value) {
    _enable = value;
    notifyListeners();
  }

  // define axis direction when scrollable widget scroll.

  late AxisDirection? _axisDirection;

  set axisDirection(AxisDirection? axisDirection) {
    _axisDirection = axisDirection;
    notifyListeners();
  }

  AxisDirection? get axisDirection {
    return _axisDirection;
  }

  // define indicator edge when scrollable widget scroll.
  late IndicatorEdge? _indicatorEdge;

  set indicatorEdge(IndicatorEdge? value) {
    _indicatorEdge = value;
    notifyListeners();
  }

  IndicatorEdge? get indicatorEdge => _indicatorEdge;

  ///
  /// Variable to check if refresh indicator should stop drag.
  /// only true when state is [RefreshDraggingState] and [RefreshArmingState]
  ///

  late bool _shouldStopDrag;
  bool get shouldStopDrag => _shouldStopDrag;
  set shouldStopDrag(bool value) {
    if (_shouldStopDrag == value) return;
    _shouldStopDrag = value;
    notifyListeners();
  }

  void stopDrag() {
    if (state is RefreshDraggingState || state is RefreshArmingState) {
      shouldStopDrag = true;
      return;
    }
    throw StateError(
        "Can't stop drag when state is not RefreshIdleState or RefreshArmingState");
  }
}
