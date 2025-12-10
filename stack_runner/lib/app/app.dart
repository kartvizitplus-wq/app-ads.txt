import 'package:flutter/material.dart';

import '../core/analytics/analytics_service.dart';
import '../features/game/game_screen.dart';
import '../features/menu/menu_screen.dart';
import 'theme.dart';

class StackRunnerApp extends StatefulWidget {
  const StackRunnerApp({super.key});

  @override
  State<StackRunnerApp> createState() => _StackRunnerAppState();
}

class _StackRunnerAppState extends State<StackRunnerApp> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.menuViewed();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stack Runner',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const MenuScreen(),
      routes: {
        GameScreen.routeName: (_) => const GameScreen(),
      },
    );
  }
}
