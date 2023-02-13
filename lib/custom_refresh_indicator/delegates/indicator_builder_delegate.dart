import 'package:custom_indicator/custom_refresh_indicator/custom_refresh_indicator_controller.dart';
import 'package:flutter/material.dart';

abstract class IndicatorBuilderDelegate {
  Widget build(BuildContext context, Widget child,
      CustomRefreshIndicatorController controller);
}
