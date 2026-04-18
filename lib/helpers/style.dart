import 'package:flutter/material.dart';
import '../constants.dart';

class StyleColors {
  Color mainColor(double opacity) {
    return kDefaultColor.withOpacity(opacity);
  }

  Color secondColor(double opacity) {
    return const Color(0xFFF0323C).withOpacity(opacity);
  }

  Color accentColor(double opacity) {
    return kSurfaceColor.withOpacity(opacity);
  }
}
