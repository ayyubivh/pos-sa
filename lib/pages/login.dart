import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apis/api.dart';
import '../apis/system.dart';
import '../apis/user.dart';
import '../config.dart';
import '../helpers/AppTheme.dart';
import '../helpers/SizeConfig.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../models/contact_model.dart';
import '../models/database.dart';
import '../models/sellDatabase.dart';
import '../models/system.dart';
import '../models/variations.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);

  final _formKey = GlobalKey<FormState>();
  Timer? timer;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA), // Soft off-white background
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0), // 8-point grid
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40), // 8-point grid (5x8)
                  // Logo/Animation
                  Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: Lottie.asset(
                      'assets/lottie/welcome.json',
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: 32), // 8-point grid (4x8)
                  // Title
                  Text(
                    AppLocalizations.of(context).translate('login'),
                    style: gfonts.GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 8), // 8-point grid (1x8)
                  // Subtitle
                  Text(
                    'Enter your credentials to continue',
                    style: gfonts.GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 40), // 8-point grid (5x8)
                  // Username Field Label
                  Text(
                    AppLocalizations.of(context).translate('username'),
                    style: gfonts.GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                      letterSpacing: 0,
                    ),
                  ),

                  SizedBox(height: 8), // 8-point grid (1x8)
                  // Username Field
                  TextFormField(
                    controller: usernameController,
                    autofocus: false,
                    style: gfonts.GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: 0,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your username',
                      hintStyle: gfonts.GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 0,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFF2F4664),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFFEF4444),
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFFEF4444),
                          width: 2,
                        ),
                      ),
                      errorStyle: gfonts.GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        ).translate('please_enter_username');
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 24), // 8-point grid (3x8)
                  // Password Field Label
                  Text(
                    AppLocalizations.of(context).translate('password'),
                    style: gfonts.GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                      letterSpacing: 0,
                    ),
                  ),

                  SizedBox(height: 8), // 8-point grid (1x8)
                  // Password Field
                  TextFormField(
                    controller: passwordController,
                    obscureText: !_passwordVisible,
                    keyboardType: TextInputType.visiblePassword,
                    style: gfonts.GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: 0,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: gfonts.GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 0,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Color(0xFF6B7280),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFF2F4664),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFFEF4444),
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFFEF4444),
                          width: 2,
                        ),
                      ),
                      errorStyle: gfonts.GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        ).translate('please_enter_password');
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 40), // 8-point grid (5x8)
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56, // 8-point grid (7x8)
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _handleLogin(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2F4664),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Color(0xFFE5E7EB),
                        disabledForegroundColor: Color(0xFF9CA3AF),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context).translate('login'),
                              style: gfonts.GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 40), // 8-point grid (5x8)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (await Helper().checkConnectivity()) {
      if (_formKey.currentState!.validate() && !isLoading) {
        setState(() {
          isLoading = true;
        });

        Map? loginResponse = await Api().login(
          usernameController.text,
          passwordController.text,
        );

        if (loginResponse!['success']) {
          // Schedule job for syncing callLogs
          Helper().jobScheduler();
          // Get current logged in user details and save it
          showLoadingDialogue();
          await loadAllData(loginResponse, context);
          Navigator.of(context).pop();
          // Take to home page
          Navigator.of(context).pushNamed('/layout');
        } else {
          setState(() {
            isLoading = false;
          });

          Fluttertoast.showToast(
            fontSize: 14,
            backgroundColor: Color(0xFFEF4444),
            textColor: Colors.white,
            msg: AppLocalizations.of(context).translate('invalid_credentials'),
          );
        }
      }
    } else {
      Fluttertoast.showToast(
        fontSize: 14,
        backgroundColor: Color(0xFFEF4444),
        textColor: Colors.white,
        msg: 'No internet connection',
      );
    }
  }

  Future<void> loadAllData(loginResponse, context) async {
    timer = Timer.periodic(Duration(seconds: 30), (Timer t) {
      (context != null)
          ? Fluttertoast.showToast(
              msg: AppLocalizations.of(
                context,
              ).translate('It_may_take_some_more_time_to_load'),
            )
          : t.cancel();
      t.cancel();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map loggedInUser = await User().get(loginResponse['access_token']);

    Config.userId = loggedInUser['id'];
    // Saving userId in disk
    prefs.setInt('userId', Config.userId!);
    DbProvider().initializeDatabase(loggedInUser['id']);

    String? lastSync = await System().getProductLastSync();
    final date2 = DateTime.now();

    // Delete system table before saving data
    System().empty();
    // Delete contact table
    Contact().emptyContact();
    // Save user details
    await System().insertUserDetails(loggedInUser);
    // Insert token
    System().insertToken(loginResponse['access_token']);
    // Save system data
    await SystemApi().store();
    await System().insertProductLastSyncDateTimeNow();
    // Check previous userId
    if (prefs.getInt('prevUserId') == null ||
        prefs.getInt('prevUserId') != prefs.getInt('userId')) {
      SellDatabase().deleteSellTables();
      await Variations().refresh();
    } else {
      // Save variations if last sync is greater than 10hrs
      if (lastSync == null ||
          (date2.difference(DateTime.parse(lastSync)).inHours > 10)) {
        if (await Helper().checkConnectivity()) {
          await Variations().refresh();
          await System().insertProductLastSyncDateTimeNow();
          SellDatabase().deleteSellTables();
        }
      }
    }
    // Take to home page
    Navigator.of(context).pushReplacementNamed('/layout');
    Navigator.of(context).pop();
  }

  Future<void> showLoadingDialogue() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie/loading.json',
                  width: 150,
                  height: 150,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: gfonts.GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
