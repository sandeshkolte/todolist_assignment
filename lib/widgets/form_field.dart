import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FormField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool isDark;
  final Color? fieldBg;
  final Color textColor;
  final Color iconColor;
  final bool showDivider;
  final Color dividerColor;
  final ValueChanged<String>? onChanged;

  final dynamic trailing;

  const FormField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.isDark,
    this.fieldBg,
    required this.textColor,
    required this.iconColor,
    required this.showDivider,
    required this.dividerColor,
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
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onChanged: onChanged,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.2,
                  ),
                  placeholderStyle: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3),
                    fontSize: 16,
                  ),
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 0.5, color: dividerColor, indent: 46),
      ],
    );
  }
}
