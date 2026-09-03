import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/theme_context.dart';
import '../theme/vinr_colors.dart';
import '../theme/vinr_typography.dart';
import 'glass_container.dart';

/// Interactive Duolingo-style Mascot & Encouragement Speech Bubble.
class VinRMascotCard extends StatefulWidget {
  final int streakDays;
  final bool isCompletedToday;

  const VinRMascotCard({
    super.key,
    required this.streakDays,
    required this.isCompletedToday,
  });

  @override
  State<VinRMascotCard> createState() => _VinRMascotCardState();
}

class _VinRMascotCardState extends State<VinRMascotCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _wiggleController;
  int _speechIndex = 0;

  static const List<String> _encouragements = [
    "You've got this! Small daily habits compound into massive wins.",
    "A 2-minute breathwork session right now can completely reset your focus.",
    "Progress is not about perfection. It's about showing up today.",
    "Your streak is your fortress. Guard it with one mindful check-in!",
    "Every day you choose growth, you rewrite your internal narrative.",
    "Win the morning, win the day. You are in total control.",
  ];

  @override
  void initState() {
    super.initState();
    _speechIndex = widget.streakDays % _encouragements.length;
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    super.dispose();
  }

  void _pokeMascot() {
    HapticFeedback.mediumImpact();
    _wiggleController.forward(from: 0.0);
    setState(() {
      _speechIndex = (_speechIndex + 1) % _encouragements.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeGold = context.goldColor;
    final primaryTextColor = context.textColor;
    final mutedTextColor = context.textMutedColor;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: _pokeMascot,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Mascot Flame with Wiggle Animation
          AnimatedBuilder(
            animation: _wiggleController,
            builder: (context, child) {
              final val = _wiggleController.value;
              final angle = sin(val * pi * 3) * 0.12;
              final scale = 1.0 + sin(val * pi) * 0.15;
              return Transform.scale(
                scale: scale,
                child: Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: VinRColors.goldGradient,
                      boxShadow: [
                        BoxShadow(
                          color: activeGold.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          LucideIcons.flame,
                          color: Colors.black,
                          size: 30,
                        ),
                        // Tiny Sparkle
                        Positioned(
                          top: 8,
                          right: 10,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 14),

          // Speech Bubble
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'VINR BUDDY',
                      style: VinRTypography.label.copyWith(
                        color: activeGold,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(LucideIcons.mousePointerClick, size: 11, color: mutedTextColor),
                        const SizedBox(width: 3),
                        Text(
                          'TAP TO POKE',
                          style: TextStyle(
                            color: mutedTextColor,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _encouragements[_speechIndex],
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
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
