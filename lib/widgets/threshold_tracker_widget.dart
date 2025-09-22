import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state_provider.dart';

class ThresholdTrackerWidget extends StatefulWidget {
  final PlayerState playerState;
  final bool isPlayer;
  final bool isCompact;

  const ThresholdTrackerWidget({
    super.key,
    required this.playerState,
    required this.isPlayer,
    this.isCompact = false,
  });

  @override
  State<ThresholdTrackerWidget> createState() => _ThresholdTrackerWidgetState();
}

class _ThresholdTrackerWidgetState extends State<ThresholdTrackerWidget>
    with TickerProviderStateMixin {
  late Map<GameElement, AnimationController> _hueControllers;
  late Map<GameElement, Animation<double>> _hueAnimations;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers for each element
    _hueControllers = {};
    _hueAnimations = {};

    for (final element in GameElement.values) {
      _hueControllers[element] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );

      _hueAnimations[element] = Tween<double>(
        begin: 0.0,
        end: 0.1, // Subtle hue shift
      ).animate(CurvedAnimation(
        parent: _hueControllers[element]!,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    for (final controller in _hueControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Transform.rotate(
      angle: widget.isPlayer ? 0 : 3.14159, // 180 degrees rotation for opponent
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B).withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: GameElement.values.map((element) {
            return _buildThresholdCounter(context, element);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildThresholdCounter(BuildContext context, GameElement element) {
    final count = widget.playerState.thresholds[element] ?? 0;
    final elementData = _getElementData(element);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onPanStart: (details) {
          // Start hue animation when swipe begins
          _hueControllers[element]?.forward();
        },
        onPanUpdate: (details) {
          // Prevent default behavior during swipe
        },
        onPanEnd: (details) {
          // Reset hue animation when swipe ends
          _hueControllers[element]?.reverse();

          final velocity = details.velocity.pixelsPerSecond;
          if (velocity.dy.abs() > velocity.dx.abs()) {
            if (velocity.dy < -300) {
              // Swipe up - increase threshold
              Provider.of<GameStateProvider>(context, listen: false)
                  .adjustThreshold(widget.isPlayer, element, 1);
            } else if (velocity.dy > 300 && count > 0) {
              // Swipe down - decrease threshold
              Provider.of<GameStateProvider>(context, listen: false)
                  .adjustThreshold(widget.isPlayer, element, -1);
            }
          }
        },
        child: AnimatedBuilder(
          animation: _hueAnimations[element]!,
          builder: (context, child) {
            final hueShift = _hueAnimations[element]!.value;
            final HSVColor hsv = HSVColor.fromColor(elementData.color);
            final Color animatedColor =
                hsv.withHue((hsv.hue + hueShift * 360) % 360).toColor();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Element count display with modern design and hue animation
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        animatedColor,
                        animatedColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: animatedColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Element name
                Text(
                  elementData.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black54,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 2),
              ],
            );
          },
        ),
      ),
    );
  }

  ElementData _getElementData(GameElement element) {
    switch (element) {
      case GameElement.fire:
        return ElementData('FIRE', const Color(0xFFEF4444));
      case GameElement.water:
        return ElementData('WATER', const Color(0xFF3B82F6));
      case GameElement.air:
        return ElementData('AIR', const Color(0xFF64748B));
      case GameElement.earth:
        return ElementData('EARTH', const Color(0xFF8B5CF6));
    }
  }
}

class ElementData {
  final String name;
  final Color color;

  ElementData(this.name, this.color);
}
