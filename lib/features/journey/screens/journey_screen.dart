import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/theme/vinr_colors.dart';
import '../../../core/theme/vinr_typography.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/celebration_confetti.dart';
import '../../../core/widgets/vinr_path_node.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/tactile_3d_button.dart';
import '../../../core/widgets/vinr_toast.dart';
import '../../streak/providers/streak_provider.dart';

class DayRoadmapItem {
  final int dayNumber;
  final String title;
  final String category;
  final String actionPrompt;
  final IconData icon;

  DayRoadmapItem({
    required this.dayNumber,
    required this.title,
    required this.category,
    required this.actionPrompt,
    required this.icon,
  });
}

class JourneyScreen extends ConsumerStatefulWidget {
  const JourneyScreen({super.key});

  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends ConsumerState<JourneyScreen> {
  static final List<DayRoadmapItem> _roadmap = [
    DayRoadmapItem(dayNumber: 1, title: 'Intention & Reset', category: 'Mindset Foundation', actionPrompt: 'Set your core 21-day goal and log your first gratitude entry.', icon: LucideIcons.compass),
    DayRoadmapItem(dayNumber: 2, title: 'Gratitude Anchor', category: 'Positive Framing', actionPrompt: 'Write 3 things that brought light to your day.', icon: LucideIcons.smile),
    DayRoadmapItem(dayNumber: 3, title: '4-7-8 Calm Breath', category: 'Nervous System', actionPrompt: 'Complete a 2-minute rhythmic breathing session.', icon: LucideIcons.wind),
    DayRoadmapItem(dayNumber: 4, title: 'Stoic Perception', category: 'Emotional Control', actionPrompt: 'Separate what is in your control from what is not.', icon: LucideIcons.sparkles),
    DayRoadmapItem(dayNumber: 5, title: 'Body Alignment', category: 'Physical Synergy', actionPrompt: 'Do 10 minutes of bodyweight movement or stretching.', icon: LucideIcons.activity),
    DayRoadmapItem(dayNumber: 6, title: 'Digital Detox', category: 'Focus & Clarity', actionPrompt: 'Take 30 minutes of undisturbed quiet reflection.', icon: LucideIcons.shieldCheck),
    DayRoadmapItem(dayNumber: 7, title: 'Week 1 Warrior', category: 'Milestone Celebration', actionPrompt: 'Reflect on 7 days of growth. Unlock your 7-Day Warrior trophy!', icon: LucideIcons.award),
    DayRoadmapItem(dayNumber: 8, title: 'Somatic Grounding', category: 'Stress Relief', actionPrompt: 'Use the 5-4-3-2-1 sensory technique to anchor present moment.', icon: LucideIcons.heartPulse),
    DayRoadmapItem(dayNumber: 9, title: 'Reframing Obstacles', category: 'Resilience', actionPrompt: 'Turn one recent challenge into a learning opportunity.', icon: LucideIcons.target),
    DayRoadmapItem(dayNumber: 10, title: 'Mid-Journey Energy', category: 'Habit Reinforcement', actionPrompt: 'Double down on your daily consistency routine.', icon: LucideIcons.zap),
    DayRoadmapItem(dayNumber: 11, title: 'Empathetic Connection', category: 'Relationships', actionPrompt: 'Express genuine appreciation to a mentor or friend.', icon: LucideIcons.heartHandshake),
    DayRoadmapItem(dayNumber: 12, title: 'Strength Exercise', category: 'Physical Power', actionPrompt: 'Complete a strength workout set to build energy.', icon: LucideIcons.dumbbell),
    DayRoadmapItem(dayNumber: 13, title: 'Mindful Soundscape', category: 'Rest & Recovery', actionPrompt: 'Listen to a soothing ambient wind-down track before sleep.', icon: LucideIcons.volume2),
    DayRoadmapItem(dayNumber: 14, title: '14-Day Fortitude', category: 'Milestone Celebration', actionPrompt: '2 full weeks completed! You are building deep mental toughness.', icon: LucideIcons.trophy),
    DayRoadmapItem(dayNumber: 15, title: 'Self-Compassion', category: 'Inner Peace', actionPrompt: 'Acknowledge your progress without harsh self-criticism.', icon: LucideIcons.heart),
    DayRoadmapItem(dayNumber: 16, title: 'Core Focus Flow', category: 'Productivity', actionPrompt: 'Execute 45 minutes of deep focus work without distraction.', icon: LucideIcons.flame),
    DayRoadmapItem(dayNumber: 17, title: 'Postural Reset', category: 'Physical Health', actionPrompt: 'Perform spine & neck mobility movements during work breaks.', icon: LucideIcons.userCheck),
    DayRoadmapItem(dayNumber: 18, title: 'Gratitude Reflection', category: 'Perspective Shift', actionPrompt: 'Log 3 personal wins achieved over the past 2 weeks.', icon: LucideIcons.penTool),
    DayRoadmapItem(dayNumber: 19, title: 'Evening Wind-Down', category: 'Sleep Quality', actionPrompt: 'Disconnect 1 hour before bed for restorative sleep.', icon: LucideIcons.moon),
    DayRoadmapItem(dayNumber: 20, title: 'Unshakable Mindset', category: 'Mastery Preparation', actionPrompt: 'Prepare your personal manifesto for lifelong consistency.', icon: LucideIcons.shield),
    DayRoadmapItem(dayNumber: 21, title: '21-Day VinR Winner', category: 'Identity Mastery', actionPrompt: 'CONGRATULATIONS! You have completed the 21-Day Transformation!', icon: LucideIcons.crown),
  ];

  void _openQuestBottomSheet(BuildContext context, DayRoadmapItem item, int totalDaysCompleted, bool isCompletedToday) {
    final isCompleted = item.dayNumber <= totalDaysCompleted;
    final isCurrent = item.dayNumber == totalDaysCompleted + 1 && !isCompletedToday;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final bg = isLight ? Colors.white : VinRColors.elevated;
        final primaryTextColor = isLight ? const Color(0xFF1A1208) : VinRColors.textPrimary;
        final mutedTextColor = isLight ? const Color(0xFF5C5446) : VinRColors.textMuted;
        final activeGold = isLight ? const Color(0xFFB8832A) : VinRColors.gold;

        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isLight ? const Color(0x22000000) : VinRColors.borderGold,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle Bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: mutedTextColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Quest Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? VinRColors.emerald.withValues(alpha: 0.15)
                            : (isCurrent ? activeGold.withValues(alpha: 0.18) : Colors.grey.withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'DAY ${item.dayNumber} QUEST',
                        style: TextStyle(
                          color: isCompleted
                              ? VinRColors.emerald
                              : (isCurrent ? activeGold : mutedTextColor),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: VinRColors.xpGem.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(LucideIcons.zap, size: 13, color: VinRColors.xpGem),
                          SizedBox(width: 4),
                          Text(
                            '+50 XP',
                            style: TextStyle(
                              color: VinRColors.xpGem,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Quest Title & Category
                Text(
                  item.title,
                  style: VinRTypography.h1.copyWith(fontSize: 22, color: primaryTextColor),
                ),
                const SizedBox(height: 4),
                Text(
                  item.category,
                  style: VinRTypography.bodySm.copyWith(color: mutedTextColor),
                ),
                const SizedBox(height: 16),

                // Prompt Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFF7F5F0) : VinRColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isLight ? const Color(0x15000000) : VinRColors.border,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: activeGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.icon, color: activeGold, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.actionPrompt,
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Button
                if (isCompleted)
                  Tactile3DButton(
                    text: 'Quest Completed ✨',
                    variant: TactileButtonVariant.emerald,
                    icon: LucideIcons.checkCheck,
                    onPressed: () => Navigator.pop(modalContext),
                  )
                else if (isCurrent)
                  Tactile3DButton(
                    text: 'Complete Day ${item.dayNumber} Quest →',
                    variant: TactileButtonVariant.gold,
                    badgeText: '+50 XP',
                    onPressed: () {
                      Navigator.pop(modalContext);
                      ref.read(streakProvider.notifier).markDayComplete();
                      CelebrationOverlay.show(context);
                      VinRToast.show(
                        context,
                        message: 'Day ${item.dayNumber} Complete! Streak updated (+50 XP)',
                        icon: LucideIcons.flame,
                        iconColor: VinRColors.gold,
                      );
                    },
                  )
                else
                  Tactile3DButton(
                    text: 'Locked — Complete Day $totalDaysCompleted First',
                    variant: TactileButtonVariant.surface,
                    icon: LucideIcons.lock,
                    onPressed: () => Navigator.pop(modalContext),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // Winding horizontal offset pattern for VinR quest trail (-0.6 to +0.6)
  double _getHorizontalOffset(int index) {
    // Smooth sinusoidal snake wave
    return sin(index * 0.95) * 0.45;
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakProvider);
    final isLight = context.isLight;
    final primaryTextColor = context.textColor;
    final mutedTextColor = context.textMutedColor;
    final activeGold = context.goldColor;

    return CelebrationOverlay(
      child: Scaffold(
        body: AmbientBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 140.0),
              children: [
                // Header Banner
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '21-Day Habit Quest',
                            style: VinRTypography.h1.copyWith(fontSize: 26, color: primaryTextColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Follow the trail to complete your identity reset.',
                            style: VinRTypography.bodySm.copyWith(color: mutedTextColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: activeGold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: activeGold.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.award, size: 14, color: activeGold),
                          const SizedBox(width: 5),
                          Text(
                            'Day ${streak.totalDaysCompleted}/21',
                            style: VinRTypography.label.copyWith(color: activeGold, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Today Status Nudge Card
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: streak.isCompletedToday
                              ? VinRColors.emerald.withValues(alpha: 0.18)
                              : activeGold.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          streak.isCompletedToday ? LucideIcons.checkCheck : LucideIcons.flame,
                          color: streak.isCompletedToday ? VinRColors.emerald : activeGold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              streak.isCompletedToday
                                  ? "TODAY'S STEP COMPLETE!"
                                  : "YOUR NEXT MILESTONE AWAITS",
                              style: TextStyle(
                                color: streak.isCompletedToday ? VinRColors.emerald : activeGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              streak.isCompletedToday
                                  ? "Momentum secured. Rest well or explore other tools."
                                  : "Tap the active stepping stone on the trail to continue.",
                              style: TextStyle(color: mutedTextColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Winding VinR Quest Path Map
                Center(
                  child: Column(
                    children: List.generate(_roadmap.length, (index) {
                      final item = _roadmap[index];
                      final dayNum = item.dayNumber;
                      final isCompleted = dayNum <= streak.totalDaysCompleted;
                      final isCurrent = dayNum == streak.totalDaysCompleted + 1 && !streak.isCompletedToday;
                      final isMilestone = dayNum == 7 || dayNum == 14 || dayNum == 21;

                      final PathNodeState nodeState = isCompleted
                          ? PathNodeState.completed
                          : (isCurrent ? PathNodeState.active : PathNodeState.locked);

                      final xOffset = _getHorizontalOffset(index);

                      return Column(
                        children: [
                          // Path connecting trail dots
                          if (index > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (dotIndex) {
                                  final dotCompleted = (dayNum - 1) < streak.totalDaysCompleted;
                                  return Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: dotCompleted
                                          ? activeGold.withValues(alpha: 0.6)
                                          : (isLight ? const Color(0xFFD4CEC2) : VinRColors.border),
                                    ),
                                  );
                                }),
                              ),
                            ),

                          // Aligned Node with Winding X Offset
                          Transform.translate(
                            offset: Offset(xOffset * 110, 0),
                            child: VinRPathNode(
                              dayNumber: dayNum,
                              title: item.title,
                              category: item.category,
                              icon: isMilestone
                                  ? (dayNum == 21 ? LucideIcons.crown : LucideIcons.trophy)
                                  : item.icon,
                              state: nodeState,
                              isMilestone: isMilestone,
                              onTap: () => _openQuestBottomSheet(
                                context,
                                item,
                                streak.totalDaysCompleted,
                                streak.isCompletedToday,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
