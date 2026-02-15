import 'package:flutter/material.dart';
import 'package:pos_final/helpers/AppTheme.dart';
import 'package:pos_final/helpers/SizeConfig.dart';

class Block extends StatelessWidget {
  const Block({
    super.key,
    this.backgroundColor,
    this.subject,
    this.image,
    this.amount,
    required this.themeData,
  });

  final Color? backgroundColor;
  final String? subject, image, amount;
  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    // Determine if we are in dark mode to adjust card color
    final isDark = themeData.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xff2C2F33) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff2D3142);
    // Use the passed background color as an accent for the icon background
    final accentColor = backgroundColor ?? themeData.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(MySize.size20!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              '$image',
              color: accentColor, // Tint the image to match the accent
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    amount ?? '',
                    style: AppTheme.getTextStyle(
                      themeData.textTheme.headlineSmall,
                      fontWeight: 700,
                      color: textColor,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subject ?? '',
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyMedium,
                    fontWeight: 500,
                    color: textColor.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
