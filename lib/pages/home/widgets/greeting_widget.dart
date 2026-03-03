import 'package:flutter/material.dart';
import 'package:pos_final/locale/MyLocalizations.dart';

class GreetingWidget extends StatefulWidget implements PreferredSizeWidget {
  const GreetingWidget({
    super.key,
    required this.themeData,
    required this.userName,
  });

  final ThemeData themeData;
  final String userName;
  static const double _kTabHeight = 80.0;

  @override
  State<GreetingWidget> createState() => _GreetingWidgetState();

  @override
  Size get preferredSize => Size.fromHeight(_kTabHeight);
}

class _GreetingWidgetState extends State<GreetingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F0FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF0F4C81),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${AppLocalizations.of(context).translate('welcome')} ${widget.userName}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: widget.themeData.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
