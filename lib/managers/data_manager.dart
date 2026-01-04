import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Skin data for the shop
class SkinData {
  final String id;
  final String name;
  final String emoji;
  final int price;
  final String description;

  const SkinData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.description,
  });
}

/// Available skins in the game
class GameSkins {
  GameSkins._();

  static const List<SkinData> allSkins = [
    SkinData(
      id: 'default',
      name: 'Classic Rice',
      emoji: '🍙',
      price: 0,
      description: 'The original rice ball!',
    ),
    SkinData(
      id: 'salmon_nigiri',
      name: 'Salmon Nigiri',
      emoji: '🍣',
      price: 100,
      description: 'Fresh salmon on rice',
    ),
    SkinData(
      id: 'california_roll',
      name: 'California Roll',
      emoji: '🥢',
      price: 150,
      description: 'Avocado & crab goodness',
    ),
    SkinData(
      id: 'shrimp_tempura',
      name: 'Shrimp Tempura',
      emoji: '🍤',
      price: 200,
      description: 'Crispy fried perfection',
    ),
    SkinData(
      id: 'golden_roll',
      name: 'Golden Roll',
      emoji: '✨',
      price: 500,
      description: 'Legendary golden sushi!',
    ),
    SkinData(
      id: 'rainbow_roll',
      name: 'Rainbow Roll',
      emoji: '🌈',
      price: 750,
      description: 'All the colors!',
    ),
  ];

  static SkinData getSkin(String id) {
    return allSkins.firstWhere(
      (s) => s.id == id,
      orElse: () => allSkins.first,
    );
  }
}

/// Centralized data persistence manager.
/// Uses SharedPreferences to store simple game data.
class DataManager {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;

  DataManager._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Keys
  static const String _keyTotalCoins = 'sushi_roll_total_coins';
  static const String _keyHighestLevel = 'sushi_roll_highest_level';
  static const String _keyIsMuted = 'sushi_roll_is_muted';
  static const String _keySelectedSkin = 'sushi_roll_selected_skin';
  static const String _keyOwnedSkinsPrefix = 'sushi_roll_owned_skin_';
  // Prefix for level stars: sushi_roll_stars_level_1, etc.
  static const String _keyLevelStarsPrefix = 'sushi_roll_stars_level_';
  // Endless mode best distance
  static const String _keyEndlessBestDistance = 'sushi_roll_endless_best_distance';

  /// Initialize SharedPreferences
  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    
    // Ensure default skin is owned
    await _setOwnedSkin('default', true);
    
    debugPrint('💾 DataManager initialized');
  }

  // ============================================
  // COINS
  // ============================================
  
  int get totalCoins => _prefs.getInt(_keyTotalCoins) ?? 0;

  Future<void> addCoins(int amount) async {
    final current = totalCoins;
    await _prefs.setInt(_keyTotalCoins, current + amount);
  }
  
  Future<bool> spendCoins(int amount) async {
    if (totalCoins >= amount) {
      await _prefs.setInt(_keyTotalCoins, totalCoins - amount);
      return true;
    }
    return false;
  }

  // ============================================
  // LEVEL PROGRESS
  // ============================================

  int get highestLevelReached => _prefs.getInt(_keyHighestLevel) ?? 1;

  Future<void> unlockLevel(int level) async {
    if (level > highestLevelReached) {
      await _prefs.setInt(_keyHighestLevel, level);
    }
  }

  // ============================================
  // STARS
  // ============================================

  int getStarsForLevel(int level) {
    return _prefs.getInt('$_keyLevelStarsPrefix$level') ?? 0;
  }

  Future<void> saveStarsForLevel(int level, int stars) async {
    final current = getStarsForLevel(level);
    if (stars > current) {
      await _prefs.setInt('$_keyLevelStarsPrefix$level', stars);
    }
  }

  // ============================================
  // SKINS
  // ============================================
  
  String get selectedSkin => _prefs.getString(_keySelectedSkin) ?? 'default';
  
  Future<void> selectSkin(String skinId) async {
    if (isSkinOwned(skinId)) {
      await _prefs.setString(_keySelectedSkin, skinId);
    }
  }
  
  bool isSkinOwned(String skinId) {
    return _prefs.getBool('$_keyOwnedSkinsPrefix$skinId') ?? (skinId == 'default');
  }
  
  Future<void> _setOwnedSkin(String skinId, bool owned) async {
    await _prefs.setBool('$_keyOwnedSkinsPrefix$skinId', owned);
  }
  
  /// Purchase a skin. Returns true if successful.
  Future<bool> purchaseSkin(String skinId) async {
    if (isSkinOwned(skinId)) return true; // Already owned
    
    final skin = GameSkins.getSkin(skinId);
    if (await spendCoins(skin.price)) {
      await _setOwnedSkin(skinId, true);
      return true;
    }
    return false;
  }
  
  /// Get the current skin data
  SkinData get currentSkinData => GameSkins.getSkin(selectedSkin);

  // ============================================
  // ENDLESS MODE
  // ============================================

  /// Get the best distance achieved in endless mode
  int get endlessBestDistance => _prefs.getInt(_keyEndlessBestDistance) ?? 0;

  /// Save the best distance if it's a new record
  Future<bool> saveEndlessBestDistance(int distance) async {
    if (distance > endlessBestDistance) {
      await _prefs.setInt(_keyEndlessBestDistance, distance);
      debugPrint('🏆 New endless mode record: $distance meters!');
      return true; // New record!
    }
    return false; // Not a new record
  }

  // ============================================
  // SETTINGS
  // ============================================

  bool get isMuted => _prefs.getBool(_keyIsMuted) ?? false;

  Future<void> setMuted(bool muted) async {
    await _prefs.setBool(_keyIsMuted, muted);
  }
}
