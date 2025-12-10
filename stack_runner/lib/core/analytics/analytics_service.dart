import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();
  FirebaseAnalytics? _analytics;

  Future<void> menuViewed() => _safeLog(
        (analytics) => analytics.logEvent(name: 'menu_viewed'),
      );

  Future<void> startButtonTapped() => _safeLog(
        (analytics) => analytics.logEvent(name: 'start_button_tapped'),
      );

  Future<void> runStarted() => _safeLog(
        (analytics) => analytics.logEvent(name: 'run_started'),
      );

  Future<void> runFinished(int score) => _safeLog(
        (analytics) => analytics.logEvent(
          name: 'run_finished',
          parameters: {'score': score},
        ),
      );

  Future<void> floorClimbed(int floor) => _safeLog(
        (analytics) => analytics.logEvent(
          name: 'floor_climbed',
          parameters: {'floor': floor},
        ),
      );

  Future<void> rewardedContinue() => _safeLog(
        (analytics) => analytics.logEvent(name: 'rewarded_continue'),
      );

  Future<void> _safeLog(
    Future<void> Function(FirebaseAnalytics analytics) callback,
  ) async {
    try {
      final analytics = _analytics ??= FirebaseAnalytics.instance;
      await callback(analytics);
    } catch (_) {
      // Analytics failures should never crash gameplay.
    }
  }
}
