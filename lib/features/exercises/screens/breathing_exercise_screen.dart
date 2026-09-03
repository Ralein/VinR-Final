import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vibration/vibration.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/theme/vinr_colors.dart';
import '../../../core/theme/vinr_typography.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/celebration_confetti.dart';
import '../../../core/widgets/tactile_3d_button.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _phase = 'Ready to begin';
  bool _isRunning = false;
  int _cyclesCompleted = 0;
  int _sessionId = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _sessionId++;
    _isRunning = false;
    _animController.stop();
    _animController.dispose();
    super.dispose();
  }

  void _toggleExercise() {
    if (_isRunning) {
      _sessionId++;
      _animController.stop();
      if (mounted) {
        setState(() {
          _isRunning = false;
          _phase = 'Session paused';
        });
      }
    } else {
      setState(() {
        _isRunning = true;
        _cyclesCompleted = 0;
      });
      _runPhaseLoop(++_sessionId);
    }
  }

  Future<void> _runPhaseLoop(int currentSessionId) async {
    while (_isRunning && mounted && currentSessionId == _sessionId) {
      // Phase 1: Inhale 4s
      if (!mounted || currentSessionId != _sessionId) break;
      setState(() => _phase = 'Inhale deeply (4s)');
      _safeVibrate(100);
      _animController.duration = const Duration(seconds: 4);
      try {
        await _animController.forward();
      } catch (_) {
        break;
      }
      if (!_isRunning || !mounted || currentSessionId != _sessionId) break;

      // Phase 2: Hold 7s
      setState(() => _phase = 'Hold breath (7s)');
      await Future.delayed(const Duration(seconds: 7));
      if (!_isRunning || !mounted || currentSessionId != _sessionId) break;

      // Phase 3: Exhale 8s
      setState(() => _phase = 'Exhale slowly (8s)');
      _safeVibrate(150);
      _animController.duration = const Duration(seconds: 8);
      try {
        await _animController.reverse();
      } catch (_) {
        break;
      }
      if (!_isRunning || !mounted || currentSessionId != _sessionId) break;

      // Increment completed cycle
      setState(() {
        _cyclesCompleted++;
      });

      if (_cyclesCompleted == 2 && mounted) {
        CelebrationOverlay.show(context);
      }
    }
  }

  void _safeVibrate(int durationMs) {
    try {
      Vibration.hasVibrator().then((hasVib) {
        if (hasVib == true && mounted) {
          Vibration.vibrate(duration: durationMs);
        }
      }).catchError((_) {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = context.textColor;
    final mutedTextColor = context.textMutedColor;

    return CelebrationOverlay(
      child: Scaffold(
        body: AmbientBackground(
          child: SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryTextColor, size: 20),
                            onPressed: () => context.pop(),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '4-7-8 Breathing Exercise',
                            style: VinRTypography.h3.copyWith(color: primaryTextColor),
                          ),
                        ],
                      ),
                      if (_cyclesCompleted > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: VinRColors.emeraldGlow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: VinRColors.emerald.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.check, color: VinRColors.emerald, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                '$_cyclesCompleted CYCLES',
                                style: const TextStyle(
                                  color: VinRColors.emerald,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _phase,
                            style: VinRTypography.h1.copyWith(
                              color: VinRColors.emerald,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _isRunning
                                ? 'Follow the aura rhythm: 4s in, 7s hold, 8s out'
                                : 'A proven technique to soothe stress & calm the nervous system',
                            style: VinRTypography.bodySm.copyWith(color: mutedTextColor),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),

                          // Expanding / Contracting Aura
                          Center(
                            child: AnimatedBuilder(
                              animation: _animController,
                              builder: (context, child) {
                                final scale = 1.0 + (_animController.value * 0.45);
                                return Container(
                                  width: 170 * scale,
                                  height: 170 * scale,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: VinRColors.emeraldGlow,
                                    border: Border.all(
                                      color: VinRColors.emerald.withValues(alpha: 0.6),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: VinRColors.emerald.withValues(alpha: 0.3 * _animController.value),
                                        blurRadius: 36 * scale,
                                        spreadRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      LucideIcons.wind,
                                      color: VinRColors.emerald,
                                      size: 50 * (0.9 + _animController.value * 0.2),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 56),

                          // 3D Tactile Button
                          Tactile3DButton(
                            text: _isRunning ? 'Pause Breathwork' : 'Start 4-7-8 Breathwork',
                            icon: _isRunning ? LucideIcons.pause : LucideIcons.play,
                            variant: TactileButtonVariant.emerald,
                            badgeText: '+30 XP',
                            onPressed: _toggleExercise,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
