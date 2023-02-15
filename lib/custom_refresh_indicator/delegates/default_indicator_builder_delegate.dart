import 'package:custom_indicator/custom_refresh_indicator/custom_refresh_indicator_controller.dart';
import 'package:custom_indicator/custom_refresh_indicator/delegates/indicator_builder_delegate.dart';
import 'package:flutter/material.dart';

class DefaultIndicatorBuilderDelegate extends IndicatorBuilderDelegate {
  @override
  Widget build(BuildContext context, Widget child,
      CustomRefreshIndicatorController controller) {
    return Stack(
      children: [
        child,
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
              ],
            ),
          )),
        ),
      ],
    );
  }
}
