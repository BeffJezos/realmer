# Realmer - Sorcery: Contested Realm Tracker

A Flutter mobile app for tracking gameplay in the Sorcery: Contested Realm trading card game.

## Features

### 🎯 Core Gameplay Tracking
- **Life Counter**: Two players starting at 20 life each
- **Death's Door State**: When a player hits 0 life, they enter "Death's Door" and need one more damage to be defeated
- **Threshold Tracker**: Four element counters (Fire, Water, Air, Earth) with color-coded indicators
- **Dice Roller**: D6 and D20 with animated rolling effects

### 🎨 UI/UX
- **Dark Mode First**: Clean, minimalist design optimized for dark environments
- **Split Layout**: Opponent section (top, rotated 180°) and player section (bottom)
- **Large Touch Targets**: Easy-to-use +/- buttons for life and threshold adjustments
- **Visual Feedback**: Color-coded life states (green → yellow → red → Death's Door)

### 💾 Persistence
- **Local Storage**: Game state automatically saved using SharedPreferences
- **Resume Gameplay**: App remembers life totals and thresholds when reopened

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- iOS Simulator / Android Emulator or physical device

### Installation
1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point and theme configuration
├── providers/
│   └── game_state_provider.dart  # Game state management with Provider
├── screens/
│   └── game_screen.dart      # Main game interface
└── widgets/
    ├── life_counter_widget.dart      # Life tracking with Death's Door
    ├── threshold_tracker_widget.dart # Element threshold counters
    └── dice_roller_modal.dart        # Animated dice rolling modal
```

## Game Rules Integration

### Life System
- Players start at 20 life
- When reaching 0 life → "Death's Door" state (orange indicator)
- One more damage from Death's Door → Defeated (red indicator)
- Healing from Death's Door restores normal life tracking

### Threshold System
- Four elements: Fire (Red), Water (Blue), Air (Gray), Earth (Brown)
- Each threshold can be incremented/decremented independently
- Visual color coding for easy element identification

### Dice Rolling
- D6 and D20 support with animated rolling effects
- Realistic rolling simulation with multiple value changes
- Elastic animation feedback for satisfying user experience

## Technical Details

- **State Management**: Provider pattern for reactive UI updates
- **Persistence**: SharedPreferences for lightweight local storage
- **Animations**: Custom rolling animations with Flutter's animation framework
- **Theme**: Consistent dark theme with purple accent colors
- **Platform Support**: iOS and Android compatible

## Version

Current version: 0.1.0+1
