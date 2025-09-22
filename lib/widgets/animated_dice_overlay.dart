import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedDiceOverlay extends StatefulWidget {
  final int sides;
  final VoidCallback onComplete;

  const AnimatedDiceOverlay({
    super.key,
    required this.sides,
    required this.onComplete,
  });

  @override
  State<AnimatedDiceOverlay> createState() => _AnimatedDiceOverlayState();
}

class _AnimatedDiceOverlayState extends State<AnimatedDiceOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fallController;
  late AnimationController _rollController;
  late AnimationController _fadeController;

  late Animation<double> _fallAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  int _currentValue = 1;
  int _finalValue = 1;
  late Random _random;

  @override
  void initState() {
    super.initState();

    _random = Random();
    _finalValue = _random.nextInt(widget.sides) + 1;

    // Fall animation
    _fallController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Roll animation
    _rollController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Fade out animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fallAnimation = Tween<double>(
      begin: -200.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fallController,
      curve: Curves.bounceOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 8 * pi, // Multiple rotations
    ).animate(CurvedAnimation(
      parent: _rollController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fallController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_fadeController);

    _startAnimation();
  }

  void _startAnimation() async {
    // Start falling
    _fallController.forward();

    // Start rolling while falling
    _rollController.repeat();

    // Listen for roll animation to change values
    _rollController.addListener(() {
      if (_rollController.isAnimating) {
        setState(() {
          _currentValue = _random.nextInt(widget.sides) + 1;
        });
      }
    });

    // Wait for fall to complete
    await _fallController.forward();

    // Stop rolling and show final value
    await Future.delayed(const Duration(milliseconds: 300));
    _rollController.stop();
    setState(() {
      _currentValue = _finalValue;
    });

    // Wait to show result
    await Future.delayed(const Duration(milliseconds: 1000));

    // Fade out
    await _fadeController.forward();

    // Complete
    widget.onComplete();
  }

  @override
  void dispose() {
    _fallController.dispose();
    _rollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _fallController,
          _rollController,
          _fadeController,
        ]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Transform.translate(
                offset: Offset(0, _fallAnimation.value),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: _buildDice(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDice() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[100]!,
          ],
        ),
      ),
      child: Center(
        child: widget.sides == 6
            ? _buildD6Face(_currentValue)
            : _buildD20Face(_currentValue),
      ),
    );
  }

  Widget _buildD6Face(int value) {
    return _buildDots(value);
  }

  Widget _buildD20Face(int value) {
    return Text(
      value.toString(),
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildDots(int count) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(9, (index) {
        return Center(
          child: _shouldShowDot(count, index)
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                )
              : const SizedBox(),
        );
      }),
    );
  }

  bool _shouldShowDot(int value, int position) {
    // Standard D6 dot patterns
    switch (value) {
      case 1:
        return position == 4; // Center
      case 2:
        return position == 0 || position == 8; // Top-left, bottom-right
      case 3:
        return position == 0 || position == 4 || position == 8; // Diagonal
      case 4:
        return position == 0 ||
            position == 2 ||
            position == 6 ||
            position == 8; // Corners
      case 5:
        return position == 0 ||
            position == 2 ||
            position == 4 ||
            position == 6 ||
            position == 8; // Corners + center
      case 6:
        return position == 0 ||
            position == 2 ||
            position == 3 ||
            position == 5 ||
            position == 6 ||
            position == 8; // Two columns
      default:
        return false;
    }
  }
}
