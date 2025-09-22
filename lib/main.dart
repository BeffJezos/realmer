import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_state_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const RealmerApp());
}

class RealmerApp extends StatelessWidget {
  const RealmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameStateProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Realmer - Sorcery TCG Tracker',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const GameScreen(),
          );
        },
      ),
    );
  }
}
