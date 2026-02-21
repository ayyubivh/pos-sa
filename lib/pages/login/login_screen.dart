import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pos_final/locale/MyLocalizations.dart';

import 'view_model_manger/login_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const Color _bg = Color(0xFFF8FAFC);
  static const Color _bgSoft = Color(0xFFF1F5F9);
  static const Color _primaryText = Color(0xFF0F172A);
  static const Color _mutedText = Color(0xFF6B7280);
  static const Color _accent = Color(0xFF0F4C81);
  static const Color _outline = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginFailed) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(
                      context,
                    ).translate('invalid_credentials'),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.red.shade700,
                ),
              );
          } else if (state is LoginSuccessfully) {
            LoginCubit.get(context).navigateToHome(context);
          }
        },
        builder: (context, state) {
          var cubit = LoginCubit.get(context);
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: _bg,
            body: SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_bgSoft, _bg],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Form(
                        key: cubit.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 96,
                              child: Lottie.asset(
                                'assets/lottie/welcome.json',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'ASAHL POS',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: _primaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context).translate('login'),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _mutedText,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              enabled: !cubit.isLoading,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: _primaryText,
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  context,
                                ).translate('username'),
                                labelStyle: theme.textTheme.bodyMedium
                                    ?.copyWith(color: _mutedText),
                                hintText: AppLocalizations.of(
                                  context,
                                ).translate('username'),
                                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                  color: _mutedText,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: _outline),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: _outline),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: _accent),
                                ),
                                suffixIcon: Icon(
                                  MdiIcons.faceMan,
                                  color: _mutedText,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              controller: cubit.usernameController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  ).translate('please_enter_username');
                                }
                                return null;
                              },
                              autofocus: true,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              enabled: !cubit.isLoading,
                              keyboardType: TextInputType.visiblePassword,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: _primaryText,
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  context,
                                ).translate('password'),
                                labelStyle: theme.textTheme.bodyMedium
                                    ?.copyWith(color: _mutedText),
                                hintText: AppLocalizations.of(
                                  context,
                                ).translate('password'),
                                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                  color: _mutedText,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: _outline),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: _outline),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: _accent),
                                ),
                                suffixIcon: IconButton(
                                  tooltip: AppLocalizations.of(
                                    context,
                                  ).translate('password'),
                                  color: _accent,
                                  icon: Icon(cubit.passwordIcon),
                                  onPressed: cubit.isLoading
                                      ? null
                                      : () {
                                          cubit.passwordVisible =
                                              !cubit.passwordVisible;
                                        },
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              obscureText: !cubit.passwordVisible,
                              controller: cubit.passwordController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  ).translate('please_enter_password');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: cubit.isLoading
                                    ? null
                                    : () async {
                                        await cubit.checkOnLogin(context);
                                      },
                                style: ButtonStyle(
                                  animationDuration: const Duration(
                                    milliseconds: 220,
                                  ),
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith(
                                        (states) =>
                                            states.contains(
                                              WidgetState.disabled,
                                            )
                                            ? _accent.withValues(alpha: 0.7)
                                            : _accent,
                                      ),
                                  foregroundColor: const WidgetStatePropertyAll(
                                    Colors.white,
                                  ),
                                  elevation: const WidgetStatePropertyAll(0),
                                  overlayColor: WidgetStateProperty.resolveWith(
                                    (states) =>
                                        states.contains(WidgetState.pressed)
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : null,
                                  ),
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  child: cubit.isLoading
                                      ? const SizedBox(
                                          key: ValueKey('loading'),
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          key: const ValueKey('text'),
                                          AppLocalizations.of(
                                            context,
                                          ).translate('login'),
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).translate('no_account'),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _mutedText,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: cubit.isLoading
                                    ? null
                                    : () async {
                                        await cubit.register();
                                      },
                                style: ButtonStyle(
                                  animationDuration: const Duration(
                                    milliseconds: 220,
                                  ),
                                  backgroundColor: const WidgetStatePropertyAll(
                                    _bg,
                                  ),
                                  side: WidgetStateProperty.resolveWith(
                                    (states) => BorderSide(
                                      color:
                                          states.contains(WidgetState.focused)
                                          ? _accent
                                          : _outline,
                                    ),
                                  ),
                                  overlayColor: WidgetStateProperty.resolveWith(
                                    (states) =>
                                        states.contains(WidgetState.pressed)
                                        ? _accent.withValues(alpha: 0.06)
                                        : null,
                                  ),
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('register'),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: _primaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
