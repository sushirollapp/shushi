import 'package:flutter/material.dart';

import '../core/game_colors.dart';
import '../core/constants.dart';
import '../core/app_theme.dart';
import '../game/sushi_roll_rush_game.dart';
import '../managers/audio_manager.dart';
import '../managers/data_manager.dart';

/// Main menu overlay - The game's hub screen
class MainMenuOverlay extends StatefulWidget {
  final SushiRollRushGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay> {
  void _showShopDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SushiShopDialog(
        onSkinChanged: () {
          setState(() {}); // Refresh main menu to show new skin
        },
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => _SettingsDialog());
  }

  @override
  Widget build(BuildContext context) {
    final currentSkin = DataManager().currentSkinData;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GameColors.salmonOrange.withValues(alpha: 0.9),
            GameColors.woodLight,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GameConstants.spacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Game Title
              const _BouncingTitle(text: 'SUSHI ROLL', fontSize: 48, delay: 0),
              const _BouncingTitle(text: 'RUSH', fontSize: 64, delay: 500),

              const SizedBox(height: GameConstants.spacingSection),

              // Rice Ball Character - shows current skin
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: GameColors.riceWhite,
                  shape: BoxShape.circle,
                  boxShadow: [GameColors.standardShadow],
                ),
                child: Center(
                  child: Text(
                    currentSkin.emoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),

              const Spacer(),

              // Play Button - Large, pulsing (Level Mode)
              _PlayButton(onPressed: () => widget.game.startGame()),

              const SizedBox(height: GameConstants.spacingMedium),
              
              // Endless Mode Button
              _EndlessModeButton(onPressed: () => widget.game.startEndlessMode()),

              const SizedBox(height: GameConstants.spacingMedium),

              // Secondary buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Shop/Skins button
                  _IconButton(
                    icon: Icons.shopping_bag_outlined,
                    onPressed: () => _showShopDialog(context),
                  ),
                  const SizedBox(width: GameConstants.spacingMedium),
                  // Settings button
                  _IconButton(
                    icon: Icons.settings,
                    onPressed: () => _showSettingsDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: GameConstants.spacingSection),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sushi Shop Dialog with skin selection and purchase
class _SushiShopDialog extends StatefulWidget {
  final VoidCallback onSkinChanged;

  const _SushiShopDialog({required this.onSkinChanged});

  @override
  State<_SushiShopDialog> createState() => _SushiShopDialogState();
}

class _SushiShopDialogState extends State<_SushiShopDialog> {
  final DataManager _dataManager = DataManager();

  Future<void> _handleSkinAction(SkinData skin) async {
    if (_dataManager.isSkinOwned(skin.id)) {
      // Select the skin
      await _dataManager.selectSkin(skin.id);
      widget.onSkinChanged();
      setState(() {});
    } else {
      // Try to purchase
      if (_dataManager.totalCoins >= skin.price) {
        final success = await _dataManager.purchaseSkin(skin.id);
        if (success) {
          await _dataManager.selectSkin(skin.id);
          widget.onSkinChanged();
          setState(() {});
        }
      } else {
        // Show not enough coins message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Not enough points! Need ${skin.price - _dataManager.totalCoins} more.',
                style: const TextStyle(fontFamily: AppTheme.bodyFont),
              ),
              backgroundColor: GameColors.tunaRed,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final coins = _dataManager.totalCoins;
    final selectedSkinId = _dataManager.selectedSkin;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: GameColors.riceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GameConstants.borderRadiusMedium),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.7,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                children: [
                  Text(
                    'Sushi Shop',
                    style: TextStyle(
                      fontFamily: AppTheme.headlineFont,
                      color: GameColors.noriBlack,
                      fontSize: 26,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  // Coins display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: GameColors.woodLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          '$coins',
                          style: TextStyle(
                            fontFamily: AppTheme.bodyFont,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: GameColors.salmonOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            Divider(color: GameColors.woodDark, height: 1),
            
            // Skin List
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shrinkWrap: true,
                itemCount: GameSkins.allSkins.length,
                itemBuilder: (context, index) {
                  final skin = GameSkins.allSkins[index];
                  final isOwned = _dataManager.isSkinOwned(skin.id);
                  final isSelected = selectedSkinId == skin.id;
                  final canAfford = coins >= skin.price;

                  return GestureDetector(
                    onTap: () => _handleSkinAction(skin),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? GameColors.matchaGreen.withValues(alpha: 0.15)
                            : GameColors.woodLight,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(color: GameColors.matchaGreen, width: 2)
                            : Border.all(color: Colors.transparent, width: 2),
                      ),
                      child: Row(
                        children: [
                          // Emoji Avatar
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: GameColors.riceWhite,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                skin.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Name & Description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  skin.name,
                                  style: TextStyle(
                                    fontFamily: AppTheme.bodyFont,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: GameColors.noriBlack,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  skin.description,
                                  style: TextStyle(
                                    fontFamily: AppTheme.bodyFont,
                                    fontSize: 11,
                                    color: GameColors.noriBlack.withValues(alpha: 0.6),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Action Button
                          _buildActionButton(skin, isOwned, isSelected, canAfford),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Close Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: GameColors.woodLight,
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      fontSize: 16,
                      color: GameColors.matchaGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    SkinData skin,
    bool isOwned,
    bool isSelected,
    bool canAfford,
  ) {
    if (isSelected) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: GameColors.matchaGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            '✓',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    if (isOwned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: GameColors.infoBlue.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Use',
          style: TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontSize: 12,
            color: GameColors.infoBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Not owned - show price
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: canAfford
            ? GameColors.salmonOrange.withValues(alpha: 0.2)
            : GameColors.woodDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 3),
          Text(
            '${skin.price}',
            style: TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 12,
              color: canAfford
                  ? GameColors.salmonOrange
                  : GameColors.noriBlack.withValues(alpha: 0.4),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings dialog with sound toggle
class _SettingsDialog extends StatefulWidget {
  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late bool _isMuted;

  @override
  void initState() {
    super.initState();
    _isMuted = DataManager().isMuted;
  }

  void _toggleMute(bool value) {
    setState(() {
      _isMuted = value;
    });
    DataManager().setMuted(value);
    AudioManager().setMuted(value);
  }

  void _showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameColors.riceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameConstants.borderRadiusMedium),
        ),
        title: Text(
          'How to Play',
          style: TextStyle(
            fontFamily: AppTheme.headlineFont,
            color: GameColors.noriBlack,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructionRow(
              Icons.swipe,
              'Swipe Left/Right to change lanes',
            ),
            const SizedBox(height: 12),
            _buildInstructionRow(
              Icons.restaurant,
              'Collect ingredients to score',
            ),
            const SizedBox(height: 12),
            _buildInstructionRow(
              Icons.warning_amber_rounded,
              'Avoid obstacles!',
            ),
            const SizedBox(height: 12),
            _buildInstructionRow(Icons.timer, 'Finish before time runs out'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Got it!',
              style: TextStyle(
                fontFamily: AppTheme.bodyFont,
                color: GameColors.matchaGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameColors.riceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameConstants.borderRadiusMedium),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            fontFamily: AppTheme.headlineFont,
            color: GameColors.noriBlack,
          ),
          textAlign: TextAlign.center,
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sushi Roll Rush is a fully offline game.',
                style: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'We do not collect, store, or share any personal data. All game progress is saved locally on your device.',
                style: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'No internet connection is required to play.',
                style: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: AppTheme.bodyFont,
                color: GameColors.matchaGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: GameColors.salmonOrange, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontSize: 14,
              color: GameColors.noriBlack,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: GameColors.riceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GameConstants.borderRadiusMedium),
      ),
      title: Text(
        'Settings',
        style: TextStyle(
          fontFamily: AppTheme.headlineFont,
          color: GameColors.noriBlack,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sound Toggle
          Container(
            padding: const EdgeInsets.all(GameConstants.spacingMedium),
            decoration: BoxDecoration(
              color: GameColors.woodLight,
              borderRadius: BorderRadius.circular(
                GameConstants.borderRadiusSmall,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: GameColors.noriBlack,
                    ),
                    const SizedBox(width: GameConstants.spacingSmall),
                    Text(
                      'Sound',
                      style: TextStyle(
                        fontFamily: AppTheme.bodyFont,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: GameColors.noriBlack,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: !_isMuted,
                  onChanged: (value) => _toggleMute(!value),
                  activeTrackColor: GameColors.matchaGreen,
                  activeThumbColor: GameColors.riceWhite,
                ),
              ],
            ),
          ),
          const SizedBox(height: GameConstants.spacingMedium),

          // How to Play Button
          _SettingsButton(
            icon: Icons.help_outline,
            label: 'How to Play',
            onTap: () => _showHowToPlayDialog(context),
          ),
          const SizedBox(height: GameConstants.spacingMedium),

          // Privacy Policy Button
          _SettingsButton(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () => _showPrivacyPolicyDialog(context),
          ),

        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Done',
            style: TextStyle(
              fontFamily: AppTheme.bodyFont,
              color: GameColors.matchaGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _BouncingTitle extends StatefulWidget {
  final String text;
  final double fontSize;
  final int delay;

  const _BouncingTitle({
    required this.text,
    required this.fontSize,
    required this.delay,
  });

  @override
  State<_BouncingTitle> createState() => _BouncingTitleState();
}

class _BouncingTitleState extends State<_BouncingTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -20.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -20.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Text(
            widget.text,
            style: TextStyle(
              fontFamily: AppTheme.headlineFont,
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
              color: GameColors.riceWhite,
              shadows: [
                Shadow(
                  color: GameColors.noriBlack.withValues(alpha: 0.3),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlayButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _PlayButton({required this.onPressed});

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: GameButtonStyles.primary.copyWith(
              minimumSize: WidgetStateProperty.all(const Size(220, 70)),
              textStyle: WidgetStateProperty.all(
                const TextStyle(
                  fontFamily: AppTheme.headlineFont,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            child: const Text('PLAY'),
          ),
        );
      },
    );
  }
}

class _EndlessModeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EndlessModeButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bestDistance = DataManager().endlessBestDistance;
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: GameColors.tunaRed,
        foregroundColor: GameColors.riceWhite,
        minimumSize: const Size(220, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameConstants.borderRadiusMedium),
        ),
        elevation: 4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🛤️', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'ENDLESS',
                style: TextStyle(
                  fontFamily: AppTheme.headlineFont,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (bestDistance > 0)
            Text(
              'Best: ${bestDistance}m',
              style: TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontSize: 12,
                color: GameColors.riceWhite.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _IconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GameColors.riceWhite,
        shape: BoxShape.circle,
        boxShadow: [GameColors.standardShadow],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: GameColors.noriBlack),
        iconSize: 32,
        padding: const EdgeInsets.all(GameConstants.spacingMedium),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GameConstants.borderRadiusSmall),
      child: Container(
        padding: const EdgeInsets.all(GameConstants.spacingMedium),
        decoration: BoxDecoration(
          color: GameColors.woodLight,
          borderRadius: BorderRadius.circular(GameConstants.borderRadiusSmall),
        ),
        child: Row(
          children: [
            Icon(icon, color: GameColors.noriBlack),
            const SizedBox(width: GameConstants.spacingSmall),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: GameColors.noriBlack,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: GameColors.noriBlack,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
