import 'package:flutter/material.dart';
import 'package:skillyr/features/home/domain/models/game_item.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Player data model
// ─────────────────────────────────────────────────────────────────────────────
class _Player {
  final int rank;
  final String name;
  final String tier;
  final int elo;
  final String initials;
  final Color avatarColor;
  final bool isYou;

  const _Player({
    required this.rank,
    required this.name,
    required this.tier,
    required this.elo,
    required this.initials,
    required this.avatarColor,
    this.isYou = false,
  });
}

final _players = <_Player>[
  _Player(rank: 1, name: 'Arjun Verma',   tier: 'Legend',     elo: 1720, initials: 'AV', avatarColor: const Color(0xFFFFB347)),
  _Player(rank: 2, name: 'Mira Kapoor',   tier: 'Legend',     elo: 1685, initials: 'MK', avatarColor: const Color(0xFFFF7EB3)),
  _Player(rank: 3, name: 'Rohan Mehta',   tier: 'Master III', elo: 1540, initials: 'RM', avatarColor: const Color(0xFF7EC8E3)),
  _Player(rank: 4, name: 'Ishita Rao',    tier: 'Master II',  elo: 1492, initials: 'IR', avatarColor: const Color(0xFFB5EAD7)),
  _Player(rank: 5, name: 'Vivaan Singh',  tier: 'Master II',  elo: 1448, initials: 'VS', avatarColor: const Color(0xFFFFD700)),
  _Player(rank: 6, name: 'Kabir Malhotra',tier: 'Master I',   elo: 1387, initials: 'KM', avatarColor: const Color(0xFFADD8E6)),
  _Player(rank: 7, name: 'Ananya Joshi',  tier: 'Master I',   elo: 1321, initials: 'AJ', avatarColor: const Color(0xFFDDA0DD)),
  _Player(rank: 8, name: 'Devansh Patel', tier: 'Diamond III',elo: 1296, initials: 'DP', avatarColor: const Color(0xFF98FB98)),
];

const _youPlayer = _Player(
  rank: 0,
  name: 'Roxane Harley',
  tier: 'Diamond III',
  elo: 1200,
  initials: 'RH',
  avatarColor: Color(0xFF9B59B6),
  isYou: true,
);

// ─────────────────────────────────────────────────────────────────────────────
// LeaderboardPanel
// ─────────────────────────────────────────────────────────────────────────────
class LeaderboardPanel extends StatefulWidget {
  final GameItem game;
  final VoidCallback onClose;
  final double scale;

  const LeaderboardPanel({
    super.key,
    required this.game,
    required this.onClose,
    required this.scale,
  });

  @override
  State<LeaderboardPanel> createState() => _LeaderboardPanelState();
}

