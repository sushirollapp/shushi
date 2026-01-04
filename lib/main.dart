import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_theme.dart';
import 'core/game_colors.dart';
import 'game/sushi_roll_rush_game.dart';
import 'managers/audio_manager.dart';
import 'managers/data_manager.dart';
import 'overlays/main_menu_overlay.dart';
import 'overlays/pause_menu_overlay.dart';
import 'overlays/game_over_overlay.dart';
import 'overlays/victory_overlay.dart';
import 'overlays/hud_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Managers
  await DataManager().init();
  await AudioManager().init();

  // Set preferred orientations (PORTRAIT for this game - vertical scrolling)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set fullscreen immersive mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const SushiRollRushApp());
}

class SushiRollRushApp extends StatelessWidget {
  const SushiRollRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sushi Roll Rush',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late SushiRollRushGame _game;

  @override
  void initState() {
    super.initState();
    _game = SushiRollRushGame();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Stop all audio when game screen is disposed
    AudioManager().stopBgm();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // App is backgrounded or inactive - pause audio
        AudioManager().pauseBgm();
        if (_game.isPlaying && !_game.isPaused) {
          _game.pauseGame();
        }
        break;
      case AppLifecycleState.resumed:
        // App came back to foreground - resume if was playing
        // Don't auto-resume, let user do it from pause menu
        break;
      case AppLifecycleState.detached:
        // App is about to be terminated - stop everything
        AudioManager().stopBgm();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.woodLight,
      body: GameWidget<SushiRollRushGame>(
        game: _game,
        initialActiveOverlays: const ['mainMenu'],
        overlayBuilderMap: {
          'mainMenu': (context, game) => MainMenuOverlay(game: game),
          'pause': (context, game) => PauseMenuOverlay(game: game),
          'gameOver': (context, game) => GameOverOverlay(game: game),
          'victory': (context, game) => VictoryOverlay(game: game),
          'hud': (context, game) => HudOverlay(game: game),
        },
      ),
    );
  }
}
