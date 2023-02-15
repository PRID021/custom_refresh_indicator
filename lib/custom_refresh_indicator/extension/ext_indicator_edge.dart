import '../constraint/enums/index.dart';

extension ExtIndicatorEdge on IndicatorEdge {
  bool get isLeadingEdge => this == IndicatorEdge.leading;
  bool get isTrailingEdge => this == IndicatorEdge.trailing;
  bool get isNoneEdge => this == IndicatorEdge.none;
}
