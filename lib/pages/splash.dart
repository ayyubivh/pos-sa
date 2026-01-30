import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../constants.dart';
import '../helpers/SizeConfig.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';

// ignore: must_be_immutable
class Splash extends StatefulWidget {
  static int themeType = 1;

  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    changeLanguage();
    super.initState();
  }

  var selectedLanguage;
  void changeLanguage() async {
    var prefs = await SharedPreferences.getInstance();
    selectedLanguage =
        prefs.getString('language_code') ?? Config().defaultLanguage;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    MySize().init(context);

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA), // Soft off-white background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.0,
              ), // 8-point grid (3x8)
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30), // 8-point grid (7.5x8)
                  // Logo/Animation Container
                  Container(
                    width: 220,
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          kDefaultColor.withOpacity(0.3),
                          kDefaultColor.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        // Outer glow
                        BoxShadow(
                          color: kDefaultColor.withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: Offset(0, 8),
                        ),
                        // Inner subtle shadow
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 10,
                          offset: Offset(-2, -2),
                        ),
                      ],
                    ),
                    child: Lottie.asset(
                      'assets/lottie/welcome.json',
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: 40), // 8-point grid (5x8)
                  // Welcome Text
                  Text(
                    AppLocalizations.of(context).translate('welcome'),
                    style: gfonts.GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.8,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 8), // 8-point grid (1x8)
                  // Subtitle
                  Text(
                    'Point of Sale System',
                    style: gfonts.GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 56), // 8-point grid (7x8)
                  // Primary Login Button
                  _buildPrimaryButton(
                    context: context,
                    label: AppLocalizations.of(context).translate('login'),
                    onPressed: () async {
                      await Helper().requestAppPermission();
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      if (prefs.getInt('userId') != null) {
                        Config.userId = prefs.getInt('userId');
                        Config.userId = Config.userId;
                        Helper().jobScheduler();
                        Navigator.of(context).pushReplacementNamed('/layout');
                      } else
                        Navigator.of(context).pushReplacementNamed('/login');
                    },
                  ),

                  SizedBox(height: 16), // 8-point grid (2x8)
                  // Secondary Language Button
                  _buildSecondaryButton(
                    context: context,
                    label: AppLocalizations.of(context).translate('language'),
                    onPressed: () {
                      _showLanguageDialog(context);
                    },
                  ),

                  SizedBox(height: 32), // 8-point grid (4x8)
                  // Register Link
                  Visibility(
                    visible: Config().showRegister,
                    child: TextButton(
                      onPressed: () async {
                        await launchUrl(
                          Uri.parse('${Config.baseUrl}/business/register'),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        minimumSize: Size(0, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate('register'),
                            style: gfonts.GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: kDefaultColor,
                              letterSpacing: 0,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: kDefaultColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 60), // 8-point grid (7.5x8)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 400),
      height: 56, // 8-point grid (7x8)
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kDefaultColor, // Primary accent color
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: Text(
          label,
          style: gfonts.GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 400),
      height: 56, // 8-point grid (7x8)
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: kDefaultColor,
          backgroundColor: Colors.white,
          elevation: 0,
          side: BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: Text(
          label,
          style: gfonts.GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog Title
              Text(
                AppLocalizations.of(context).translate('language'),
                style: gfonts.GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),

              SizedBox(height: 8),

              // Subtitle
              Text(
                'Select your preferred language',
                style: gfonts.GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),

              SizedBox(height: 24),

              // Language Selector
              changeAppLanguage(),

              SizedBox(height: 24),

              // Close Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: kDefaultColor,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'Close',
                    style: gfonts.GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  Widget changeAppLanguage() {
    var appLanguage = Provider.of<AppLanguage>(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE5E7EB), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
          isExpanded: true,
          onChanged: (String? newValue) {
            appLanguage.changeLanguage(Locale(newValue!), newValue);
            selectedLanguage = newValue;
            Navigator.pop(context);
          },
          value: selectedLanguage,
          items: Config().lang.map<DropdownMenuItem<String>>((Map locale) {
            return DropdownMenuItem<String>(
              value: locale['languageCode'],
              child: Text(
                locale['name'],
                style: gfonts.GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
