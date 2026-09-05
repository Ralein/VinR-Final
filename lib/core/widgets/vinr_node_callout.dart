import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/vinr_colors.dart';
import 'tactile_3d_button.dart';

/// Anchored Speech-Bubble Callout Modal,
/// directly inspired by Duolingo's node interaction speech bubble.
class VinRNodeCalloutBubble extends StatelessWidget {
  final int dayNumber;
  final String title;
  final String category;
  final int catalystCount;
  final int totalXP;
  final bool isCompleted;
  final bool isCurrent;
  final VoidCallback onStartMission;
  final VoidCallback onViewCatalysts;

  const VinRNodeCalloutBubble({
    super.key,
    required this.dayNumber,
    required this.title,
    required this.category,
    required this.catalystCount,
    this.totalXP = 50,
    required this.isCompleted,
    required this.isCurrent,
    required this.onStartMission,
    required this.onViewCatalysts,
  });

  static void show(
    BuildContext context, {
    required int dayNumber,
    required String title,
    required String category,
    required int catalystCount,
    int totalXP = 50,
    required bool isCompleted,
    required bool isCurrent,
    required VoidCallback onStartMission,
    required VoidCallback onViewCatalysts,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VinRNodeCalloutBubble(
        dayNumber: dayNumber,
        title: title,
        category: category,
        catalystCount: catalystCount,
        totalXP: totalXP,
        isCompleted: isCompleted,
        isCurrent: isCurrent,
        onStartMission: onStartMission,
        onViewCatalysts: onViewCatalysts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bubbleThemeColor = isCompleted
        ? VinRColors.gold
        : (isCurrent ? VinRColors.emerald : const Color(0xFF3B82F6));

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: bubbleThemeColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: bubbleThemeColor.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Speech Bubble Pointer Arrow pointing up
          Positioned(
            top: -9,
            child: CustomPaint(
              size: const Size(18, 10),
              painter: _CalloutArrowPainter(color: bubbleThemeColor),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Day Pill + Catalyst count + XP Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'DAY $dayNumber \u2022 $category',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.zap, size: 11, color: Colors.white),
                          const SizedBox(width: 3.5),
                          Text(
                            '+$totalXP XP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Main Mission Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  isCompleted
                      ? 'Completed \u2022 Tap to review your entries & reflections'
                      : (isCurrent
                          ? '$catalystCount action catalysts ready for today'
                          : 'Locked \u2022 Complete prior days to unlock'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.5,
                  ),
                ),

                const SizedBox(height: 18),

                // Primary 3D Action Button ("START MISSION" or "REVIEW MISSION")
                Tactile3DButton(
                  text: isCompleted
                      ? 'Review Day $dayNumber (+0 XP)'
                      : (isCurrent ? 'Start Mission (+$totalXP XP)' : 'Preview Catalysts'),
                  variant: isCurrent
                      ? TactileButtonVariant.gold
                      : (isCompleted ? TactileButtonVariant.surface : TactileButtonVariant.sapphire),
                  height: 50,
                  borderRadius: 15,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                    onStartMission();
                  },
                ),

                const SizedBox(height: 10),

                // Secondary Button ("VIEW CATALYSTS")
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    onViewCatalysts();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.listTodo, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'View $catalystCount Catalysts Breakdown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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

class _CalloutArrowPainter extends CustomPainter {
  final Color color;
  const _CalloutArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _CalloutArrowPainter old) => old.color != color;
}
