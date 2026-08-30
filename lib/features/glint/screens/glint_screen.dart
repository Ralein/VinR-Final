import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/theme/vinr_colors.dart';
import '../../../core/theme/vinr_typography.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/vinr_toast.dart';
import '../models/glint_card_model.dart';
import '../providers/glint_provider.dart';

class GlintScreen extends ConsumerStatefulWidget {
  const GlintScreen({super.key});

  @override
  ConsumerState<GlintScreen> createState() => _GlintScreenState();
}

class _GlintScreenState extends ConsumerState<GlintScreen> {
  bool _showSettings = false;

  Color _resolveAccentColor(String accent) {
    switch (accent.toLowerCase()) {
      case 'emerald':
        return VinRColors.emerald;
      case 'sapphire':
        return VinRColors.sapphire;
      case 'ruby':
      case 'crimson':
        return VinRColors.crimson;
      case 'gold':
      default:
        return VinRColors.gold;
    }
  }

  IconData _resolveIcon(String type) {
    switch (type.toLowerCase()) {
      case 'streak':
        return LucideIcons.flame;
      case 'quote':
        return LucideIcons.quote;
      case 'reflection':
        return LucideIcons.sparkles;
      case 'challenge':
        return LucideIcons.target;
      case 'motivation':
      default:
        return LucideIcons.zap;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = context.textColor;
    final mutedTextColor = context.textMutedColor;
    final activeGold = context.goldColor;
    final glintState = ref.watch(glintProvider);
    final glintNotifier = ref.read(glintProvider.notifier);

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.flame, color: activeGold, size: 24),
                        const SizedBox(width: 8),
                        Text('Glint', style: VinRTypography.h1.copyWith(fontSize: 26, color: primaryTextColor)),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => setState(() => _showSettings = !_showSettings),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: activeGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: activeGold.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  glintState.selectedTopic,
                                  style: TextStyle(color: activeGold, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 4),
                                Icon(LucideIcons.chevronDown, color: activeGold, size: 12),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (glintState.isGenerating)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: activeGold),
                            ),
                          ),
                        IconButton(
                          icon: Icon(LucideIcons.refreshCw, color: mutedTextColor, size: 20),
                          onPressed: () {
                            glintNotifier.loadGlintsForTopic(glintState.selectedTopic, forceRefresh: true);
                            VinRToast.show(
                              context,
                              message: 'Generating fresh on-device Glints...',
                              icon: LucideIcons.sparkles,
                              iconColor: activeGold,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Perspective Tuning Bar
              if (_showSettings) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  color: context.surfaceColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PERSPECTIVE TUNING', style: VinRTypography.label.copyWith(color: activeGold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['Stress Relief', 'Focus', 'Discipline', 'Mindfulness'].map((topic) {
                          final isSel = glintState.selectedTopic == topic;
                          return ChoiceChip(
                            selected: isSel,
                            label: Text(topic, style: TextStyle(color: isSel ? Colors.black : primaryTextColor, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                            selectedColor: activeGold,
                            backgroundColor: context.surfaceColor,
                            onSelected: (_) {
                              glintNotifier.setTopic(topic);
                              setState(() => _showSettings = false);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],

              // Dynamic Vertical Shorts Cards Feed
              Expanded(
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: glintState.cards.length,
                  itemBuilder: (context, index) {
                    final item = glintState.cards[index];
                    final color = _resolveAccentColor(item.accent);
                    final icon = _resolveIcon(item.type);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Tag & Bookmark
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: color.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    item.tag.toUpperCase(),
                                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    item.isFavorite ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
                                    color: item.isFavorite ? activeGold : mutedTextColor,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    glintNotifier.toggleFavorite(item.id);
                                    VinRToast.show(
                                      context,
                                      message: item.isFavorite ? 'Removed from saved' : 'Saved to Glint collection',
                                      icon: LucideIcons.bookmarkCheck,
                                      iconColor: activeGold,
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Spacer(),

                            // Center Orb Icon
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color.withValues(alpha: 0.12),
                                  border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.18),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(icon, color: color, size: 48),
                              ),
                            ),

                            const Spacer(),

                            // Title
                            Text(
                              item.title,
                              style: VinRTypography.h2.copyWith(color: primaryTextColor, fontSize: 22, height: 1.25),
                            ),
                            const SizedBox(height: 8),

                            // Body description
                            Text(
                              item.body,
                              style: VinRTypography.body.copyWith(color: mutedTextColor, height: 1.45),
                            ),

                            if (item.quote != null && item.quote!.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border(left: BorderSide(color: color, width: 3)),
                                ),
                                child: Text(
                                  '“${item.quote}”\n— ${item.author ?? "VinR"}',
                                  style: TextStyle(
                                    color: primaryTextColor,
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Footer channel & audio indicator
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: activeGold.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.channel,
                                    style: TextStyle(color: activeGold, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(LucideIcons.sparkles, color: mutedTextColor, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  'On-Device AI',
                                  style: TextStyle(color: mutedTextColor, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
