import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/theme/vinr_colors.dart';
import '../../../core/theme/vinr_typography.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/celebration_confetti.dart';
import '../../../core/widgets/tactile_3d_button.dart';
import '../../../core/widgets/vinr_path_node.dart';
import '../../../core/widgets/vinr_toast.dart';
import '../../streak/providers/streak_provider.dart';

// =============================================================================
// DATA MODELS
// =============================================================================

class DayTask {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String? toolRoute;
  final String? toolLabel;
  final int xpReward;

  const DayTask({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.toolRoute,
    this.toolLabel,
    this.xpReward = 15,
  });
}

class DayRoadmapItem {
  final int dayNumber;
  final String title;
  final String category;
  final String phase;
  final int phaseIndex;
  final IconData icon;
  final List<DayTask> tasks;

  const DayRoadmapItem({
    required this.dayNumber,
    required this.title,
    required this.category,
    required this.phase,
    required this.phaseIndex,
    required this.icon,
    required this.tasks,
  });
}

// =============================================================================
// STOIC COMPASS QUOTES (Curated, full-breadth quotes that fit cleanly)
// =============================================================================
const List<Map<String, String>> _compassQuotes = [
  {'quote': 'Optimal momentum. Every brick laid today compounds forever.', 'author': 'VinR Compass'},
  {'quote': 'You have power over your mind, not outside events.', 'author': 'Marcus Aurelius'},
  {'quote': 'Difficulties strengthen the mind, as labor does the body.', 'author': 'Seneca'},
  {'quote': 'The impediment to action advances action. What stands in the way becomes the way.', 'author': 'Marcus Aurelius'},
  {'quote': 'He who conquers himself is the mightiest warrior.', 'author': 'Confucius'},
  {'quote': 'Waste no more time arguing what a good man should be. Be one.', 'author': 'Marcus Aurelius'},
  {'quote': 'It is not daily increase but daily decrease — hack away the inessential.', 'author': 'Bruce Lee'},
];

// =============================================================================
// MAIN SCREEN
// =============================================================================

