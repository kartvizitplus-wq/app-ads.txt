import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService instance = RemoteConfigService._();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    await _remoteConfig.setDefaults(<String, Object>{
      'obstacle_speed_multiplier': 1.0,
      'spawn_interval_ms': 1200,
      'obstacle_gap_factor': 0.4,
    });

    await _remoteConfig.fetchAndActivate();
    _initialized = true;
  }

  double get speedMultiplier =>
      _remoteConfig.getDouble('obstacle_speed_multiplier').clamp(0.5, 3.0);

  int get spawnIntervalMs =>
      _remoteConfig.getInt('spawn_interval_ms').clamp(400, 4000);

  double get gapFactor =>
      _remoteConfig.getDouble('obstacle_gap_factor').clamp(0.2, 0.8);
}
