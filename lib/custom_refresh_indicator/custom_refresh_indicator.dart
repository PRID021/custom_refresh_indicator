import 'package:custom_indicator/custom_refresh_indicator/custom_refresh_indicator_controller.dart';
import 'package:custom_indicator/custom_refresh_indicator/custom_refresh_indicator_state.dart';
import 'package:flutter/material.dart';

import 'delegates/indicator_builder_delegate.dart';

class CustomRefreshIndicator extends StatefulWidget {
  final CustomRefreshIndicatorController? controller;
  final bool? isDraggable;
  final Widget child;
  final IndicatorBuilderDelegate? builderDelegate;
  final bool? leadingScrollIndicatorVisible;
  final bool? trailingScrollIndicatorVisible;
  final double? offsetToArmed;
  final double? extendContainerPercentageToArmed;

  CustomRefreshIndicator({
    super.key,
    this.controller,
    this.isDraggable,
    required this.child,
    this.builderDelegate,
    this.leadingScrollIndicatorVisible,
    this.trailingScrollIndicatorVisible,
    this.offsetToArmed,
    this.extendContainerPercentageToArmed,
  }) {
    assert(offsetToArmed == null || extendContainerPercentageToArmed == null,
        "offsetToArmed and extendContainerPercentageToArmed can not be set at the same time");
  }

  @override
  State<CustomRefreshIndicator> createState() => CustomRefreshIndicatorState();
}
