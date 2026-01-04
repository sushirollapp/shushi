import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import '../core/asset_paths.dart';

/// Centralized audio management for the game.
/// Handles background music (BGM) and sound effects (SFX).
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal();

  bool _isMuted = false;
  final double _sfxVolume = 1.0;
  final double _bgmVolume = 0.5;

  bool get isMuted => _isMuted;

  /// Initialize audio system and preload assets
  Future<void> init() async {
    try {
      // Preload all audio files
      await FlameAudio.audioCache.loadAll([
        AssetPaths.bgmMain.replaceFirst('audio/', ''),
        AssetPaths.bgmLevel.replaceFirst('audio/', ''),
        AssetPaths.sfxPop.replaceFirst('audio/', ''),
        AssetPaths.sfxSplat.replaceFirst('audio/', ''),
        AssetPaths.sfxSwipe.replaceFirst('audio/', ''),
        AssetPaths.sfxWin.replaceFirst('audio/', ''),
      ]);
      debugPrint('🎵 Audio assets preloaded');
    } catch (e) {
      debugPrint('⚠️ Error preloading audio: $e');
    }
  }

  /// Play background music with loop
  void playBgm(String fileName) {
    if (_isMuted) return;
    
    // Clean filename as FlameAudio expects file without 'audio/' prefix if in assets/audio/
    // But AssetPaths include 'audio/'. FlameAudio assumes assets/audio/ by default for cache,
    // but play methods might behave differently depending on version.
    // FlameAudio.bgm.play matches internal logic.
    
    final name = fileName.replaceFirst('audio/', '');
    
    try {
      FlameAudio.bgm.play(name, volume: _bgmVolume);
    } catch (e) {
      debugPrint('⚠️ Error playing BGM: $e');
    }
  }

  /// Stop currently playing BGM
  void stopBgm() {
    FlameAudio.bgm.stop();
  }

  /// Pause BGM
  void pauseBgm() {
    FlameAudio.bgm.pause();
  }

  /// Resume BGM
  void resumeBgm() {
    if (!_isMuted) {
      FlameAudio.bgm.resume();
    }
  }

  /// Play a sound effect once
  void playSfx(String fileName) {
    if (_isMuted) return;
    
    final name = fileName.replaceFirst('audio/', '');
    
    try {
      FlameAudio.play(name, volume: _sfxVolume);
    } catch (e) {
      debugPrint('⚠️ Error playing SFX: $e');
    }
  }

  /// Toggle mute state for all audio
  void setMuted(bool muted) {
    _isMuted = muted;
    if (muted) {
      FlameAudio.bgm.stop();
    } else {
      // Logic to resume or restart BGM could go here if we tracked current track
      // For now, we rely on the game loop to handle BGM state or explicit calls
    }
  }
}
