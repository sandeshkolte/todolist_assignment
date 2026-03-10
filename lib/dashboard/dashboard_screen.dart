import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/top_bar_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final provider = context.read<TaskProvider>();
    Future.microtask(() async {
      await provider.fetchTasks();
      if (mounted) {
        _listController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _showAddTaskSheet() {
    HapticFeedback.lightImpact();
    TextEditingController controller = TextEditingController();

    showCupertinoModalPopup(
      context: context,
      builder: (_) => _TaskBottomSheet(
        title: 'New Task',
        controller: controller,
        actionLabel: 'Add',
        onAction: () {
          if (controller.text.trim().isNotEmpty) {
            context.read<TaskProvider>().addTask(controller.text.trim());
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showEditTaskSheet(int id, String currentTitle) {
    HapticFeedback.lightImpact();
    TextEditingController controller = TextEditingController(
      text: currentTitle,
    );

    showCupertinoModalPopup(
      context: context,
      builder: (_) => _TaskBottomSheet(
        title: 'Edit Task',
        controller: controller,
        actionLabel: 'Save',
        onAction: () {
          if (controller.text.trim().isNotEmpty) {
            context.read<TaskProvider>().updateTask(id, controller.text.trim());
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _confirmDelete(int id) {
    HapticFeedback.mediumImpact();
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete Task'),
        content: const Text('This task will be permanently removed.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              context.read<TaskProvider>().deleteTask(id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final completedCount = provider.tasks
        .where((t) => t['is_completed'] == true)
        .length;
    final totalCount = provider.tasks.length;

    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark
        ? const Color(0xFF1C1C1E)
        : Colors.white.withValues(alpha: 0.85);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final textSecondary = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF6E6E73);
    final accentColor = const Color(0xFF007AFF);
    final separatorColor = isDark
        ? const Color(0xFF38383A)
        : const Color(0xFFE5E5EA);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Bar ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'My Tasks',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                              letterSpacing: -0.8,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
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
                    const SizedBox(width: 8),
                    // Logout
                    TopBarButton(
                      icon: CupertinoIcons.square_arrow_right,
                      isDark: isDark,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await Supabase.instance.client.auth.signOut();
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(builder: (_) => LoginScreen()),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Progress Card ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ProgressCard(
                  completed: completedCount,
                  total: totalCount,
                  isDark: isDark,
                  cardColor: cardColor,
                  accentColor: accentColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // ── Section Header ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      totalCount == 0
                          ? 'No Tasks'
                          : '$totalCount ${totalCount == 1 ? 'Task' : 'Tasks'}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Task List ─────────────────────────────────────────────
              Expanded(
                child: provider.loading
                    ? Center(
                        child: CupertinoActivityIndicator(
                          radius: 14,
                          color: accentColor,
                        ),
                      )
                    : provider.tasks.isEmpty
                    ? _EmptyState(isDark: isDark, textSecondary: textSecondary)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: provider.tasks.length,
                        separatorBuilder: (_, _) => Padding(
                          padding: const EdgeInsets.only(left: 68),
                          child: Divider(
                            height: 1,
                            thickness: 0.5,
                            color: separatorColor,
                          ),
                        ),
                        itemBuilder: (context, index) {
                          final task = provider.tasks[index];
                          return TaskTile(
                            key: ValueKey(task['id']),
                            task: task,
                            isDark: isDark,
                            cardColor: cardColor,
                            accentColor: accentColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            isFirst: index == 0,
                            isLast: index == provider.tasks.length - 1,
                            onToggle: () {
                              HapticFeedback.selectionClick();
                              provider.toggleTask(
                                task['id'],
                                task['is_completed'],
                              );
                            },
                            onEdit: () =>
                                _showEditTaskSheet(task['id'], task['title']),
                            onDelete: () => _confirmDelete(task['id']),
                            animationController: _listController,
                            index: index,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        // ── FAB ───────────────────────────────────────────────────────
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _IOSFab(accentColor: accentColor, onTap: _showAddTaskSheet),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤';
    return 'Good evening 🌙';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress Card
// ─────────────────────────────────────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final bool isDark;
  final Color cardColor;
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;

  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.isDark,
    required this.cardColor,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    final remaining = total - completed;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.6),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        total == 0
                            ? 'Nothing here yet'
                            : remaining == 0
                            ? 'All done! 🎉'
                            : '$remaining remaining',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$completed of $total completed',
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: Text(
                        total == 0 ? '–' : '${(progress * 100).round()}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Bar Button
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// iOS FAB
// ─────────────────────────────────────────────────────────────────────────────
class _IOSFab extends StatefulWidget {
  final Color accentColor;
  final VoidCallback onTap;

  const _IOSFab({required this.accentColor, required this.onTap});

  @override
  State<_IOSFab> createState() => _IOSFabState();
}

class _IOSFabState extends State<_IOSFab> {
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
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: widget.accentColor,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(CupertinoIcons.add, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'New Task',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task Bottom Sheet (iOS-style modal)
// ─────────────────────────────────────────────────────────────────────────────
class _TaskBottomSheet extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String actionLabel;
  final VoidCallback onAction;

  const _TaskBottomSheet({
    required this.title,
    required this.controller,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
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
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.15),
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
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.black.withValues(alpha: 0.04),
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
                          ? Colors.white.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.3),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const BoxDecoration(color: Colors.transparent),
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
                        color: Colors.white,
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

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final Color textSecondary;

  const _EmptyState({required this.isDark, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.checkmark_circle,
            size: 56,
            color: textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textSecondary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "New Task" to get started',
            style: TextStyle(
              fontSize: 14,
              color: textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
