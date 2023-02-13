import 'package:custom_indicator/custom_refresh_indicator/custom_refresh_indicator_controller.dart';
import 'package:custom_indicator/custom_refresh_indicator/delegates/indicator_builder_delegate.dart';
import 'package:flutter/src/widgets/framework.dart';

class DefaultIndicatorBuilderDelegate extends IndicatorBuilderDelegate {
  @override
  Widget build(BuildContext context, Widget child,
      CustomRefreshIndicatorController controller) {
    return child;
  }
}
