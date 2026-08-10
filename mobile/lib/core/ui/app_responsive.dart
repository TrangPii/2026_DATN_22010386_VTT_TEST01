import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Responsive sizing helpers for Smart Service mobile UI.
///
/// Design reference width is 390dp. Spacing and media scale gently with
/// viewport width and are clamped to avoid oversized UI on tablets or tiny UI
/// on compact phones. Typography is intentionally scaled less aggressively.
class AppResponsive {
  AppResponsive._();

  static const double designWidth = 390;
  static const double minScale = 0.88;
  static const double maxScale = 1.14;

  static double scaleOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width / designWidth).clamp(minScale, maxScale);
  }

  static double spacing(BuildContext context, double value) {
    return value * scaleOf(context);
  }

  static double radius(BuildContext context, double value) {
    return value * scaleOf(context);
  }

  static double icon(BuildContext context, double value) {
    return value * scaleOf(context);
  }

  static double font(BuildContext context, double value) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = (width / designWidth).clamp(0.94, 1.08);
    return value * scale;
  }

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 600) return 32;
    if (width >= 430) return 24;
    return spacing(context, 20);
  }

  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return math.min(width, 720);
  }

  static EdgeInsets pagePadding(
    BuildContext context, {
    double top = 20,
    double bottom = 24,
  }) {
    return EdgeInsets.fromLTRB(
      horizontalPadding(context),
      spacing(context, top),
      horizontalPadding(context),
      spacing(context, bottom),
    );
  }
}

extension ResponsiveNum on num {
  double rw(BuildContext context) => AppResponsive.spacing(context, toDouble());
  double rr(BuildContext context) => AppResponsive.radius(context, toDouble());
  double ri(BuildContext context) => AppResponsive.icon(context, toDouble());
  double rf(BuildContext context) => AppResponsive.font(context, toDouble());
}