class _LeaderboardPanelState extends State<LeaderboardPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<double>> _slideAnims;

  @override
  void initState() {
    super.initState();

    final total = _players.length + 1; // +1 for "you" row
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();

    const staggerStep = 0.10;
    _fadeAnims = List.generate(total, (i) {
      final start = i * staggerStep;
      final end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    _slideAnims = List.generate(total, (i) {
      final start = i * staggerStep;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 24.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final s = widget.scale;

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [game.gradFrom, game.gradTo],
          ),
        ),
        child: Stack(
          children: [
            // Radial glow — top-left this time for variety
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topLeft,
                    radius: 1.5,
                    colors: [
                      game.accentColor.withOpacity(0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Faint grid
            Positioned.fill(
              child: CustomPaint(painter: _GridPainter(game.accentColor)),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.fromLTRB(16 * s, 18 * s, 16 * s, 12 * s),
              child: Column(
                children: [
                  // ── Header ────────────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 38 * s,
                        height: 38 * s,
                        decoration: BoxDecoration(
                          color: game.accentColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10 * s),
                          border: Border.all(
                            color: game.accentColor.withOpacity(0.4),
                          ),
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: game.accentColor,
                          size: 20 * s,
                        ),
                      ),
                      SizedBox(width: 12 * s),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LEADERBOARD',
                              style: TextStyle(
                                color: game.accentColor,
                                fontSize: (10 * s).clamp(8.0, 12.0),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.8,
                              ),
                            ),
                            SizedBox(height: 2 * s),
                            Text(
                              game.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (16 * s).clamp(12.0, 20.0),
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Subtitle pill: top % badge
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8 * s, vertical: 3 * s),
                        decoration: BoxDecoration(
                          color: game.accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: game.accentColor.withOpacity(0.35)),
                        ),
                        child: Text(
                          'Top 8%',
                          style: TextStyle(
                            color: game.accentColor,
                            fontSize: (9 * s).clamp(7.0, 11.0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      // Close button
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          width: 34 * s,
                          height: 34 * s,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.18)),
                          ),
                          child: Icon(Icons.close_rounded,
                              color: Colors.white, size: 16 * s),
                        ),
                      ),
                    ],
                  ),

                  // Divider
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10 * s),
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          game.accentColor.withOpacity(0.5),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),

                  // Column labels
                  Padding(
                    padding: EdgeInsets.only(
                        left: 4 * s, right: 4 * s, bottom: 6 * s),
                    child: Row(
                      children: [
                        SizedBox(width: 28 * s), // rank col
                        SizedBox(width: 10 * s),
                        SizedBox(width: 32 * s), // avatar col
                        SizedBox(width: 10 * s),
                        Expanded(
                          child: Text(
                            'PLAYER',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: (7.5 * s).clamp(6.0, 9.0),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Text(
                          'ELO',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: (7.5 * s).clamp(6.0, 9.0),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 6 * s),
                      ],
                    ),
                  ),

                  // ── Player list ───────────────────────────────────────────
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _staggerCtrl,
                      builder: (context, _) {
                        return Column(
                          children: List.generate(_players.length, (i) {
                            return Expanded(
                              child: Opacity(
                                opacity: _fadeAnims[i].value,
                                child: Transform.translate(
                                  offset: Offset(0, _slideAnims[i].value),
                                  child: _PlayerRow(
                                    player: _players[i],
                                    accentColor: game.accentColor,
                                    accentLight: game.accentLight,
                                    scale: s,
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),

                  // ── "You" pinned row ──────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(top: 8 * s),
                    child: AnimatedBuilder(
                      animation: _staggerCtrl,
                      builder: (context, _) {
                        final i = _players.length;
                        return Opacity(
                          opacity: _fadeAnims[i].value,
                          child: Transform.translate(
                            offset: Offset(0, _slideAnims[i].value),
                            child: _YouRow(
                              player: _youPlayer,
                              topPercent: 'Top 8%',
                              accentColor: game.accentColor,
                              accentLight: game.accentLight,
                              scale: s,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single player row
// ─────────────────────────────────────────────────────────────────────────────
class _PlayerRow extends StatelessWidget {
  final _Player player;
  final Color accentColor;
  final Color accentLight;
  final double scale;

  const _PlayerRow({
    required this.player,
    required this.accentColor,
    required this.accentLight,
    required this.scale,
  });

  // Medal colour for top 3
  Color? get _medalColor {
    switch (player.rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFB8BEC7);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final medal = _medalColor;
    final isTop3 = medal != null;

    return Container(
      margin: EdgeInsets.only(bottom: 5 * s),
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 5 * s),
      decoration: BoxDecoration(
        color: isTop3
            ? medal!.withOpacity(0.07)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10 * s),
        border: Border.all(
          color: isTop3
              ? medal!.withOpacity(0.25)
              : Colors.white.withOpacity(0.07),
          width: isTop3 ? 1 : 0.5,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 22 * s,
            child: isTop3
                ? Icon(Icons.emoji_events_rounded,
                    color: medal, size: 16 * s)
                : Text(
                    '${player.rank}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: (11 * s).clamp(8.0, 14.0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          SizedBox(width: 8 * s),

          // Avatar
          Container(
            width: 28 * s,
            height: 28 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: player.avatarColor.withOpacity(0.25),
              border: Border.all(
                  color: player.avatarColor.withOpacity(0.5), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              player.initials,
              style: TextStyle(
                color: player.avatarColor,
                fontSize: (8.5 * s).clamp(7.0, 11.0),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 8 * s),

          // Name + tier
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  player.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (11 * s).clamp(8.5, 13.5),
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1 * s),
                Row(
                  children: [
                    Text(
                      isTop3 ? '👑' : '✦',
                      style: TextStyle(fontSize: (8 * s).clamp(6.0, 10.0)),
                    ),
                    SizedBox(width: 3 * s),
                    Text(
                      player.tier,
                      style: TextStyle(
                        color: isTop3
                            ? medal!.withOpacity(0.85)
                            : accentColor.withOpacity(0.7),
                        fontSize: (8.5 * s).clamp(7.0, 10.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ELO + trophy
          Row(
            children: [
              Text(
                '${player.elo}',
                style: TextStyle(
                  color: isTop3 ? medal : Colors.white,
                  fontSize: (12 * s).clamp(9.0, 15.0),
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 5 * s),
              Icon(
                Icons.emoji_events_outlined,
                color: (isTop3 ? medal : Colors.white)!.withOpacity(0.55),
                size: 13 * s,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "You" pinned row — highlighted, always visible at bottom
// ─────────────────────────────────────────────────────────────────────────────
class _YouRow extends StatelessWidget {
  final _Player player;
  final String topPercent;
  final Color accentColor;
  final Color accentLight;
  final double scale;

  const _YouRow({
    required this.player,
    required this.topPercent,
    required this.accentColor,
    required this.accentLight,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.22),
            accentColor.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: accentColor.withOpacity(0.55), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // "You" label
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'You',
                style: TextStyle(
                  color: accentColor,
                  fontSize: (9 * s).clamp(7.0, 11.0),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                topPercent,
                style: TextStyle(
                  color: accentColor.withOpacity(0.65),
                  fontSize: (7.5 * s).clamp(6.0, 9.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(width: 10 * s),

          // Avatar
          Container(
            width: 32 * s,
            height: 32 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [accentColor, accentLight],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              player.initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: (10 * s).clamp(8.0, 13.0),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 10 * s),

          // Name + tier
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (12 * s).clamp(9.0, 14.5),
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2 * s),
                Row(
                  children: [
                    Text('✦',
                        style:
                            TextStyle(fontSize: (8 * s).clamp(6.0, 10.0))),
                    SizedBox(width: 3 * s),
                    Text(
                      player.tier,
                      style: TextStyle(
                        color: accentColor.withOpacity(0.85),
                        fontSize: (9 * s).clamp(7.0, 11.0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ELO
          Row(
            children: [
              Text(
                '${player.elo}',
                style: TextStyle(
                  color: accentColor,
                  fontSize: (13 * s).clamp(10.0, 16.0),
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 5 * s),
              Icon(Icons.emoji_events_outlined,
                  color: accentColor.withOpacity(0.7), size: 14 * s),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid painter (same as RulesPanel)
// ─────────────────────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.05)
      ..strokeWidth = 0.8;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}