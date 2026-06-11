import 'package:flutter/material.dart';
import 'package:skillyr/features/home/domain/models/game_item.dart';
import 'package:skillyr/features/home/presentation/widgets/daily_challenge_card.dart';
import 'package:skillyr/features/home/presentation/widgets/play_row.dart';

class BottomSection extends StatelessWidget {
  final GameItem game;
  final String timerStr;
  final Animation<double> pulseAnim;
  final Animation<double> pressAnim;
  final double scale;
  final VoidCallback onPlay;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onRules;

   BottomSection({
    required this.game,
    required this.timerStr,
    required this.pulseAnim,
    required this.pressAnim,
    required this.scale,
    required this.onPlay,
    required this.onTapDown,
    required this.onTapUp,
    required this.onRules,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.fromLTRB(14 * s, 16 * s, 14 * s, 16 * s),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.85),
            Colors.black.withOpacity(0.95),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Align(
      alignment: Alignment.centerLeft,
      child: _PlayerCountPill(game: game, scale: s),
    ),
          DailyChallengeCard(game: game, timerStr: timerStr, scale: s),
          SizedBox(height: 12 * s),
          PlayRow(
            game: game,
            pulseAnim: pulseAnim,
            pressAnim: pressAnim,
            scale: s,
            onPlay: onPlay,
            onTapDown: onTapDown,
            onTapUp: onTapUp,
            onRules: onRules,
          ),
          SizedBox(height: 8 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 28 * s,
                  height: 1,
                  color: game.accentColor.withOpacity(0.5)),
              SizedBox(width: 8 * s),
              Text(
                'Let the battle begin!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: (10 * s).clamp(8.0, 12.0),
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8 * s),
              Container(
                  width: 28 * s,
                  height: 1,
                  color: game.accentColor.withOpacity(0.5)),
            ],
          ),
        ],
      ),
    );
  }
}
class _PlayerCountPill extends StatelessWidget {
  final GameItem game;
  final double scale;
  const _PlayerCountPill({required this.game, required this.scale});

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6 * s,
            height: 6 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: game.accentColor,
              boxShadow: [
                BoxShadow(
                  color: game.accentColor.withOpacity(0.8),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: 6 * s),
          Text(
            '${game.playerCount} players',
            style: TextStyle(
              color: Colors.white,
              fontSize: (10 * s).clamp(8.0, 12.0),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8 * s),
          // Stacked avatar circles
          SizedBox(
            width: 42 * s,
            height: 16 * s,
            child: Stack(
              children: List.generate(3, (i) {
                final colors = [
                  const Color(0xFF7C3AED),
                  const Color(0xFF2563EB),
                  const Color(0xFF059669),
                ];
                return Positioned(
                  left: i * 12.0 * s,
                  child: Container(
                    width: 16 * s,
                    height: 16 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors[i],
                      border: Border.all(
                          color: Colors.black.withOpacity(0.5),
                          width: 1.5),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

