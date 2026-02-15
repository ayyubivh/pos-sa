import 'package:flutter/material.dart';
import 'package:pos_final/config.dart';
import 'package:pos_final/helpers/AppTheme.dart';
import 'package:pos_final/helpers/SizeConfig.dart';
import 'package:pos_final/helpers/icons.dart';
import 'package:pos_final/locale/MyLocalizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key, required this.themeData});

  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    // List of actions with icon, label, gradient colors
    final actions = [
      {
        'icon': IconBroken.Paper_Plus,
        'label': 'add_product',
        'gradientColors': [const Color(0xff6C5CE7), const Color(0xff8B7FE8)],
      },
      {
        'icon': IconBroken.Wallet,
        'label': 'expenses',
        'gradientColors': [const Color(0xffFF7675), const Color(0xffFF9A9A)],
      },
      {
        'icon': IconBroken.Setting,
        'label': 'language',
        'gradientColors': [const Color(0xff00B894), const Color(0xff55D4B4)],
      },
      {
        'icon': IconBroken.Buy,
        'label': 'new_sale',
        'gradientColors': [const Color(0xff0984E3), const Color(0xff4DA8F0)],
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MySize.size20!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).translate('quick_actions'),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.titleMedium,
                  fontWeight: 700,
                  letterSpacing: -0.3,
                  fontSize: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: themeData.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${actions.length}',
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodySmall,
                    fontWeight: 700,
                    color: themeData.primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.size20!),
          Row(
            children: actions.map((action) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: action == actions.last ? 0 : MySize.size12!,
                  ),
                  child: _AnimatedActionCard(
                    themeData: themeData,
                    icon: action['icon'] as IconData,
                    label: action['label'] as String,
                    gradientColors: action['gradientColors'] as List<Color>,
                    onTap: () =>
                        _handleActionTap(context, action['label'] as String),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: MySize.size20!),
        ],
      ),
    );
  }

  void _handleActionTap(BuildContext context, String label) {
    if (label == 'language') {
      _showLanguageBottomSheet(context);
    } else if (label == 'expenses') {
      _showFeatureDialog(context, label, 'Expenses feature coming soon');
    } else {
      _showFeatureDialog(context, label, 'Feature coming soon');
    }
  }

  void _showFeatureDialog(BuildContext context, String label, String message) {
    final isDark = themeData.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xff2C2F33) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeData.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: themeData.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context).translate(label),
                style: AppTheme.getTextStyle(
                  themeData.textTheme.titleMedium,
                  fontWeight: 700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTheme.getTextStyle(
            themeData.textTheme.bodyMedium,
            fontWeight: 400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: themeData.primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              AppLocalizations.of(context).translate('close'),
              style: TextStyle(
                color: themeData.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final isDark = themeData.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff23272A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(MySize.size20!),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeData.primaryColor,
                            themeData.primaryColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: themeData.primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.language_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            ).translate('select_language'),
                            style: AppTheme.getTextStyle(
                              themeData.textTheme.titleLarge,
                              fontWeight: 700,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose your preferred language',
                            style: AppTheme.getTextStyle(
                              themeData.textTheme.bodySmall,
                              fontWeight: 400,
                              color: themeData.textTheme.bodySmall?.color
                                  ?.withOpacity(0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Language list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: MySize.size20!,
                    vertical: MySize.size12!,
                  ),
                  itemCount: Config().lang.length,
                  itemBuilder: (context, index) {
                    final lang = Config().lang[index];
                    return _LanguageItem(
                      themeData: themeData,
                      languageCode: lang['languageCode'],
                      languageName: lang['name'],
                      countryCode: lang['countryCode'],
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString(
                          'language_code',
                          lang['languageCode'],
                        );
                        await prefs.setString(
                          'countryCode',
                          lang['countryCode'],
                        );
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedActionCard extends StatefulWidget {
  const _AnimatedActionCard({
    required this.themeData,
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onTap,
  });

  final ThemeData themeData;
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  @override
  State<_AnimatedActionCard> createState() => _AnimatedActionCardState();
}

class _AnimatedActionCardState extends State<_AnimatedActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeData.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xff2C2F33) : Colors.white;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? widget.gradientColors[0].withOpacity(0.2)
                    : (isDark ? Colors.black38 : Colors.grey.withOpacity(0.1)),
                blurRadius: _isPressed ? 8 : 20,
                offset: Offset(0, _isPressed ? 2 : 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gradient overlay at the top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: widget.gradientColors),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: widget.gradientColors[0].withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          AppLocalizations.of(context).translate(widget.label),
                          textAlign: TextAlign.center,
                          style: AppTheme.getTextStyle(
                            widget.themeData.textTheme.bodySmall,
                            fontWeight: 700,
                            fontSize: 11,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageItem extends StatefulWidget {
  const _LanguageItem({
    required this.themeData,
    required this.languageCode,
    required this.languageName,
    required this.countryCode,
    required this.onTap,
  });

  final ThemeData themeData;
  final String languageCode;
  final String languageName;
  final String countryCode;
  final VoidCallback onTap;

  @override
  State<_LanguageItem> createState() => _LanguageItemState();
}

class _LanguageItemState extends State<_LanguageItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeData.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (hovering) => setState(() => _isHovered = hovering),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isHovered
                  ? widget.themeData.primaryColor.withOpacity(0.05)
                  : (isDark
                        ? const Color(0xff2C2F33)
                        : const Color(0xffF8F9FA)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered
                    ? widget.themeData.primaryColor.withOpacity(0.3)
                    : (isDark
                          ? Colors.white10
                          : Colors.black.withOpacity(0.05)),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: _isHovered
                        ? LinearGradient(
                            colors: [
                              widget.themeData.primaryColor,
                              widget.themeData.primaryColor.withOpacity(0.7),
                            ],
                          )
                        : null,
                    color: _isHovered
                        ? null
                        : widget.themeData.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.languageCode.toString().toUpperCase(),
                    style: TextStyle(
                      color: _isHovered
                          ? Colors.white
                          : widget.themeData.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.languageName,
                    style: AppTheme.getTextStyle(
                      widget.themeData.textTheme.bodyLarge,
                      fontWeight: 600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: _isHovered
                      ? widget.themeData.primaryColor
                      : widget.themeData.iconTheme.color?.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
