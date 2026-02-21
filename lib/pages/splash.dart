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
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: _buildLanguageAction(),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _buildContent(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _selectedLanguageCode() {
    final code = selectedLanguage;
    if (code == null || code.isEmpty) {
      return '--';
    }
    return code.toUpperCase();
  }

  Widget _buildLanguageAction() {
    return OutlinedButton(
      onPressed: _openLanguageSheet,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 40),
        side: BorderSide(color: _outline),
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        foregroundColor: _primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _isLanguageLoading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.language_rounded, size: 16, color: _muted),
          const SizedBox(width: 8),
          Text(
            _isLanguageLoading ? 'Loading...' : _selectedLanguageCode(),
            style: AppTheme.getTextStyle(
              themeData.textTheme.bodySmall,
              color: _primary,
              fontWeight: 600,
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: _muted),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/welcome.json',
              height: 280,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context).translate('welcome'),
              textAlign: TextAlign.center,
              style: AppTheme.getTextStyle(
                themeData.textTheme.displaySmall,
                color: _primary,
                fontWeight: 800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Streamlined POS workflow with a refined,\ndistraction-free interface.',
                textAlign: TextAlign.center,
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyLarge,
                  color: _muted,
                  fontWeight: 500,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isContinuing ? null : _handleContinue,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
              elevation: 0,
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _accent.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: _isContinuing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate('login'),
                        style: AppTheme.getTextStyle(
                          themeData.textTheme.titleLarge,
                          color: Colors.white,
                          fontWeight: 700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
          ),
        ),
        if (Config().showRegister) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () async {
              await launchUrl(
                Uri.parse('${Config.baseUrl}/business/register'),
                mode: LaunchMode.externalApplication,
              );
            },
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
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
