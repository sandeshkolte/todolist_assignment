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
import '../widgets/progress_card.dart';
import '../widgets/ios_fab.dart';
import '../widgets/task_bottom_sheet.dart';
import '../widgets/empty_state.dart';

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
      builder: (_) => TaskBottomSheet(
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
      builder: (_) => TaskBottomSheet(
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
                        final currentNavigator = Navigator.of(context);
                        await Supabase.instance.client.auth.signOut();
                        if (mounted) {
                          currentNavigator.pushReplacement(
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
                child: ProgressCard(
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
                    ? EmptyState(isDark: isDark, textSecondary: textSecondary)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: provider.tasks.length,
                        separatorBuilder: (context, index) => Padding(
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
          child: IOSFab(accentColor: accentColor, onTap: _showAddTaskSheet),
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
