import 'dart:ui';
import 'package:flutter/cupertino.dart' hide FormField;
import 'package:flutter/material.dart' hide FormField;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorial_2026/providers/theme_provider.dart';

import '../dashboard/dashboard_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/form_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/top_bar_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark
        ? const Color(0xFF1C1C1E)
        : Colors.white.withValues(alpha: 0.9);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final textSecondary = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF6E6E73);
    final accentColor = const Color(0xFF007AFF);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top bar ───────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TopBarButton(
                            icon: isDark
                                ? CupertinoIcons.sun_max_fill
                                : CupertinoIcons.moon_fill,
                            isDark: isDark,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              themeProvider.toggleTheme();
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Hero icon ─────────────────────────────────
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.checkmark_circle_fill,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Heading ───────────────────────────────────
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.8,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to continue to TaskHub',
                        style: TextStyle(
                          fontSize: 15,
                          color: textSecondary,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.2,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Form Card ─────────────────────────────────
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white.withValues(alpha: 0.7),
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Email field
                                FormField(
                                  controller: emailController,
                                  placeholder: 'Email',
                                  icon: CupertinoIcons.mail,
                                  keyboardType: TextInputType.emailAddress,
                                  isDark: isDark,
                                  fieldBg: Colors.transparent,
                                  textColor: textPrimary,
                                  iconColor: textSecondary,
                                  showDivider: true,
                                  dividerColor: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.07),
                                ),

                                // Password field
                                FormField(
                                  controller: passwordController,
                                  placeholder: 'Password',
                                  icon: CupertinoIcons.lock,
                                  obscureText: _obscurePassword,
                                  isDark: isDark,
                                  fieldBg: Colors.transparent,
                                  textColor: textPrimary,
                                  iconColor: textSecondary,
                                  showDivider: false,
                                  dividerColor: Colors.transparent,
                                  trailing: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      );
                                    },
                                    child: Icon(
                                      _obscurePassword
                                          ? CupertinoIcons.eye
                                          : CupertinoIcons.eye_slash,
                                      size: 18,
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Login Button ──────────────────────────────
                      auth.loading
                          ? Center(
                              child: CupertinoActivityIndicator(
                                radius: 13,
                                color: accentColor,
                              ),
                            )
                          : PrimaryButton(
                              label: 'Sign In',
                              accentColor: accentColor,
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                FocusScope.of(context).unfocus();
                                try {
                                  await auth.login(
                                    emailController.text.trim(),
                                    passwordController.text,
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) => const DashboardScreen(),
                                    ),
                                  );
                                } catch (e) {
                                  HapticFeedback.mediumImpact();
                                  String message;
                                  if (e is AuthException &&
                                      e.message.contains(
                                        'Email not confirmed',
                                      )) {
                                    message =
                                        'Please verify your email first by clicking the link sent to your inbox.';
                                  } else {
                                    message = e.toString();
                                  }
                                  _showErrorSheet(
                                    context,
                                    message,
                                    isDark,
                                    textPrimary,
                                    textSecondary,
                                  );
                                }
                              },
                            ),

                      const SizedBox(height: 20),

                      // ── Divider ───────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.08),
                              thickness: 0.5,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.08),
                              thickness: 0.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Create Account ────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => SignupScreen(),
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Create one',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSheet(
    BuildContext context,
    String message,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.exclamationmark_circle,
                color: Color(0xFFFF3B30),
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Sign In Failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: textSecondary, height: 1.4),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(14),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
