import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state_provider.dart';
import '../models/avatar.dart';
import 'dart:ui' as ui;

class LifeCounterWidget extends StatefulWidget {
  final PlayerState playerState;
  final bool isPlayer;
  final bool isRotated;

  const LifeCounterWidget({
    super.key,
    required this.playerState,
    required this.isPlayer,
    required this.isRotated,
  });

  @override
  State<LifeCounterWidget> createState() => _LifeCounterWidgetState();
}

class _LifeCounterWidgetState extends State<LifeCounterWidget> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _isInitialized = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: widget.isRotated ? 3.14159 : 0, // 180 degrees for opponent
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Life display container (swipe will be handled by specific areas)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getLifeGradient(context),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _buildCardContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        final avatar =
            widget.isPlayer ? gameState.playerAvatar : gameState.opponentAvatar;

        if (avatar == null) {
          // Show avatar selection directly in card
          return _buildAvatarSelection(context);
        } else {
          // Normal game state with avatar background
          return Stack(
            children: [
              // ASCII Art Background for both player and opponent
              _buildStaticAsciiBackground(context),
              // Life display on top
              _buildLifeDisplay(context),
            ],
          );
        }
      },
    );
  }

  Widget _buildAvatarSelection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white12
            : Colors.black12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black54,
            child: Transform.rotate(
              angle:
                  widget.isRotated ? 3.14159 : 0, // Counter-rotate for opponent
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.isPlayer
                          ? 'Choose Your Avatar'
                          : 'Choose Opponent Avatar',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: Avatar.values.length,
                      itemBuilder: (context, index) {
                        final avatar = Avatar.values[index];
                        return ListTile(
                          title: Text(
                            avatar.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            Provider.of<GameStateProvider>(context,
                                    listen: false)
                                .setAvatar(widget.isPlayer, avatar);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAsciiArtWidget(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final avatar =
        widget.isPlayer ? gameState.playerAvatar : gameState.opponentAvatar;

    if (avatar == null) {
      return Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white12
            : Colors.black12,
        child: const Center(
          child: Text(
            '⚔️ Choose Avatar ⚔️',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Transform.scale(
      scale: 1.2, // 20% more zoom than contain, but less than original cover
      child: Image.asset(
        avatar.assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white12
                : Colors.black12,
            child: Center(
              child: Text(
                '⚔️ ${avatar.displayName} ⚔️',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaticAsciiBackground(BuildContext context) {
    if (!_isInitialized) return const SizedBox.shrink();

    return Positioned.fill(
      child: _buildAsciiArtWidget(context),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, Color color,
      VoidCallback onPressed) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6), // Softer black
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4), // Softer border
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2), // Softer shadow
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.9), // Slightly softer white
            size: 16,
          ),
        ),
      ),
    );
  }

  List<Color> _getLifeGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Keep background constant - no life-based color changes
    return isDark
        ? [
            const Color(0xFF1A2332),
            const Color(0xFF2D3A4B)
          ] // Consistent mystical dark tones
        : [
            const Color(0xFFFEFEFE),
            const Color(0xFFF1F5F9)
          ]; // Consistent pure mystical whites
  }

  Widget _buildLifeDisplay(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLife =
        widget.playerState.life.clamp(0, 999); // Ensure non-negative
    final baseLife = currentLife.clamp(0, 20); // Life up to 20
    final extraLife = currentLife > 20 ? currentLife - 20 : 0; // Life over 20

    // Special states - only show game over when completely defeated
    if (widget.playerState.life < 0) {
      return Center(child: _buildGameOverIndicator(isDark));
    }

    // Normal life display with grid and fantasy slider
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left half: Life grid system with swipe - make it bigger
          Expanded(
            flex: 3, // Increased from 1 to 3 for more space
            child: GestureDetector(
              onPanEnd: (details) {
                final velocity = details.velocity.pixelsPerSecond;
                print('Grid swipe detected: dy=${velocity.dy}'); // Debug
                if (velocity.dy.abs() > velocity.dx.abs()) {
                  if (velocity.dy < -200) {
                    // Lower threshold
                    // Swipe up - increase life
                    print('Grid swipe UP detected');
                    Provider.of<GameStateProvider>(context, listen: false)
                        .adjustLife(widget.isPlayer, 1);
                  } else if (velocity.dy > 200) {
                    // Lower threshold
                    // Swipe down - decrease life
                    print('Grid swipe DOWN detected');
                    Provider.of<GameStateProvider>(context, listen: false)
                        .adjustLife(widget.isPlayer, -1);
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grid with fixed position
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.center,
                        child: _buildLifeGrid(baseLife, isDark, extraLife),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right half: Fantasy slider + buttons - smaller now
          Expanded(
            flex: 2, // Adjusted from 1 to 2 (grid is 3, so 3:2 ratio)
            child: Container(
              padding:
                  const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
              child: Column(
                children: [
                  // Fantasy slider constrained to button width
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: SizedBox(
                        width:
                            80, // Width of two buttons + spacing (36 + 8 + 36)
                        child: _buildFantasySlider(isDark),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Action buttons at bottom
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(
                        context,
                        Icons.chat_bubble_outline,
                        Colors.blue,
                        () => _showChatDialog(context),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        Icons.menu_book, // Book icon for rule book
                        Colors.orange,
                        () => _showInfoDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifeGrid(int life, bool isDark, int extraLife) {
    return Flexible(
      // Use Flexible instead of fixed size
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 4), // More space at top
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withValues(alpha: 0.45), // 20% less transparent
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Grid
            ...List.generate(4, (row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly, // Center squares
                  children: List.generate(5, (col) {
                    final squareIndex =
                        (row * 5) + col + 1; // 1-20 normal layout
                    final isLit = squareIndex <= life;

                    return _buildLifeSquare(isLit, isDark, squareIndex);
                  }),
                ),
              );
            }),

            // Bottom row with status indicators on left and avatar name on right
            const SizedBox(height: 6), // Reduced from 8 to fix overflow
            Row(
              children: [
                // Left side: Status indicators
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Extra life indicator for >20
                    if (extraLife > 0) ...[
                      _buildExtraLifeIndicator(extraLife, isDark),
                    ],

                    // Deaths door special state indicator
                    if (widget.playerState.isOnDeathsDoor) ...[
                      _buildMiniDeathsDoorIndicator(isDark),
                    ],
                  ],
                ),

                // Spacer to push avatar name to the right
                const Spacer(),

                // Right side: Selected avatar name
                _buildSelectedAvatarName(isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifeSquare(bool isLit, bool isDark, int number) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive size based on available width
        final double squareSize =
            (constraints.maxWidth / 5) - 3; // Account for padding
        final double responsiveSize =
            squareSize.clamp(20.0, 32.0); // Min 20, max 32

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: responsiveSize,
          width: responsiveSize, // Make it perfectly square
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(6), // More rounded to match card
            color: isLit
                ? Colors.white
                    .withValues(alpha: 0.15) // Has life: glasig durchsichtig
                : Colors.transparent, // No life: invisible/disappeared
            border: isLit
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  )
                : null, // No border when invisible
            boxShadow: isLit
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [], // No shadow when invisible
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: (responsiveSize * 0.4)
                    .clamp(10.0, 14.0), // Responsive font size
                fontWeight: FontWeight.bold,
                color: isLit
                    ? Colors.white
                        .withValues(alpha: 0.9) // Whiter text on glasig squares
                    : Colors
                        .transparent, // Invisible text when square is invisible
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedAvatarName(bool isDark) {
    final gameState = Provider.of<GameStateProvider>(context, listen: false);
    final avatar =
        widget.isPlayer ? gameState.playerAvatar : gameState.opponentAvatar;

    return GestureDetector(
      onTap: () {
        // Show avatar selection - same as the floating button functionality
        final gameState =
            Provider.of<GameStateProvider>(context, listen: false);
        _showAvatarSelectionDialog(context, gameState);
      },
      child: Container(
        height: 24, // Same height as grid squares
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15), // Like grid squares
          borderRadius: BorderRadius.circular(6), // Like grid squares
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25), // Like grid squares
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), // Like grid squares
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            avatar?.displayName ?? "Choose Avatar",
            style: const TextStyle(
              fontSize: 10, // Same as plus life indicator
              fontWeight: FontWeight.w500,
              color: Colors.white, // No underline, just white text
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildExtraLifeIndicator(int extraLife, bool isDark) {
    return Container(
      width: 24, // Same size as grid squares
      height: 24, // Same size as grid squares
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15), // Like grid squares
        borderRadius: BorderRadius.circular(6), // Like grid squares
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25), // Like grid squares
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1), // Like grid squares
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '+$extraLife',
          style: TextStyle(
            fontSize: 10, // Smaller to fit in grid-sized box
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.9), // Like grid squares
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverIndicator(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.black
            .withValues(alpha: 0.8), // Darker background for contrast
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.8), // More visible border
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.4), // Stronger glow
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mystical game over icon
          Icon(
            Icons.auto_awesome,
            size: 36,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          // Game Over text - much more readable
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 24, // Bigger
                fontWeight: FontWeight.bold,
                color: Colors.white, // White for max contrast
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    color: Colors.red.withValues(alpha: 0.8),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Realm Conquered',
            style: TextStyle(
              fontSize: 14, // Bigger
              fontWeight: FontWeight.w600,
              color: Colors.red.withValues(alpha: 0.9), // More visible
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniDeathsDoorIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6), // Like action buttons
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4), // Like action buttons
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2), // Like action buttons
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        "DEATH'S DOOR",
        style: TextStyle(
          fontSize: 11, // Bigger text
          fontWeight: FontWeight.bold,
          color: Colors.white.withValues(alpha: 0.9), // Like action buttons
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isPlayer ? 'Player Chat' : 'Opponent Chat'),
        content: const Text('Chat feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Info'),
        content: Text(
          'Life: ${widget.playerState.life}\n'
          'On Death\'s Door: ${widget.playerState.isOnDeathsDoor}\n'
          'Thresholds:\n'
          'Air: ${widget.playerState.thresholds[GameElement.air]}\n'
          'Earth: ${widget.playerState.thresholds[GameElement.earth]}\n'
          'Fire: ${widget.playerState.thresholds[GameElement.fire]}\n'
          'Water: ${widget.playerState.thresholds[GameElement.water]}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFantasySlider(bool isDark) {
    return GestureDetector(
      onTap: () {
        // Tap anywhere to increase life
        print('Slider tap detected - increase life');
        Provider.of<GameStateProvider>(context, listen: false)
            .adjustLife(widget.isPlayer, 1);
      },
      onPanEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond;
        print('Slider swipe detected: dy=${velocity.dy}'); // Debug
        if (velocity.dy.abs() > velocity.dx.abs()) {
          if (velocity.dy < -50) {
            // Very low threshold for easier detection
            // Swipe up - increase life
            print('Slider swipe UP detected');
            Provider.of<GameStateProvider>(context, listen: false)
                .adjustLife(widget.isPlayer, 1);
          } else if (velocity.dy > 50) {
            // Very low threshold for easier detection
            // Swipe down - decrease life
            print('Slider swipe DOWN detected');
            Provider.of<GameStateProvider>(context, listen: false)
                .adjustLife(widget.isPlayer, -1);
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black.withValues(alpha: 0.5),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Up arrow - tappable area
            Expanded(
              child: GestureDetector(
                onTap: () {
                  print('Up arrow tapped - increase life');
                  Provider.of<GameStateProvider>(context, listen: false)
                      .adjustLife(widget.isPlayer, 1);
                },
                child: Container(
                  width: double.infinity,
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    size: 24,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),

            // Middle area with LIFE text
            Text(
              'LIFE',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            // Down arrow - tappable area
            Expanded(
              child: GestureDetector(
                onTap: () {
                  print('Down arrow tapped - decrease life');
                  Provider.of<GameStateProvider>(context, listen: false)
                      .adjustLife(widget.isPlayer, -1);
                },
                child: Container(
                  width: double.infinity,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 24,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarSelectionDialog(
      BuildContext context, GameStateProvider gameState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isPlayer
            ? 'Choose Player Avatar'
            : 'Choose Opponent Avatar'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: Avatar.values.length,
            itemBuilder: (context, index) {
              final avatar = Avatar.values[index];
              return ListTile(
                leading: Image.asset(
                  avatar.assetPath,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
                title: Text(avatar.displayName),
                onTap: () {
                  gameState.setAvatar(widget.isPlayer, avatar);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
