import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;
import 'package:lottie/lottie.dart';
import 'package:pos_final/constants.dart';
import 'package:pos_final/locale/MyLocalizations.dart';
import 'package:pos_final/helpers/otherHelpers.dart';

import 'view_model_manger/login_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginFailed) {
            LoginCubit.get(context).isLoading = false;

            // Check if there's internet connectivity
            Helper().checkConnectivity().then((hasInternet) {
              if (!hasInternet) {
                Fluttertoast.showToast(
                  fontSize: 14,
                  backgroundColor: Color(0xFFEF4444),
                  textColor: Colors.white,
                  msg: 'No internet connection',
                );
              } else {
                Fluttertoast.showToast(
                  fontSize: 14,
                  backgroundColor: Color(0xFFEF4444),
                  textColor: Colors.white,
                  msg: AppLocalizations.of(
                    context,
                  ).translate('invalid_credentials'),
                );
              }
            });
          } else if (state is LoginSuccessfully) {
            LoginCubit.get(context).navigateToHome(context);
          }
        },
        builder: (context, state) {
          var cubit = LoginCubit.get(context);
          return Scaffold(
            backgroundColor: Color(0xFFF8F9FA), // Soft off-white background
            body: SafeArea(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                  ), // 8-point grid (3x8)
                  child: Form(
                    key: cubit.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 90), // 8-point grid (5x8)
                        // Logo/Animation
                        SizedBox(height: 24), // 8-point grid (3x8)
                        // App Title
                        Text(
                          'ASAHL POS',
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
                          'Sign in to your account',
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
                          controller: cubit.usernameController,
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
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: kDefaultColor,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xFFEF4444),
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
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
                          controller: cubit.passwordController,
                          obscureText: !cubit.passwordVisible,
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
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                cubit.passwordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Color(0xFF6B7280),
                                size: 20,
                              ),
                              onPressed: () {
                                cubit.passwordVisible = !cubit.passwordVisible;
                              },
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: kDefaultColor,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xFFEF4444),
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
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
                            onPressed: cubit.isLoading
                                ? null
                                : () async {
                                    await cubit.checkOnLogin(context);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kDefaultColor,
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
                            child: cubit.isLoading
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
                                    AppLocalizations.of(
                                      context,
                                    ).translate('login'),
                                    style: gfonts.GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 32), // 8-point grid (4x8)
                        // Divider with text
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Color(0xFFE5E7EB),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or',
                                style: gfonts.GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Color(0xFFE5E7EB),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 32), // 8-point grid (4x8)
                        // Register Section
                        Center(
                          child: Column(
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('no_account'),
                                style: gfonts.GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              SizedBox(height: 16), // 8-point grid (2x8)
                              SizedBox(
                                width: double.infinity,
                                height: 56, // 8-point grid (7x8)
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await cubit.register();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: kDefaultColor,
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                    side: BorderSide(
                                      color: Color(0xFFE5E7EB),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).translate('register'),
                                    style: gfonts.GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
        },
      ),
    );
  }
}