class JourneyScreen extends ConsumerStatefulWidget {
  const JourneyScreen({super.key});

  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends ConsumerState<JourneyScreen>
    with TickerProviderStateMixin {
  // Smooth organic breathing animation (gentle, high-end pulse)
  late final AnimationController _pulseController;
  late final Animation<double> _auraAnimation;

  // Shimmer along upcoming path
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  // Quote transition
  late final AnimationController _quoteFadeController;
  late final Animation<double> _quoteFadeAnimation;

  // Animated XP counter
  late AnimationController _xpCountController;
  late Animation<int> _xpCountAnimation;
  int _targetXP = 0;

  // Ripple indicator on the upcoming milestone
  late final AnimationController _rippleController;
  late final Animation<double> _rippleAnimation;

  final Set<String> _todayCompletedTaskIds = {};
  final ScrollController _scrollController = ScrollController();
  int _currentQuoteIndex = 0;

  // =============================================================================
  // ROADMAP DATA (21 Days)
  // =============================================================================
  static final List<DayRoadmapItem> _roadmap = [
    DayRoadmapItem(dayNumber: 1, title: 'Intention & Reset', category: 'Mindset Foundation', phase: 'Phase 1: Genesis', phaseIndex: 1, icon: LucideIcons.compass, tasks: [
      DayTask(id: 'd1_t1', title: 'Core 21-Day Intention', description: 'Define the single highest-leverage habit or standard you will build over these 21 days.', icon: LucideIcons.target, toolRoute: '/journal', toolLabel: 'Write In Journal', xpReward: 15),
      DayTask(id: 'd1_t2', title: 'Gratitude Anchor Entry', description: 'Log 3 specific moments of light or opportunity you are grateful for this morning.', icon: LucideIcons.smile, toolRoute: '/journal', toolLabel: 'Log Gratitude', xpReward: 15),
      DayTask(id: 'd1_t3', title: 'Digital Clean Slate', description: 'Clear unnecessary desktop tabs and phone notifications for uninterrupted presence.', icon: LucideIcons.shieldCheck, xpReward: 20),
    ]),
    DayRoadmapItem(dayNumber: 2, title: 'Gratitude Anchor', category: 'Positive Framing', phase: 'Phase 1: Genesis', phaseIndex: 1, icon: LucideIcons.smile, tasks: [
      DayTask(id: 'd2_t1', title: 'Morning Appreciation Scribe', description: 'Document 3 things that went well yesterday and why they were meaningful.', icon: LucideIcons.penTool, toolRoute: '/journal', toolLabel: 'Open Journal', xpReward: 15),
      DayTask(id: 'd2_t2', title: 'Affirmation of Ownership', description: 'Read aloud: "I control my actions, my perceptions, and my standard of effort."', icon: LucideIcons.volume2, xpReward: 15),
      DayTask(id: 'd2_t3', title: '5-Minute Mindful Walk', description: 'Take a short tech-free walk observing your physical surroundings.', icon: LucideIcons.footprints, xpReward: 20),
    ]),
    DayRoadmapItem(dayNumber: 3, title: 'Dopamine Detox', category: 'Focus & Clarity', phase: 'Phase 1: Genesis', phaseIndex: 1, icon: LucideIcons.zapOff, tasks: [
      DayTask(id: 'd3_t1', title: '60-Minute Screen Silence', description: 'Spend your first waking hour with no social feeds, emails, or short-form videos.', icon: LucideIcons.zapOff, xpReward: 20),
      DayTask(id: 'd3_t2', title: 'Hydration Catalyst', description: 'Drink 500ml of water with minerals before any caffeine consumption.', icon: LucideIcons.droplets, xpReward: 15),
      DayTask(id: 'd3_t3', title: 'Focus Priority Selection', description: 'Identify the ONE task that makes everything else secondary today.', icon: LucideIcons.checkSquare, xpReward: 15),
    ]),
    DayRoadmapItem(dayNumber: 4, title: 'Breath Alignment', category: 'Emotional Regulation', phase: 'Phase 1: Genesis', phaseIndex: 1, icon: LucideIcons.wind, tasks: [
      DayTask(id: 'd4_t1', title: '4-7-8 Parasympathetic Reset', description: 'Complete 4 full cycles of 4-7-8 diaphragmatic breathing to steady heart-rate variability.', icon: LucideIcons.wind, toolRoute: '/breathing', toolLabel: 'Start 4-7-8 Breathing', xpReward: 20),
      DayTask(id: 'd4_t2', title: 'Body Scan Check-in', description: 'Notice where tension is stored in your shoulders, neck, or jaw and gently exhale release.', icon: LucideIcons.activity, toolRoute: '/grounding', toolLabel: '2-Min Grounding', xpReward: 15),
      DayTask(id: 'd4_t3', title: 'Mindful Pause Before Reacting', description: 'Take 3 deliberate belly breaths before answering any urgent message today.', icon: LucideIcons.shieldAlert, xpReward: 15),
    ]),
    DayRoadmapItem(dayNumber: 5, title: 'Stoic Perspective', category: 'Inner Resilience', phase: 'Phase 1: Genesis', phaseIndex: 1, icon: LucideIcons.bookOpen, tasks: [
      DayTask(id: 'd5_t1', title: 'Dichotomy of Control Audit', description: 'List one frustrating situation. Divide elements into: "In My Power" vs "Outside My Power".', icon: LucideIcons.bookOpen, toolRoute: '/journal', toolLabel: 'Journal Audit', xpReward: 15),
      DayTask(id: 'd5_t2', title: 'Surrender What You Cannot Control', description: 'Mentally release anger over external delays, weather, or other people\'s opinions.', icon: LucideIcons.feather, xpReward: 15),
      DayTask(id: 'd5_t3', title: 'Amor Fati Micro-Reflection', description: 'Say: "Whatever happens today is fuel for my growth and character."', icon: LucideIcons.flame, xpReward: 20),
    ]),
    DayRoadmapItem(dayNumber: 6, title: 'Physical Vitality', category: 'Energy & Movement', phase: 'Phase 1: Genesis', phaseIndex: 1, icon: LucideIcons.dumbbell, tasks: [
      DayTask(id: 'd6_t1', title: 'Mobility Flow or Core Strength', description: 'Perform 15 minutes of functional mobility, yoga stretches, or bodyweight circuits.', icon: LucideIcons.dumbbell, toolRoute: '/workout', toolLabel: 'View Workout Flow', xpReward: 20),
      DayTask(id: 'd6_t2', title: 'Sunlight Exposure', description: 'Get 10 minutes of direct morning sunlight to align your circadian rhythm.', icon: LucideIcons.sun, xpReward: 15),
      DayTask(id: 'd6_t3', title: 'Post-Workout Stretch', description: 'Spend 5 minutes stretching hips and hamstrings to accelerate physical recovery.', icon: LucideIcons.userCheck, toolRoute: '/yoga', toolLabel: 'Mobility Stretch', xpReward: 15),
    ]),
    DayRoadmapItem(dayNumber: 7, title: '7-Day Genesis Review', category: 'Genesis Milestone', phase: 'Phase 1: Genesis', phaseIndex: 1, icon: LucideIcons.award, tasks: [
      DayTask(id: 'd7_t1', title: 'Week 1 Momentum Reflection', description: 'Write a brief review: How has your energy and intentionality shifted over 7 days?', icon: LucideIcons.penTool, toolRoute: '/journal', toolLabel: 'Log Week 1 Review', xpReward: 20),
      DayTask(id: 'd7_t2', title: 'Celebrate 1/3 Completion', description: 'You completed Phase 1! Acknowledge your dedication and unlock the Awakening Gate.', icon: LucideIcons.award, xpReward: 15),
      DayTask(id: 'd7_t3', title: 'Set Crucible Phase Standard', description: 'Commit to raising your standard for Phase 2: The Crucible (Days 8-14).', icon: LucideIcons.flame, xpReward: 15),
    ]),
    DayRoadmapItem(dayNumber: 8, title: 'Friction Tolerance', category: 'Mental Toughness', phase: 'Phase 2: Crucible', phaseIndex: 2, icon: LucideIcons.flame, tasks: [
      DayTask(id: 'd8_t1', title: 'Tackle The Hardest Task First', description: 'Spend the first 45 minutes of work conquering your most resisted priority.', icon: LucideIcons.target, xpReward: 20),
      DayTask(id: 'd8_t2', title: 'Cold Water Finish', description: 'End your morning shower with 30-60 seconds of cold water to build grit.', icon: LucideIcons.droplets, xpReward: 15),
      DayTask(id: 'd8_t3', title: 'Resist The Procrastination Urge', description: 'When feeling resistance, count down "3-2-1" and initiate immediate action.', icon: LucideIcons.zap, xpReward: 15),
    ]),
    DayRoadmapItem(dayNumber: 9, title: 'Deep Work Immersion', category: 'Focus Mastery', phase: 'Phase 2: Crucible', phaseIndex: 2, icon: LucideIcons.clock, tasks: [
      DayTask(id: 'd9_t1', title: '90-Minute Unbroken Sprint', description: 'Execute a single 90-minute deep work session in airplane mode with zero interruptions.', icon: LucideIcons.clock, xpReward: 20),
      DayTask(id: 'd9_t2', title: 'Environmental De-Clutter', description: 'Organize your physical workspace to remove visual cognitive load.', icon: LucideIcons.sparkles, xpReward: 15),
      DayTask(id: 'd9_t3', title: 'Brain Dump Scribe', description: 'Empty wandering thoughts into your journal before starting deep work.', icon: LucideIcons.penTool, toolRoute: '/journal', toolLabel: 'Write Brain Dump', xpReward: 15),
    ]),
    DayRoadmapItem(dayNumber: 10, title: 'Digital Cleanse', category: 'Attention Sovereignty', phase: 'Phase 2: Crucible', phaseIndex: 2, icon: LucideIcons.shield, tasks: [
      DayTask(id: 'd10_t1', title: 'App Notification Audit', description: 'Permanently disable non-essential banners, badges, and alerts on your phone.', icon: LucideIcons.bellOff, xpReward: 15),
      DayTask(id: 'd10_t2', title: 'Social Media Fast Until Sunset', description: 'No passive infinite scrolling until the workday is completely wrapped.', icon: LucideIcons.eyeOff, xpReward: 20),
      DayTask(id: 'd10_t3', title: 'Evening Tech Curfew', description: 'Store phone outside the bedroom 45 minutes before sleep.', icon: LucideIcons.moon, xpReward: 15),
    ]),
    DayRoadmapItem(dayNumber: 11, title: 'The Mirror of Truth', category: 'Self-Awareness', phase: 'Phase 2: Crucible', phaseIndex: 2, icon: LucideIcons.scanFace, tasks: [
      DayTask(id: 'd11_t1', title: 'Honest Habit Inventory', description: 'Identify 1 recurring micro-excuse you make and write down its counter-measure.', icon: LucideIcons.scanFace, toolRoute: '/journal', toolLabel: 'Write Honest Audit', xpReward: 20),
      DayTask(id: 'd11_t2', title: 'Self-Accountability Affirmation', description: 'Affirm: "I am the architect of my conditions. No excuses, only adjustments."', icon: LucideIcons.volume2, xpReward: 15),
      DayTask(id: 'd11_t3', title: 'Feedback Welcome', description: 'Ask a peer or partner: "What is one area I could show up better in?"', icon: LucideIcons.messageSquare, xpReward: 15),
    ]),
    DayRoadmapItem(dayNumber: 12, title: 'Endurance & Grit', category: 'Physical Resilience', phase: 'Phase 2: Crucible', phaseIndex: 2, icon: LucideIcons.activity, tasks: [
      DayTask(id: 'd12_t1', title: 'Zone 2 Cardio or Brisk Ruck', description: 'Maintain 30 minutes of aerobic steady-state effort (hiking, jogging, or cycling).', icon: LucideIcons.activity, xpReward: 20),
      DayTask(id: 'd12_t2', title: 'Mental Wall Breakthrough', description: 'When feeling tired at minute 20, push through 5 more minutes with steady breathing.', icon: LucideIcons.flame, xpReward: 15),
      DayTask(id: 'd12_t3', title: 'Hydration & Mineral Replenish', description: 'Replenish electrolytes and minerals after your endurance session.', icon: LucideIcons.droplets, xpReward: 15),
    ]),
    DayRoadmapItem(dayNumber: 13, title: 'Mindful Soundscape', category: 'Rest & Recovery', phase: 'Phase 2: Crucible', phaseIndex: 2, icon: LucideIcons.volume2, tasks: [
      DayTask(id: 'd13_t1', title: 'Ambient Audio Decompression', description: 'Listen to 10 minutes of binaural beats or soothing ambient soundscapes.', icon: LucideIcons.volume2, xpReward: 15),
      DayTask(id: 'd13_t2', title: 'Sensory Wind-Down', description: 'Dim the room lights 1 hour before sleep to signal melatonin release.', icon: LucideIcons.moon, xpReward: 15),
      DayTask(id: 'd13_t3', title: 'Evening Gratitude Scribe', description: 'Write 3 simple gifts you experienced during the day.', icon: LucideIcons.penTool, toolRoute: '/journal', toolLabel: 'Log Evening Win', xpReward: 20),
    ]),
    DayRoadmapItem(dayNumber: 14, title: '14-Day Fortitude', category: 'Crucible Milestone', phase: 'Phase 2: Crucible', phaseIndex: 2, icon: LucideIcons.trophy, tasks: [
      DayTask(id: 'd14_t1', title: 'Two-Week Victory Audit', description: 'Reflect on 14 straight days. Your identity as a disciplined builder is taking root.', icon: LucideIcons.trophy, toolRoute: '/journal', toolLabel: 'Open Journal', xpReward: 20),
      DayTask(id: 'd14_t2', title: 'Fortitude Crest Unlock', description: 'Celebrate unlocking your Crucible Fortitude milestone. You are in the final tier!', icon: LucideIcons.award, xpReward: 15),
      DayTask(id: 'd14_t3', title: 'Prepare for Sovereign Mastery', description: 'Set your sights on the final 7 days of identity transformation.', icon: LucideIcons.crown, xpReward: 15),
    ]),
    DayRoadmapItem(dayNumber: 15, title: 'Self-Compassion', category: 'Inner Peace', phase: 'Phase 3: Pinnacle', phaseIndex: 3, icon: LucideIcons.heart, tasks: [
      DayTask(id: 'd15_t1', title: 'Release The Inner Critic', description: 'Notice any harsh self-judgment today and replace it with constructive encouragement.', icon: LucideIcons.heart, toolRoute: '/journal', toolLabel: 'Journal Reflection', xpReward: 15),
      DayTask(id: 'd15_t2', title: 'Progress Over Perfection', description: 'Affirm: "Consistency over time surpasses sporadic perfection."', icon: LucideIcons.check, xpReward: 15),
      DayTask(id: 'd15_t3', title: 'Deep Rest Period', description: 'Give yourself 15 minutes of guilt-free restorative rest or reading.', icon: LucideIcons.moon, xpReward: 20),
    ]),
    DayRoadmapItem(dayNumber: 16, title: 'Core Focus Flow', category: 'Productivity', phase: 'Phase 3: Pinnacle', phaseIndex: 3, icon: LucideIcons.flame, tasks: [
      DayTask(id: 'd16_t1', title: '60-Minute Focus Sprint', description: 'Complete one uninterrupted 60-minute sprint on your single most vital project.', icon: LucideIcons.flame, xpReward: 20),
      DayTask(id: 'd16_t2', title: 'Ruthless Prioritization', description: 'Say no to at least one low-priority distraction or commitment today.', icon: LucideIcons.xCircle, xpReward: 15),
      DayTask(id: 'd16_t3', title: 'Deep Breath Transition', description: 'Take 5 grounding breaths before switching focus between projects.', icon: LucideIcons.wind, toolRoute: '/breathing', toolLabel: 'Reset Breath', xpReward: 15),
    ]),
    DayRoadmapItem(dayNumber: 17, title: 'Postural Reset', category: 'Physical Health', phase: 'Phase 3: Pinnacle', phaseIndex: 3, icon: LucideIcons.userCheck, tasks: [
      DayTask(id: 'd17_t1', title: 'Ergonomic Body Check', description: 'Adjust screen height and chair ergonomics to maintain open, upright chest posture.', icon: LucideIcons.userCheck, xpReward: 15),
      DayTask(id: 'd17_t2', title: 'Spinal Decompression Flow', description: 'Complete 3 rounds of cat-cow or thoracic extension stretches.', icon: LucideIcons.activity, toolRoute: '/yoga', toolLabel: 'Mobility Stretch', xpReward: 20),
      DayTask(id: 'd17_t3', title: 'Hydration & Mineral Intake', description: 'Ensure adequate water and electrolytes for sustained cognitive vitality.', icon: LucideIcons.droplets, xpReward: 15),
    ]),
    DayRoadmapItem(dayNumber: 18, title: 'Gratitude Reflection', category: 'Perspective Shift', phase: 'Phase 3: Pinnacle', phaseIndex: 3, icon: LucideIcons.penTool, tasks: [
      DayTask(id: 'd18_t1', title: 'Transformation Catalog', description: 'Document 3 tangible ways your habits and mindset have changed since Day 1.', icon: LucideIcons.penTool, toolRoute: '/journal', toolLabel: 'Open Journal', xpReward: 20),
      DayTask(id: 'd18_t2', title: 'Acknowledge The Struggle', description: 'Thank yourself for pushing through the days when motivation was absent.', icon: LucideIcons.sparkles, xpReward: 15),
      DayTask(id: 'd18_t3', title: 'Share Your Momentum', description: 'Encourage a peer or partner on their own personal development journey.', icon: LucideIcons.share2, xpReward: 15),
    ]),
    DayRoadmapItem(dayNumber: 19, title: 'Evening Wind-Down', category: 'Sleep Quality', phase: 'Phase 3: Pinnacle', phaseIndex: 3, icon: LucideIcons.moon, tasks: [
      DayTask(id: 'd19_t1', title: 'Digital Sunset at 9 PM', description: 'Turn off all monitors, laptops, and phone notifications 1 hour before sleep.', icon: LucideIcons.moon, xpReward: 20),
      DayTask(id: 'd19_t2', title: 'Room Temperature Drop', description: 'Ensure your bedroom is cool and well-ventilated for deep delta wave sleep.', icon: LucideIcons.thermometer, xpReward: 15),
      DayTask(id: 'd19_t3', title: 'Reflective Book Reading', description: 'Read 15 pages of philosophy, fiction, or biography under warm lighting.', icon: LucideIcons.bookOpen, xpReward: 15),
    ]),
    DayRoadmapItem(dayNumber: 20, title: 'Identity Solidified', category: 'Character Armor', phase: 'Phase 3: Pinnacle', phaseIndex: 3, icon: LucideIcons.shield, tasks: [
      DayTask(id: 'd20_t1', title: 'Personal Philosophy Manifesto', description: 'Write down your 3 non-negotiable core principles going forward in life.', icon: LucideIcons.shield, toolRoute: '/journal', toolLabel: 'Write Manifesto', xpReward: 20),
      DayTask(id: 'd20_t2', title: 'Reaffirm Lifelong Identity', description: 'Affirm: "Discipline is not what I do, it is who I am."', icon: LucideIcons.award, xpReward: 15),
      DayTask(id: 'd20_t3', title: 'Plan Beyond Day 21', description: 'Select your next 90-day physical and intellectual growth goals.', icon: LucideIcons.target, xpReward: 15),
    ]),
    DayRoadmapItem(dayNumber: 21, title: 'The Sovereign Crown', category: 'Identity Mastery', phase: 'Phase 3: Pinnacle', phaseIndex: 3, icon: LucideIcons.crown, tasks: [
      DayTask(id: 'd21_t1', title: '21-Day Mastery Celebration', description: 'Congratulations! You have completed the 21-Day VinR Transformation!', icon: LucideIcons.crown, toolRoute: '/journal', toolLabel: 'Log Crown Victory', xpReward: 25),
      DayTask(id: 'd21_t2', title: 'Trophy Room Induction', description: 'Unlock your Sovereign Crown trophy badge in your Profile trophy showcase.', icon: LucideIcons.trophy, xpReward: 15),
      DayTask(id: 'd21_t3', title: 'Seal The Identity Transformation', description: 'Take pride in the new standard of excellence and mental toughness you built.', icon: LucideIcons.sparkles, xpReward: 10),
    ]),
  ];

  // =============================================================================
  // CURATED SERPENTINE OFFSETS
  // Maximum right offset is clamped to +65.0 so nodes NEVER touch or hide behind
  // the AI Chathub floating action button on the right side of the screen!
  // =============================================================================
  static const List<double> _nodeOffsets = [
    0.0,    // Day 1 (Origin, Centered)
    48.0,   // Day 2 (Right)
    65.0,   // Day 3 (Peak Right - Safe from AI Chathub)
    25.0,   // Day 4 (Center-Right transition)
    -45.0,  // Day 5 (Center-Left)
    -75.0,  // Day 6 (Peak Left)
    0.0,    // Day 7 (Milestone 1 Genesis Chest - Centered)
    48.0,   // Day 8 (Crucible Entry - Right)
    65.0,   // Day 9 (Peak Right)
    25.0,   // Day 10 (Center-Right)
    -45.0,  // Day 11 (Center-Left)
    -75.0,  // Day 12 (Peak Left)
    -35.0,  // Day 13 (Center-Left)
    0.0,    // Day 14 (Milestone 2 Fortitude Trophy - Centered)
    45.0,   // Day 15 (Pinnacle Entry - Right)
    65.0,   // Day 16 (Peak Right)
    20.0,   // Day 17 (Center-Right)
    -40.0,  // Day 18 (Center-Left)
    -75.0,  // Day 19 (Peak Left)
    -30.0,  // Day 20 (Center-Left)
    0.0,    // Day 21 (Sovereign Summit Crown - Centered Finale)
  ];

  double _getNodeOffset(int dayNumber) {
    final idx = (dayNumber - 1).clamp(0, _nodeOffsets.length - 1);
    return _nodeOffsets[idx];
  }

  @override
  void initState() {
    super.initState();

    // Smooth organic breathing pulse
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
    _auraAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _shimmerController, curve: Curves.linear));

