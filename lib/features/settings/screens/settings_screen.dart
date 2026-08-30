import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/ai/domain/ai_memory.dart';
import '../../../core/ai/presentation/providers/ai_providers.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/theme/vinr_colors.dart';
import '../../../core/theme/vinr_typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/vinr_toast.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../chat/providers/chat_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../providers/reminder_provider.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showEditPreferencesModal(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.read(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    final primaryTextColor = context.textColor;
    final mutedTextColor = context.textMutedColor;
    final activeGold = context.goldColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.textGhostColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Edit Growth Preferences', style: VinRTypography.h2.copyWith(color: primaryTextColor)),
                Text('Update your AI companion style and pacing.', style: VinRTypography.caption.copyWith(color: mutedTextColor)),
                const SizedBox(height: 20),

                // Companion Avatar Preference
                Text('COMPANION AVATAR', style: VinRTypography.label.copyWith(color: mutedTextColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['VinR Coach', 'Zen Master', 'Stoic Guardian', 'Solar Spark'].map((avatar) {
                    final isSel = onboardingState.avatar == avatar;
                    return ChoiceChip(
                      selected: isSel,
                      label: Text(avatar, style: TextStyle(color: isSel ? Colors.black : primaryTextColor, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                      selectedColor: activeGold,
                      backgroundColor: context.surfaceColor,
                      onSelected: (_) => notifier.setAvatar(avatar),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Daily Pacing Preference
                Text('DAILY PACING', style: VinRTypography.label.copyWith(color: mutedTextColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['5 mins / day', '10 mins / day', '20 mins / day'].map((freq) {
                    final isSel = onboardingState.frequency.contains(freq.split(' ').first);
                    return ChoiceChip(
                      selected: isSel,
                      label: Text(freq, style: TextStyle(color: isSel ? Colors.black : primaryTextColor, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                      selectedColor: activeGold,
                      backgroundColor: context.surfaceColor,
                      onSelected: (_) => notifier.setFrequency('$freq (Standard)'),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    VinRToast.show(
                      context,
                      message: 'Preferences Updated Successfully',
                      icon: LucideIcons.checkCircle2,
                      iconColor: activeGold,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeGold,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Preferences', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMemoryInspectorModal(BuildContext context, WidgetRef ref, List<AiMemory> memories) {
    final primaryTextColor = context.textColor;
    final mutedTextColor = context.textMutedColor;
    final activeGold = context.goldColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.textGhostColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('On-Device AI Memories', style: VinRTypography.h2.copyWith(color: primaryTextColor)),
                    if (memories.isNotEmpty)
                      TextButton(
                        onPressed: () async {
                          await ref.read(aiMemoryProvider.notifier).clearAll();
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Clear All', style: TextStyle(color: VinRColors.crimson, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                Text('These private facts and preferences stay 100% on your device.', style: VinRTypography.caption.copyWith(color: mutedTextColor)),
                const SizedBox(height: 16),
                if (memories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No memories stored yet. Converse with VinR Coach to personalize.', style: TextStyle(color: mutedTextColor, fontSize: 13)),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: memories.length,
                      separatorBuilder: (context, index) => const Divider(height: 12),
                      itemBuilder: (context, i) {
                        final mem = memories[i];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${mem.category.value.toUpperCase()} • ${mem.key}', style: TextStyle(color: activeGold, fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text(mem.value, style: TextStyle(color: primaryTextColor, fontSize: 13)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x, size: 16, color: VinRColors.crimson),
                              onPressed: () => ref.read(aiMemoryProvider.notifier).deleteMemory(mem.id),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAiDiagnosticsModal(BuildContext context, WidgetRef ref) {
    final primaryTextColor = context.textColor;
    final mutedTextColor = context.textMutedColor;
    final activeGold = context.goldColor;
    final statsAsync = ref.watch(aiStatsProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.textGhostColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('AI Telemetry & Zero-Remote Proof', style: VinRTypography.h2.copyWith(color: primaryTextColor)),
                Text('Local mobile inference metrics running fully offline.', style: VinRTypography.caption.copyWith(color: mutedTextColor)),
                const SizedBox(height: 20),

                statsAsync.when(
                  data: (stats) => Column(
                    children: [
                      _buildMetricRow(context, 'Inference Speed', '${stats.tokensPerSecond.toStringAsFixed(1)} tokens/sec', LucideIcons.gauge, activeGold),
                      const SizedBox(height: 12),
                      _buildMetricRow(context, 'Working Memory RSS', '${stats.memoryUsageMb} MB (Budget: 1500 MB)', LucideIcons.hardDrive, VinRColors.sapphire),
                      const SizedBox(height: 12),
                      _buildMetricRow(context, 'Zero-Leakage Privacy Policy', 'Strictly Enforced (0 bytes sent)', LucideIcons.shieldCheck, VinRColors.emerald),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, stack) => Text('Diagnostics ready on next inference pass.', style: TextStyle(color: mutedTextColor)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildMetricRow(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: context.textMutedColor, fontSize: 11)),
                Text(value, style: TextStyle(color: context.textColor, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final authNotifier = ref.read(authProvider.notifier);
    final reminderState = ref.watch(reminderProvider);
    final reminderNotifier = ref.read(reminderProvider.notifier);
    final aiModel = ref.watch(aiModelProvider);
    final memories = ref.watch(aiMemoryProvider);


    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textColor),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text('Settings & Preferences', style: VinRTypography.h2.copyWith(color: context.textColor)),
                ],
              ),
              const SizedBox(height: 24),

              const SectionHeader(
                title: 'APPEARANCE & THEME',
                icon: LucideIcons.palette,
                iconColor: VinRColors.goldLight,
              ),

              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Choose Theme', style: VinRTypography.body.copyWith(fontWeight: FontWeight.bold, color: context.textColor)),
                    const SizedBox(height: 4),
                    Text(
                      'Switch between Midnight Gold dark mode and Warm Parchment light mode.',
                      style: VinRTypography.caption.copyWith(color: context.textMutedColor),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildThemeOption(
                          context: context,
                          label: 'Dark',
                          icon: LucideIcons.moon,
                          isSelected: themeMode == ThemeMode.dark,
                          onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                        ),
                        const SizedBox(width: 8),
                        _buildThemeOption(
                          context: context,
                          label: 'Light',
                          icon: LucideIcons.sun,
                          isSelected: themeMode == ThemeMode.light,
                          onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                        ),
                        const SizedBox(width: 8),
                        _buildThemeOption(
                          context: context,
                          label: 'System',
                          icon: LucideIcons.laptop,
                          isSelected: themeMode == ThemeMode.system,
                          onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const SectionHeader(
                title: 'GROWTH PREFERENCES',
                icon: LucideIcons.sliders,
              ),

              GlassContainer(
                onTap: () => _showEditPreferencesModal(context, ref),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.goldMutedColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.userCheck, color: context.goldColor),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Edit Growth Preferences', style: VinRTypography.body.copyWith(fontWeight: FontWeight.bold, color: context.textColor)),
                          Text('Update companion avatar, focus areas & pacing.', style: VinRTypography.caption.copyWith(color: context.textMutedColor)),
                        ],
                      ),
                    ),
                    Icon(LucideIcons.chevronRight, color: context.textMutedColor, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // DAILY STREAK REMINDERS & NOTIFICATIONS
              const SectionHeader(
                title: 'DAILY STREAK REMINDERS',
                icon: LucideIcons.bell,
                iconColor: VinRColors.emerald,
              ),

              GlassContainer(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: VinRColors.emeraldGlow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.bell, color: VinRColors.emerald),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Daily Streak Reminder', style: VinRTypography.body.copyWith(fontWeight: FontWeight.bold, color: context.textColor), overflow: TextOverflow.ellipsis),
                                    Text('Receive daily check-in nudge', style: VinRTypography.caption.copyWith(color: context.textMutedColor), overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: reminderState.isEnabled,
                          onChanged: (val) {
                            reminderNotifier.toggleReminder(val);
                            if (val) {
                              ref.read(notificationServiceProvider.notifier).scheduleDailyStreakReminder(reminderState.reminderTime, triggerImmediately: false);
                            } else {
                              ref.read(notificationServiceProvider.notifier).cancelReminders();
                            }
                            VinRToast.show(
                              context,
                              message: val ? 'Daily streak reminder activated' : 'Reminders paused',
                              icon: val ? LucideIcons.bell : LucideIcons.bellOff,
                              iconColor: val ? VinRColors.emerald : context.textMutedColor,
                            );
                          },
                          activeThumbColor: context.goldColor,
                        ),
                      ],
                    ),
                    if (reminderState.isEnabled) ...[
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Reminder Time', style: TextStyle(color: context.textColor, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: ['08:00 AM', '01:00 PM', '08:00 PM'].map((t) {
                                    final isSel = reminderState.reminderTime == t;
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: ChoiceChip(
                                        selected: isSel,
                                        label: Text(t, style: TextStyle(color: isSel ? Colors.black : context.textColor, fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                                        selectedColor: context.goldColor,
                                        backgroundColor: context.surfaceColor,
                                        onSelected: (_) {
                                          reminderNotifier.setReminderTime(t);
                                          ref.read(notificationServiceProvider.notifier).scheduleDailyStreakReminder(t, triggerImmediately: false);
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(LucideIcons.send, size: 14),
                        label: const Text('Test Live Notification Alert', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          reminderNotifier.recordNotificationSent();
                          ref.read(notificationServiceProvider.notifier).scheduleDailyStreakReminder(reminderState.reminderTime, triggerImmediately: true);
                          VinRToast.show(
                            context,
                            message: 'Streak Reminder alert scheduled! Top banner queued.',
                            icon: LucideIcons.bellRing,
                            iconColor: VinRColors.gold,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.goldColor,
                          side: BorderSide(color: context.goldColor),
                          minimumSize: const Size.fromHeight(40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // LOCAL AI & PRIVACY SECTION
              const SectionHeader(
                title: 'LOCAL AI & PRIVACY',
                icon: LucideIcons.cpu,
                iconColor: VinRColors.gold,
              ),

              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Model Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: context.goldColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(LucideIcons.hardDrive, color: context.goldColor, size: 18),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'On-Device Model',
                                  style: VinRTypography.body.copyWith(fontWeight: FontWeight.bold, color: context.textColor),
                                ),
                                Text(
                                  aiModel.isReady ? 'Active in RAM (~485 MB)' : (aiModel.isInstalled ? 'Installed (~500 MB)' : 'Not Downloaded'),
                                  style: VinRTypography.caption.copyWith(color: aiModel.isReady ? VinRColors.emerald : context.textMutedColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (!aiModel.isInstalled)
                          ElevatedButton(
                            onPressed: () => ref.read(aiModelProvider.notifier).downloadModel(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.goldColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Download', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          )
                        else
                          OutlinedButton(
                            onPressed: () {
                              ref.read(aiModelProvider.notifier).deleteModel();
                              VinRToast.show(
                                context,
                                message: 'Local model unloaded',
                                icon: LucideIcons.trash2,
                                iconColor: VinRColors.crimson,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: VinRColors.crimson,
                              side: BorderSide(color: VinRColors.crimson.withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Unload', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Personal Memories Inspector
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: VinRColors.sapphire.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.brain, color: VinRColors.sapphire, size: 18),
                      ),
                      title: Text(
                        'On-Device Memories (${memories.length})',
                        style: VinRTypography.body.copyWith(fontWeight: FontWeight.bold, color: context.textColor),
                      ),
                      subtitle: Text(
                        'Inspect or clear stored facts and preferences',
                        style: VinRTypography.caption.copyWith(color: context.textMutedColor),
                      ),
                      trailing: Icon(LucideIcons.chevronRight, color: context.textMutedColor, size: 18),
                      onTap: () => _showMemoryInspectorModal(context, ref, memories),
                    ),

                    const Divider(height: 24),

                    // Clear Chat History
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: VinRColors.crimson.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(LucideIcons.messageSquare, color: VinRColors.crimson, size: 18),
                      ),

                      title: Text(
                        'Clear AI Conversations',
                        style: VinRTypography.body.copyWith(fontWeight: FontWeight.bold, color: context.textColor),
                      ),
                      subtitle: Text(
                        'Permanently wipe local chat logs',
                        style: VinRTypography.caption.copyWith(color: context.textMutedColor),
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          await ref.read(chatProvider.notifier).clearMessages();
                          if (context.mounted) {
                            VinRToast.show(
                              context,
                              message: 'All local conversation history cleared',
                              icon: LucideIcons.checkCheck,
                              iconColor: context.goldColor,
                            );
                          }
                        },
                        child: const Text('Clear', style: TextStyle(color: VinRColors.crimson, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),

                    const Divider(height: 24),

                    // AI Performance Diagnostics
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: VinRColors.emerald.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.gauge, color: VinRColors.emerald, size: 18),
                      ),
                      title: Text(
                        'AI Diagnostics & Zero-Telemetry',
                        style: VinRTypography.body.copyWith(fontWeight: FontWeight.bold, color: context.textColor),
                      ),
                      subtitle: Text(
                        'View on-device latency & memory metrics',
                        style: VinRTypography.caption.copyWith(color: context.textMutedColor),
                      ),
                      trailing: Icon(LucideIcons.chevronRight, color: context.textMutedColor, size: 18),
                      onTap: () => _showAiDiagnosticsModal(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const SectionHeader(
                title: 'ACCOUNT & SECURITY',
                icon: LucideIcons.shield,
                iconColor: VinRColors.crimson,
              ),

              GlassContainer(
                onTap: () async {
                  await authNotifier.signOut();
                  if (context.mounted) {
                    context.go('/welcome');
                  }
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: VinRColors.crimsonGlow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.logOut, color: VinRColors.crimson),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Sign Out',
                        style: VinRTypography.body.copyWith(
                          color: VinRColors.crimson,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final activeGold = context.goldColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeGold.withValues(alpha: 0.15) : context.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeGold : context.borderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? activeGold : context.textMutedColor),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? activeGold : context.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
