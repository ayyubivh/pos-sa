import 'package:flutter/material.dart';
import 'package:pos_final/helpers/AppTheme.dart';
import 'package:pos_final/locale/MyLocalizations.dart';

class GreetingWidget extends StatefulWidget {
  const GreetingWidget({
    super.key,
    required this.themeData,
    required this.userName,
  });

  final ThemeData themeData;
  final String userName;

  @override
  State<GreetingWidget> createState() => _GreetingWidgetState();
}

class _GreetingWidgetState extends State<GreetingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('welcome'),
            style: AppTheme.getTextStyle(
              widget.themeData.textTheme.bodyLarge,
              color: widget.themeData.textTheme.bodyLarge?.color?.withOpacity(
                0.6,
              ),
              fontWeight: 400,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.userName,
            style: AppTheme.getTextStyle(
              widget.themeData.textTheme.displaySmall,
              fontWeight: 700,
              fontSize: 32,
              color: widget.themeData.textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
