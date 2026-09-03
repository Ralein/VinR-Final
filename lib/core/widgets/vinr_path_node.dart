import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/theme_context.dart';
import '../theme/vinr_colors.dart';
import '../theme/vinr_typography.dart';
import 'app_animations.dart';

enum PathNodeState {
  completed,
  active,
  locked,
}

/// A winding VinR interactive path node for habit and journey milestones.
class VinRPathNode extends StatefulWidget {
  final int dayNumber;
  final String title;
  final String category;
  final IconData icon;
  final PathNodeState state;
  final bool isMilestone;
  final String? subtitle;
  final VoidCallback onTap;

  const VinRPathNode({
    super.key,
    required this.dayNumber,
    required this.title,
    required this.category,
    required this.icon,
    required this.state,
    this.isMilestone = false,
    this.subtitle,
    required this.onTap,
  });

  @override
  State<VinRPathNode> createState() => _VinRPathNodeState();
}

class _VinRPathNodeState extends State<VinRPathNode> {
  bool _isPressed = false;
  static const double _depth = 4.0;

  @override
  Widget build(BuildContext context) {
    final isLight = context.isLight;
    final nodeSize = widget.isMilestone ? 74.0 : 66.0;

    Color topColor;
    Color bevelColor;
    Color iconColor;

    switch (widget.state) {
      case PathNodeState.completed:
        topColor = VinRColors.gold;
        bevelColor = isLight ? const Color(0xFF8E631C) : VinRColors.goldBevel;
        iconColor = Colors.black;
        break;
      case PathNodeState.active:
        topColor = VinRColors.emerald;
        bevelColor = isLight ? const Color(0xFF1E6C51) : VinRColors.emeraldBevel;
        iconColor = Colors.white;
        break;
      case PathNodeState.locked:
        topColor = isLight ? const Color(0xFFE2DDD2) : const Color(0xFF161C2C);
        bevelColor = isLight ? const Color(0xFFC7C0B2) : const Color(0xFF0D111A);
        iconColor = isLight ? const Color(0xFF8C8474) : VinRColors.textGhost;
        break;
    }

    final currentTranslation = _isPressed ? _depth : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Active Node Pointer Speech Bubble ("START HERE" or Flame)
        if (widget.state == PathNodeState.active)
          AnimatedPulse(
            duration: const Duration(milliseconds: 1400),
            minScale: 0.94,
            maxScale: 1.06,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: VinRColors.emerald,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: VinRColors.emerald.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(LucideIcons.play, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'TODAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (widget.isMilestone)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
            decoration: BoxDecoration(
              color: VinRColors.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: VinRColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.crown, size: 11, color: context.goldColor),
                const SizedBox(width: 4),
                Text(
                  'DAY ${widget.dayNumber} CHEST',
                  style: TextStyle(
                    color: context.goldColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        // Interactive 3D Node
        SizedBox(
          width: nodeSize,
          height: nodeSize + _depth,
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
                // 3D Bottom Bevel Base
                Positioned(
                  top: _depth,
                  child: Container(
                    width: nodeSize,
                    height: nodeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bevelColor,
                    ),
                  ),
                ),

                // Top Face Circle (Compresses down by 4px on tap)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 70),
                  curve: Curves.easeOutQuad,
                  top: currentTranslation,
                  child: Container(
                    width: nodeSize,
                    height: nodeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: topColor,
                      gradient: widget.state == PathNodeState.completed
                          ? VinRColors.goldGradient
                          : null,
                      border: Border.all(
                        color: widget.state == PathNodeState.active
                            ? Colors.white.withValues(alpha: 0.8)
                            : (widget.state == PathNodeState.completed
                                ? Colors.white.withValues(alpha: 0.4)
                                : context.borderColor),
                        width: widget.state == PathNodeState.active ? 2.5 : 1.5,
                      ),
                      boxShadow: widget.state == PathNodeState.locked || _isPressed
                          ? []
                          : [
                              BoxShadow(
                                color: topColor.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          widget.state == PathNodeState.locked
                              ? LucideIcons.lock
                              : (widget.state == PathNodeState.completed
                                  ? LucideIcons.check
                                  : widget.icon),
                          color: iconColor,
                          size: widget.isMilestone ? 30 : 26,
                        ),
                        // Small Star Badge on Completed
                        if (widget.state == PathNodeState.completed)
                          Positioned(
                            bottom: 6,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: const Icon(
                                LucideIcons.sparkles,
                                size: 10,
                                color: Color(0xFFFFD700),
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
        // Day Label Text & Task Pill
        GestureDetector(
          onTap: widget.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Day ${widget.dayNumber}',
                style: VinRTypography.label.copyWith(
                  color: widget.state == PathNodeState.locked
                      ? context.textGhostColor
                      : context.textColor,
                  fontWeight: widget.state == PathNodeState.active
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 11,
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: widget.state == PathNodeState.active
                        ? VinRColors.emerald.withValues(alpha: 0.15)
                        : (isLight ? const Color(0xFFECE7DC) : VinRColors.surface),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.state == PathNodeState.active
                          ? VinRColors.emerald.withValues(alpha: 0.3)
                          : context.borderColor,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: widget.state == PathNodeState.active
                          ? VinRColors.emerald
                          : context.textMutedColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
