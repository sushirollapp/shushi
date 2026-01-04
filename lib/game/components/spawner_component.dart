import 'dart:math';

import 'package:flame/components.dart';

import '../../core/asset_paths.dart';
import '../../core/constants.dart';
import '../sushi_roll_rush_game.dart';
import 'ingredient_component.dart';
import 'obstacle_component.dart';

class SpawnerComponent extends Component with HasGameReference<SushiRollRushGame> {
  final Random _random = Random();
  double _timer = 0.0;
  double _nextSpawnInterval = 1.5;
  
  // Pattern System
  final List<SpawnRequest> _patternQueue = [];
  bool _isSpawningPattern = false;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _resetTimer();
  }

  void _resetTimer() {
    _timer = 0.0;
    
    // Scale interval based on level number
    double baseInterval = GameConstants.baseSpawnInterval - ((game.currentLevel - 1) * 0.1);
    baseInterval = max(baseInterval, GameConstants.minSpawnInterval);
    
    // If in pattern mode, spawn faster
    if (_isSpawningPattern && _patternQueue.isNotEmpty) {
      _nextSpawnInterval = 0.5; // Fast spawns for patterns
    } else {
      // Normal random variance
      double variance = baseInterval * 0.2;
      _nextSpawnInterval = baseInterval + (_random.nextDouble() * variance * 2 - variance);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!game.isPlaying || game.isPaused || game.isGameOver) return;
    
    _timer += dt;
    if (_timer >= _nextSpawnInterval) {
      _spawnItem();
      _resetTimer();
    }
  }
  
  void _spawnItem() {
    // Priority 1: Process Pattern Queue
    if (_patternQueue.isNotEmpty) {
      _isSpawningPattern = true;
      final request = _patternQueue.removeAt(0);
      _spawnEntity(request.lane, request.isObstacle);
      
      if (_patternQueue.isEmpty) {
        _isSpawningPattern = false;
      }
      return;
    }
    
    // Priority 2: Chance to trigger a new pattern (20% chance)
    if (_random.nextDouble() < 0.2) {
      _generatePattern();
      // Immediately spawn first item of pattern
      if (_patternQueue.isNotEmpty) {
         _isSpawningPattern = true;
         final request = _patternQueue.removeAt(0);
         _spawnEntity(request.lane, request.isObstacle);
         return;
      }
    }
    
    // Priority 3: Random Spawn
    // Pick a lane (0, 1, 2)
    final laneIndex = _random.nextInt(GameConstants.laneCount);
    // Use current obstacle ratio (dynamic in endless mode)
    final isObstacle = _random.nextDouble() < game.currentObstacleRatio;
    
    _spawnEntity(laneIndex, isObstacle);
  }
  
  void _spawnEntity(int laneIndex, bool isObstacle) {
    double xPos = 0;
    switch (laneIndex) {
      case 0:
        xPos = game.size.x / 2 + GameConstants.laneLeft;
        break;
      case 1:
        xPos = game.size.x / 2 + GameConstants.laneCenter;
        break;
      case 2:
        xPos = game.size.x / 2 + GameConstants.laneRight;
        break;
    }
    
    if (isObstacle) {
      final spritePath = AssetPaths.obstacles[_random.nextInt(AssetPaths.obstacles.length)];
      game.add(ObstacleComponent(spritePath: spritePath)
        ..position = Vector2(xPos, -100)
      );
    } else {
      final spritePath = AssetPaths.ingredients[_random.nextInt(AssetPaths.ingredients.length)];
      game.add(IngredientComponent(spritePath: spritePath)
        ..position = Vector2(xPos, -100)
      );
    }
  }
  
  void _generatePattern() {
    final patternType = _random.nextInt(3); // 0, 1, 2
    
    switch (patternType) {
      case 0: // "The Line" - 3 ingredients in a row
        final lane = _random.nextInt(3);
        _patternQueue.add(SpawnRequest(lane: lane, isObstacle: false));
        _patternQueue.add(SpawnRequest(lane: lane, isObstacle: false));
        _patternQueue.add(SpawnRequest(lane: lane, isObstacle: false));
        break;
        
      case 1: // "The Slalom" - Left, Center, Right (Ingredients)
        _patternQueue.add(SpawnRequest(lane: 0, isObstacle: false));
        _patternQueue.add(SpawnRequest(lane: 1, isObstacle: false));
        _patternQueue.add(SpawnRequest(lane: 2, isObstacle: false));
        break;
        
      case 2: // "The Wall" - 2 obstacles, 1 gap
        // We push a row where 2 lanes have obstacles
        // Since queue is sequential in time, this spawns them "close" but not simultaneous unless we change timer logic
        // With 0.5s interval, they come one after another
        // To make a "wall", we might need simultaneous spawning or very fast.
        // Let's stick to sequential patterns for now.
        // Left Obstacle, Right Obstacle (Gap Center)
        _patternQueue.add(SpawnRequest(lane: 0, isObstacle: true));
        _patternQueue.add(SpawnRequest(lane: 2, isObstacle: true));
        break;
    }
  }
}

class SpawnRequest {
  final int lane;
  final bool isObstacle;
  
  SpawnRequest({required this.lane, required this.isObstacle});
}
