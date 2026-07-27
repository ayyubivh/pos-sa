import 'package:flutter/material.dart';

enum LayoutBreakpoint { compact, medium, expanded }

/// Returns the current layout breakpoint based on window width.
LayoutBreakpoint layoutBreakpoint(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return LayoutBreakpoint.compact;
  if (width < 1024) return LayoutBreakpoint.medium;
  return LayoutBreakpoint.expanded;
}

/// Adapts its child based on the available window width.
/// - compact  < 600px : single-pane (mobile-like)
/// - medium   600-1024px: two-pane
/// - expanded > 1024px  : three-pane
class AdaptiveLayout extends StatelessWidget {
  final Widget? compact;
  final Widget? medium;
  final Widget? expanded;

  const AdaptiveLayout({
    super.key,
    this.compact,
    this.medium,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    final bp = layoutBreakpoint(context);
    switch (bp) {
      case LayoutBreakpoint.expanded:
        return expanded ?? medium ?? compact ?? const SizedBox.shrink();
      case LayoutBreakpoint.medium:
        return medium ?? compact ?? const SizedBox.shrink();
      case LayoutBreakpoint.compact:
        return compact ?? const SizedBox.shrink();
    }
  }
}
