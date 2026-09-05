import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/theme/vinr_colors.dart';
import '../../../core/theme/vinr_typography.dart';
import '../../../core/widgets/tactile_3d_button.dart';

/// A modal dossier inspired by Duolingo's Unit Guidebook,
/// providing philosophical principles, mental models, and grounding mantras.
class StoicCodexModal extends StatelessWidget {
  final int sectionNumber;
  final String sectionTitle;
  final String sectionTheme;

  const StoicCodexModal({
    super.key,
    required this.sectionNumber,
    required this.sectionTitle,
    required this.sectionTheme,
  });

  static void show(
    BuildContext context, {
    required int sectionNumber,
    required String sectionTitle,
    required String sectionTheme,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StoicCodexModal(
        sectionNumber: sectionNumber,
        sectionTitle: sectionTitle,
        sectionTheme: sectionTheme,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = context.isLight;
    final goldColor = context.goldColor;

    final principles = sectionNumber == 1
        ? [
            {
              'title': 'The Dichotomy of Control',
              'quote': 'Some things are in our control and others not. Things in our control are opinion, pursuit, desire, and aversion.',
              'author': 'Epictetus',
              'rule': 'Invest 100% of your energy into your preparation and response. Release all anxiety over outcomes.',
              'icon': LucideIcons.target,
            },
            {
              'title': 'Amor Fati (Love of Fate)',
              'quote': 'A blazing fire makes flame and brightness out of everything that is thrown into it.',
              'author': 'Marcus Aurelius',
              'rule': 'Do not merely endure adversity. Welcome it as essential fuel to forge character.',
              'icon': LucideIcons.flame,
            },
            {
              'title': 'Memento Mori (Mindful Mortality)',
              'quote': 'You could leave life right now. Let that determine what you do and say and think.',
              'author': 'Marcus Aurelius',
              'rule': 'Ruthlessly cut trivial noise and digital feeds. Treat each day as a complete lifetime.',
              'icon': LucideIcons.hourglass,
            },
            {
              'title': 'Voluntary Discomfort',
              'quote': 'We suffer more often in imagination than in reality.',
              'author': 'Seneca',
              'rule': 'Practice small frictions daily (cold finish, delayed gratification) so hardship never breaks you.',
              'icon': LucideIcons.shieldCheck,
            },
          ]
        : (sectionNumber == 2
            ? [
                {
                  'title': 'The Inner Citadel',
                  'quote': 'Nowhere can man find a quieter or more untroubled retreat than in his own soul.',
                  'author': 'Marcus Aurelius',
                  'rule': 'Protect your attention like a sovereign fortress. Never surrender peace of mind to external chaos.',
                  'icon': LucideIcons.shield,
                },
                {
                  'title': 'Action Over Anxiety',
                  'quote': 'Don\'t explain your philosophy. Embody it.',
                  'author': 'Epictetus',
                  'rule': 'When resistance whispers doubt, count 3-2-1 and execute without negotiation.',
                  'icon': LucideIcons.zap,
                },
              ]
            : [
                {
                  'title': 'Sovereign Equanimity',
                  'quote': 'He who conquers himself is the mightiest warrior.',
                  'author': 'Confucius',
                  'rule': 'You are no longer building habits; you have become the embodiment of lifelong discipline.',
                  'icon': LucideIcons.crown,
                },
              ]);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
                  tooltip: 'Close Codex',
                ),
                Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.share2, color: context.textMutedColor, size: 19),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  tooltip: 'Share Principles',
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
              children: [
                // Header Badge & Title
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: goldColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: goldColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.bookOpen, size: 13, color: goldColor),
                        const SizedBox(width: 6),
                        Text(
                          'SECTION $sectionNumber \u2022 FIELD GUIDE',
                          style: TextStyle(
                            color: goldColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  sectionTitle,
                  style: VinRTypography.headlineMedium.copyWith(
                    color: context.textColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  sectionTheme,
                  style: TextStyle(
                    color: context.textMutedColor,
                    fontSize: 13,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 22),

                // Section Label: "CORE PRINCIPLES"
                Row(
                  children: [
                    Text(
                      'CORE MENTAL MODELS',
                      style: TextStyle(
                        color: goldColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Divider(color: context.borderColor, height: 1)),
                  ],
                ),

                const SizedBox(height: 14),

                // Principles Cards (Duolingo Key Phrases style)
                ...principles.map((p) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isLight ? const Color(0xFFF7F5F0) : VinRColors.ashSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isLight ? const Color(0xFFE2DDD2) : VinRColors.borderAsh,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: goldColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(p['icon'] as IconData, size: 16, color: goldColor),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                p['title'] as String,
                                style: TextStyle(
                                  color: context.textColor,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '"${p['quote']}"\n— ${p['author']}',
                            style: TextStyle(
                              color: context.textMutedColor,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(LucideIcons.checkCircle2, size: 14, color: VinRColors.emerald),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                p['rule'] as String,
                                style: TextStyle(
                                  color: context.textColor,
                                  fontSize: 12.5,
                                  height: 1.3,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 10),

                // Bottom Action Button
                Tactile3DButton(
                  text: 'Embody These Principles',
                  backgroundColor: goldColor,
                  textColor: Colors.black,
                  height: 52,
                  borderRadius: 16,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
