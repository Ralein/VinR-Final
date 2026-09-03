import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme_context.dart';
import '../theme/vinr_colors.dart';
import '../theme/vinr_typography.dart';

enum TactileButtonVariant {
  gold,
  emerald,
  sapphire,
  crimson,
  surface,
}

/// A modern, 21st-century 3D tactile button inspired by Duolingo.
///
/// Features a realistic bottom bevel edge (4px depth) and physically
/// compresses downward when pressed, accompanied by springy tactile feedback.
class Tactile3DButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final TactileButtonVariant variant;
  final IconData? icon;
  final String? badgeText;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;

  const Tactile3DButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = TactileButtonVariant.gold,
    this.icon,
    this.badgeText,
    this.isLoading = false,
    this.width,
    this.height = 54.0,
    this.borderRadius = 16.0,
  });

  @override
  State<Tactile3DButton> createState() => _Tactile3DButtonState();
}

class _Tactile3DButtonState extends State<Tactile3DButton> {
  bool _isPressed = false;
  static const double _depth = 4.0;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null || widget.isLoading) return;
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _isPressed = false);
    widget.onPressed!();
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  ({Color topColor, Color bevelColor, Color textColor, Gradient? gradient}) _getColors(
    BuildContext context,
  ) {
    final isLight = context.isLight;

    switch (widget.variant) {
      case TactileButtonVariant.gold:
        return (
          topColor: VinRColors.gold,
          bevelColor: isLight ? const Color(0xFF8E631C) : VinRColors.goldBevel,
          textColor: Colors.black,
          gradient: VinRColors.goldGradient,
        );
      case TactileButtonVariant.emerald:
        return (
          topColor: VinRColors.emerald,
          bevelColor: isLight ? const Color(0xFF1E6C51) : VinRColors.emeraldBevel,
          textColor: Colors.white,
          gradient: null,
        );
      case TactileButtonVariant.sapphire:
        return (
          topColor: VinRColors.sapphire,
          bevelColor: isLight ? const Color(0xFF1E4C7A) : VinRColors.sapphireBevel,
          textColor: Colors.white,
          gradient: null,
        );
      case TactileButtonVariant.crimson:
        return (
          topColor: VinRColors.crimson,
          bevelColor: isLight ? const Color(0xFF882525) : VinRColors.crimsonBevel,
          textColor: Colors.white,
          gradient: null,
        );
      case TactileButtonVariant.surface:
        return (
          topColor: isLight ? Colors.white : VinRColors.elevated,
          bevelColor: isLight ? const Color(0xFFD6D0C2) : VinRColors.surfaceBevel,
          textColor: context.textColor,
          gradient: null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final colors = _getColors(context);
    final currentTranslation = _isPressed ? _depth : 0.0;

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height + _depth,
      child: GestureDetector(
        onTapDown: isDisabled ? null : _handleTapDown,
        onTapUp: isDisabled ? null : _handleTapUp,
        onTapCancel: isDisabled ? null : _handleTapCancel,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // 3D Bottom Bevel Layer (Base)
            Positioned(
              top: _depth,
              left: 0,
              right: 0,
              height: widget.height,
              child: Container(
                decoration: BoxDecoration(
                  color: isDisabled
                      ? (context.isLight ? const Color(0xFFE0DDD5) : const Color(0xFF101420))
                      : colors.bevelColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
              ),
            ),

            // Top Face Layer (Depresses downward by _depth on tap)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 70),
              curve: Curves.easeOutQuad,
              top: currentTranslation,
              left: 0,
              right: 0,
              height: widget.height,
              child: Container(
                decoration: BoxDecoration(
                  gradient: isDisabled ? null : colors.gradient,
                  color: isDisabled
                      ? (context.isLight ? const Color(0xFFECE7DC) : VinRColors.surface)
                      : (colors.gradient == null ? colors.topColor : null),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: widget.variant == TactileButtonVariant.surface
                      ? Border.all(color: context.borderColor, width: 1.2)
                      : null,
                  boxShadow: isDisabled || _isPressed
                      ? []
                      : [
                          BoxShadow(
                            color: colors.topColor.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(colors.textColor),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(widget.icon, color: colors.textColor, size: 20),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                widget.text,
                                style: VinRTypography.body.copyWith(
                                  color: isDisabled
                                      ? context.textMutedColor
                                      : colors.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.5,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.badgeText != null) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  widget.badgeText!,
                                  style: TextStyle(
                                    color: colors.textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
