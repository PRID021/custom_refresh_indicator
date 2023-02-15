import '../constraint/enums/index.dart';

extension ExtIndicatorSide on IndicatorSide {
  bool get isTop => this == IndicatorSide.top;
  bool get isRight => this == IndicatorSide.right;
  bool get isBottom => this == IndicatorSide.bottom;
  bool get isLeft => this == IndicatorSide.left;
  bool get isNone => this == IndicatorSide.none;
}
