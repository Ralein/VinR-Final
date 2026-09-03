import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/theme/vinr_colors.dart';
import '../../../core/theme/vinr_typography.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/celebration_confetti.dart';
import '../../../core/widgets/vinr_path_node.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/tactile_3d_button.dart';
import '../../../core/widgets/vinr_toast.dart';
import '../../streak/providers/streak_provider.dart';

class DayTask {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String? toolRoute;
  final String? toolLabel;

  const DayTask({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.toolRoute,
    this.toolLabel,
  });
}

class DayRoadmapItem {
  final int dayNumber;
  final String title;
  final String category;
  final String phase;
  final IconData icon;
  final List<DayTask> tasks;

  const DayRoadmapItem({
    required this.dayNumber,
    required this.title,
    required this.category,
    required this.phase,
    required this.icon,
    required this.tasks,
  });
}

class JourneyScreen extends ConsumerStatefulWidget {
  const JourneyScreen({super.key});

  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends ConsumerState<JourneyScreen> {
  int _activePhaseFilter = 0; // 0: All, 1: Genesis (1-7), 2: Crucible (8-14), 3: Pinnacle (15-21)

  static final List<DayRoadmapItem> _roadmap = [
    // Phase 1: Genesis (Days 1–7)
    DayRoadmapItem(
      dayNumber: 1,
      title: 'Intention & Reset',
      category: 'Mindset Foundation',
      phase: 'Phase 1: Genesis',
      icon: LucideIcons.compass,
      tasks: [
        DayTask(
          id: 'd1_t1',
          title: 'Core 21-Day Intention',
          description: 'Define the single highest-leverage habit or standard you will build over these 21 days.',
          icon: LucideIcons.target,
          toolRoute: '/journal',
          toolLabel: 'Write In Journal',
        ),
        DayTask(
          id: 'd1_t2',
          title: 'Gratitude Anchor Entry',
          description: 'Log 3 specific moments of light or opportunity you are grateful for this morning.',
          icon: LucideIcons.smile,
          toolRoute: '/journal',
          toolLabel: 'Log Gratitude',
        ),
        DayTask(
          id: 'd1_t3',
          title: 'Digital Clean Slate',
          description: 'Clear unnecessary desktop tabs and phone notifications for uninterrupted presence.',
          icon: LucideIcons.shieldCheck,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 2,
      title: 'Gratitude Anchor',
      category: 'Positive Framing',
      phase: 'Phase 1: Genesis',
      icon: LucideIcons.smile,
      tasks: [
        DayTask(
          id: 'd2_t1',
          title: 'Morning Appreciation Scribe',
          description: 'Document 3 things that went well yesterday and why they were meaningful.',
          icon: LucideIcons.penTool,
          toolRoute: '/journal',
          toolLabel: 'Open Journal',
        ),
        DayTask(
          id: 'd2_t2',
          title: 'Affirmation of Ownership',
          description: 'Read aloud: "I control my actions, my perceptions, and my standard of effort."',
          icon: LucideIcons.volume2,
        ),
        DayTask(
          id: 'd2_t3',
          title: '5-Minute Mindful Walk',
          description: 'Step outside or take 5 minutes of mindful walking without your smartphone.',
          icon: LucideIcons.activity,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 3,
      title: '4-7-8 Calm Breath',
      category: 'Nervous System',
      phase: 'Phase 1: Genesis',
      icon: LucideIcons.wind,
      tasks: [
        DayTask(
          id: 'd3_t1',
          title: 'Complete 4-7-8 Breathwork',
          description: 'Engage in a 4-cycle guided 4-7-8 rhythmic breathing session to reset nervous tone.',
          icon: LucideIcons.wind,
          toolRoute: '/exercises/breathing',
          toolLabel: 'Start Breathwork',
        ),
        DayTask(
          id: 'd3_t2',
          title: 'Physiological Sigh Check',
          description: 'Practice two deep inhales through the nose followed by an extended sigh release.',
          icon: LucideIcons.heartPulse,
        ),
        DayTask(
          id: 'd3_t3',
          title: 'Hydration Anchor',
          description: 'Drink 500ml of water to rehydrate your brain and kickstart cognitive clarity.',
          icon: LucideIcons.droplets,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 4,
      title: 'Stoic Perception',
      category: 'Emotional Control',
      phase: 'Phase 1: Genesis',
      icon: LucideIcons.sparkles,
      tasks: [
        DayTask(
          id: 'd4_t1',
          title: 'Circle of Control Inventory',
          description: 'Separate today’s challenges into "Direct Control" vs "Outside Control".',
          icon: LucideIcons.helpCircle,
          toolRoute: '/journal',
          toolLabel: 'Reflect In Journal',
        ),
        DayTask(
          id: 'd4_t2',
          title: 'Pause Before Reaction',
          description: 'Take 3 deep breaths whenever an unexpected friction or delay occurs today.',
          icon: LucideIcons.pause,
        ),
        DayTask(
          id: 'd4_t3',
          title: 'Marcus Aurelius Meditation',
          description: 'Reflect on: "You have power over your mind, not outside events."',
          icon: LucideIcons.quote,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 5,
      title: 'Body Alignment',
      category: 'Physical Synergy',
      phase: 'Phase 1: Genesis',
      icon: LucideIcons.activity,
      tasks: [
        DayTask(
          id: 'd5_t1',
          title: 'Midday Postural Reset',
          description: 'Decompress your neck and spine with 5 minutes of mobility stretching.',
          icon: LucideIcons.userCheck,
        ),
        DayTask(
          id: 'd5_t2',
          title: 'Energy Elevation Movement',
          description: 'Complete 10 bodyweight squats or brisk stair climbing to surge circulation.',
          icon: LucideIcons.zap,
        ),
        DayTask(
          id: 'd5_t3',
          title: 'Mindful Eating Pause',
          description: 'Eat one meal today without screens, savoring flavor and texture attentively.',
          icon: LucideIcons.coffee,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 6,
      title: 'Digital Detox',
      category: 'Focus & Clarity',
      phase: 'Phase 1: Genesis',
      icon: LucideIcons.shieldCheck,
      tasks: [
        DayTask(
          id: 'd6_t1',
          title: '45-Min Airplane Mode Block',
          description: 'Perform a single 45-minute deep work block in total digital airplane mode.',
          icon: LucideIcons.clock,
        ),
        DayTask(
          id: 'd6_t2',
          title: 'Notification Audit',
          description: 'Disable badge notifications on at least 2 non-essential social or news apps.',
          icon: LucideIcons.bellOff,
        ),
        DayTask(
          id: 'd6_t3',
          title: 'Stillness Reflection',
          description: 'Spend 5 minutes sitting in quiet stillness, observing mental chatter without judgment.',
          icon: LucideIcons.eye,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 7,
      title: 'Week 1 Warrior',
      category: 'Genesis Milestone',
      phase: 'Phase 1: Genesis',
      icon: LucideIcons.award,
      tasks: [
        DayTask(
          id: 'd7_t1',
          title: '7-Day Momentum Review',
          description: 'Write a quick debrief: What felt effortless? Where did resistance occur?',
          icon: LucideIcons.award,
          toolRoute: '/journal',
          toolLabel: 'Log 7-Day Review',
        ),
        DayTask(
          id: 'd7_t2',
          title: 'Celebrate Small Wins',
          description: 'Acknowledge your 7 days of consistency. You have laid the true habit foundation.',
          icon: LucideIcons.sparkles,
        ),
        DayTask(
          id: 'd7_t3',
          title: 'Commit to Phase 2',
          description: 'Prepare your mindset for Phase 2 (Crucible): Building unbreakable fortitude.',
          icon: LucideIcons.flame,
        ),
      ],
    ),

    // Phase 2: Crucible (Days 8–14)
    DayRoadmapItem(
      dayNumber: 8,
      title: 'Somatic Grounding',
      category: 'Stress Relief',
      phase: 'Phase 2: Crucible',
      icon: LucideIcons.heartPulse,
      tasks: [
        DayTask(
          id: 'd8_t1',
          title: '5-4-3-2-1 Sensory Scan',
          description: 'Identify 5 things you see, 4 you feel, 3 you hear, 2 you smell, 1 you taste.',
          icon: LucideIcons.heartPulse,
        ),
        DayTask(
          id: 'd8_t2',
          title: 'Grounding Breath Connection',
          description: 'Take 10 prolonged diaphragmatic breaths feeling your feet anchored to the floor.',
          icon: LucideIcons.wind,
          toolRoute: '/exercises/breathing',
          toolLabel: 'Practice Breath',
        ),
        DayTask(
          id: 'd8_t3',
          title: 'Release Physical Tension',
          description: 'Consciously drop your shoulders and unclamp your jaw during focus transitions.',
          icon: LucideIcons.smile,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 9,
      title: 'Reframing Obstacles',
      category: 'Resilience',
      phase: 'Phase 2: Crucible',
      icon: LucideIcons.target,
      tasks: [
        DayTask(
          id: 'd9_t1',
          title: 'The Obstacle Is The Way',
          description: 'Select one frustrating situation and write 2 ways it makes you stronger.',
          icon: LucideIcons.target,
          toolRoute: '/journal',
          toolLabel: 'Write Reframe',
        ),
        DayTask(
          id: 'd9_t2',
          title: 'Humor & Detachment',
          description: 'Smile gently at a minor inconvenience, acknowledging how fleeting it is.',
          icon: LucideIcons.smile,
        ),
        DayTask(
          id: 'd9_t3',
          title: 'Solution Bias',
          description: 'Spend 90% of your mental energy on the next actionable solution step.',
          icon: LucideIcons.checkCheck,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 10,
      title: 'Mid-Journey Energy',
      category: 'Habit Reinforcement',
      phase: 'Phase 2: Crucible',
      icon: LucideIcons.zap,
      tasks: [
        DayTask(
          id: 'd10_t1',
          title: 'Habit Anchor Audit',
          description: 'Ensure your daily VinR check-in is linked to an existing trigger (e.g. morning coffee).',
          icon: LucideIcons.anchor,
        ),
        DayTask(
          id: 'd10_t2',
          title: 'Double Down on Consistency',
          description: 'Never miss twice: protect your winning streak regardless of schedule friction.',
          icon: LucideIcons.flame,
        ),
        DayTask(
          id: 'd10_t3',
          title: 'Cold Water Finish',
          description: 'End your morning shower with 30 seconds of brisk cold water to elevate dopamine.',
          icon: LucideIcons.droplets,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 11,
      title: 'Empathetic Connection',
      category: 'Relationships',
      phase: 'Phase 2: Crucible',
      icon: LucideIcons.heartHandshake,
      tasks: [
        DayTask(
          id: 'd11_t1',
          title: 'Unprompted Appreciation',
          description: 'Send a genuine 2-sentence note of gratitude to a friend, mentor, or family member.',
          icon: LucideIcons.heartHandshake,
        ),
        DayTask(
          id: 'd11_t2',
          title: 'Active Listening Practice',
          description: 'In your next conversation, listen completely without thinking of your reply.',
          icon: LucideIcons.mic,
        ),
        DayTask(
          id: 'd11_t3',
          title: 'Kindness Micro-Action',
          description: 'Perform one small, anonymous act of kindness without expecting recognition.',
          icon: LucideIcons.gift,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 12,
      title: 'Physical Fortitude',
      category: 'Power & Drive',
      phase: 'Phase 2: Crucible',
      icon: LucideIcons.dumbbell,
      tasks: [
        DayTask(
          id: 'd12_t1',
          title: 'Intense Movement Burst',
          description: 'Complete 15 minutes of strength exercises, pushups, or a high-cadence walk.',
          icon: LucideIcons.dumbbell,
        ),
        DayTask(
          id: 'd12_t2',
          title: 'Endurance Mindset',
          description: 'Push past the initial feeling of physical boredom or fatigue with steady breaths.',
          icon: LucideIcons.activity,
        ),
        DayTask(
          id: 'd12_t3',
          title: 'Post-Workout Stretch',
          description: 'Spend 5 minutes stretching hips and hamstrings to accelerate physical recovery.',
          icon: LucideIcons.userCheck,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 13,
      title: 'Mindful Soundscape',
      category: 'Rest & Recovery',
      phase: 'Phase 2: Crucible',
      icon: LucideIcons.volume2,
      tasks: [
        DayTask(
          id: 'd13_t1',
          title: 'Ambient Audio Decompression',
          description: 'Listen to 10 minutes of binaural beats or soothing ambient soundscapes.',
          icon: LucideIcons.volume2,
        ),
        DayTask(
          id: 'd13_t2',
          title: 'Sensory Wind-Down',
          description: 'Dim the room lights 1 hour before sleep to signal melatonin release.',
          icon: LucideIcons.moon,
        ),
        DayTask(
          id: 'd13_t3',
          title: 'Evening Gratitude Scribe',
          description: 'Write 3 simple gifts you experienced during the day.',
          icon: LucideIcons.penTool,
          toolRoute: '/journal',
          toolLabel: 'Log Evening Win',
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 14,
      title: '14-Day Fortitude',
      category: 'Crucible Milestone',
      phase: 'Phase 2: Crucible',
      icon: LucideIcons.trophy,
      tasks: [
        DayTask(
          id: 'd14_t1',
          title: 'Two-Week Victory Audit',
          description: 'Reflect on 14 straight days. Your identity as a disciplined builder is taking root.',
          icon: LucideIcons.trophy,
          toolRoute: '/journal',
          toolLabel: 'Open Journal',
        ),
        DayTask(
          id: 'd14_t2',
          title: 'Fortitude Crest Unlock',
          description: 'Celebrate unlocking your Crucible Fortitude milestone. You are in the final tier!',
          icon: LucideIcons.award,
        ),
        DayTask(
          id: 'd14_t3',
          title: 'Prepare for Sovereign Mastery',
          description: 'Set your sights on the final 7 days of identity transformation.',
          icon: LucideIcons.crown,
        ),
      ],
    ),

    // Phase 3: Pinnacle (Days 15–21)
    DayRoadmapItem(
      dayNumber: 15,
      title: 'Self-Compassion',
      category: 'Inner Peace',
      phase: 'Phase 3: Pinnacle',
      icon: LucideIcons.heart,
      tasks: [
        DayTask(
          id: 'd15_t1',
          title: 'Release The Inner Critic',
          description: 'Notice any harsh self-judgment today and replace it with constructive encouragement.',
          icon: LucideIcons.heart,
          toolRoute: '/journal',
          toolLabel: 'Journal Reflection',
        ),
        DayTask(
          id: 'd15_t2',
          title: 'Progress Over Perfection',
          description: 'Affirm: "Consistency over time surpasses sporadic perfection."',
          icon: LucideIcons.check,
        ),
        DayTask(
          id: 'd15_t3',
          title: 'Deep Rest Period',
          description: 'Give yourself 15 minutes of guilt-free restorative rest or reading.',
          icon: LucideIcons.moon,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 16,
      title: 'Core Focus Flow',
      category: 'Productivity',
      phase: 'Phase 3: Pinnacle',
      icon: LucideIcons.flame,
      tasks: [
        DayTask(
          id: 'd16_t1',
          title: '60-Minute Focus Sprint',
          description: 'Complete one uninterrupted 60-minute sprint on your single most vital project.',
          icon: LucideIcons.flame,
        ),
        DayTask(
          id: 'd16_t2',
          title: 'Ruthless Prioritization',
          description: 'Say no to at least one low-priority distraction or commitment today.',
          icon: LucideIcons.xCircle,
        ),
        DayTask(
          id: 'd16_t3',
          title: 'Deep Breath Transition',
          description: 'Take 5 grounding breaths before switching focus between projects.',
          icon: LucideIcons.wind,
          toolRoute: '/exercises/breathing',
          toolLabel: 'Reset Breath',
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 17,
      title: 'Postural Reset',
      category: 'Physical Health',
      phase: 'Phase 3: Pinnacle',
      icon: LucideIcons.userCheck,
      tasks: [
        DayTask(
          id: 'd17_t1',
          title: 'Ergonomic Body Check',
          description: 'Adjust screen height and chair ergonomics to maintain open, upright chest posture.',
          icon: LucideIcons.userCheck,
        ),
        DayTask(
          id: 'd17_t2',
          title: 'Spinal Decompression Flow',
          description: 'Complete 3 rounds of cat-cow or thoracic extension stretches.',
          icon: LucideIcons.activity,
        ),
        DayTask(
          id: 'd17_t3',
          title: 'Hydration & Mineral Intake',
          description: 'Ensure adequate water and electrolytes for sustained cognitive vitality.',
          icon: LucideIcons.droplets,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 18,
      title: 'Gratitude Reflection',
      category: 'Perspective Shift',
      phase: 'Phase 3: Pinnacle',
      icon: LucideIcons.penTool,
      tasks: [
        DayTask(
          id: 'd18_t1',
          title: 'Transformation Catalog',
          description: 'Document 3 tangible ways your habits and mindset have changed since Day 1.',
          icon: LucideIcons.penTool,
          toolRoute: '/journal',
          toolLabel: 'Open Journal',
        ),
        DayTask(
          id: 'd18_t2',
          title: 'Acknowledge The Struggle',
          description: 'Thank yourself for pushing through the days when motivation was absent.',
          icon: LucideIcons.sparkles,
        ),
        DayTask(
          id: 'd18_t3',
          title: 'Share Your Momentum',
          description: 'Encourage a peer or partner on their own personal development journey.',
          icon: LucideIcons.share2,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 19,
      title: 'Evening Wind-Down',
      category: 'Sleep Quality',
      phase: 'Phase 3: Pinnacle',
      icon: LucideIcons.moon,
      tasks: [
        DayTask(
          id: 'd19_t1',
          title: 'Digital Sunset at 9 PM',
          description: 'Turn off all monitors, laptops, and phone notifications 1 hour before sleep.',
          icon: LucideIcons.moon,
        ),
        DayTask(
          id: 'd19_t2',
          title: 'Room Temperature Drop',
          description: 'Ensure your bedroom is cool and well-ventilated for deep delta wave sleep.',
          icon: LucideIcons.thermometer,
        ),
        DayTask(
          id: 'd19_t3',
          title: 'Mind Clearing Brain Dump',
          description: 'Write down tomorrow’s top 3 tasks on paper to empty mental RAM before bed.',
          icon: LucideIcons.list,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 20,
      title: 'Unshakable Mindset',
      category: 'Mastery Preparation',
      phase: 'Phase 3: Pinnacle',
      icon: LucideIcons.shield,
      tasks: [
        DayTask(
          id: 'd20_t1',
          title: 'Draft Personal Manifesto',
          description: 'Write your 5 core life principles that will govern your consistency forever.',
          icon: LucideIcons.shield,
          toolRoute: '/journal',
          toolLabel: 'Write Manifesto',
        ),
        DayTask(
          id: 'd20_t2',
          title: 'Reaffirm Lifelong Identity',
          description: 'Affirm: "Discipline is not what I do, it is who I am."',
          icon: LucideIcons.award,
        ),
        DayTask(
          id: 'd20_t3',
          title: 'Plan Beyond Day 21',
          description: 'Select your next 90-day physical and intellectual growth goals.',
          icon: LucideIcons.target,
        ),
      ],
    ),
    DayRoadmapItem(
      dayNumber: 21,
      title: 'The Sovereign Crown',
      category: 'Identity Mastery',
      phase: 'Phase 3: Pinnacle',
      icon: LucideIcons.crown,
      tasks: [
        DayTask(
          id: 'd21_t1',
          title: '21-Day Mastery Celebration',
          description: 'CONGRATULATIONS! You have completed the 21-Day VinR Transformation!',
          icon: LucideIcons.crown,
          toolRoute: '/journal',
          toolLabel: 'Log Crown Victory',
        ),
        DayTask(
          id: 'd21_t2',
          title: 'Trophy Room Induction',
          description: 'Unlock your Sovereign Crown trophy badge in your Profile trophy showcase.',
          icon: LucideIcons.trophy,
        ),
        DayTask(
          id: 'd21_t3',
          title: 'Seal The Identity Transformation',
          description: 'Take pride in the new standard of excellence and mental toughness you built.',
          icon: LucideIcons.sparkles,
        ),
      ],
    ),
  ];

  void _openQuestBottomSheet(BuildContext context, DayRoadmapItem item, int totalDaysCompleted, bool isCompletedToday) {
    final isCompleted = item.dayNumber <= totalDaysCompleted;
    final isCurrent = item.dayNumber == totalDaysCompleted + 1 && !isCompletedToday;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
        return _QuestDetailModal(
          item: item,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          totalDaysCompleted: totalDaysCompleted,
          onCompletePressed: () {
            Navigator.pop(modalContext);
            ref.read(streakProvider.notifier).markDayComplete();
            CelebrationOverlay.show(context);
            VinRToast.show(
              context,
              message: 'Day ${item.dayNumber} Complete! Streak updated (+50 XP)',
              icon: LucideIcons.flame,
              iconColor: VinRColors.gold,
            );
          },
        );
      },
    );
  }

  // Winding horizontal offset pattern for VinR quest trail (-0.6 to +0.6)
  double _getHorizontalOffset(int index) {
    return sin(index * 0.95) * 0.45;
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakProvider);
    final isLight = context.isLight;
    final primaryTextColor = context.textColor;
    final mutedTextColor = context.textMutedColor;
    final activeGold = context.goldColor;

    // Filter roadmap based on active phase filter
    List<DayRoadmapItem> displayedRoadmap;
    if (_activePhaseFilter == 1) {
      displayedRoadmap = _roadmap.where((d) => d.dayNumber >= 1 && d.dayNumber <= 7).toList();
    } else if (_activePhaseFilter == 2) {
      displayedRoadmap = _roadmap.where((d) => d.dayNumber >= 8 && d.dayNumber <= 14).toList();
    } else if (_activePhaseFilter == 3) {
      displayedRoadmap = _roadmap.where((d) => d.dayNumber >= 15 && d.dayNumber <= 21).toList();
    } else {
      displayedRoadmap = _roadmap;
    }

    final todayDayNumber = (streak.totalDaysCompleted + 1).clamp(1, 21);
    final todayItem = _roadmap.firstWhere(
      (item) => item.dayNumber == todayDayNumber,
      orElse: () => _roadmap.first,
    );

    return CelebrationOverlay(
      child: Scaffold(
        body: AmbientBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 140.0),
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '21-Day Habit Quest',
                            style: VinRTypography.h1.copyWith(fontSize: 26, color: primaryTextColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Complete 3 daily catalysts to lock in identity transformation.',
                            style: VinRTypography.bodySm.copyWith(color: mutedTextColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: activeGold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: activeGold.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.award, size: 14, color: activeGold),
                          const SizedBox(width: 5),
                          Text(
                            'Day ${streak.totalDaysCompleted}/21',
                            style: VinRTypography.label.copyWith(color: activeGold, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Interactive Phase Filter Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPhasePill(0, 'All 21 Days', LucideIcons.map),
                      const SizedBox(width: 8),
                      _buildPhasePill(1, 'Phase 1: Genesis (1–7)', LucideIcons.sparkles),
                      const SizedBox(width: 8),
                      _buildPhasePill(2, 'Phase 2: Crucible (8–14)', LucideIcons.flame),
                      const SizedBox(width: 8),
                      _buildPhasePill(3, 'Phase 3: Pinnacle (15–21)', LucideIcons.crown),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Interactive Today Status & Mission Spotlight
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  onTap: () => _openQuestBottomSheet(
                    context,
                    todayItem,
                    streak.totalDaysCompleted,
                    streak.isCompletedToday,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: streak.isCompletedToday
                                      ? VinRColors.emerald.withValues(alpha: 0.18)
                                      : activeGold.withValues(alpha: 0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  streak.isCompletedToday ? LucideIcons.checkCheck : LucideIcons.flame,
                                  color: streak.isCompletedToday ? VinRColors.emerald : activeGold,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    streak.isCompletedToday
                                        ? "TODAY'S MISSION COMPLETE"
                                        : "DAY $todayDayNumber MISSION SPOTLIGHT",
                                    style: TextStyle(
                                      color: streak.isCompletedToday ? VinRColors.emerald : activeGold,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  Text(
                                    todayItem.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primaryTextColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: VinRColors.xpGem.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '3 Tasks',
                              style: TextStyle(
                                color: VinRColors.xpGem,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        streak.isCompletedToday
                            ? "All 3 daily catalysts achieved today. Great momentum!"
                            : "Tap to review today's 3 micro-catalysts and claim +50 XP.",
                        style: TextStyle(color: mutedTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Winding VinR Quest Path Map
                Center(
                  child: Column(
                    children: List.generate(displayedRoadmap.length, (index) {
                      final item = displayedRoadmap[index];
                      final dayNum = item.dayNumber;
                      final isCompleted = dayNum <= streak.totalDaysCompleted;
                      final isCurrent = dayNum == streak.totalDaysCompleted + 1 && !streak.isCompletedToday;
                      final isMilestone = dayNum == 7 || dayNum == 14 || dayNum == 21;

                      final PathNodeState nodeState = isCompleted
                          ? PathNodeState.completed
                          : (isCurrent ? PathNodeState.active : PathNodeState.locked);

                      final xOffset = _getHorizontalOffset(dayNum - 1);

                      return Column(
                        children: [
                          // Milestone Shrine Card Checkpoints
                          if (dayNum == 8 && _activePhaseFilter == 0)
                            _buildMilestoneShrine(
                              context,
                              title: 'PHASE I MASTERED: AWAKENING',
                              quote: '“The mind once expanded to the dimensions of larger ideas, never returns to its original size.”',
                              icon: LucideIcons.sparkles,
                              color: VinRColors.gold,
                              isPassed: streak.totalDaysCompleted >= 7,
                            ),
                          if (dayNum == 15 && _activePhaseFilter == 0)
                            _buildMilestoneShrine(
                              context,
                              title: 'PHASE II MASTERED: FORTITUDE',
                              quote: '“Difficulties strengthen the mind, as labor does the body.” — Seneca',
                              icon: LucideIcons.shieldCheck,
                              color: VinRColors.sapphire,
                              isPassed: streak.totalDaysCompleted >= 14,
                            ),

                          // Path connecting trail dots
                          if (index > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (dotIndex) {
                                  final dotCompleted = (dayNum - 1) < streak.totalDaysCompleted;
                                  return Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: dotCompleted
                                          ? activeGold.withValues(alpha: 0.6)
                                          : (isLight ? const Color(0xFFD4CEC2) : VinRColors.border),
                                    ),
                                  );
                                }),
                              ),
                            ),

                          // Aligned Node with Winding X Offset & Subtitle
                          Transform.translate(
                            offset: Offset(xOffset * 110, 0),
                            child: VinRPathNode(
                              dayNumber: dayNum,
                              title: item.title,
                              category: item.category,
                              subtitle: '${item.tasks.length} Tasks',
                              icon: isMilestone
                                  ? (dayNum == 21 ? LucideIcons.crown : LucideIcons.trophy)
                                  : item.icon,
                              state: nodeState,
                              isMilestone: isMilestone,
                              onTap: () => _openQuestBottomSheet(
                                context,
                                item,
                                streak.totalDaysCompleted,
                                streak.isCompletedToday,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhasePill(int index, String label, IconData icon) {
    final isSelected = _activePhaseFilter == index;
    final isLight = context.isLight;
    final activeGold = context.goldColor;

    return GestureDetector(
      onTap: () => setState(() => _activePhaseFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? activeGold.withValues(alpha: 0.2)
              : (isLight ? const Color(0xFFF0ECE0) : VinRColors.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeGold : context.borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? activeGold : context.textMutedColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? context.textColor : context.textMutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneShrine(
    BuildContext context, {
    required String title,
    required String quote,
    required IconData icon,
    required Color color,
    required bool isPassed,
  }) {
    final isLight = context.isLight;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPassed
            ? color.withValues(alpha: isLight ? 0.12 : 0.16)
            : (isLight ? const Color(0xFFF7F5EE) : VinRColors.surface),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPassed ? color.withValues(alpha: 0.5) : context.borderColor,
          width: isPassed ? 1.5 : 1.0,
        ),
        boxShadow: isPassed
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isPassed ? color : context.textGhostColor, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isPassed ? color : context.textMutedColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 11.5,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            quote,
            style: TextStyle(
              color: context.textColor,
              fontSize: 12,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuestDetailModal extends StatefulWidget {
  final DayRoadmapItem item;
  final bool isCompleted;
  final bool isCurrent;
  final int totalDaysCompleted;
  final VoidCallback onCompletePressed;

  const _QuestDetailModal({
    required this.item,
    required this.isCompleted,
    required this.isCurrent,
    required this.totalDaysCompleted,
    required this.onCompletePressed,
  });

  @override
  State<_QuestDetailModal> createState() => _QuestDetailModalState();
}

class _QuestDetailModalState extends State<_QuestDetailModal> {
  late Set<String> _completedTaskIds;
  int _selectedResonanceIndex = 0;

  static const List<String> _resonanceMoods = [
    '🔥 Focused',
    '🧘 Calm',
    '⚡ Energized',
    '🛡️ Resilient',
  ];

  @override
  void initState() {
    super.initState();
    // If already marked completed in streak, check all tasks by default
    _completedTaskIds = widget.isCompleted
        ? widget.item.tasks.map((t) => t.id).toSet()
        : <String>{};
  }

  void _toggleTask(String taskId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_completedTaskIds.contains(taskId)) {
        _completedTaskIds.remove(taskId);
      } else {
        _completedTaskIds.add(taskId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? Colors.white : VinRColors.elevated;
    final primaryTextColor = isLight ? const Color(0xFF1A1208) : VinRColors.textPrimary;
    final mutedTextColor = isLight ? const Color(0xFF5C5446) : VinRColors.textMuted;
    final activeGold = isLight ? const Color(0xFFB8832A) : VinRColors.gold;

    final allTasksDone = _completedTaskIds.length == widget.item.tasks.length;
    final progress = widget.item.tasks.isEmpty
        ? 1.0
        : (_completedTaskIds.length / widget.item.tasks.length);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isLight ? const Color(0x22000000) : VinRColors.borderGold,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: mutedTextColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Quest Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.isCompleted
                          ? VinRColors.emerald.withValues(alpha: 0.15)
                          : (widget.isCurrent ? activeGold.withValues(alpha: 0.18) : Colors.grey.withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'DAY ${widget.item.dayNumber} MISSION • ${widget.item.phase.toUpperCase()}',
                      style: TextStyle(
                        color: widget.isCompleted
                            ? VinRColors.emerald
                            : (widget.isCurrent ? activeGold : mutedTextColor),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: VinRColors.xpGem.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(LucideIcons.zap, size: 13, color: VinRColors.xpGem),
                        SizedBox(width: 4),
                        Text(
                          '+50 XP',
                          style: TextStyle(
                            color: VinRColors.xpGem,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Quest Title & Category
              Text(
                widget.item.title,
                style: VinRTypography.h1.copyWith(fontSize: 22, color: primaryTextColor),
              ),
              const SizedBox(height: 4),
              Text(
                widget.item.category,
                style: VinRTypography.bodySm.copyWith(color: mutedTextColor),
              ),
              const SizedBox(height: 16),

              // Interactive Task Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DAILY CATALYSTS (${_completedTaskIds.length}/${widget.item.tasks.length} DONE)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: activeGold,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: activeGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isLight ? const Color(0xFFE6E2D8) : VinRColors.border,
                  color: allTasksDone ? VinRColors.emerald : activeGold,
                  minHeight: 7,
                ),
              ),
              const SizedBox(height: 18),

              // Interactive Multi-Task List Cards
              Column(
                children: widget.item.tasks.map((task) {
                  final isDone = _completedTaskIds.contains(task.id);

                  return GestureDetector(
                    onTap: () => _toggleTask(task.id),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDone
                          ? VinRColors.emerald.withValues(alpha: isLight ? 0.08 : 0.12)
                          : (isLight ? const Color(0xFFF7F5F0) : VinRColors.surface),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDone
                            ? VinRColors.emerald.withValues(alpha: 0.5)
                            : (isLight ? const Color(0x15000000) : VinRColors.border),
                        width: isDone ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Interactive Checkbox Button
                            GestureDetector(
                              onTap: () => _toggleTask(task.id),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDone ? VinRColors.emerald : Colors.transparent,
                                  border: Border.all(
                                    color: isDone ? VinRColors.emerald : activeGold,
                                    width: 2,
                                  ),
                                ),
                                child: isDone
                                    ? const Icon(LucideIcons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primaryTextColor,
                                      fontSize: 14,
                                      decoration: isDone ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    task.description,
                                    style: TextStyle(
                                      color: mutedTextColor,
                                      fontSize: 12.5,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Direct Deep-Link Tool Shortcut
                        if (task.toolRoute != null && task.toolLabel != null) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                context.push(task.toolRoute!);
                              },
                              icon: const Icon(LucideIcons.externalLink, size: 13),
                              label: Text(task.toolLabel!, style: const TextStyle(fontSize: 11)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: activeGold,
                                side: BorderSide(color: activeGold.withValues(alpha: 0.5)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),

              // Mindset Resonance Chips
              Text(
                'MINDSET RESONANCE',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: mutedTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(_resonanceMoods.length, (idx) {
                  final isSelected = _selectedResonanceIndex == idx;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedResonanceIndex = idx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? activeGold.withValues(alpha: 0.2)
                            : (isLight ? const Color(0xFFEDE9DF) : VinRColors.surface),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? activeGold : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        _resonanceMoods[idx],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? primaryTextColor : mutedTextColor,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              if (widget.isCompleted)
                Tactile3DButton(
                  text: 'Quest Completed ✨',
                  variant: TactileButtonVariant.emerald,
                  icon: LucideIcons.checkCheck,
                  onPressed: () => Navigator.pop(context),
                )
              else if (widget.isCurrent)
                Tactile3DButton(
                  text: allTasksDone
                      ? 'Complete Day ${widget.item.dayNumber} Mission →'
                      : 'Complete Mission (${_completedTaskIds.length}/${widget.item.tasks.length} Done) →',
                  variant: TactileButtonVariant.gold,
                  badgeText: '+50 XP',
                  onPressed: widget.onCompletePressed,
                )
              else
                Tactile3DButton(
                  text: 'Locked — Complete Day ${widget.totalDaysCompleted} First',
                  variant: TactileButtonVariant.surface,
                  icon: LucideIcons.lock,
                  onPressed: () => Navigator.pop(context),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
