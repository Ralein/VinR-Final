import 'dart:math';
import 'package:flutter/material.dart';

class CelebrationParticle {
  double x;
  double y;
  double vx;
  double vy;
  double rotation;
  double vRotation;
  double size;
  Color color;
  double opacity;
  bool isStar;

  CelebrationParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.vRotation,
    required this.size,
    required this.color,
    this.opacity = 1.0,
    this.isStar = false,
  });
}

/// A lightweight, celebratory particle explosion widget for VinR habit milestones.
/// Spawns golden stars and vibrant confetti ribbons upon completing goals/streaks.
class CelebrationOverlay extends StatefulWidget {
  final Widget child;

  const CelebrationOverlay({
    super.key,
    required this.child,
  });

  static void show(BuildContext context) {
    final state = context.findAncestorStateOfType<_CelebrationOverlayState>();
    state?.triggerBurst();
  }

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<CelebrationParticle> _particles = [];
  final Random _random = Random();

  static const List<Color> _palette = [
    Color(0xFFFFD700), // Bright Gold
    Color(0xFFF0C96B), // Soft Gold
    Color(0xFF4ECBA0), // Emerald
    Color(0xFF4A90D9), // Sapphire
    Color(0xFFFF6B6B), // Coral
    Color(0xFFFFB800), // Amber
    Color(0xFF8B7EC8), // Lavender
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..addListener(_updatePhysics);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void triggerBurst() {
    _particles.clear();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final originX = width / 2;
    final originY = height * 0.45;

    for (int i = 0; i < 65; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 6.0 + _random.nextDouble() * 14.0;
      _particles.add(
        CelebrationParticle(
          x: originX + (_random.nextDouble() - 0.5) * 80,
          y: originY + (_random.nextDouble() - 0.5) * 40,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 6.0, // initial upward lift
          rotation: _random.nextDouble() * 2 * pi,
          vRotation: (_random.nextDouble() - 0.5) * 0.3,
          size: 7.0 + _random.nextDouble() * 8.0,
          color: _palette[_random.nextInt(_palette.length)],
          isStar: i % 3 == 0,
        ),
      );
    }

    _animController.forward(from: 0.0);
  }

  void _updatePhysics() {
    final progress = _animController.value;
    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.45; // gravity
      p.vx *= 0.97; // air drag
      p.rotation += p.vRotation;
      p.opacity = (1.0 - progress * 1.05).clamp(0.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_animController.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ConfettiPainter(particles: _particles),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<CelebrationParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.opacity <= 0) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      if (p.isStar) {
        // Draw cute diamond star
        final path = Path();
        final s = p.size;
        path.moveTo(0, -s);
        path.lineTo(s * 0.35, -s * 0.35);
        path.lineTo(s, 0);
        path.lineTo(s * 0.35, s * 0.35);
        path.lineTo(0, s);
        path.lineTo(-s * 0.35, s * 0.35);
        path.lineTo(-s, 0);
        path.lineTo(-s * 0.35, -s * 0.35);
        path.close();
        canvas.drawPath(path, paint);
      } else {
        // Draw confetti ribbon rectangle
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.55,
        );
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
        canvas.drawRRect(rrect, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
