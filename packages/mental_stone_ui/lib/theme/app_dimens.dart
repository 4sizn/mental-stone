import 'package:flutter/widgets.dart';

/// Spacing rhythm (8px base) + corner radii. Source: DESIGN.md.
abstract class AppSpacing {
  static const double stackSm = 8;
  static const double gutter = 16;
  static const double stackMd = 16;
  static const double glassPadding = 20;
  static const double marginPage = 24;
  static const double stackLg = 32;
}

abstract class AppRadii {
  static const double sm = 4; // 0.25rem
  static const double md = 8; // 0.5rem (DEFAULT)
  static const double lg = 12; // 0.75rem
  static const double xl = 16; // 1rem
  static const double xxl = 24; // 1.5rem
  static const double full = 9999;

  static const BorderRadius rSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius rMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius rLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius rXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius rXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius rCard = BorderRadius.all(Radius.circular(32));
  static const BorderRadius rPill = BorderRadius.all(Radius.circular(full));
}

/// Glass / elevation constants. Hierarchy comes from backdrop blur,
/// not black shadows (see DESIGN.md › Elevation & Depth).
abstract class AppGlass {
  /// Level 2 — navigation/cards.
  static const double blurCard = 40;
  static const double opacityCard = 0.20;

  /// Level 3 — modals / active stone / floating nav.
  static const double blurModal = 60;
  static const double opacityModal = 0.40;

  /// Inputs.
  static const double blurInput = 20;
  static const double opacityInput = 0.10;

  static const Color edge = Color(0x4DFFFFFF); // white @ 30% — the glass edge
  static const Color edgeStrong = Color(0x80FFFFFF); // white @ 50%
}
