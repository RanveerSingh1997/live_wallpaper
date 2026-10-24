import 'package:flutter/widgets.dart';

/// Standard layout dimensions, spacings, icon sizes, and border radii for Wallora.
abstract final class AppDimensions {
  // Spacing & Paddings
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // Standard EdgeInsets
  static const EdgeInsets paddingZero = EdgeInsets.zero;
  static const EdgeInsets paddingAll4 = EdgeInsets.all(space4);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(space8);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(space12);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(space16);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(space20);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(space24);

  static const EdgeInsets paddingH16V8 = EdgeInsets.symmetric(horizontal: space16, vertical: space8);
  static const EdgeInsets paddingH16V12 = EdgeInsets.symmetric(horizontal: space16, vertical: space12);
  static const EdgeInsets paddingH20V12 = EdgeInsets.symmetric(horizontal: space20, vertical: space12);
  static const EdgeInsets paddingH24V16 = EdgeInsets.symmetric(horizontal: space24, vertical: space16);

  // Border Radii
  static const double radius6 = 6.0;
  static const double radius8 = 8.0;
  static const double radius10 = 10.0;
  static const double radius12 = 12.0;
  static const double radius14 = 14.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
  static const double radiusFull = 999.0;

  static const BorderRadius borderRadius6 = BorderRadius.all(Radius.circular(radius6));
  static const BorderRadius borderRadius8 = BorderRadius.all(Radius.circular(radius8));
  static const BorderRadius borderRadius12 = BorderRadius.all(Radius.circular(radius12));
  static const BorderRadius borderRadius14 = BorderRadius.all(Radius.circular(radius14));
  static const BorderRadius borderRadius16 = BorderRadius.all(Radius.circular(radius16));
  static const BorderRadius borderRadius20 = BorderRadius.all(Radius.circular(radius20));
  static const BorderRadius borderRadius24 = BorderRadius.all(Radius.circular(radius24));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));

  // Icon Sizes
  static const double iconXs = 14.0;
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 28.0;
  static const double iconXl = 36.0;
  static const double iconXxl = 48.0;

  // Bottom Sheet Defaults
  static const double sheetTopRadius = 24.0;
  static const BorderRadius sheetBorderRadius = BorderRadius.vertical(top: Radius.circular(sheetTopRadius));
  static const double sheetGrabberWidth = 40.0;
  static const double sheetGrabberHeight = 4.0;
}
