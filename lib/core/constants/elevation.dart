import 'package:flutter/material.dart';

class AppElevation {
  static const cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const cardShadowLight = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const cardShadowHover = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  static const bottomBarShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 20,
      offset: Offset(0, -4),
    ),
  ];
}
