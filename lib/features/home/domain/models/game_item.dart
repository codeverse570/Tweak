import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GameStat  — one stat cell (icon + value + label)
// ─────────────────────────────────────────────────────────────────────────────
class GameStat {
  final String icon;
  final String value;
  final String label;
  const GameStat(
      {required this.icon, required this.value, required this.label});
}

// ─────────────────────────────────────────────────────────────────────────────
// GameItem  — one entry in the games list
// ─────────────────────────────────────────────────────────────────────────────
class GameItem {
  final String title;
  final String description;
  final String emoji;
  final String category;
  final Color accentColor;
  final Color accentLight;
  final Color gradFrom;
  final Color gradTo;
  final String rating;
  final String rankLabel;
  final List<GameStat> stats;
  final String playerCount;
  final bool comingSoon;

  const GameItem({
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.accentColor,
    required this.accentLight,
    required this.gradFrom,
    required this.gradTo,
    required this.rating,
    required this.rankLabel,
    required this.stats,
    required this.playerCount,
    this.comingSoon = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Game data
// ─────────────────────────────────────────────────────────────────────────────
const List<GameItem> games = [
  GameItem(
    title: 'Competitive Intuition',
    description:
        'Face off in rapid-fire judgment rounds.\nTest your gut instinct.',
    emoji: '⚔️',
    category: 'MENTAL',
    accentColor: Color(0xFFEF4444),
    accentLight: Color(0xFFFCA5A5),
    gradFrom: Color(0xFF3d1010),
    gradTo: Color(0xFF1a0505),
    rating: '1420',
    rankLabel: 'Diamond III',
    stats: [
      GameStat(icon: '🔥', value: '6', label: 'Win Streak'),
      GameStat(icon: '⚡', value: '72%', label: 'Win Rate'),
      GameStat(icon: '🏆', value: 'Top 8%', label: ''),
    ],
    playerCount: '32.4K',
  ),
  GameItem(
    title: 'Physics Duel',
    description:
        'Test ballistics, optics & thermodynamics.\nWho masters the universe?',
    emoji: '🔭',
    category: 'SCIENCE',
    accentColor: Color(0xFF3B82F6),
    accentLight: Color(0xFF93C5FD),
    gradFrom: Color(0xFF1a2a4a),
    gradTo: Color(0xFF0d1a35),
    rating: '1180',
    rankLabel: 'Platinum I',
    stats: [
      GameStat(icon: '🔥', value: '4', label: 'Win Streak'),
      GameStat(icon: '⚡', value: '68%', label: 'Win Rate'),
    ],
    playerCount: '1.1K',
  ),
  GameItem(
    title: 'Mathematics Arena',
    description:
        'Race through algebra, calculus & logic puzzles.\nSpeed and accuracy win.',
    emoji: '📐',
    category: 'LOGIC',
    accentColor: Color(0xFF10B981),
    accentLight: Color(0xFF6EE7B7),
    gradFrom: Color(0xFF0d2a1e),
    gradTo: Color(0xFF071a12),
    rating: '980',
    rankLabel: 'Gold V',
    stats: [
      GameStat(icon: '📊', value: '—', label: 'Win Streak'),
      GameStat(icon: '⚡', value: '—', label: 'Win Rate'),
    ],
    playerCount: '—',
    comingSoon: true,
  ),
];