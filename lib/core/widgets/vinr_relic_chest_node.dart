import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/theme_context.dart';
import '../theme/vinr_colors.dart';
import '../theme/vinr_motion.dart';
import '../theme/vinr_typography.dart';
import 'app_animations.dart';

enum RelicChestState {
  locked,
  readyToClaim,
  claimed,
}

/// A tactile 3D Stoic Relic Chest placed directly on the serpentine path,
/// inspired by Duolingo's milestone treasure chest progression nodes.
class VinRRelicChestNode extends StatefulWidget {
  final int milestoneDay;
  final String title;
  final String rewardXP;
  final RelicChestState state;
  final VoidCallback onTap;

  const VinRRelicChestNode({
    super.key,
    required this.milestoneDay,
    required this.title,
    this.rewardXP = '+100 XP',
    required this.state,
    required this.onTap,
  });

  @override
  State<VinRRelicChestNode> createState() => _VinRRelicChestNodeState();
}

class _VinRRelicChestNodeState extends State<VinRRelicChestNode> {
  bool _isPressed = false;
  static const double _depth = 5.0;

  @override
  Widget build(BuildContext context) {
    final isLight = context.isLight;
    final isReady = widget.state == RelicChestState.readyToClaim;
    final isClaimed = widget.state == RelicChestState.claimed;
    final isLocked = widget.state == RelicChestState.locked;

    // Palette per state
    final Color chestBodyColor = isClaimed
        ? (isLight ? const Color(0xFFD6C8A8) : const Color(0xFF2A2318))
        : (isReady
            ? (isLight ? const Color(0xFFE5A638) : const Color(0xFF926315))
            : (isLight ? const Color(0xFFD9D4C7) : const Color(0xFF181E2C)));

    final Color chestBevelColor = isClaimed
        ? (isLight ? const Color(0xFFB5A480) : const Color(0xFF1B160E))
        : (isReady
            ? (isLight ? const Color(0xFFB87C17) : const Color(0xFF5A3D0B))
            : (isLight ? const Color(0xFFB8B1A0) : const Color(0xFF0D111A)));

    final Color trimColor = isClaimed
        ? VinRColors.gold.withValues(alpha: 0.6)
        : (isReady ? VinRColors.gold : const Color(0xFF4A5568));

    final currentTranslation = _isPressed ? _depth : 0.0;

    Widget chestWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Floating Callout / Status Pill
        if (isReady)
          AnimatedPulse(
            duration: const Duration(milliseconds: 1200),
            minScale: 0.95,
            maxScale: 1.05,
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: VinRColors.gold,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: VinRColors.gold.withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.sparkles, size: 11, color: Colors.black),
                  const SizedBox(width: 4),
                  Text(
                    'CLAIM ${widget.rewardXP}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: isClaimed
                  ? VinRColors.gold.withValues(alpha: 0.15)
                  : (isLight ? const Color(0xFFECE7DB) : VinRColors.ashSurface),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isClaimed
                    ? VinRColors.gold.withValues(alpha: 0.4)
                    : (isLight ? const Color(0xFFD6CFBF) : VinRColors.borderAsh),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isClaimed ? LucideIcons.checkCheck : LucideIcons.crown,
                  size: 11,
                  color: isClaimed ? context.goldColor : context.textMutedColor,
                ),
                const SizedBox(width: 4),
                Text(
                  isClaimed ? 'CLAIMED' : 'DAY ${widget.milestoneDay} RELIC',
                  style: TextStyle(
                    color: isClaimed ? context.goldColor : context.textMutedColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),

        // 3D Chest Body
        SizedBox(
          width: 86,
          height: 72 + _depth,
          child: GestureDetector(
            onTapDown: (_) {
              HapticFeedback.lightImpact();
              setState(() => _isPressed = true);
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              widget.onTap();
            },
            onTapCancel: () {
              if (_isPressed) setState(() => _isPressed = false);
            },
            behavior: HitTestBehavior.opaque,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 3D Bottom Bevel Shadow
                Positioned(
                  top: _depth,
                  child: Container(
                    width: 84,
                    height: 68,
                    decoration: BoxDecoration(
                      color: chestBevelColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),

                // Top Tactile Chest Face (Compresses down on tap)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 70),
                  curve: Curves.easeOutQuad,
                  top: currentTranslation,
                  child: Container(
                    width: 84,
                    height: 68,
                    decoration: BoxDecoration(
                      color: chestBodyColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isReady
                            ? Colors.white.withValues(alpha: 0.8)
                            : (isClaimed
                                ? VinRColors.gold.withValues(alpha: 0.5)
                                : (isLight ? const Color(0xFFC7BFAD) : const Color(0xFF2A354D))),
                        width: isReady ? 2.0 : 1.2,
                      ),
                      boxShadow: isReady && !_isPressed
                          ? [
                              BoxShadow(
                                color: VinRColors.gold.withValues(alpha: 0.4),
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Decorative horizontal wood/metal seam
                        Positioned(
                          top: 24,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3,
                            color: chestBevelColor.withValues(alpha: 0.7),
                          ),
                        ),

                        // Left vertical strap
                        Positioned(
                          left: 16,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 8,
                            decoration: BoxDecoration(
                              color: trimColor.withValues(alpha: isReady ? 0.9 : 0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Right vertical strap
                        Positioned(
                          right: 16,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 8,
                            decoration: BoxDecoration(
                              color: trimColor.withValues(alpha: isReady ? 0.9 : 0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Central Golden Keyhole Lock Clasp
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isReady ? VinRColors.gold : (isClaimed ? const Color(0xFFD4AF37) : const Color(0xFF2E384D)),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isReady ? Colors.white : Colors.black.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              isClaimed
                                  ? LucideIcons.check
                                  : (isReady ? LucideIcons.key : LucideIcons.lock),
                              size: 14,
                              color: isReady ? Colors.black : (isClaimed ? Colors.black : const Color(0xFF7E8EA8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Subtitle / Milestone description
        Text(
          widget.title,
          style: VinRTypography.label.copyWith(
            color: isReady ? context.goldColor : (isClaimed ? context.textColor : context.textGhostColor),
            fontSize: 10.5,
            fontWeight: isReady ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ],
    );

    return chestWidget;
  }
}
