import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../core/game_colors.dart';
import '../core/constants.dart';
import '../core/asset_paths.dart';
import '../managers/audio_manager.dart';
import '../managers/data_manager.dart';
import 'components/background_component.dart';
import 'components/player_component.dart';
import 'components/spawner_component.dart';
import 'components/ingredient_component.dart';
import 'components/obstacle_component.dart';
import 'components/finish_line_component.dart';
import 'components/floating_text_component.dart';

/// Main game class for Sushi Roll Rush
/// Implements the core game loop with collision detection and swipe controls
class SushiRollRushGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        TapCallbacks,
        DragCallbacks,
        HasCollisionDetection {
  // Random for particles
  final Random _random = Random();

  // ============================================
  // GAME STATE
  // ============================================

  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> collectedIngredients = ValueNotifier(0);
  final ValueNotifier<double> levelProgress = ValueNotifier(0.0);

  // Endless mode specific
  final ValueNotifier<int> distanceTraveled = ValueNotifier(0);
  bool isEndlessMode = false;
  bool isNewRecord = false; // Track if current run is a new best
  double _endlessSpeed = GameConstants.endlessStartSpeed;

  int currentLevel = 1;
  double _elapsedTime = 0.0;
  bool _finishLineSpawned = false;

  bool isPlaying = false;
  bool isPaused = false;
  bool isGameOver = false;
  bool isVictory = false;

  // Current lane (0 = left, 1 = center, 2 = right)
  int currentLane = 1;

  // Speed control
  double scrollSpeedMultiplier = 1.0;
  double _slowdownTimer = 0.0;

  // Components
  late PlayerComponent player;
  late SpawnerComponent spawner;

  // ============================================
  // LEVEL CONFIGURATION
  // ============================================

  late LevelConfig levelConfig;

  // Getter for current effective scroll speed
  double get effectiveScrollSpeed {
    if (isEndlessMode) {
      return _endlessSpeed * scrollSpeedMultiplier;
    }
    return levelConfig.scrollSpeed * scrollSpeedMultiplier;
  }

  // Getter for current obstacle ratio (dynamic in endless mode)
  double get currentObstacleRatio {
    if (isEndlessMode) {
      // Increase obstacle ratio based on distance traveled
      final difficultySteps =
          distanceTraveled.value ~/ GameConstants.endlessDifficultyStepDistance;
      final ratio =
          GameConstants.endlessStartObstacleRatio + (difficultySteps * 0.03);
      return ratio.clamp(
        GameConstants.endlessStartObstacleRatio,
        GameConstants.endlessMaxObstacleRatio,
      );
    }
    return levelConfig.obstacleRatio;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    levelConfig = LevelConfig.getLevel(currentLevel);

    // Add components
    add(BackgroundComponent());

    spawner = SpawnerComponent();
    add(spawner);

    player = PlayerComponent();
    add(player);

    // Note: BGM is started when user clicks Play (startGame) to comply with browser autoplay policies

    debugPrint('🍣 Sushi Roll Rush Game loaded!');
    debugPrint('📍 Level: ${levelConfig.levelNumber} - ${levelConfig.theme}');
  }

  @override
  void update(double dt) {
    if (!isPlaying || isPaused || isGameOver || isVictory) return;
    super.update(dt);

    _elapsedTime += dt;

    // Handle slowdown recovery
    if (_slowdownTimer > 0) {
      _slowdownTimer -= dt;
      if (_slowdownTimer <= 0) {
        scrollSpeedMultiplier = 1.0;
        debugPrint('🚀 Speed restored!');
      }
    }

    if (isEndlessMode) {
      // ============================================
      // ENDLESS MODE LOGIC
      // ============================================

      // Update distance traveled (based on effective speed)
      distanceTraveled.value = (_elapsedTime * effectiveScrollSpeed / 50)
          .toInt();

      // Gradually increase speed over time
      _endlessSpeed =
          (GameConstants.endlessStartSpeed +
                  (_elapsedTime * GameConstants.endlessSpeedIncrement))
              .clamp(
                GameConstants.endlessStartSpeed,
                GameConstants.endlessMaxSpeed,
              );

      // Update level config with new difficulty parameters
      final difficultySteps =
          distanceTraveled.value ~/ GameConstants.endlessDifficultyStepDistance;
      levelConfig = LevelConfig.endless(
        scrollSpeed: _endlessSpeed,
        obstacleRatio: currentObstacleRatio,
        obstacleMoveSpeed: 2.0 + (difficultySteps * 0.3),
        obstacleMoveRange: 50.0 + (difficultySteps * 5.0),
      );

      // Progress bar shows "difficulty" in endless mode (0-100% of max speed)
      levelProgress.value =
          ((_endlessSpeed - GameConstants.endlessStartSpeed) /
                  (GameConstants.endlessMaxSpeed -
                      GameConstants.endlessStartSpeed))
              .clamp(0.0, 1.0);
    } else {
      // ============================================
      // LEVEL MODE LOGIC
      // ============================================

      // Update level progress (0.0 to 1.0)
      levelProgress.value = (_elapsedTime / levelConfig.durationSeconds).clamp(
        0.0,
        1.0,
      );

      // Spawn finish line when time is up
      if (_elapsedTime >= levelConfig.durationSeconds && !_finishLineSpawned) {
        _finishLineSpawned = true;
        spawner.removeFromParent(); // Stop spawning new items

        // Spawn finish line just above screen
        add(FinishLineComponent()..position = Vector2(size.x / 2, -100));
        debugPrint('🏁 Spawning Finish Line!');
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Render base background color (wood texture will overlay this)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = GameColors.woodLight,
    );

    super.render(canvas);

    // Fog Effect (Level 10+)
    if (levelConfig.newMechanic == 'Fog Effect') {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = Colors.white.withValues(alpha: 0.3),
      );
    }
  }

  // ============================================
  // INPUT HANDLING
  // ============================================

  // For drag/swipe tracking
  Vector2? _dragStartPosition;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!isPlaying || isPaused) return;
    _dragStartPosition = event.canvasPosition.clone();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!isPlaying || isPaused) return;

    // Use velocity for swipe detection
    final velocityX = event.velocity.x;

    if (velocityX > 200) {
      // Swipe right
      moveRight();
    } else if (velocityX < -200) {
      // Swipe left
      moveLeft();
    }

    _dragStartPosition = null;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _dragStartPosition = null;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!isPlaying || isPaused || _dragStartPosition == null) return;

    // Calculate horizontal drag distance
    final dragDelta = event.canvasEndPosition.x - _dragStartPosition!.x;

    // Threshold for swipe detection (50 pixels)
    if (dragDelta.abs() > 50) {
      if (dragDelta > 0) {
        moveRight();
      } else {
        moveLeft();
      }
      // Reset start position to allow continuous swipes
      _dragStartPosition = event.canvasEndPosition.clone();
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (!isPlaying || isPaused) return;

    // Tap on left third of screen = move left
    // Tap on right third of screen = move right
    final tapX = event.canvasPosition.x;
    final screenWidth = size.x;

    if (tapX < screenWidth / 3) {
      moveLeft();
    } else if (tapX > screenWidth * 2 / 3) {
      moveRight();
    }
  }

  void moveLeft() {
    if (currentLane > 0) {
      currentLane--;
      AudioManager().playSfx(AssetPaths.sfxSwipe);
      debugPrint('🍣 Moved to lane $currentLane');
    }
  }

  void moveRight() {
    if (currentLane < GameConstants.laneCount - 1) {
      currentLane++;
      AudioManager().playSfx(AssetPaths.sfxSwipe);
      debugPrint('🍣 Moved to lane $currentLane');
    }
  }

  // ============================================
  // GAME ACTIONS
  // ============================================

  /// Start/Resume the game (Level Mode)
  void startGame() {
    isEndlessMode = false;
    isPlaying = true;
    isPaused = false;
    isGameOver = false;
    isVictory = false;
    isNewRecord = false;

    overlays.remove('mainMenu');
    overlays.add('hud');

    AudioManager().playBgm(AssetPaths.bgmLevel);

    debugPrint('🎮 Game started!');
  }

  /// Start Endless Mode
  void startEndlessMode() {
    isEndlessMode = true;
    isPlaying = true;
    isPaused = false;
    isGameOver = false;
    isVictory = false;
    isNewRecord = false;

    // Reset endless mode specific values
    distanceTraveled.value = 0;
    _endlessSpeed = GameConstants.endlessStartSpeed;
    score.value = 0;
    collectedIngredients.value = 0;
    levelProgress.value = 0.0;
    _elapsedTime = 0.0;
    currentLane = 1;
    scrollSpeedMultiplier = 1.0;
    _slowdownTimer = 0.0;

    // Set endless level config
    levelConfig = LevelConfig.endless();

    overlays.remove('mainMenu');
    overlays.add('hud');

    AudioManager().playBgm(AssetPaths.bgmLevel);

    debugPrint('🎮 Endless Mode started! 🛤️');
  }

  /// Pause the game
  void pauseGame() {
    if (!isPlaying) return;
    isPaused = true;
    pauseEngine();
    AudioManager().pauseBgm();
    overlays.add('pause');
    overlays.remove('hud');
    debugPrint('⏸️ Game paused');
  }

  /// Resume from pause
  void resumeGame() {
    isPaused = false;
    resumeEngine();
    AudioManager().resumeBgm();
    overlays.remove('pause');
    overlays.add('hud');
    debugPrint('▶️ Game resumed');
  }

  /// Handle collecting an ingredient
  void collectIngredient(int points) {
    score.value += points;
    collectedIngredients.value++;

    AudioManager().playSfx(AssetPaths.sfxPop);

    // Visual growth
    player.grow();

    // Floating Text (using star emoji instead of dollar sign)
    add(
      FloatingTextComponent(
        text: '+$points ⭐',
        position: player.position - Vector2(0, 40),
      ),
    );

    // Sparkle effect
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 10,
          lifespan: 0.5,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 100),
            speed:
                Vector2.random(_random) * 200 -
                Vector2(100, 200), // Upward burst
            position: player.position.clone(),
            child: CircleParticle(
              radius: 3,
              paint: Paint()..color = GameColors.salmonOrange,
            ),
          ),
        ),
      ),
    );

    debugPrint('✨ Collected! Score: ${score.value}');
  }

  /// Handle hitting an obstacle
  void hitObstacle() {
    score.value = (score.value - GameConstants.obstaclePenalty)
        .clamp(0, double.infinity)
        .toInt();
    collectedIngredients.value =
        (collectedIngredients.value - GameConstants.ingredientsLostOnHit)
            .clamp(0, double.infinity)
            .toInt();

    AudioManager().playSfx(AssetPaths.sfxSplat);
    player.showState(PlayerState.hurt);

    // Sneeze / Splat Particles
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 15,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            speed: Vector2.random(_random) * 300 - Vector2(150, 150),
            acceleration: Vector2(0, 200), // Gravity
            position: player.position.clone(),
            child: CircleParticle(
              radius: 4,
              paint: Paint()
                ..color = Colors.greenAccent.withValues(
                  alpha: 0.8,
                ), // Wasabi green
            ),
          ),
        ),
      ),
    );

    // Camera shake
    camera.viewfinder.add(
      MoveEffect.by(
        Vector2(10, 0),
        EffectController(duration: 0.1, alternate: true, repeatCount: 3),
      ),
    );

    // Slow down
    scrollSpeedMultiplier = 0.5;
    _slowdownTimer = 1.5; // 1.5 seconds slowdown

    debugPrint('💥 Hit obstacle! Score: ${score.value}');

    // In endless mode, game over when ingredients reach 0
    if (isEndlessMode && collectedIngredients.value <= 0) {
      endlessGameOver();
    }
  }

  /// Game over for endless mode - saves best distance
  Future<void> endlessGameOver() async {
    isGameOver = true;
    isPlaying = false;
    pauseEngine();

    AudioManager().stopBgm();
    AudioManager().playSfx(AssetPaths.sfxSplat);

    // Save best distance
    final dataManager = DataManager();
    isNewRecord = await dataManager.saveEndlessBestDistance(
      distanceTraveled.value,
    );

    // Also save coins earned
    await dataManager.addCoins(score.value);

    overlays.remove('hud');
    overlays.add('gameOver');

    debugPrint(
      '😵 Endless Mode Over! Distance: ${distanceTraveled.value}m | New Record: $isNewRecord',
    );
  }

  /// Level completed successfully
  Future<void> levelComplete() async {
    isVictory = true;
    isPlaying = false;
    pauseEngine();

    // Stop level BGM and play win sound
    AudioManager().stopBgm();
    AudioManager().playSfx(AssetPaths.sfxWin);

    // Save Data
    final stars = calculateStars();
    final dataManager = DataManager();
    await dataManager.addCoins(score.value);
    await dataManager.unlockLevel(currentLevel + 1);
    await dataManager.saveStarsForLevel(currentLevel, stars);

    overlays.remove('hud');
    overlays.add('victory');
    debugPrint('🎉 Level complete! Final score: ${score.value}');
  }

  /// Game over (only when finishing with 0 ingredients)
  void gameOver() {
    isGameOver = true;
    isPlaying = false;
    pauseEngine();
    AudioManager().stopBgm(); // Stop music on game over
    overlays.remove('hud');
    overlays.add('gameOver');
    debugPrint('😵 Game over! Score: ${score.value}');
  }

  /// Restart the current level or endless mode
  void restartLevel() {
    score.value = 0;
    collectedIngredients.value = 0;
    levelProgress.value = 0.0;
    _elapsedTime = 0.0;
    _finishLineSpawned = false;
    currentLane = 1;
    scrollSpeedMultiplier = 1.0;
    _slowdownTimer = 0.0;
    isNewRecord = false;

    // Reset endless mode specific values
    if (isEndlessMode) {
      distanceTraveled.value = 0;
      _endlessSpeed = GameConstants.endlessStartSpeed;
      levelConfig = LevelConfig.endless();
    }

    isGameOver = false;
    isVictory = false;
    isPaused = false;

    overlays.remove('gameOver');
    overlays.remove('victory');
    overlays.remove('pause');
    overlays.add('hud');

    resumeEngine();
    AudioManager().playBgm(AssetPaths.bgmLevel); // Restart level music

    // Clear existing entities
    children.whereType<IngredientComponent>().forEach(
      (c) => c.removeFromParent(),
    );
    children.whereType<ObstacleComponent>().forEach(
      (c) => c.removeFromParent(),
    );
    children.whereType<FinishLineComponent>().forEach(
      (c) => c.removeFromParent(),
    );

    // Add spawner back if it was removed
    if (!children.contains(spawner)) {
      add(spawner);
    }

    // Reset player
    if (player.isMounted) {
      player.current = PlayerState.normal;
      player.resetGrowth(); // Reset size
    }

    isPlaying = true;
    debugPrint('🔄 ${isEndlessMode ? "Endless mode" : "Level"} restarted');
  }

  /// Go to next level
  void nextLevel() {
    currentLevel++;
    levelConfig = LevelConfig.getLevel(currentLevel);
    restartLevel();
    debugPrint('⬆️ Next level: ${levelConfig.levelNumber}');
  }

  /// Return to main menu
  void goToMainMenu() {
    score.value = 0;
    collectedIngredients.value = 0;
    levelProgress.value = 0.0;
    _elapsedTime = 0.0;
    _finishLineSpawned = false;
    currentLevel = 1;
    currentLane = 1;
    scrollSpeedMultiplier = 1.0;
    _slowdownTimer = 0.0;

    // Reset endless mode state
    isEndlessMode = false;
    distanceTraveled.value = 0;
    _endlessSpeed = GameConstants.endlessStartSpeed;
    isNewRecord = false;

    isPlaying = false;
    isGameOver = false;
    isVictory = false;
    isPaused = false;

    levelConfig = LevelConfig.getLevel(currentLevel);

    overlays.remove('gameOver');
    overlays.remove('victory');
    overlays.remove('pause');
    overlays.remove('hud');
    overlays.add('mainMenu');

    resumeEngine();

    // Stop current BGM first, then don't play menu BGM (main menu is silent or can manually start)
    AudioManager().stopBgm();

    // Clear game entities
    children.whereType<IngredientComponent>().forEach(
      (c) => c.removeFromParent(),
    );
    children.whereType<ObstacleComponent>().forEach(
      (c) => c.removeFromParent(),
    );
    children.whereType<FinishLineComponent>().forEach(
      (c) => c.removeFromParent(),
    );

    // Add spawner back if it was removed
    if (!children.contains(spawner)) {
      add(spawner);
    }

    debugPrint('🏠 Returned to main menu');
  }

  // ============================================
  // STAR RATING CALCULATION
  // ============================================

  /// Calculate star rating based on sushi meter (collected ingredients)
  int calculateStars() {
    // Assume perfect run = 30 ingredients for a level
    const perfectIngredients = 30;
    final percentage = collectedIngredients.value / perfectIngredients;

    if (percentage >= 0.9) return 3; // 90%+ = 3 stars
    if (percentage >= 0.5) return 2; // 50%+ = 2 stars
    return 1; // Finished = 1 star
  }
}
