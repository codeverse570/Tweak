import 'package:flutter/material.dart';
import 'package:skillyr/features/home/domain/models/game_item.dart';

class DailyChallengeCard extends StatelessWidget {
  final GameItem game;
  final String timerStr;
  final double scale;
   DailyChallengeCard(
      {required this.game, required this.timerStr, required this.scale});

  @override
  Widget build(BuildContext context) {
    final s = scale;
    const double currentProgress = 9;
    const double maxProgress = 14;

    return Container(
      padding: EdgeInsets.fromLTRB(12 * s, 10 * s, 12 * s, 10 * s),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40 * s,
                height: 40 * s,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      game.accentColor.withOpacity(0.7),
                      game.accentColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10 * s),
                ),
                child: Icon(Icons.anchor_rounded,
                    color: Colors.white, size: 20 * s),
              ),
              SizedBox(width: 10 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY CHALLENGE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (12 * s).clamp(9.0, 14.0),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2 * s),
                    Text(
                      'Answer 14 questions correctly',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: (10 * s).clamp(8.0, 12.0),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.card_giftcard_rounded,
                      color: const Color(0xFFFFB74D), size: 22 * s),
                  SizedBox(height: 2 * s),
                  Text(
                    timerStr,
                    style: TextStyle(
                      color: const Color(0xFF7C3AED),
                      fontSize: (10 * s).clamp(8.0, 12.0),
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8 * s),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: currentProgress / maxProgress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor:
                  AlwaysStoppedAnimation<Color>(game.accentColor),
              minHeight: 5 * s,
            ),
          ),
          SizedBox(height: 8 * s),
          Row(
            children: [
              Icon(Icons.bolt,
                  color: const Color(0xFFFBBF24), size: 13 * s),
              SizedBox(width: 3 * s),
              Text(
                '200 XP',
                style: TextStyle(
                  color: const Color(0xFFFBBF24),
                  fontSize: (10 * s).clamp(8.0, 12.0),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 12 * s),
              Icon(Icons.monetization_on_rounded,
                  color: const Color(0xFF60A5FA), size: 13 * s),
              SizedBox(width: 3 * s),
              Text(
                '50',
                style: TextStyle(
                  color: const Color(0xFF60A5FA),
                  fontSize: (10 * s).clamp(8.0, 12.0),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${currentProgress.toInt()} / ${maxProgress.toInt()}',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: (10 * s).clamp(8.0, 12.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
