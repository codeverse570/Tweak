import 'dart:ui';

import 'package:skillyr/core/constants/app_colors.dart';

class GameItem {
  final String emoji;
  final String title;
  final String description;
  final String playerCount;
  final Color accentColor;
  final Color accentLight;
 
  const GameItem({
    required this.emoji,
    required this.title,
    required this.description,
    required this.playerCount,
    required this.accentColor,
    required this.accentLight,
  });
}
 
const List<GameItem> games = [
  GameItem(
    emoji: '⚔️',
    title: 'Competitive Intuition',
    description:
        'Face off in rapid-fire judgment rounds. Test your gut instinct against a real opponent under pressure.',
    playerCount: '32.4K players',
    accentColor: AppColors.purple,
    accentLight: AppColors.purpleLight,
  ),
  GameItem(
    emoji: '🔭',
    title: 'Physics Duel',
    description:
        '1v1 battles through mechanics, optics & thermodynamics. Who masters the laws of the universe?',
    playerCount: '18.1K players',
    accentColor: AppColors.blue,
    accentLight: AppColors.blueLight,
  ),
  GameItem(
    emoji: '📐',
    title: 'Mathematics Arena',
    description:
        'Race your opponent through algebra, calculus & logic puzzles. Speed and accuracy decide the winner.',
    playerCount: '24.7K players',
    accentColor: AppColors.green,
    accentLight: AppColors.greenLight,
  ),
];