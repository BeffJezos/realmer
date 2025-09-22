import 'package:flutter/material.dart';
import 'dart:math';

class DiceRollerModal extends StatefulWidget {
  const DiceRollerModal({super.key});

  @override
  State<DiceRollerModal> createState() => _DiceRollerModalState();
}

class _DiceRollerModalState extends State<DiceRollerModal>
    with TickerProviderStateMixin {
  final Random _random = Random();
  int? _d6Result;
  int? _d20Result;
  bool _isRollingD6 = false;
  bool _isRollingD20 = false;

  late AnimationController _d6Controller;
  late AnimationController _d20Controller;
  late Animation<double> _d6Animation;
  late Animation<double> _d20Animation;

  @override
  void initState() {
    super.initState();
    
    _d6Controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _d20Controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _d6Animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _d6Controller,
      curve: Curves.elasticOut,
    ));

    _d20Animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _d20Controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _d6Controller.dispose();
    _d20Controller.dispose();
    super.dispose();
  }

  void _rollD6() async {
    if (_isRollingD6) return;

    setState(() {
      _isRollingD6 = true;
      _d6Result = null;
    });

    _d6Controller.reset();
    _d6Controller.forward();

    // Simulate rolling animation
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) {
        setState(() {
          _d6Result = _random.nextInt(6) + 1;
        });
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      setState(() {
        _d6Result = _random.nextInt(6) + 1;
        _isRollingD6 = false;
      });
    }
  }

  void _rollD20() async {
    if (_isRollingD20) return;

    setState(() {
      _isRollingD20 = true;
      _d20Result = null;
    });

    _d20Controller.reset();
    _d20Controller.forward();

    // Simulate rolling animation
    for (int i = 0; i < 15; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) {
        setState(() {
          _d20Result = _random.nextInt(20) + 1;
        });
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      setState(() {
        _d20Result = _random.nextInt(20) + 1;
        _isRollingD20 = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Text(
            'DICE ROLLER',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Dice section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  // D6 Section
                  Expanded(
                    child: _buildDiceSection(
                      'D6',
                      _d6Result,
                      _isRollingD6,
                      _rollD6,
                      _d6Animation,
                      Colors.blue[600]!,
                    ),
                  ),
                  
                  const SizedBox(width: 32),
                  
                  // D20 Section
                  Expanded(
                    child: _buildDiceSection(
                      'D20',
                      _d20Result,
                      _isRollingD20,
                      _rollD20,
                      _d20Animation,
                      Colors.purple[600]!,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Close button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B5563),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceSection(
    String diceType,
    int? result,
    bool isRolling,
    VoidCallback onRoll,
    Animation<double> animation,
    Color color,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          diceType,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Dice result display
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: isRolling ? 0.8 + (animation.value * 0.2) : 1.0,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isRolling
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        )
                      : Text(
                          result?.toString() ?? '?',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Roll button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isRolling ? null : onRoll,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              disabledBackgroundColor: color.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isRolling ? 'Rolling...' : 'Roll $diceType',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
