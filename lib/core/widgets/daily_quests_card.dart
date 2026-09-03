import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/theme_context.dart';
import '../theme/vinr_colors.dart';
import '../theme/vinr_typography.dart';
import 'glass_container.dart';

class DailyQuestItem {
  final String id;
  final String title;
  final String xp;
  final bool isCompleted;
  final IconData icon;
  final String route;

  const DailyQuestItem({
    required this.id,
    required this.title,
    required this.xp,
    required this.isCompleted,
    required this.icon,
    required this.route,
  });
}

/// VinR Daily Quests & XP tracker card.
class DailyQuestsCard extends StatelessWidget {
  final bool isCheckinDone;
  final bool isJournalDone;
  final bool isExerciseDone;

  const DailyQuestsCard({
    super.key,
    required this.isCheckinDone,
    this.isJournalDone = false,
    this.isExerciseDone = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeGold = context.goldColor;
    final primaryTextColor = context.textColor;
    final mutedTextColor = context.textMutedColor;

    final quests = [
      DailyQuestItem(
        id: 'q1',
        title: "Daily Mindset Spark",
        xp: '+50 XP',
        isCompleted: isCheckinDone,
        icon: LucideIcons.flame,
        route: '/journey',
      ),
      DailyQuestItem(
        id: 'q2',
        title: "4-7-8 Breath or Grounding",
        xp: '+30 XP',
        isCompleted: isExerciseDone,
        icon: LucideIcons.wind,
        route: '/breathing',
      ),
      DailyQuestItem(
        id: 'q3',
        title: "Gratitude Scribe",
        xp: '+40 XP',
        isCompleted: isJournalDone,
        icon: LucideIcons.penTool,
        route: '/journal',
      ),
    ];

    final completedCount = quests.where((q) => q.isCompleted).length;
    final totalXpEarned = (isCheckinDone ? 50 : 0) + (isExerciseDone ? 30 : 0) + (isJournalDone ? 40 : 0);
    final allComplete = completedCount == quests.length;

    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with XP Gem
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: VinRColors.xpGem.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.zap, size: 16, color: VinRColors.xpGem),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DAILY QUESTS',
                    style: VinRTypography.label.copyWith(
                      color: activeGold,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: allComplete
                      ? VinRColors.emerald.withValues(alpha: 0.18)
                      : activeGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: allComplete
                        ? VinRColors.emerald.withValues(alpha: 0.5)
                        : activeGold.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      allComplete ? LucideIcons.award : LucideIcons.sparkles,
                      size: 12,
                      color: allComplete ? VinRColors.emerald : activeGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$totalXpEarned / 120 XP',
                      style: TextStyle(
                        color: allComplete ? VinRColors.emerald : activeGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completedCount / 3.0,
              backgroundColor: context.borderColor,
              color: allComplete ? VinRColors.emerald : activeGold,
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 14),

          // Quest Items Checklist
          ...quests.map((q) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () {
                  if (!q.isCompleted) {
                    context.push(q.route);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: q.isCompleted
                        ? VinRColors.emerald.withValues(alpha: 0.10)
                        : (context.isLight ? Colors.white.withValues(alpha: 0.6) : VinRColors.surface),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: q.isCompleted
                          ? VinRColors.emerald.withValues(alpha: 0.35)
                          : context.borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Animated checkmark
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: q.isCompleted ? VinRColors.emerald : Colors.transparent,
                          border: Border.all(
                            color: q.isCompleted ? VinRColors.emerald : mutedTextColor,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: q.isCompleted
                              ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),

                      Icon(q.icon, size: 16, color: q.isCompleted ? VinRColors.emerald : activeGold),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          q.title,
                          style: TextStyle(
                            color: q.isCompleted ? mutedTextColor : primaryTextColor,
                            fontSize: 13,
                            fontWeight: q.isCompleted ? FontWeight.normal : FontWeight.w600,
                            decoration: q.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),

                      // XP Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: VinRColors.xpGem.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          q.xp,
                          style: const TextStyle(
                            color: VinRColors.xpGem,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
