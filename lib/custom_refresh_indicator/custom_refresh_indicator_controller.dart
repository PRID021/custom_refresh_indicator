import 'package:custom_indicator/custom_refresh_indicator/constraint/enums/indicator_edge.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:monkey_lib/utils/pretty_json.dart';
import 'constraint/enums/indicator_side.dart';
import 'models/refresh_indicator_state/index.dart';
import './extension/index.dart';

class CustomRefreshIndicatorController extends ChangeNotifier {
  CustomRefreshIndicatorController(
      {required RefreshIndicatorState initState,
      bool? enable,
      bool? shouldStopDrag}) {
    _state = initState;
    _enable = enable ?? true;
    _shouldStopDrag = shouldStopDrag ?? false;
    _scrollDirection = ScrollDirection.idle;
    _currentEdge = IndicatorEdge.leading;
    _indicatorTriggerEdge = IndicatorEdge.leading;
    _value = 0.0;
    _axisDirection = AxisDirection.down;
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
    if (newState == _state) return;
    Logger.w("RefreshIndicatorState changed from $_state to $newState");
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

  //  define scroll direction when scrollable widget scroll.

  late ScrollDirection _scrollDirection;

  set scrollDirection(ScrollDirection scrollDirection) {
    if (scrollDirection == _scrollDirection) return;
    // Logger.w(
    //     "ScrollDirection changed from $_scrollDirection to $scrollDirection");
    _scrollDirection = scrollDirection;
    notifyListeners();
  }

  ScrollDirection get scrollDirection {
    return _scrollDirection;
  }

  bool get isScrollingForward {
    return _scrollDirection == ScrollDirection.forward;
  }

  bool get isScrollingReverse {
    return _scrollDirection == ScrollDirection.reverse;
  }

  bool get isScrollingIdle {
    return _scrollDirection == ScrollDirection.idle;
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
  // using when decide the trigger  edge fresh action.
  late IndicatorEdge _indicatorTriggerEdge;

  set indicatorTriggerEdge(IndicatorEdge value) {
    _indicatorTriggerEdge = value;
    notifyListeners();
  }

  IndicatorEdge get indicatorTriggerEdge => _indicatorTriggerEdge;

  late bool _shouldStopDrag;

  ///
  /// [shouldStopDrag] used to check if refresh indicator should stop dragging.
  /// only true when state is [RefreshDraggingState] and [RefreshArmingState]
  ///

  bool get shouldStopDrag => _shouldStopDrag;
  set shouldStopDrag(bool value) {
    if (_shouldStopDrag == value) return;
    _shouldStopDrag = value;
    notifyListeners();
  }

  /// The current edge of the scrollable widget.
  late IndicatorEdge? _currentEdge;

  set currentEdge(IndicatorEdge? value) {
    if (value == currentEdge) return;
    // Logger.w("currentEdge change: from $currentEdge to $value");
    _currentEdge = value;
    notifyListeners();
  }

  IndicatorEdge? get currentEdge => _currentEdge;

  // Using to defien the offset of refresh indicator.

  IndicatorSide get side {
    final edge = indicatorTriggerEdge;
    switch (axisDirection) {
      case AxisDirection.up:
        return edge.isLeadingEdge ? IndicatorSide.bottom : IndicatorSide.top;
      case AxisDirection.right:
        return edge.isLeadingEdge ? IndicatorSide.left : IndicatorSide.right;
      case AxisDirection.down:
        return edge.isLeadingEdge ? IndicatorSide.top : IndicatorSide.bottom;
      case AxisDirection.left:
        return edge.isLeadingEdge ? IndicatorSide.right : IndicatorSide.left;
      case null:
        return IndicatorSide.none;
    }
  }
}
