/// Game constants and configuration values
class GameConstants {
  GameConstants._();

  // ============================================
  // GAME SETTINGS
  // ============================================
  
  /// Number of lanes on the conveyor belt
  static const int laneCount = 3;
  
  /// Lane positions (relative X coordinates)
  static const double laneLeft = -100.0;
  static const double laneCenter = 0.0;
  static const double laneRight = 100.0;
  
  /// Player movement lerp speed (0.0 - 1.0)
  static const double playerLerpSpeed = 0.15;

  // ============================================
  // SPAWNING SETTINGS
  // ============================================
  
  /// Base spawn interval in seconds
  static const double baseSpawnInterval = 1.5;
  
  /// Minimum spawn interval at max difficulty
  static const double minSpawnInterval = 0.8;

  // ============================================
  // SCORING
  // ============================================
  
  /// Points per ingredient collected
  static const int ingredientPoints = 10;
  
  /// Points lost per obstacle hit
  static const int obstaclePenalty = 20;
  
  /// Ingredients lost per obstacle hit
  static const int ingredientsLostOnHit = 2;

  // ============================================
  // ANIMATION DURATIONS (milliseconds)
  // ============================================
  
  /// Squish effect duration
  static const int squishDuration = 100;
  
  /// Camera shake duration
  static const int cameraShakeDuration = 200;
  
  /// Slow-down duration after hitting obstacle
  static const int slowdownDuration = 1500;

  // ============================================
  // UI SPACING (8px grid system)
  // ============================================
  
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingSection = 32.0;
  
  /// Minimum button height for mobile tap targets
  static const double minButtonHeight = 56.0;
  
  /// Standard border radius
  static const double borderRadiusSmall = 16.0;
  static const double borderRadiusMedium = 24.0;
  static const double borderRadiusLarge = 30.0;

  // ============================================
  // ENDLESS MODE SETTINGS
  // ============================================
  
  /// Starting scroll speed for endless mode
  static const double endlessStartSpeed = 120.0;
  
  /// How much speed increases per second (pixels/second²)
  static const double endlessSpeedIncrement = 2.0;
  
  /// Maximum scroll speed cap for endless mode
  static const double endlessMaxSpeed = 500.0;
  
  /// Obstacle ratio for endless mode (increases over time)
  static const double endlessStartObstacleRatio = 0.25;
  
  /// Maximum obstacle ratio for endless mode
  static const double endlessMaxObstacleRatio = 0.55;
  
  /// How many meters before obstacle ratio increases
  static const int endlessDifficultyStepDistance = 100;
}

/// Level configuration data
class LevelConfig {
  final int levelNumber;
  final double scrollSpeed;
  final int durationSeconds;
  final double obstacleRatio;
  final String theme;
  final String? newMechanic;
  
  /// Speed of horizontal oscillation for obstacles (0 = no movement)
  final double obstacleMoveSpeed;
  
  /// Range of horizontal movement for obstacles
  final double obstacleMoveRange;

  const LevelConfig({
    required this.levelNumber,
    required this.scrollSpeed,
    required this.durationSeconds,
    required this.obstacleRatio,
    required this.theme,
    this.newMechanic,
    this.obstacleMoveSpeed = 0.0,
    this.obstacleMoveRange = 0.0,
  });

  /// Predefined level configurations
  static const List<LevelConfig> levels = [
    // Tutorial / Basics (Levels 1-3)
    LevelConfig(
      levelNumber: 1,
      scrollSpeed: 100,
      durationSeconds: 30,
      obstacleRatio: 0.2,
      theme: 'Tutorial',
      newMechanic: 'Swipe to Move',
    ),
    LevelConfig(
      levelNumber: 2,
      scrollSpeed: 100,
      durationSeconds: 30,
      obstacleRatio: 0.25,
      theme: 'Tutorial',
    ),
    LevelConfig(
      levelNumber: 3,
      scrollSpeed: 110,
      durationSeconds: 30,
      obstacleRatio: 0.3,
      theme: 'Tutorial',
    ),
    // The Lunch Rush (Levels 4-6)
    // Introducing moving obstacles with increasing difficulty
    LevelConfig(
      levelNumber: 4,
      scrollSpeed: 140, // Increased speed
      durationSeconds: 45,
      obstacleRatio: 0.4, // Increased ratio
      theme: 'Lunch Rush',
      newMechanic: 'Moving Obstacles',
      obstacleMoveSpeed: 2.0, // Base movement
      obstacleMoveRange: 50.0,
    ),
    LevelConfig(
      levelNumber: 5,
      scrollSpeed: 160, // Faster
      durationSeconds: 45,
      obstacleRatio: 0.45,
      theme: 'Lunch Rush',
      obstacleMoveSpeed: 2.5, // Faster movement
      obstacleMoveRange: 60.0, // Wider range
    ),
    LevelConfig(
      levelNumber: 6,
      scrollSpeed: 180, // Even faster
      durationSeconds: 45,
      obstacleRatio: 0.5,
      theme: 'Lunch Rush',
      obstacleMoveSpeed: 3.0,
      obstacleMoveRange: 70.0,
    ),
    // Dinner Service (Levels 7-9)
    // Moving obstacles continue + Speed Pads
    LevelConfig(
      levelNumber: 7,
      scrollSpeed: 200,
      durationSeconds: 60,
      obstacleRatio: 0.5,
      theme: 'Dinner Service',
      newMechanic: 'Speed Pads',
      obstacleMoveSpeed: 3.5, // Faster oscillation
      obstacleMoveRange: 75.0,
    ),
    LevelConfig(
      levelNumber: 8,
      scrollSpeed: 220,
      durationSeconds: 60,
      obstacleRatio: 0.55,
      theme: 'Dinner Service',
      obstacleMoveSpeed: 4.0,
      obstacleMoveRange: 80.0,
    ),
    LevelConfig(
      levelNumber: 9,
      scrollSpeed: 240,
      durationSeconds: 60,
      obstacleRatio: 0.6,
      theme: 'Dinner Service',
      obstacleMoveSpeed: 4.5,
      obstacleMoveRange: 85.0,
    ),
    // Master Chef (Level 10+)
    LevelConfig(
      levelNumber: 10,
      scrollSpeed: 260,
      durationSeconds: 90,
      obstacleRatio: 0.65,
      theme: 'Master Chef',
      newMechanic: 'Fog Effect',
      obstacleMoveSpeed: 5.0, // Very fast
      obstacleMoveRange: 90.0, // Almost full lane width
    ),
  ];

  static LevelConfig getLevel(int level) {
    if (level <= 0) return levels[0];
    if (level > levels.length) return levels.last;
    return levels[level - 1];
  }

  /// Special config for endless mode (dynamically updated)
  static LevelConfig endless({
    double scrollSpeed = GameConstants.endlessStartSpeed,
    double obstacleRatio = GameConstants.endlessStartObstacleRatio,
    double obstacleMoveSpeed = 2.0,
    double obstacleMoveRange = 50.0,
  }) {
    return LevelConfig(
      levelNumber: 0, // 0 indicates endless mode
      scrollSpeed: scrollSpeed,
      durationSeconds: 999999, // Effectively infinite
      obstacleRatio: obstacleRatio,
      theme: 'Endless',
      newMechanic: 'Conveyor Belt',
      obstacleMoveSpeed: obstacleMoveSpeed,
      obstacleMoveRange: obstacleMoveRange,
    );
  }
}
