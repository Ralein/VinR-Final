import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vinr_app/core/widgets/tactile_3d_button.dart';
import 'package:vinr_app/core/widgets/celebration_confetti.dart';
import 'package:vinr_app/core/widgets/duolingo_path_node.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Duolingo-Style Tactile UI Components Tests', () {
    testWidgets('Tactile3DButton renders text, badge, and handles tap callback', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Tactile3DButton(
                text: 'Claim Quest Reward',
                badgeText: '+50 XP',
                icon: LucideIcons.trophy,
                onPressed: () => wasTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Claim Quest Reward'), findsOneWidget);
      expect(find.text('+50 XP'), findsOneWidget);
      expect(find.byIcon(LucideIcons.trophy), findsOneWidget);

      await tester.tap(find.text('Claim Quest Reward'));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
    });

    testWidgets('DuolingoPathNode renders active and completed states', (WidgetTester tester) async {
      bool nodeTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: DuolingoPathNode(
                dayNumber: 1,
                title: 'Intention & Reset',
                category: 'Mindset',
                icon: LucideIcons.compass,
                state: PathNodeState.active,
                onTap: () => nodeTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Day 1'), findsOneWidget);
      expect(find.text('TODAY'), findsOneWidget);

      await tester.tap(find.text('Day 1'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(nodeTapped, isTrue);
    });

    testWidgets('CelebrationOverlay triggers particle explosion without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CelebrationOverlay(
            child: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => CelebrationOverlay.show(context),
                  child: const Text('Burst'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Burst'), findsOneWidget);
      await tester.tap(find.text('Burst'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();
    });
  });
}
