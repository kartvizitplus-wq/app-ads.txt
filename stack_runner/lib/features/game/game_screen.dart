import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/ads/ads_constants.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/remote_config/remote_config_service.dart';
import 'stack_runner_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const routeName = '/game';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final StackRunnerGame _game;
  InterstitialAd? _interstitialAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isGameOver = false;
  int _finalScore = 0;

  @override
  void initState() {
    super.initState();
    _game = StackRunnerGame(
      remoteConfigService: RemoteConfigService.instance,
      analyticsService: AnalyticsService.instance,
      onGameOver: _onGameOver,
    );
    _game.scoreNotifier.addListener(_scoreListener);
    _loadInterstitial();
    _loadRewardedInterstitial();
  }

  void _scoreListener() {
    if (!_isGameOver) {
      setState(() => _finalScore = _game.scoreNotifier.value);
    }
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdsConstants.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  void _loadRewardedInterstitial() {
    RewardedInterstitialAd.load(
      adUnitId: AdsConstants.rewardedInterstitialUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) => _rewardedInterstitialAd = ad,
        onAdFailedToLoad: (_) => _rewardedInterstitialAd = null,
      ),
    );
  }

  void _onGameOver() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isGameOver = true;
      _finalScore = _game.scoreNotifier.value;
    });
    AnalyticsService.instance.runFinished(_finalScore);
    _showInterstitial();
  }

  void _showInterstitial() {
    final ad = _interstitialAd;
    if (ad == null) {
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (_, __) => ad.dispose(),
    );
    ad.show();
    _interstitialAd = null;
  }

  void _showRewardedInterstitial() {
    final ad = _rewardedInterstitialAd;
    if (ad == null) {
      _loadRewardedInterstitial();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) => _loadRewardedInterstitial(),
      onAdFailedToShowFullScreenContent: (_, __) => _loadRewardedInterstitial(),
    );

    ad.show(onUserEarnedReward: (_, __) {
      AnalyticsService.instance.rewardedContinue();
      _game.grantSecondChance();
      setState(() => _isGameOver = false);
    });

    _rewardedInterstitialAd = null;
  }

  void _restartGame() {
    AnalyticsService.instance.runStarted();
    _game.reset();
    _loadInterstitial();
    if (mounted) {
      setState(() {
        _isGameOver = false;
        _finalScore = 0;
      });
    }
  }

  @override
  void dispose() {
    _game.scoreNotifier.removeListener(_scoreListener);
    _game.disposeGame();
    _interstitialAd?.dispose();
    _rewardedInterstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF050B18), Color(0xFF0F1B33)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: GameWidget(game: _game),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Card(
                  color: Colors.black.withOpacity(0.4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Text('Score $_finalScore'),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              if (_isGameOver)
                _GameOverOverlay(
                  score: _finalScore,
                  onRestart: _restartGame,
                  onExit: () => Navigator.of(context).pop(),
                  onSecondChance: _showRewardedInterstitial,
                  canUseSecondChance: _rewardedInterstitialAd != null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({
    required this.score,
    required this.onRestart,
    required this.onExit,
    required this.onSecondChance,
    required this.canUseSecondChance,
  });

  final int score;
  final VoidCallback onRestart;
  final VoidCallback onExit;
  final VoidCallback onSecondChance;
  final bool canUseSecondChance;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Game Over',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text('Floors climbed: $score'),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: onRestart, child: const Text('Retry')),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: canUseSecondChance ? onSecondChance : null,
                  child: const Text('Second Chance (Ad)'),
                ),
                const SizedBox(height: 12),
                TextButton(
                    onPressed: onExit, child: const Text('Back to Menu')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
