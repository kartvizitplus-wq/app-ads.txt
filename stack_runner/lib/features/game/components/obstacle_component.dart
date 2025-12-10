import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../stack_runner_game.dart';
import 'player_component.dart';

class ObstacleComponent extends RectangleComponent
    with CollisionCallbacks, HasGameRef<StackRunnerGame> {
  ObstacleComponent({required this.lane, required this.widthFactor})
      : super(
          size: Vector2.zero(),
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0xFFFF3366),
        );

  final int lane;
  final double widthFactor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(gameRef.laneWidth * widthFactor, 18);
    position = Vector2(gameRef.laneCenter(lane), -size.y);
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += gameRef.currentScrollSpeed * dt;
    if (position.y - size.y / 2 > gameRef.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      gameRef.onPlayerHit();
    }
  }
}
