import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state_provider.dart';
import '../widgets/life_counter_widget.dart';
import '../widgets/threshold_tracker_widget.dart';
import 'settings_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _showResetDialog(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<GameStateProvider>(
        builder: (context, gameState, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Column(
            children: [
              // Opponent Section (Top Half)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              const Color(0xFF0F172A),
                              const Color(0xFF1E293B),
                            ]
                          : [
                              const Color(0xFFF8FAFC),
                              const Color(0xFFE2E8F0),
                            ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Small opponent label (rotated for opponent's view)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Transform.rotate(
                          angle: 3.14159, // 180 degrees rotation
                          child: Text(
                            'OPPONENT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[400],
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),

                      // Thresholds compact
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ThresholdTrackerWidget(
                          playerState: gameState.opponent,
                          isPlayer: false,
                          isCompact: true,
                        ),
                      ),

                      // Life counter takes remaining space
                      Expanded(
                        child: LifeCounterWidget(
                          playerState: gameState.opponent,
                          isPlayer: false,
                          isRotated: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Player Section (Bottom Half)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              const Color(0xFF1E293B),
                              const Color(0xFF0F172A),
                            ]
                          : [
                              const Color(0xFFE2E8F0),
                              const Color(0xFFF8FAFC),
                            ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Life counter takes most space
                      Expanded(
                        child: LifeCounterWidget(
                          playerState: gameState.player,
                          isPlayer: true,
                          isRotated: false,
                        ),
                      ),

                      // Thresholds compact
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ThresholdTrackerWidget(
                          playerState: gameState.player,
                          isPlayer: true,
                          isCompact: true,
                        ),
                      ),

                      // Small player label
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[400],
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Game'),
          content: const Text(
              'Are you sure you want to reset the game? This will reset all life points and thresholds.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<GameStateProvider>(context, listen: false)
                    .resetGame();
                Navigator.of(context).pop();
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}
