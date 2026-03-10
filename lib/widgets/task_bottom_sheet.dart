import 'dart:ui';
import 'package:flutter/cupertino.dart';

class TaskBottomSheet extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String actionLabel;
  final VoidCallback onAction;

  const TaskBottomSheet({
    super.key,
    required this.title,
    required this.controller,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final textColor = isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF1C1C1E);
    final accentColor = const Color(0xFF007AFF);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            color: bgColor,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFFFFFFFF).withValues(alpha: 0.2)
                          : const Color(0xFF000000).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Text field
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFFFFFFFF).withValues(alpha: 0.07)
                        : const Color(0xFF000000).withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: CupertinoTextField(
                    controller: controller,
                    autofocus: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    placeholder: 'Task name',
                    placeholderStyle: TextStyle(
                      color: isDark
                          ? const Color(0xFFFFFFFF).withValues(alpha: 0.3)
                          : const Color(0xFF000000).withValues(alpha: 0.3),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const BoxDecoration(color: Color(0x00000000)),
                    onSubmitted: (_) => onAction(),
                  ),
                ),

                const SizedBox(height: 14),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(14),
                    onPressed: onAction,
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