    _quoteFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _quoteFadeAnimation = CurvedAnimation(parent: _quoteFadeController, curve: Curves.easeInOut);
    _quoteFadeController.forward();
    _startQuoteLoop();

    _xpCountController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _xpCountAnimation = IntTween(begin: 0, end: 0).animate(CurvedAnimation(parent: _xpCountController, curve: Curves.easeOut));

    _rippleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
    _rippleAnimation = CurvedAnimation(parent: _rippleController, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) => _autoScrollToActive());
  }

  void _startQuoteLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 7));
      if (!mounted) break;
      await _quoteFadeController.reverse();
      if (!mounted) break;
      setState(() => _currentQuoteIndex = (_currentQuoteIndex + 1) % _compassQuotes.length);
      _quoteFadeController.forward();
    }
  }

  void _updateXPCounter(int newXP) {
    if (newXP == _targetXP) return;
    final oldXP = _targetXP;
    _targetXP = newXP;
    _xpCountAnimation = IntTween(begin: oldXP, end: newXP).animate(CurvedAnimation(parent: _xpCountController, curve: Curves.easeOut));
    _xpCountController..reset()..forward();
  }

  void _autoScrollToActive() {
    if (!_scrollController.hasClients) return;
    final streakState = ref.read(streakProvider);
    final todayDay = (streakState.totalDaysCompleted + 1).clamp(1, 21);
    double offset = 120.0;
    for (int i = 0; i < todayDay - 1; i++) {
      offset += 165.0;
      if (i == 6) offset += 150.0;
      if (i == 13) offset += 150.0;
    }
    final screenH = MediaQuery.of(context).size.height;
    final targetScroll = (offset - screenH / 2 + 50).clamp(0.0, double.infinity);
    _scrollController.animateTo(targetScroll, duration: const Duration(milliseconds: 900), curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    _quoteFadeController.dispose();
    _xpCountController.dispose();
    _rippleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleTask(String taskId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_todayCompletedTaskIds.contains(taskId)) {
        _todayCompletedTaskIds.remove(taskId);
      } else {
        _todayCompletedTaskIds.add(taskId);
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _openQuestBottomSheet(BuildContext context, DayRoadmapItem item, int totalDaysCompleted, bool isCompletedToday) {
    final isCompleted = item.dayNumber <= totalDaysCompleted;
    final isCurrent = item.dayNumber == totalDaysCompleted + 1 && !isCompletedToday;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true, // Guarantees modal renders ABOVE bottom navigation and FAB
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (modalContext) => _QuestDetailModal(
        item: item,
        isCompleted: isCompleted,
        isCurrent: isCurrent,
        totalDaysCompleted: totalDaysCompleted,
        completedTaskIds: isCompleted ? item.tasks.map((t) => t.id).toSet() : (isCurrent ? _todayCompletedTaskIds : <String>{}),
        onToggleTask: isCurrent ? _toggleTask : null,
        onCompletePressed: () {
          Navigator.pop(modalContext);
          ref.read(streakProvider.notifier).markDayComplete();
          CelebrationOverlay.show(context);
          VinRToast.show(context, message: 'Day ${item.dayNumber} Complete! (+50 XP)', icon: LucideIcons.flame, iconColor: VinRColors.gold);
        },
      ),
    );
  }

  void _scrollToPhase(int phaseIndex) {
    double offset = 120.0;
    if (phaseIndex == 2) offset += 7 * 165.0 + 150.0;
    if (phaseIndex == 3) offset += 14 * 165.0 + 300.0;
    _scrollController.animateTo(offset, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakProvider);
    final isLight = context.isLight;
    final activeGold = context.goldColor;
    final totalDaysCompleted = streak.totalDaysCompleted;
    final todayDayNumber = (totalDaysCompleted + 1).clamp(1, 21);
    final todayItem = _roadmap.firstWhere((item) => item.dayNumber == todayDayNumber, orElse: () => _roadmap.first);
    final daysRemaining = (21 - totalDaysCompleted).clamp(0, 21);
    final currentPhaseIndex = todayDayNumber <= 7 ? 1 : (todayDayNumber <= 14 ? 2 : 3);
    final currentPhaseTitle = currentPhaseIndex == 1 ? 'SECTION 1 \u2022 GENESIS' : (currentPhaseIndex == 2 ? 'SECTION 2 \u2022 CRUCIBLE' : 'SECTION 3 \u2022 PINNACLE');
    final currentPhaseSubtitle = currentPhaseIndex == 1 ? 'Mindset & Habits' : (currentPhaseIndex == 2 ? 'Resilience & Grit' : 'Sovereign Mastery');
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(320.0, 500.0);

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateXPCounter(totalDaysCompleted * 50));

    return CelebrationOverlay(
      child: Scaffold(
        backgroundColor: isLight ? const Color(0xFFF5F2EC) : VinRColors.voidBg,
        body: AmbientBackground(
          child: SafeArea(
            child: Stack(
              children: [
                // Scrollable roadmap trail with plenty of bottom padding for navigation bar and AI chathub clearance
                CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 155)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 200.0), // Ample bottom clearance
                        child: Center(
                          child: SizedBox(
                            width: contentWidth,
                            child: _buildRoadmapTrail(
                              context: context,
                              streak: streak,
                              todayDayNumber: todayDayNumber,
                              activeGold: activeGold,
                              isLight: isLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Enhanced Top Section Header
                Positioned(
                  top: 8, left: 16, right: 16,
                  child: _buildEnhancedTopHeader(
                    context: context,
                    currentPhaseIndex: currentPhaseIndex,
                    currentPhaseTitle: currentPhaseTitle,
                    currentPhaseSubtitle: currentPhaseSubtitle,
                    totalDaysCompleted: totalDaysCompleted,
                    daysRemaining: daysRemaining,
                    activeGold: activeGold,
                    isLight: isLight,
                    todayItem: todayItem,
                    todayDayNumber: todayDayNumber,
                    streak: streak,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ENHANCED TOP HEADER SECTION
  // Clean, consistent, luxurious Glassmorphic Horizon Header
  // ==========================================================================
  Widget _buildEnhancedTopHeader({
    required BuildContext context,
    required int currentPhaseIndex,
    required String currentPhaseTitle,
    required String currentPhaseSubtitle,
    required int totalDaysCompleted,
    required int daysRemaining,
    required Color activeGold,
    required bool isLight,
    required DayRoadmapItem todayItem,
    required int todayDayNumber,
    required dynamic streak,
  }) {
    final phaseProgress = totalDaysCompleted >= 21 ? 1.0 : (totalDaysCompleted % 7) / 7.0;
    final completedInPhase = totalDaysCompleted >= 21 ? 7 : (totalDaysCompleted % 7);
    final quote = _compassQuotes[_currentQuoteIndex];

    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white.withValues(alpha: 0.94) : VinRColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLight ? const Color(0x18000000) : VinRColors.borderGold.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.06 : 0.40),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Section Title Chip + Badges (XP & Days Left)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Section Selector Chip
              GestureDetector(
                onTap: () => _showSectionPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: activeGold.withValues(alpha: isLight ? 0.12 : 0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: activeGold.withValues(alpha: 0.35), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.compass, size: 11, color: activeGold),
                      const SizedBox(width: 5),
                      Text(
                        currentPhaseTitle,
                        style: TextStyle(
                          color: activeGold,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(LucideIcons.chevronDown, size: 10, color: activeGold),
                    ],
                  ),
                ),
              ),

              // Badges
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _xpCountAnimation,
                    builder: (context, _) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: VinRColors.xpGem.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: VinRColors.xpGem.withValues(alpha: 0.3), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.zap, size: 10.5, color: VinRColors.xpGem),
                          const SizedBox(width: 3),
                          Text('${_xpCountAnimation.value} XP', style: const TextStyle(color: VinRColors.xpGem, fontSize: 10, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: activeGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: activeGold.withValues(alpha: 0.3), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.flag, size: 10.5, color: activeGold),
                        const SizedBox(width: 3),
                        Text(
                          daysRemaining == 0 ? 'COMPLETE' : '$daysRemaining left',
                          style: TextStyle(color: activeGold, fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Row 2: Phase Subtitle + Progress Fraction
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentPhaseSubtitle,
                style: TextStyle(
                  color: context.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                '$completedInPhase / 7 Days Cleared',
                style: TextStyle(
                  color: context.textMutedColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Progress Bar with Shimmer Stardust
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: phaseProgress == 0 && totalDaysCompleted > 0 ? 1.0 : phaseProgress,
                  backgroundColor: isLight ? const Color(0xFFE5E0D5) : const Color(0xFF1B2232),
                  color: activeGold,
                  minHeight: 4,
                ),
              ),
              if (phaseProgress > 0 && phaseProgress < 1)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (context, _) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: phaseProgress,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: ShaderMask(
                          shaderCallback: (rect) => LinearGradient(
                            colors: [Colors.white.withValues(alpha: 0.0), Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.0)],
                            stops: [(_shimmerAnimation.value - 0.25).clamp(0.0, 1.0), _shimmerAnimation.value.clamp(0.0, 1.0), (_shimmerAnimation.value + 0.25).clamp(0.0, 1.0)],
                          ).createShader(rect),
                          blendMode: BlendMode.srcIn,
                          child: Container(height: 4, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Full-width Stoic Wisdom Quote (Never truncated!)
          FadeTransition(
            opacity: _quoteFadeAnimation,
            child: Row(
              children: [
                Icon(LucideIcons.sparkles, size: 10, color: activeGold.withValues(alpha: 0.7)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '"${quote['quote']}" — ${quote['author']}',
                    style: TextStyle(
                      color: context.textMutedColor,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION PICKER
  // ==========================================================================
  void _showSectionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        final isLight = context.isLight;
        return Container(
          decoration: BoxDecoration(
            color: isLight ? Colors.white : VinRColors.elevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text('SELECT ROADMAP SECTION', style: VinRTypography.label.copyWith(color: context.goldColor, fontSize: 11, letterSpacing: 1.0)),
                const SizedBox(height: 12),
                _buildSectionPickerItem(title: 'Section 1: Genesis', subtitle: 'Days 1-7 \u2022 Mindset Foundations', icon: LucideIcons.sparkles, onTap: () { Navigator.pop(modalCtx); _scrollToPhase(1); }),
                _buildSectionPickerItem(title: 'Section 2: Crucible', subtitle: 'Days 8-14 \u2022 Friction & Mental Grit', icon: LucideIcons.flame, onTap: () { Navigator.pop(modalCtx); _scrollToPhase(2); }),
                _buildSectionPickerItem(title: 'Section 3: Pinnacle', subtitle: 'Days 15-21 \u2022 Identity & Sovereign Crown', icon: LucideIcons.crown, onTap: () { Navigator.pop(modalCtx); _scrollToPhase(3); }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionPickerItem({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: context.goldColor.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(icon, color: context.goldColor, size: 18)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: context.textColor, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: context.textMutedColor, fontSize: 12)),
      trailing: Icon(LucideIcons.chevronRight, size: 16, color: context.textMutedColor),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  // ==========================================================================
  // ROADMAP TRAIL
  // Serpentine S-Curves within safe margins so nodes never hide behind AI Chathub
  // ==========================================================================
  Widget _buildRoadmapTrail({
    required BuildContext context,
    required dynamic streak,
    required int todayDayNumber,
    required Color activeGold,
    required bool isLight,
  }) {
    return Column(
      children: List.generate(_roadmap.length, (index) {
        final item = _roadmap[index];
        final dayNum = item.dayNumber;
        final isCompleted = dayNum <= streak.totalDaysCompleted;
        final isCurrent = dayNum == streak.totalDaysCompleted + 1 && !streak.isCompletedToday;
        final isNextLocked = dayNum == streak.totalDaysCompleted + 2 && !streak.isCompletedToday;
        final isMilestone = dayNum == 7 || dayNum == 14 || dayNum == 21;
        final nodeState = isCompleted ? PathNodeState.completed : (isCurrent ? PathNodeState.active : PathNodeState.locked);
        final currentXOffset = _getNodeOffset(dayNum);

        return Column(
          children: [
            // Architectural Gateway I (between Day 7 and Day 8)
            if (dayNum == 8)
              _buildArchitecturalGateway(
                context: context,
                romanNumeral: 'I',
                gatewayTitle: 'GATEWAY I: THE AWAKENING',
                quote: 'The mind once expanded to the dimensions of larger ideas, never returns to its original size.',
                author: 'Oliver Wendell Holmes',
                isUnlocked: streak.totalDaysCompleted >= 7,
                activeColor: VinRColors.gold,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.15, end: 0),

            // Architectural Gateway II (between Day 14 and Day 15)
            if (dayNum == 15)
              _buildArchitecturalGateway(
                context: context,
                romanNumeral: 'II',
                gatewayTitle: 'GATEWAY II: THE CRUCIBLE',
                quote: 'Difficulties strengthen the mind, as labor does the body.',
                author: 'Seneca',
                isUnlocked: streak.totalDaysCompleted >= 14,
                activeColor: VinRColors.sapphire,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.15, end: 0),

            // Curved Trail Connector from previous node
            if (index > 0)
              _buildCurvedTrailConnector(
                prevOffset: _getNodeOffset(dayNum - 1),
                currentOffset: currentXOffset,
                isCompleted: dayNum - 1 <= streak.totalDaysCompleted,
                activeGold: activeGold,
                isLight: isLight,
              ),

            // Node with Aura & Ripple Rings
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Active node luminous beacon aura (Smooth, organic breathing)
                if (isCurrent)
                  AnimatedBuilder(
                    animation: _auraAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(currentXOffset, 0),
                      child: Container(
                        width: 90 * _auraAnimation.value,
                        height: 90 * _auraAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: VinRColors.emerald.withValues(alpha: 0.12),
                          boxShadow: [
                            BoxShadow(
                              color: VinRColors.emerald.withValues(alpha: 0.28),
                              blurRadius: 26,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Ripple ring on the next locked milestone
                if (isNextLocked)
                  AnimatedBuilder(
                    animation: _rippleAnimation,
                    builder: (context, child) {
                      final rippleSize = 65.0 + (_rippleAnimation.value * 35);
                      return Transform.translate(
                        offset: Offset(currentXOffset, 0),
                        child: Container(
                          width: rippleSize,
                          height: rippleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: activeGold.withValues(alpha: (1.0 - _rippleAnimation.value) * 0.40),
                              width: 1.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // Node Widget
                Transform.translate(
                  offset: Offset(currentXOffset, 0),
                  child: VinRPathNode(
                    dayNumber: dayNum,
                    title: item.title,
                    category: item.category,
                    subtitle: '${item.tasks.length} Catalysts',
                    icon: isMilestone ? (dayNum == 21 ? LucideIcons.crown : LucideIcons.trophy) : item.icon,
                    state: nodeState,
                    isMilestone: isMilestone,
                    onTap: () => _openQuestBottomSheet(context, item, streak.totalDaysCompleted, streak.isCompletedToday),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // The Sovereign Summit Gateway at Day 21
            if (dayNum == 21)
              _buildArchitecturalGateway(
                context: context,
                romanNumeral: 'III',
                gatewayTitle: 'THE SOVEREIGN SUMMIT',
                quote: 'He who conquers himself is the mightiest warrior.\nYou have forged lifelong identity mastery.',
                author: 'VinR Sovereign Order',
                isUnlocked: streak.totalDaysCompleted >= 21,
                activeColor: VinRColors.gold,
                isSummit: true,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.15, end: 0),
          ],
        );
      }),
    );
  }

  // ==========================================================================
  // CURVED TRAIL CONNECTOR (High-contrast, luminous, 52px tall Bézier ribbon)
  // ==========================================================================
  Widget _buildCurvedTrailConnector({
    required double prevOffset,
    required double currentOffset,
    required bool isCompleted,
    required Color activeGold,
    required bool isLight,
  }) {
    return SizedBox(
      height: 52,
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, _) => CustomPaint(
          size: const Size(double.infinity, 52),
          painter: _TrailSegmentPainter(
            startX: prevOffset,
            endX: currentOffset,
            isCompleted: isCompleted,
            activeColor: activeGold,
            trackColor: isLight ? const Color(0xFFD0C8B8) : const Color(0xFF1E283C),
            coreTrackColor: isLight ? const Color(0xFFB8AE9C) : const Color(0xFF2E3D5C),
            shimmerProgress: isCompleted ? 0.0 : _shimmerAnimation.value,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ARCHITECTURAL GATEWAY (Tactile, glowing milestone portal card)
  // ==========================================================================
  Widget _buildArchitecturalGateway({
    required BuildContext context,
    required String romanNumeral,
    required String gatewayTitle,
    required String quote,
    required String author,
    required bool isUnlocked,
    required Color activeColor,
    bool isSummit = false,
  }) {
    final isLight = context.isLight;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? activeColor.withValues(alpha: isLight ? 0.08 : 0.12)
            : (isLight ? const Color(0xFFF7F5EE) : const Color(0xFF0F1420)),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isUnlocked
              ? activeColor.withValues(alpha: 0.55)
              : (isLight ? const Color(0xFFDDD8CC) : const Color(0xFF222B3E)),
          width: isUnlocked ? 1.5 : 1.0,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnlocked ? activeColor.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isUnlocked ? activeColor.withValues(alpha: 0.5) : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSummit ? LucideIcons.crown : (isUnlocked ? LucideIcons.sparkles : LucideIcons.lock),
                      size: 12,
                      color: isUnlocked ? activeColor : context.textGhostColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      romanNumeral,
                      style: TextStyle(
                        color: isUnlocked ? activeColor : context.textGhostColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  gatewayTitle,
                  style: TextStyle(
                    color: isUnlocked ? activeColor : context.textMutedColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 11.5,
                    letterSpacing: 0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            '"$quote"',
            style: TextStyle(
              color: context.textColor,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          Text(
            '— $author',
            style: TextStyle(
              color: context.textMutedColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? activeColor.withValues(alpha: 0.16)
                  : Colors.black.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUnlocked ? activeColor.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUnlocked ? LucideIcons.award : LucideIcons.shieldAlert,
                  size: 12,
                  color: isUnlocked ? activeColor : context.textGhostColor,
                ),
                const SizedBox(width: 6),
                Text(
                  isUnlocked
                      ? (isSummit ? 'SOVEREIGN ASCENSION COMPLETE (+100 XP)' : 'GATEWAY CLEARED (+50 XP)')
                      : 'LOCKED \u2022 CONQUER ALL PRIOR DAYS',
                  style: TextStyle(
                    color: isUnlocked ? activeColor : context.textGhostColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
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

// =============================================================================
// CUSTOM PAINTER: Trail Segment (Bézier + high-contrast stardust beads)
// =============================================================================
class _TrailSegmentPainter extends CustomPainter {
  final double startX;
  final double endX;
  final bool isCompleted;
  final Color activeColor;
  final Color trackColor;
  final Color coreTrackColor;
  final double shimmerProgress;

  _TrailSegmentPainter({
    required this.startX,
    required this.endX,
    required this.isCompleted,
    required this.activeColor,
    required this.trackColor,
    required this.coreTrackColor,
    this.shimmerProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final p0 = Offset(cx + startX, 0);
    final p1 = Offset(cx + endX, size.height);
    final cp0 = Offset(p0.dx, size.height * 0.5);
    final cp1 = Offset(p1.dx, size.height * 0.5);
    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..cubicTo(cp0.dx, cp0.dy, cp1.dx, cp1.dy, p1.dx, p1.dy);

    if (isCompleted) {
      canvas.drawPath(
        path,
        Paint()
          ..color = activeColor.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = activeColor.withValues(alpha: 0.40)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0
          ..strokeCap = StrokeCap.round,
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = activeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round,
      );
    } else {
      canvas.drawPath(
        path,
        Paint()
          ..color = trackColor.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0
          ..strokeCap = StrokeCap.round,
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = coreTrackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round,
      );
    }

    const dotCount = 5;
    for (int i = 1; i <= dotCount; i++) {
      final t = i / (dotCount + 1).toDouble();
      final dotPos = _cubicBezier(p0, cp0, cp1, p1, t);

      if (isCompleted) {
        canvas.drawCircle(
          dotPos,
          4.5,
          Paint()..color = activeColor.withValues(alpha: 0.3)..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          dotPos,
          2.5,
          Paint()..color = Colors.white..style = PaintingStyle.fill,
        );
      } else {
        canvas.drawCircle(
          dotPos,
          2.8,
          Paint()..color = coreTrackColor..style = PaintingStyle.fill,
        );
      }

      if (!isCompleted && shimmerProgress > 0) {
        final shimmerDist = ((t - shimmerProgress).abs());
        if (shimmerDist < 0.18) {
          final intensity = 1.0 - (shimmerDist / 0.18);
          canvas.drawCircle(
            dotPos,
            4.0 * intensity,
            Paint()
              ..color = activeColor.withValues(alpha: 0.45 * intensity)
              ..style = PaintingStyle.fill
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
          );
        }
      }
    }
  }

  Offset _cubicBezier(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final u = 1.0 - t;
    final tt = t * t;
    final uu = u * u;
    final uuu = uu * u;
    final ttt = tt * t;
    return Offset(
      uuu * p0.dx + 3 * uu * t * p1.dx + 3 * u * tt * p2.dx + ttt * p3.dx,
      uuu * p0.dy + 3 * uu * t * p1.dy + 3 * u * tt * p2.dy + ttt * p3.dy,
    );
  }

  @override
  bool shouldRepaint(covariant _TrailSegmentPainter old) =>
      old.startX != startX ||
      old.endX != endX ||
      old.isCompleted != isCompleted ||
      old.activeColor != activeColor ||
      old.shimmerProgress != shimmerProgress;
}

// =============================================================================
// QUEST DETAIL MODAL (Opens above bottom navigation bar & FAB with root navigator)
// =============================================================================
class _QuestDetailModal extends StatefulWidget {
  final DayRoadmapItem item;
  final bool isCompleted;
  final bool isCurrent;
  final int totalDaysCompleted;
  final Set<String> completedTaskIds;
  final void Function(String taskId)? onToggleTask;
  final VoidCallback onCompletePressed;

  const _QuestDetailModal({
    required this.item,
    required this.isCompleted,
    required this.isCurrent,
    required this.totalDaysCompleted,
    required this.completedTaskIds,
    this.onToggleTask,
    required this.onCompletePressed,
  });

  @override
  State<_QuestDetailModal> createState() => _QuestDetailModalState();
}

class _QuestDetailModalState extends State<_QuestDetailModal> with SingleTickerProviderStateMixin {
  late Set<String> _localCompletedTaskIds;
  int _selectedResonanceIndex = 0;
  final Set<String> _burstingTaskIds = {};
  late final AnimationController _burstController;

  static const List<Map<String, dynamic>> _resonanceMoods = [
    {'label': 'Focused', 'icon': LucideIcons.target},
    {'label': 'Calm', 'icon': LucideIcons.feather},
    {'label': 'Energized', 'icon': LucideIcons.zap},
    {'label': 'Resilient', 'icon': LucideIcons.shield},
  ];

  @override
  void initState() {
    super.initState();
    _localCompletedTaskIds = Set<String>.from(widget.completedTaskIds);
    _burstController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _burstController.dispose();
    super.dispose();
  }

  void _handleToggle(String taskId) {
    HapticFeedback.selectionClick();
    final isNowCompleting = !_localCompletedTaskIds.contains(taskId);
    setState(() {
      if (_localCompletedTaskIds.contains(taskId)) {
        _localCompletedTaskIds.remove(taskId);
      } else {
        _localCompletedTaskIds.add(taskId);
        _burstingTaskIds.add(taskId);
      }
    });

    if (isNowCompleting) {
      HapticFeedback.mediumImpact();
      _burstController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) setState(() => _burstingTaskIds.remove(taskId));
      });
    }

    widget.onToggleTask?.call(taskId);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? Colors.white : VinRColors.elevated;
    final primaryTextColor = isLight ? const Color(0xFF1A1208) : VinRColors.textPrimary;
    final mutedTextColor = isLight ? const Color(0xFF5C5446) : VinRColors.textMuted;
    final activeGold = isLight ? const Color(0xFFB8832A) : VinRColors.gold;
    final allTasksDone = _localCompletedTaskIds.length == widget.item.tasks.length;
    final progress = widget.item.tasks.isEmpty ? 1.0 : (_localCompletedTaskIds.length / widget.item.tasks.length);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isLight ? const Color(0x22000000) : VinRColors.borderGold,
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.fromLTRB(22, 16, 22, max(24.0, bottomInset + 16)),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: mutedTextColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: widget.isCompleted
                            ? VinRColors.emerald.withValues(alpha: 0.15)
                            : (widget.isCurrent ? activeGold.withValues(alpha: 0.18) : Colors.grey.withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'DAY ${widget.item.dayNumber} \u2022 ${widget.item.phase.toUpperCase()}',
                        style: TextStyle(
                          color: widget.isCompleted
                              ? VinRColors.emerald
                              : (widget.isCurrent ? activeGold : mutedTextColor),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: VinRColors.xpGem.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(LucideIcons.zap, size: 13, color: VinRColors.xpGem),
                        SizedBox(width: 4),
                        Text('+50 XP', style: TextStyle(color: VinRColors.xpGem, fontSize: 11, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(widget.item.title, style: VinRTypography.h1.copyWith(fontSize: 22, color: primaryTextColor)),
              const SizedBox(height: 4),
              Text(widget.item.category, style: VinRTypography.bodySm.copyWith(color: mutedTextColor)),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DAILY CATALYSTS (${_localCompletedTaskIds.length}/${widget.item.tasks.length})',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: activeGold),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: allTasksDone ? VinRColors.emerald : activeGold),
                  ),
                ],
              ),
              const SizedBox(height: 7),
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

              Column(
                children: widget.item.tasks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final task = entry.value;
                  final isDone = _localCompletedTaskIds.contains(task.id);
                  final isBursting = _burstingTaskIds.contains(task.id);

                  return GestureDetector(
                    onTap: widget.isCurrent ? () => _handleToggle(task.id) : null,
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDone
                            ? VinRColors.emerald.withValues(alpha: isLight ? 0.08 : 0.12)
                            : (isLight ? const Color(0xFFF7F5F0) : VinRColors.surface),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDone ? VinRColors.emerald.withValues(alpha: 0.5) : (isLight ? const Color(0x15000000) : VinRColors.border),
                          width: isDone ? 1.5 : 1.0,
                        ),
                        boxShadow: isBursting ? [BoxShadow(color: VinRColors.emerald.withValues(alpha: 0.35), blurRadius: 16, spreadRadius: 2)] : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedScale(
                                scale: isBursting ? 1.25 : 1.0,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.elasticOut,
                                child: Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDone ? VinRColors.emerald : Colors.transparent,
                                    border: Border.all(color: isDone ? VinRColors.emerald : activeGold, width: 2),
                                  ),
                                  child: isDone
                                      ? const Icon(LucideIcons.check, size: 17, color: Colors.white)
                                      : Center(child: Text('${index + 1}', style: TextStyle(color: activeGold, fontSize: 11, fontWeight: FontWeight.bold))),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            task.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: primaryTextColor,
                                              fontSize: 13.5,
                                              decoration: isDone ? TextDecoration.lineThrough : null,
                                              decorationColor: mutedTextColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('+${task.xpReward} XP', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: isDone ? VinRColors.emerald : activeGold)),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(task.description, style: TextStyle(color: mutedTextColor, fontSize: 12, height: 1.35)),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ).animate(delay: (index * 60).ms).fadeIn(duration: 300.ms).slideY(begin: 0.15, end: 0);
                }).toList(),
              ),

              const SizedBox(height: 8),

              Text('MINDSET RESONANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: mutedTextColor)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 6,
                children: List.generate(_resonanceMoods.length, (idx) {
                  final isSelected = _selectedResonanceIndex == idx;
                  final mood = _resonanceMoods[idx];
                  final String label = mood['label'] as String;
                  final IconData icon = mood['icon'] as IconData;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedResonanceIndex = idx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? activeGold.withValues(alpha: 0.2) : (isLight ? const Color(0xFFEDE9DF) : VinRColors.surface),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? activeGold : Colors.transparent, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 13, color: isSelected ? activeGold : mutedTextColor),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? primaryTextColor : mutedTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              if (widget.isCompleted)
                Tactile3DButton(
                  text: 'Quest Completed',
                  variant: TactileButtonVariant.emerald,
                  icon: LucideIcons.checkCheck,
                  onPressed: () => Navigator.pop(context),
                )
              else if (widget.isCurrent)
                Tactile3DButton(
                  text: allTasksDone
                      ? 'Complete Day ${widget.item.dayNumber} Mission'
                      : 'Complete Mission (${_localCompletedTaskIds.length}/${widget.item.tasks.length})',
                  variant: TactileButtonVariant.gold,
                  badgeText: '+50 XP',
                  onPressed: widget.onCompletePressed,
                )
              else
                Tactile3DButton(
                  text: 'Locked \u2022 Complete Day ${widget.totalDaysCompleted} First',
                  variant: TactileButtonVariant.surface,
                  icon: LucideIcons.lock,
                  onPressed: () => Navigator.pop(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
