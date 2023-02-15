import 'package:flutter/material.dart';

import '../../custom_refresh_indicator_controller.dart';
import '../../models/custom_indicator_events/indicator_state_change_event.dart';

///
/// Callback for [CustomRefreshIndicatorController] state change.
///

typedef IndicatorStateChangeCallback = void Function(
    IndicatorStateChangeEvent event);

///
///
///
typedef CustomRefreshIndicatorCallback<T> = Future<T> Function();

typedef IndicatorBuilder = Widget Function(
  BuildContext context,
  Widget child,
  CustomRefreshIndicatorController controller,
);
