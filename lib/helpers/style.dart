import 'package:flutter/material.dart';
import '../constants.dart';

class StyleColors {
  mainColor(double opacity) {
    return kDefaultColor.withOpacity(opacity);
  }

  secondColor(double opacity) {
    return const Color(0xFFF0323C).withOpacity(opacity);
  }

  accentColor(double opacity) {
    return kSurfaceColor.withOpacity(opacity);
  }
}
