/// Centralized asset path constants
/// Ensures consistency and easy refactoring
class AssetPaths {
  AssetPaths._();

  // ============================================
  // IMAGE PATHS
  // ============================================

  // Player sprites
  static const String playerNormal = 'assets/images/player_normal.png';
  static const String playerHurt = 'assets/images/player_hurt.png';
  static const String playerHappy = 'assets/images/player_happy.png';

  // Ingredients (collectibles)
  static const String ingredientSalmon = 'assets/images/ingredient_salmon.png';
  static const String ingredientTuna = 'assets/images/ingredient_tuna.png';
  static const String ingredientAvocado = 'assets/images/ingredient_avocado.png';
  static const String ingredientShrimp = 'assets/images/ingredient_shrimp.png';

  // Obstacles (avoid these)
  static const String obstacleWasabi = 'assets/images/obstacle_wasabi.png';
  static const String obstacleFishbone = 'assets/images/obstacle_fishbone.png';
  static const String obstacleChopsticks = 'assets/images/obstacle_chopsticks.png';

  // Backgrounds
  static const String bgBamboo = 'assets/images/bg_bamboo.png';
  static const String bgWood = 'assets/images/bg_wood.png';

  // UI elements
  static const String uiPlayButton = 'assets/images/ui_play_button.png';
  static const String uiGameLogo = 'assets/images/ui_game_logo.png';

  // ============================================
  // AUDIO PATHS
  // ============================================

  // Background music
  static const String bgmMain = 'audio/bgm.mp3';
  static const String bgmLevel = 'audio/bglevel.mp3';

  // Sound effects
  static const String sfxPop = 'audio/sfx_pop.mp3';      // Collect ingredient
  static const String sfxSplat = 'audio/sfx_splat.mp3';  // Hit obstacle
  static const String sfxSwipe = 'audio/sfx_swipe.mp3'; // Lane change
  static const String sfxWin = 'audio/sfx_win.mp3';      // Level complete

  // ============================================
  // LISTS FOR PRELOADING
  // ============================================

  /// All images that should be preloaded
  static const List<String> allImages = [
    playerNormal,
    playerHurt,
    playerHappy,
    ingredientSalmon,
    ingredientTuna,
    ingredientAvocado,
    ingredientShrimp,
    obstacleWasabi,
    obstacleFishbone,
    obstacleChopsticks,
    bgBamboo,
    bgWood,
    uiPlayButton,
    uiGameLogo,
  ];

  /// All ingredients for random spawning
  static const List<String> ingredients = [
    ingredientSalmon,
    ingredientTuna,
    ingredientAvocado,
    ingredientShrimp,
  ];

  /// All obstacles for random spawning
  static const List<String> obstacles = [
    obstacleWasabi,
    obstacleFishbone,
    obstacleChopsticks,
  ];
}
