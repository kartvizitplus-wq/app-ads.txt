import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../stack_runner_game.dart';

class PlayerComponent extends RectangleComponent
    with CollisionCallbacks, HasGameRef<StackRunnerGame> {
  PlayerComponent({required this.laneCount})
      : super(
          size: Vector2.all(40),
          paint: Paint()..color = const Color(0xFF7DF9FF),
          anchor: Anchor.center,
        );

  final int laneCount;
  final double _moveSpeed = 420;
  int _targetLane = 0;
  int _currentLane = 0;

  int get currentLane => _currentLane;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    _currentLane = laneCount ~/ 2;
    _targetLane = _currentLane;
  }

  void moveLeft() {
    _targetLane = max(0, _targetLane - 1);
  }

  void moveRight() {
    _targetLane = min(laneCount - 1, _targetLane + 1);
  }

  void resetLane() {
    _currentLane = laneCount ~/ 2;
    _targetLane = _currentLane;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final targetX = gameRef.laneCenter(_targetLane);
    final dx = targetX - position.x;
    if (dx.abs() <= _moveSpeed * dt) {
      position.x = targetX;
      _currentLane = _targetLane;
    } else {
      position.x += _moveSpeed * dt * dx.sign;
    }
  }
}
