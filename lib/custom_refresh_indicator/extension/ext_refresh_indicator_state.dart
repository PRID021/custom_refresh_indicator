import 'package:custom_indicator/custom_refresh_indicator/models/refresh_indicator_state/index.dart';

extension ExtRefreshIndicatorState on RefreshIndicatorState {
  bool get isIdleState => this is RefreshIdleState;
  bool get isDraggingState => this is RefreshDraggingState;
  bool get isCancelingState => this is RefreshCancelingState;
  bool get isArmingState => this is RefreshArmingState;
  bool get isSettlingState => this is RefreshSettlingState;
  bool get isLoadingState => this is RefreshLoadingState;
  bool get isRelizingState => this is RefreshRelizingState;
}
