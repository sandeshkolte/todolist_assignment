import 'dart:ui';
import 'package:flutter/cupertino.dart' hide FormField;
import 'package:flutter/material.dart' hide FormField;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorial_2026/providers/theme_provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/form_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/top_bar_button.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Password strength: 0=empty, 1=weak, 2=medium, 3=strong
  int _passwordStrength(String pw) {
    if (pw.isEmpty) return 0;
    int score = 0;
    if (pw.length >= 8) score++;
    if (pw.contains(RegExp(r'[A-Z]')) && pw.contains(RegExp(r'[a-z]'))) score++;
    if (pw.contains(RegExp(r'[0-9]')) && pw.contains(RegExp(r'[!@#\$&*~]')))
      score++;
    return score;
  }

  Color _strengthColor(int strength) {
    switch (strength) {
      case 1:
        return const Color(0xFFFF3B30);
      case 2:
        return const Color(0xFFFF9500);
      case 3:
        return const Color(0xFF34C759);
      default:
        return Colors.transparent;
    }
  }

  String _strengthLabel(int strength) {
    switch (strength) {
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Strong';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark
        ? const Color(0xFF1C1C1E)
        : Colors.white.withOpacity(0.9);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final textSecondary = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF6E6E73);
    final accentColor = const Color(0xFF007AFF);
    final separatorColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.07);

    final pwStrength = _passwordStrength(passwordController.text);

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
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button
                            TopBarButton(
                              icon: CupertinoIcons.chevron_left,
                              isDark: isDark,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(context);
                              },
                            ),
                            // Theme toggle
                            TopBarButton(
                              icon: isDark
                                  ? CupertinoIcons.sun_max_fill
                                  : CupertinoIcons.moon_fill,
                              isDark: isDark,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                themeProvider.toggleTheme();
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Hero icon ─────────────────────────────────
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF007AFF).withOpacity(0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.person_badge_plus,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Heading ───────────────────────────────────
                      Text(
                        'Create account',
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
                        'Start organizing your tasks today',
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
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.white.withOpacity(0.7),
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Email
                                FormField(
                                  controller: emailController,
                                  placeholder: 'Email',
                                  icon: CupertinoIcons.mail,
                                  keyboardType: TextInputType.emailAddress,
                                  isDark: isDark,
                                  textColor: textPrimary,
                                  iconColor: textSecondary,
                                  showDivider: true,
                                  dividerColor: separatorColor,
                                ),

                                // Password
                                FormField(
                                  controller: passwordController,
                                  placeholder: 'Password',
                                  icon: CupertinoIcons.lock,
                                  obscureText: _obscurePassword,
                                  isDark: isDark,
                                  textColor: textPrimary,
                                  iconColor: textSecondary,
                                  showDivider: true,
                                  dividerColor: separatorColor,
                                  onChanged: (_) => setState(() {}),
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

                                // Confirm password
                                FormField(
                                  controller: confirmPasswordController,
                                  placeholder: 'Confirm Password',
                                  icon: CupertinoIcons.lock_shield,
                                  obscureText: _obscureConfirm,
                                  isDark: isDark,
                                  textColor: textPrimary,
                                  iconColor: textSecondary,
                                  showDivider: false,
                                  dividerColor: Colors.transparent,
                                  onChanged: (_) => setState(() {}),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(
                                        () =>
                                            _obscureConfirm = !_obscureConfirm,
                                      );
                                    },
                                    child: Icon(
                                      _obscureConfirm
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

                      // ── Password strength ─────────────────────────
                      if (passwordController.text.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ...List.generate(3, (i) {
                              final filled = i < pwStrength;
                              return Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 4,
                                  margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                                  decoration: BoxDecoration(
                                    color: filled
                                        ? _strengthColor(pwStrength)
                                        : (isDark
                                              ? Colors.white.withOpacity(0.1)
                                              : Colors.black.withOpacity(0.08)),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(width: 10),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _strengthLabel(pwStrength),
                                key: ValueKey(pwStrength),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _strengthColor(pwStrength),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // ── Password match indicator ──────────────────
                      if (confirmPasswordController.text.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              passwordController.text ==
                                      confirmPasswordController.text
                                  ? CupertinoIcons.checkmark_circle_fill
                                  : CupertinoIcons.xmark_circle_fill,
                              size: 14,
                              color:
                                  passwordController.text ==
                                      confirmPasswordController.text
                                  ? const Color(0xFF34C759)
                                  : const Color(0xFFFF3B30),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              passwordController.text ==
                                      confirmPasswordController.text
                                  ? 'Passwords match'
                                  : 'Passwords do not match',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    passwordController.text ==
                                        confirmPasswordController.text
                                    ? const Color(0xFF34C759)
                                    : const Color(0xFFFF3B30),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Signup Button ─────────────────────────────
                      auth.loading
                          ? Center(
                              child: CupertinoActivityIndicator(
                                radius: 13,
                                color: accentColor,
                              ),
                            )
                          : PrimaryButton(
                              label: 'Create Account',
                              accentColor: accentColor,
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                FocusScope.of(context).unfocus();

                                if (passwordController.text !=
                                    confirmPasswordController.text) {
                                  _showSheet(
                                    context,
                                    isSuccess: false,
                                    title: 'Passwords Don\'t Match',
                                    message:
                                        'Please make sure both password fields are identical.',
                                    isDark: isDark,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                  );
                                  return;
                                }

                                // Check if email is already registered
                                try {
                                  await auth.login(
                                    emailController.text.trim(),
                                    passwordController.text,
                                  );
                                  // If login succeeds, email is already registered
                                  HapticFeedback.mediumImpact();
                                  _showSheet(
                                    context,
                                    isSuccess: false,
                                    title: 'Email Already Registered',
                                    message:
                                        'This email is already registered. Please login instead.',
                                    isDark: isDark,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                  );
                                  return;
                                } catch (e) {
                                  if (!(e is AuthException &&
                                      (e.message.contains(
                                            'Email not confirmed',
                                          ) ||
                                          e.message.contains(
                                            'Invalid login credentials',
                                          )))) {
                                    // Other error, show it
                                    HapticFeedback.mediumImpact();
                                    _showSheet(
                                      context,
                                      isSuccess: false,
                                      title: 'Error',
                                      message: e.toString(),
                                      isDark: isDark,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                    );
                                    return;
                                  }
                                  // If Email not confirmed or Invalid credentials, proceed with signup
                                }

                                try {
                                  await auth.signup(
                                    emailController.text.trim(),
                                    passwordController.text,
                                  );
                                  await _showSheet(
                                    context,
                                    isSuccess: true,
                                    title: 'Check your inbox',
                                    message:
                                        'We sent a verification link to ${emailController.text.trim()}. Tap it to activate your account.',
                                    isDark: isDark,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) => LoginScreen(),
                                    ),
                                  );
                                } catch (e) {
                                  HapticFeedback.mediumImpact();
                                  _showSheet(
                                    context,
                                    isSuccess: false,
                                    title: 'Sign Up Failed',
                                    message: e.toString(),
                                    isDark: isDark,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                  );
                                }
                              },
                            ),

                      const SizedBox(height: 20),

                      // ── Divider + Login link ──────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.08),
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
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.08),
                              thickness: 0.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.pushReplacement(
                              context,
                              CupertinoPageRoute(builder: (_) => LoginScreen()),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign in',
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

  Future<void> _showSheet(
    BuildContext context, {
    required bool isSuccess,
    required String title,
    required String message,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) async {
    final iconColor = isSuccess
        ? const Color(0xFF34C759)
        : const Color(0xFFFF3B30);
    final icon = isSuccess
        ? CupertinoIcons.checkmark_circle_fill
        : CupertinoIcons.exclamationmark_circle;

    await showCupertinoModalPopup(
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
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
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
              style: TextStyle(fontSize: 14, color: textSecondary, height: 1.5),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(14),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Got it',
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

// ─────────────────────────────────────────────────────────────────────────────
// Form Field
// ─────────────────────────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool isDark;
  final Color textColor;
  final Color iconColor;
  final bool showDivider;
  final Color dividerColor;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;

  const _FormField({
    required this.controller,
    required this.placeholder,
    required this.icon,
    required this.isDark,
    required this.textColor,
    required this.iconColor,
    required this.showDivider,
    required this.dividerColor,
    required this.obscureText,
    required this.keyboardType,
    this.trailing,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoTextField(
                  controller: controller,
                  placeholder: placeholder,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  onChanged: onChanged,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.2,
                  ),
                  placeholderStyle: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.3),
                    fontSize: 16,
                  ),
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 0.5, color: dividerColor, indent: 46),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary Button
// ─────────────────────────────────────────────────────────────────────────────
class _PrimaryButton extends StatefulWidget {
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: widget.accentColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Bar Button
// ─────────────────────────────────────────────────────────────────────────────
class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _TopBarButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
        ),
      ),
    );
  }
}
