import 'package:custom_indicator/custom_refresh_indicator/models/custom_indicator_events/refresh_indicator_event.dart';
import 'package:custom_indicator/custom_refresh_indicator/models/refresh_indicator_state/refresh_indicator_state.dart';

class IndicatorStateChangeEvent extends RefreshIndicatorEvent {
  final RefreshIndicatorState currentstate;
  final RefreshIndicatorState nextState;

  IndicatorStateChangeEvent(
      {required this.currentstate, required this.nextState});
}
