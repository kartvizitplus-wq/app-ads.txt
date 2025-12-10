import 'dart:math';
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/remote_config/remote_config_service.dart';
import 'components/obstacle_component.dart';
import 'components/player_component.dart';

class StackRunnerGame extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  StackRunnerGame({
    required this.remoteConfigService,
    required this.analyticsService,
    required this.onGameOver,
  });

  final RemoteConfigService remoteConfigService;
  final AnalyticsService analyticsService;
  final VoidCallback onGameOver;

  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);

  late final PlayerComponent _player;
  final Random _random = Random();
  double _distance = 0;
  double _spawnTimer = 0;
  double _laneWidth = 0;
  double _canvasHeight = 0;
  bool _isGameOver = false;
  bool _initialized = false;
  double _invincibilityTimer = 0;

  static const int laneCount = 3;
  static const double _floorHeight = 120;

  double get currentScrollSpeed =>
      (140 + scoreNotifier.value * 2.2) * remoteConfigService.speedMultiplier;
  double get laneWidth => _laneWidth;

  double laneCenter(int lane) {
    if (laneWidth <= 0) {
      return 0;
    }
    return (laneWidth * lane) + laneWidth / 2;
  }

  @override
  Color backgroundColor() => const Color(0xFF050B18);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _player = PlayerComponent(laneCount: laneCount);
    add(_player);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _laneWidth = laneCount == 0 ? 0 : size.x / laneCount;
    _canvasHeight = size.y;
    _player.position = Vector2(laneCenter(_player.currentLane), size.y * 0.75);
    if (!_initialized && size.x > 0 && size.y > 0) {
      _initialized = true;
      reset();
    }
  }

  void reset() {
    children
        .whereType<ObstacleComponent>()
        .toList()
        .forEach((obstacle) => obstacle.removeFromParent());
    scoreNotifier.value = 0;
    _distance = 0;
    _spawnTimer = 0;
    _invincibilityTimer = 0;
    _isGameOver = false;
    if (_canvasHeight == 0) {
      return;
    }
    _player
      ..resetLane()
      ..position =
          Vector2(laneCenter(_player.currentLane), _canvasHeight * 0.75);
    resumeEngine();
  }

  void grantSecondChance() {
    if (!_isGameOver) {
      return;
    }
    _invincibilityTimer = 2.5;
    _isGameOver = false;
    resumeEngine();
  }

  void onPlayerHit() {
    if (_invincibilityTimer > 0 || _isGameOver) {
      return;
    }
    _isGameOver = true;
    pauseEngine();
    onGameOver();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_initialized || _isGameOver) {
      return;
    }

    _invincibilityTimer = (_invincibilityTimer - dt).clamp(0, double.infinity);

    final speed = currentScrollSpeed;
    _distance += speed * dt;
    _spawnTimer += dt;

    final floors = (_distance / _floorHeight).floor();
    if (floors > scoreNotifier.value) {
      scoreNotifier.value = floors;
      analyticsService.floorClimbed(floors);
    }

    final spawnIntervalSeconds = remoteConfigService.spawnIntervalMs / 1000;
    if (_spawnTimer >= spawnIntervalSeconds) {
      _spawnTimer = 0;
      _spawnObstacleRow();
    }
  }

  void _spawnObstacleRow() {
    if (laneWidth <= 0) {
      return;
    }
    final safeLane = _random.nextInt(laneCount);
    for (var lane = 0; lane < laneCount; lane++) {
      if (lane == safeLane) {
        continue;
      }
      final widthFactor = 0.4 + remoteConfigService.gapFactor;
      add(ObstacleComponent(
          lane: lane, widthFactor: widthFactor.clamp(0.3, 0.9)));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (_isGameOver || !_initialized) {
      return;
    }
    final tapX = event.canvasPosition.x;
    tapX < size.x / 2 ? _player.moveLeft() : _player.moveRight();
  }

  void disposeGame() {
    scoreNotifier.dispose();
  }
}
