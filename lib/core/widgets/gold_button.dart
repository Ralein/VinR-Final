import 'package:flutter/material.dart';
import 'tactile_3d_button.dart';

/// App-wide Primary Gold Button, now powered by the 3D Tactile engine.
class GoldButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final String? badgeText;

  const GoldButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Tactile3DButton(
      text: text,
      onPressed: onPressed,
      variant: TactileButtonVariant.gold,
      isLoading: isLoading,
      icon: icon,
      width: width,
      badgeText: badgeText,
    );
  }
}
