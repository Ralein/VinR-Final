import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/theme/vinr_colors.dart';

/// Interactive Journey Track and Chapter Switcher,
/// directly inspired by Duolingo's multi-course switcher modal.
class JourneyTrackSwitcher extends StatelessWidget {
  final int currentPhaseIndex;
  final int totalDaysCompleted;
  final ValueChanged<int> onSelectPhase;

  const JourneyTrackSwitcher({
    super.key,
    required this.currentPhaseIndex,
    required this.totalDaysCompleted,
    required this.onSelectPhase,
  });

  static void show(
    BuildContext context, {
    required int currentPhaseIndex,
    required int totalDaysCompleted,
    required ValueChanged<int> onSelectPhase,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JourneyTrackSwitcher(
        currentPhaseIndex: currentPhaseIndex,
        totalDaysCompleted: totalDaysCompleted,
        onSelectPhase: onSelectPhase,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = context.isLight;
    final goldColor = context.goldColor;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : VinRColors.backgroundElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: isLight ? const Color(0xFFE2DDD2) : VinRColors.borderAsh,
            width: 1.2,
          ),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle & Top Close Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(LucideIcons.x, color: context.textColor, size: 22),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close Track Switcher',
                ),
                Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 48), // Balance spacing
              ],
            ),
          ),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
              children: [
                // Header
                Text(
                  'JOURNEY TRACKS',
                  style: TextStyle(
                    color: goldColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Active Track Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFFAF7F0) : VinRColors.ashSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: goldColor.withValues(alpha: 0.6),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: goldColor.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: goldColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(LucideIcons.compass, size: 20, color: goldColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: VinRColors.emerald.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'ACTIVE TRACK',
                                        style: TextStyle(
                                          color: VinRColors.emerald,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Day ${(totalDaysCompleted + 1).clamp(1, 21)} of 21',
                                      style: TextStyle(
                                        color: context.textMutedColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'The Stoic Sovereign',
                                  style: TextStyle(
                                    color: context.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(LucideIcons.checkCircle2, color: goldColor, size: 22),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Foundations of emotional control, mental toughness, and sovereign identity transformation.',
                        style: TextStyle(
                          color: context.textMutedColor,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Jump to Phase within Active Track
                Text(
                  'JUMP TO CHAPTER',
                  style: TextStyle(
                    color: context.textMutedColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),

                _buildPhaseJumpItem(
                  context: context,
                  phaseNumber: 1,
                  title: 'Section 1: Genesis',
                  subtitle: 'Days 1-7 \u2022 Mindset Foundations',
                  icon: LucideIcons.sparkles,
                  color: VinRColors.gold,
                  isActive: currentPhaseIndex == 1,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    onSelectPhase(1);
                  },
                ),
                const SizedBox(height: 8),

                _buildPhaseJumpItem(
                  context: context,
                  phaseNumber: 2,
                  title: 'Section 2: The Crucible',
                  subtitle: 'Days 8-14 \u2022 Friction & Mental Grit',
                  icon: LucideIcons.flame,
                  color: VinRColors.sapphire,
                  isActive: currentPhaseIndex == 2,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    onSelectPhase(2);
                  },
                ),
                const SizedBox(height: 8),

                _buildPhaseJumpItem(
                  context: context,
                  phaseNumber: 3,
                  title: 'Section 3: Pinnacle',
                  subtitle: 'Days 15-21 \u2022 Sovereign Crown Mastery',
                  icon: LucideIcons.crown,
                  color: VinRColors.gold,
                  isActive: currentPhaseIndex == 3,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    onSelectPhase(3);
                  },
                ),

                const SizedBox(height: 24),

                // Alternate Tracks Section (Duolingo "New Courses" style)
                Text(
                  'EXPLORE MORE JOURNEYS',
                  style: TextStyle(
                    color: context.textMutedColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),

                _buildUpcomingTrackCard(
                  context: context,
                  title: 'Deep Focus & Dopamine Reset',
                  days: '7-Day Sprint',
                  description: 'Rewire dopamine receptors, eliminate distractions, and cultivate uninterrupted flow states.',
                  icon: LucideIcons.zapOff,
                  badgeColor: const Color(0xFF38BDF8),
                ),
                const SizedBox(height: 10),

                _buildUpcomingTrackCard(
                  context: context,
                  title: 'Somatic Equilibrium',
                  days: '14-Day Reset',
                  description: 'Nervous system regulation, parasympathetic breathwork, and deep restorative sleep.',
                  icon: LucideIcons.wind,
                  badgeColor: const Color(0xFFA78BFA),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseJumpItem({
    required BuildContext context,
    required int phaseNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isLight = context.isLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.12)
              : (isLight ? const Color(0xFFF6F3EC) : VinRColors.ashSurface),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.5) : context.borderColor,
            width: isActive ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.textColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.textMutedColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: context.textMutedColor),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTrackCard({
    required BuildContext context,
    required String title,
    required String days,
    required String description,
    required IconData icon,
    required Color badgeColor,
  }) {
    final isLight = context.isLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF9F7F2) : const Color(0xFF131722),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: badgeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: context.textColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        days,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: context.textMutedColor,
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
