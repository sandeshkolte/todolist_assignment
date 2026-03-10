import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TaskTile extends StatefulWidget {
  final Map<String, dynamic> task;
  final bool isDark;
  final Color cardColor;
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final AnimationController animationController;
  final int index;

  const TaskTile({
    required super.key,
    required this.task,
    required this.isDark,
    required this.cardColor,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.isFirst,
    required this.isLast,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.animationController,
    required this.index,
  });

  @override
  State<TaskTile> createState() => TaskTileState();
}

class TaskTileState extends State<TaskTile>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task['is_completed'] == true;

    final delay = widget.index * 0.07;
    final animation = CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(
        delay.clamp(0.0, 1.0),
        (delay + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(animation),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              color: widget.cardColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: widget.onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? widget.accentColor
                            : Colors.transparent,
                        border: Border.all(
                          color: isCompleted
                              ? widget.accentColor
                              : widget.isDark
                              ? const Color(0xFF636366)
                              : const Color(0xFFC7C7CC),
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(
                              CupertinoIcons.checkmark,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: isCompleted
                            ? widget.textSecondary
                            : widget.textPrimary,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: widget.textSecondary,
                        letterSpacing: -0.2,
                      ),
                      child: Text(widget.task['title']),
                    ),
                  ),

                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TileIconButton(
                        icon: CupertinoIcons.pencil,
                        color: widget.accentColor,
                        onTap: widget.onEdit,
                      ),
                      const SizedBox(width: 4),
                      TileIconButton(
                        icon: CupertinoIcons.trash,
                        color: const Color(0xFFFF3B30),
                        onTap: widget.onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Icon Button for Tile
// ─────────────────────────────────────────────────────────────────────────────
class TileIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const TileIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<TileIconButton> createState() => TileIconButtonState();
}

class TileIconButtonState extends State<TileIconButton> {
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
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(widget.icon, color: widget.color, size: 16),
        ),
      ),
    );
  }
}
