import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../helpers/AppTheme.dart';
import '../helpers/SizeConfig.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  static int themeType = 1;

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  ThemeData themeData = AppTheme.getThemeFromThemeMode(Splash.themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(Splash.themeType);

  String? selectedLanguage;
  bool _isLanguageLoading = true;
  bool _isContinuing = false;

  static const Color _bg = Color(0xFFF8FAFC);
  static const Color _bgSoft = Color(0xFFF1F5F9);
  static const Color _primary = Color(0xFF0F172A);
  static const Color _accent = Color(0xFF0F4C81);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _outline = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    setState(() {
      selectedLanguage =
          prefs.getString('language_code') ?? Config().defaultLanguage;
      _isLanguageLoading = false;
    });
  }

  Future<void> _handleContinue() async {
    if (_isContinuing) {
      return;
    }

    setState(() => _isContinuing = true);

    try {
      await Helper().requestAppPermission();
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) {
        return;
      }

      if (prefs.getInt('userId') != null) {
        Config.userId = prefs.getInt('userId');
        Helper().jobScheduler();
        Navigator.of(context).pushReplacementNamed('/layout');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade600,
          content: const Text('Something went wrong. Please try again.'),
        ),
      );
      setState(() => _isContinuing = false);
    }
  }

  Future<void> _openLanguageSheet() async {
    if (_isLanguageLoading || selectedLanguage == null) {
      return;
    }

    final appLanguage = Provider.of<AppLanguage>(context, listen: false);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: Config().lang.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final locale = Config().lang[index];
              final value = locale['languageCode'] as String;
              final selected = value == selectedLanguage;

              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: _outline),
                ),
                tileColor: selected
                    ? _accent.withValues(alpha: 0.06)
                    : Colors.transparent,
                leading: Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? _accent : _primary,
                ),
                title: Text(
                  locale['name'] as String,
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyLarge,
                    color: _primary,
                    fontWeight: 600,
                  ),
                ),
                onTap: () {
                  appLanguage.changeLanguage(Locale(value), value);
                  setState(() => selectedLanguage = value);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MySize().init(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgSoft, _bg],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 36,
              left: 14,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(96, 96),
                  painter: _CornerGridPainter(
                    color: _accent.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 42,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 470),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                      child: _buildContent(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _outline),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.72),
                _bgSoft.withValues(alpha: 0.4),
              ],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('welcome'),
                    textAlign: TextAlign.center,
                    style: AppTheme.getTextStyle(
                      themeData.textTheme.headlineMedium,
                      color: _primary,
                      fontWeight: 700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Streamlined POS workflow with a refined, distraction-free interface.',
                      textAlign: TextAlign.center,
                      style: AppTheme.getTextStyle(
                        themeData.textTheme.bodyMedium,
                        color: _muted,
                        fontWeight: 500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 196,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 236,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _accent.withValues(alpha: 0.16),
                                _accent.withValues(alpha: 0.02),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Lottie.asset(
                          'assets/lottie/welcome.json',
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        OutlinedButton.icon(
          onPressed: _openLanguageSheet,
          icon: _isLanguageLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.language_rounded, size: 18),
          label: Text(
            _isLanguageLoading
                ? 'Loading...'
                : AppLocalizations.of(context).translate('language'),
            style: AppTheme.getTextStyle(
              themeData.textTheme.bodyLarge,
              color: _primary,
              fontWeight: 600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            side: BorderSide(color: _outline),
            foregroundColor: _primary,
            backgroundColor: _bgSoft.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isContinuing ? null : _handleContinue,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(58),
            elevation: 0,
            backgroundColor: _accent,
            disabledBackgroundColor: _accent.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isContinuing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  AppLocalizations.of(context).translate('login'),
                  style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyLarge,
                    color: Colors.white,
                    fontWeight: 700,
                  ),
                ),
        ),
        if (Config().showRegister) ...[
          const SizedBox(height: 22),
          TextButton(
            onPressed: () async {
              await launchUrl(
                Uri.parse('${Config.baseUrl}/business/register'),
                mode: LaunchMode.externalApplication,
              );
            },
            child: Text(
              AppLocalizations.of(context).translate('register'),
              style: AppTheme.getTextStyle(
                themeData.textTheme.bodyLarge,
                color: _accent,
                fontWeight: 600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CornerGridPainter extends CustomPainter {
  const _CornerGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color
      ..strokeCap = StrokeCap.round;

    final cell = size.width / 4;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if ((i + j).isOdd) {
          continue;
        }
        final rect = Rect.fromLTWH(
          i * cell + 3,
          j * cell + 3,
          cell - 8,
          cell - 8,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          stroke,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CornerGridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
