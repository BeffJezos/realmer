import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state_provider.dart';

class LifeCounterWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: isRotated ? 3.14159 : 0, // 180 degrees for opponent
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Life display with swipe gestures (full area)
            GestureDetector(
              onPanEnd: (details) {
                final velocity = details.velocity.pixelsPerSecond;
                if (velocity.dy.abs() > velocity.dx.abs()) {
                  if (velocity.dy < -500) {
                    // Swipe up - increase life
                    Provider.of<GameStateProvider>(context, listen: false)
                        .adjustLife(isPlayer, 1);
                  } else if (velocity.dy > 500) {
                    // Swipe down - decrease life
                    Provider.of<GameStateProvider>(context, listen: false)
                        .adjustLife(isPlayer, -1);
                  }
                }
              },
              child: Container(
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
                child: _buildLifeDisplay(context),
              ),
            ),

            // Action buttons overlay (bottom right for player, top left for opponent when rotated)
            Positioned(
              bottom: isRotated ? null : 12,
              top: isRotated ? 12 : null,
              right: isRotated ? null : 12,
              left: isRotated ? 12 : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                    Icons.menu_book,
                    Colors.amber,
                    () => _showRulebookDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, Color color,
      VoidCallback onPressed) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
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
            color: color,
            size: 16,
          ),
        ),
      ),
    );
  }

  List<Color> _getLifeGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (playerState.life < 0) {
      return [Colors.red[900]!, Colors.red[700]!];
    } else if (playerState.isOnDeathsDoor) {
      return [Colors.orange[700]!, Colors.orange[500]!];
    } else if (playerState.life <= 5) {
      return [Colors.red[600]!, Colors.red[400]!];
    } else if (playerState.life <= 10) {
      return [Colors.orange[600]!, Colors.orange[400]!];
    } else {
      return isDark
          ? [const Color(0xFF1E293B), const Color(0xFF334155)]
          : [Colors.white, const Color(0xFFF8FAFC)];
    }
  }

  Widget _buildLifeDisplay(BuildContext context) {
    Color lifeColor;
    String lifeText;
    String statusText = '';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (playerState.life < 0) {
      lifeColor = Colors.white;
      lifeText = 'DEFEATED';
      statusText = '';
    } else if (playerState.isOnDeathsDoor) {
      lifeColor = Colors.white;
      lifeText = '0';
      statusText = "DEATH'S DOOR";
    } else if (playerState.life <= 10) {
      lifeColor = Colors.white;
      lifeText = playerState.life.toString();
    } else {
      lifeColor = isDark ? Colors.white : Colors.black87;
      lifeText = playerState.life.toString();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main life number
          Text(
            lifeText,
            style: TextStyle(
              fontSize: playerState.life < 0 ? 32 : 72,
              fontWeight: FontWeight.w300,
              color: lifeColor,
              letterSpacing: -2,
            ),
            textAlign: TextAlign.center,
          ),

          // Status text if needed
          if (statusText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isPlayer ? 'Player Chat' : 'Opponent Chat'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('AI Chat feature coming soon!'),
              SizedBox(height: 16),
              Icon(Icons.chat_bubble_outline, size: 48, color: Colors.blue),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showRulebookDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rulebook'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Digital rulebook coming soon!'),
              SizedBox(height: 16),
              Icon(Icons.menu_book, size: 48, color: Colors.amber),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
