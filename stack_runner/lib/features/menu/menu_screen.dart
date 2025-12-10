import 'package:flutter/material.dart';

import '../../core/ads/banner_ad_container.dart';
import '../../core/analytics/analytics_service.dart';
import '../game/game_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  static const routeName = '/';

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _isNavigating = false;

  Future<void> _startGame() async {
    if (_isNavigating) {
      return;
    }

    setState(() => _isNavigating = true);
    await AnalyticsService.instance.startButtonTapped();
    await AnalyticsService.instance.runStarted();
    if (!mounted) {
      return;
    }

    await Navigator.of(context).pushNamed(GameScreen.routeName);
    if (mounted) {
      setState(() => _isNavigating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF050B18), Color(0xFF0F1B33)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 48),
                  Text(
                    'Stack Runner',
                    style:
                        theme.textTheme.headlineMedium?.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Climb endlessly, dodge obstacles, and set a new record.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _isNavigating ? null : _startGame,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Start Run'),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: BannerAdContainer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
