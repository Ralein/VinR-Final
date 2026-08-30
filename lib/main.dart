import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/ai/application/ai_scheduler.dart';
import 'core/ai/infrastructure/runtime/model_manager.dart';
import 'core/theme/vinr_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/navigation/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: VinRApp(),
    ),
  );
}

class VinRApp extends ConsumerStatefulWidget {
  const VinRApp({super.key});

  @override
  ConsumerState<VinRApp> createState() => _VinRAppState();
}

class _VinRAppState extends ConsumerState<VinRApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      debugPrint('VinRApp: App backgrounded or paused. Cancelling background AI tasks.');
      AiScheduler.instance.clearBackgroundQueue();
    }
  }

  @override
  void didHaveMemoryPressure() {
    debugPrint('VinRApp: System memory pressure warning received! Unloading AI model.');
    AiScheduler.instance.cancelCurrent();
    AiScheduler.instance.clearBackgroundQueue();
    ModelManager.instance.unloadModel();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'VinR — Emotional Wellness & Growth Platform',
      debugShowCheckedModeBanner: false,
      theme: VinRTheme.lightTheme,
      darkTheme: VinRTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
