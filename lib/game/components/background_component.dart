import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

import '../../core/asset_paths.dart';
import '../sushi_roll_rush_game.dart';

class BackgroundComponent extends ParallaxComponent<SushiRollRushGame> {
  BackgroundComponent() : super(priority: -10);

  @override
  Future<void> onLoad() async {
    // The base speed will be controlled by the game's level config
    final speed = game.levelConfig.scrollSpeed;
    
    // Using the wood texture for the conveyor belt look
    // We strip the 'assets/images/' prefix since Flame expects paths relative to that
    final bgImage = AssetPaths.bgWood.split('/').last;
    
    parallax = await game.loadParallax(
      [
        ParallaxImageData(bgImage),
      ],
      baseVelocity: Vector2(0, -speed), // Negative Y for moving up (conveyor moves up/forward)
      repeat: ImageRepeat.repeat,
      fill: LayerFill.width,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update speed if level changes or multiplier changes
    if (parallax != null) {
      parallax!.baseVelocity = Vector2(0, -game.effectiveScrollSpeed);
    }
  }
}
