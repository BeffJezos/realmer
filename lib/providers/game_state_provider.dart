import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameElement { fire, water, air, earth }

class PlayerState {
  int life;
  bool isOnDeathsDoor;
  Map<GameElement, int> thresholds;

  PlayerState({
    this.life = 20,
    this.isOnDeathsDoor = false,
    Map<GameElement, int>? thresholds,
  }) : thresholds = thresholds ?? {
          GameElement.fire: 0,
          GameElement.water: 0,
          GameElement.air: 0,
          GameElement.earth: 0,
        };

  Map<String, dynamic> toJson() => {
        'life': life,
        'isOnDeathsDoor': isOnDeathsDoor,
        'thresholds': thresholds.map(
          (key, value) => MapEntry(key.name, value),
        ),
      };

  factory PlayerState.fromJson(Map<String, dynamic> json) {
    final thresholds = <GameElement, int>{};
    final thresholdJson = json['thresholds'] as Map<String, dynamic>? ?? {};
    
    for (final element in GameElement.values) {
      thresholds[element] = thresholdJson[element.name] as int? ?? 0;
    }

    return PlayerState(
      life: json['life'] as int? ?? 20,
      isOnDeathsDoor: json['isOnDeathsDoor'] as bool? ?? false,
      thresholds: thresholds,
    );
  }
}

class GameStateProvider extends ChangeNotifier {
  PlayerState _player = PlayerState();
  PlayerState _opponent = PlayerState();
  bool _isPlayerTurn = true;
  
  // Getters
  PlayerState get player => _player;
  PlayerState get opponent => _opponent;
  bool get isPlayerTurn => _isPlayerTurn;

  GameStateProvider() {
    _loadGameState();
  }

  // Life management
  void adjustLife(bool isPlayer, int change) {
    final targetPlayer = isPlayer ? _player : _opponent;
    
    if (change < 0 && targetPlayer.life == 0 && !targetPlayer.isOnDeathsDoor) {
      // First time hitting 0 life - Death's Door state
      targetPlayer.isOnDeathsDoor = true;
    } else if (change < 0 && targetPlayer.isOnDeathsDoor) {
      // Already on Death's Door, this damage defeats them
      targetPlayer.life = -1; // Mark as defeated
      targetPlayer.isOnDeathsDoor = false;
    } else if (change > 0 && targetPlayer.isOnDeathsDoor) {
      // Healing from Death's Door
      targetPlayer.life = change;
      targetPlayer.isOnDeathsDoor = false;
    } else {
      // Normal life adjustment
      targetPlayer.life = (targetPlayer.life + change).clamp(-1, 999);
      if (targetPlayer.life > 0) {
        targetPlayer.isOnDeathsDoor = false;
      }
    }
    
    _saveGameState();
    notifyListeners();
  }

  // Threshold management
  void adjustThreshold(bool isPlayer, GameElement element, int change) {
    final targetPlayer = isPlayer ? _player : _opponent;
    targetPlayer.thresholds[element] = 
        (targetPlayer.thresholds[element]! + change).clamp(0, 99);
    
    _saveGameState();
    notifyListeners();
  }

  // Game control
  void switchTurn() {
    _isPlayerTurn = !_isPlayerTurn;
    _saveGameState();
    notifyListeners();
  }

  void resetGame() {
    _player = PlayerState();
    _opponent = PlayerState();
    _isPlayerTurn = true;
    _saveGameState();
    notifyListeners();
  }

  // Persistence
  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_state', _encodePlayerState(_player));
    await prefs.setString('opponent_state', _encodePlayerState(_opponent));
    await prefs.setBool('is_player_turn', _isPlayerTurn);
  }

  Future<void> _loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    
    final playerStateJson = prefs.getString('player_state');
    if (playerStateJson != null) {
      _player = _decodePlayerState(playerStateJson);
    }
    
    final opponentStateJson = prefs.getString('opponent_state');
    if (opponentStateJson != null) {
      _opponent = _decodePlayerState(opponentStateJson);
    }
    
    _isPlayerTurn = prefs.getBool('is_player_turn') ?? true;
    notifyListeners();
  }

  String _encodePlayerState(PlayerState state) {
    // Simple JSON-like encoding for SharedPreferences
    return '${state.life},${state.isOnDeathsDoor},'
        '${state.thresholds[GameElement.fire]},'
        '${state.thresholds[GameElement.water]},'
        '${state.thresholds[GameElement.air]},'
        '${state.thresholds[GameElement.earth]}';
  }

  PlayerState _decodePlayerState(String encoded) {
    final parts = encoded.split(',');
    if (parts.length != 6) return PlayerState();
    
    return PlayerState(
      life: int.tryParse(parts[0]) ?? 20,
      isOnDeathsDoor: parts[1] == 'true',
      thresholds: {
        GameElement.fire: int.tryParse(parts[2]) ?? 0,
        GameElement.water: int.tryParse(parts[3]) ?? 0,
        GameElement.air: int.tryParse(parts[4]) ?? 0,
        GameElement.earth: int.tryParse(parts[5]) ?? 0,
      },
    );
  }
}
