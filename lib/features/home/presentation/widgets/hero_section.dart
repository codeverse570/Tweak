import 'dart:math';
import 'package:flutter/material.dart';
import 'package:skillyr/core/constants/app_colors.dart';
import 'package:skillyr/features/home/domain/models/game_item.dart';
import 'package:skillyr/features/matchmaking/presentation/screens/matchmaking_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HeroSection  — full-screen PageView of cinematic game cards
// ─────────────────────────────────────────────────────────────────────────────
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Header row ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
          child: _HeaderRow(),
        ),

        // ── Paged hero cards ────────────────────────────────────────────────
        SizedBox(
          height: screenH * 0.72,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: games.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (ctx, i) => _GameHeroCard(game: games[i]),
          ),
        ),

        // ── Dot indicators ──────────────────────────────────────────────────
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(games.length, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: active
                    ? games[_currentPage].accentColor
                    : Colors.white.withOpacity(0.25),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HeaderRow
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar + name
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.purple, AppColors.purpleGlow],
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'RH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Roxane Harley',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.purpleGlow.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    '⚡ Expert',
                    style: TextStyle(
                      color: AppColors.purpleGlow,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // XP + bell
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.purple, AppColors.purpleLight],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    '1200',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GameHeroCard  — cinematic full-width card for one game
// ─────────────────────────────────────────────────────────────────────────────
class _GameHeroCard extends StatefulWidget {
  final GameItem game;
  const _GameHeroCard({required this.game});

  @override
  State<_GameHeroCard> createState() => _GameHeroCardState();
}

class _GameHeroCardState extends State<_GameHeroCard>
    with TickerProviderStateMixin {
  // Shimmer on title
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerAnim;

  // Play button pulse
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // Press scale
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressAnim;

  // Timer countdown
  late final AnimationController _timerCtrl;
  int _remainingSecs = 18 * 3600 + 24 * 60 + 10; // 18:24:10

  @override
  void initState() {
    super.initState();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );

    // Tick every second for the timer
    _timerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          if (mounted) setState(() => _remainingSecs--);
          _timerCtrl.forward(from: 0);
        }
      });
    _timerCtrl.forward();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    _pressCtrl.dispose();
    _timerCtrl.dispose();
    super.dispose();
  }

  String get _timerStr {
    final h = _remainingSecs ~/ 3600;
    final m = (_remainingSecs % 3600) ~/ 60;
    final s = _remainingSecs % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  void _handlePlay() {
    if (widget.game.comingSoon) return;
    _pressCtrl.forward().then((_) => _pressCtrl.reverse());
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MatchmakingScreen(
        gameTitle: widget.game.title,
        gameEmoji: widget.game.emoji,
        accentColor: widget.game.accentColor,
        accentLight: widget.game.accentLight,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: AnimatedBuilder(
        animation:
            Listenable.merge([_shimmerAnim, _pulseAnim, _pressAnim]),
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: game.accentColor.withOpacity(0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: game.accentColor.withOpacity(0.18),
                  blurRadius: 32,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                // ── Cinematic background ──────────────────────────────────
                _CinematicBackground(game: game),

                // ── Dark gradient overlay (bottom-heavy) ──────────────────
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.35, 0.65, 1.0],
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.transparent,
                          Colors.black.withOpacity(0.55),
                          Colors.black.withOpacity(0.92),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Side action buttons ───────────────────────────────────
                Positioned(
                  right: 12,
                  top: 80,
                  child: _SideActions(accentColor: game.accentColor),
                ),

                // ── Top: category badge ───────────────────────────────────
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _CategoryBadge(
                      label: game.category,
                      accentColor: game.accentColor,
                    ),
                  ),
                ),

                // ── Middle: title + description + player count ─────────────
                Positioned(
                  left: 16,
                  right: 70,
                  top: 48,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shimmer title
                      ShaderMask(
                        shaderCallback: (bounds) {
                          final x = _shimmerAnim.value;
                          return LinearGradient(
                            begin: Alignment(x - 0.6, 0),
                            end: Alignment(x + 0.6, 0),
                            colors: [
                              Colors.white,
                              game.accentLight,
                              Colors.white,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ).createShader(bounds);
                        },
                        child: Text(
                          game.title.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Description with dot
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: game.accentColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              game.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Player count pill ─────────────────────────────────────
                Positioned(
                  left: 16,
                  top: 190,
                  child: _PlayerCountPill(game: game),
                ),

                // ── Bottom section ────────────────────────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _BottomSection(
                    game: game,
                    timerStr: _timerStr,
                    pulseAnim: _pulseAnim,
                    pressAnim: _pressAnim,
                    onPlay: _handlePlay,
                    onTapDown: () => _pressCtrl.forward(),
                    onTapUp: () => _pressCtrl.reverse(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cinematic background — emoji art + radial glow
// ─────────────────────────────────────────────────────────────────────────────
class _CinematicBackground extends StatelessWidget {
  final GameItem game;
  const _CinematicBackground({required this.game});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Dark base
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [game.gradFrom, game.gradTo],
              ),
            ),
          ),
          // Radial glow center
          Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    game.accentColor.withOpacity(0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Huge emoji art
          Positioned(
            bottom: 160,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                game.emoji,
                style: const TextStyle(fontSize: 160),
              ),
            ),
          ),
          // Subtle particle dots
          ..._buildParticles(game.accentColor),
        ],
      ),
    );
  }

  List<Widget> _buildParticles(Color color) {
    final rng = Random(42);
    return List.generate(12, (i) {
      final left = rng.nextDouble() * 300;
      final top = rng.nextDouble() * 350;
      final size = 2.0 + rng.nextDouble() * 3;
      final opacity = 0.15 + rng.nextDouble() * 0.3;
      return Positioned(
        left: left,
        top: top,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(opacity),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category badge
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color accentColor;
  const _CategoryBadge({required this.label, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accentColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Side action buttons
// ─────────────────────────────────────────────────────────────────────────────
class _SideActions extends StatelessWidget {
  final Color accentColor;
  const _SideActions({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SideActionBtn(
          icon: Icons.bar_chart_rounded,
          label: 'Rank',
          accentColor: accentColor,
        ),
        const SizedBox(height: 16),
        _SideActionBtn(
          icon: Icons.emoji_events_rounded,
          label: 'Top Players',
          accentColor: accentColor,
        ),
        const SizedBox(height: 16),
        _SideActionBtn(
          icon: Icons.card_giftcard_rounded,
          label: 'Rewards',
          accentColor: accentColor,
        ),
      ],
    );
  }
}

class _SideActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  const _SideActionBtn(
      {required this.icon,
      required this.label,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Player count pill
// ─────────────────────────────────────────────────────────────────────────────
class _PlayerCountPill extends StatelessWidget {
  final GameItem game;
  const _PlayerCountPill({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
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
          const SizedBox(width: 6),
          Text(
            '${game.playerCount} players',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          // Stacked avatar circles
          SizedBox(
            width: 42,
            height: 16,
            child: Stack(
              children: List.generate(3, (i) {
                final colors = [
                  const Color(0xFF7C3AED),
                  const Color(0xFF2563EB),
                  const Color(0xFF059669),
                ];
                return Positioned(
                  left: i * 12.0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors[i],
                      border: Border.all(
                          color: Colors.black.withOpacity(0.5), width: 1.5),
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

// ─────────────────────────────────────────────────────────────────────────────
// Bottom section — daily challenge + play button
// ─────────────────────────────────────────────────────────────────────────────
class _BottomSection extends StatelessWidget {
  final GameItem game;
  final String timerStr;
  final Animation<double> pulseAnim;
  final Animation<double> pressAnim;
  final VoidCallback onPlay;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;

  const _BottomSection({
    required this.game,
    required this.timerStr,
    required this.pulseAnim,
    required this.pressAnim,
    required this.onPlay,
    required this.onTapDown,
    required this.onTapUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
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
          // ── Daily challenge card ────────────────────────────────────────
          _DailyChallengeCard(game: game, timerStr: timerStr),

          const SizedBox(height: 12),

          // ── Play row ────────────────────────────────────────────────────
          _PlayRow(
            game: game,
            pulseAnim: pulseAnim,
            pressAnim: pressAnim,
            onPlay: onPlay,
            onTapDown: onTapDown,
            onTapUp: onTapUp,
          ),

          const SizedBox(height: 8),

          // ── Tagline ─────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 28, height: 1, color: game.accentColor.withOpacity(0.5)),
              const SizedBox(width: 8),
              Text(
                'Let the battle begin!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 28, height: 1, color: game.accentColor.withOpacity(0.5)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily challenge card
// ─────────────────────────────────────────────────────────────────────────────
class _DailyChallengeCard extends StatelessWidget {
  final GameItem game;
  final String timerStr;
  const _DailyChallengeCard({required this.game, required this.timerStr});

  @override
  Widget build(BuildContext context) {
    const double currentProgress = 9;
    const double maxProgress = 14;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Anchor badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      game.accentColor.withOpacity(0.7),
                      game.accentColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.anchor_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DAILY CHALLENGE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Answer 14 questions correctly',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              // Chest icon + timer
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.card_giftcard_rounded,
                      color: Color(0xFFFFB74D), size: 22),
                  const SizedBox(height: 2),
                  Text(
                    timerStr,
                    style: const TextStyle(
                      color: Color(0xFF7C3AED),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: currentProgress / maxProgress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor:
                  AlwaysStoppedAnimation<Color>(game.accentColor),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 8),
          // Rewards row
          Row(
            children: [
              const Icon(Icons.bolt, color: Color(0xFFFBBF24), size: 13),
              const SizedBox(width: 3),
              const Text(
                '200 XP',
                style: TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.monetization_on_rounded,
                  color: Color(0xFF60A5FA), size: 13),
              const SizedBox(width: 3),
              const Text(
                '50',
                style: TextStyle(
                  color: Color(0xFF60A5FA),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${currentProgress.toInt()} / ${maxProgress.toInt()}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
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

// ─────────────────────────────────────────────────────────────────────────────
// Play row — Rules | circular PLAY icon | Practice
// ─────────────────────────────────────────────────────────────────────────────
class _PlayRow extends StatefulWidget {
  final GameItem game;
  final Animation<double> pulseAnim;
  final Animation<double> pressAnim;
  final VoidCallback onPlay;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;

  const _PlayRow({
    required this.game,
    required this.pulseAnim,
    required this.pressAnim,
    required this.onPlay,
    required this.onTapDown,
    required this.onTapUp,
  });

  @override
  State<_PlayRow> createState() => _PlayRowState();
}

class _PlayRowState extends State<_PlayRow> with TickerProviderStateMixin {
  // Press: scale down then elastic spring back
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  // Ripple 1 — inner ring
  late final AnimationController _ripple1Ctrl;
  late final Animation<double> _ripple1Scale;
  late final Animation<double> _ripple1Opacity;

  // Ripple 2 — outer ring, slightly delayed
  late final AnimationController _ripple2Ctrl;
  late final Animation<double> _ripple2Scale;
  late final Animation<double> _ripple2Opacity;

  @override
  void initState() {
    super.initState();

    // Bounce: squish → overshoot → settle
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.78)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.78, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.18, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_bounceCtrl);

    // Inner ripple
    _ripple1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _ripple1Scale = Tween<double>(begin: 1.0, end: 1.9).animate(
      CurvedAnimation(parent: _ripple1Ctrl, curve: Curves.easeOut),
    );
    _ripple1Opacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _ripple1Ctrl, curve: Curves.easeOut),
    );

    // Outer ripple (delayed ~100 ms via forward offset)
    _ripple2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _ripple2Scale = Tween<double>(begin: 1.0, end: 2.4).animate(
      CurvedAnimation(parent: _ripple2Ctrl, curve: Curves.easeOut),
    );
    _ripple2Opacity = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(parent: _ripple2Ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _ripple1Ctrl.dispose();
    _ripple2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _triggerTap() async {
    _bounceCtrl.forward(from: 0);
    _ripple1Ctrl.forward(from: 0);
    // slight delay so outer ring starts after inner
    await Future.delayed(const Duration(milliseconds: 80));
    if (mounted) _ripple2Ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Rules
        _SecondaryAction(
          icon: Icons.help_outline_rounded,
          label: 'Rules',
          accentColor: game.accentColor,
          onTap: () {},
        ),

        const Spacer(),

        // ── Circular PLAY button ─────────────────────────────────────────
        GestureDetector(
          onTapDown: (_) {
            widget.onTapDown();
            if (!game.comingSoon) _triggerTap();
          },
          onTapUp: (_) => widget.onTapUp(),
          onTapCancel: widget.onTapUp,
          onTap: widget.onPlay,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              widget.pulseAnim,
              _bounceAnim,
              _ripple1Scale,
              _ripple1Opacity,
              _ripple2Scale,
              _ripple2Opacity,
            ]),
            builder: (context, _) {
              const double btnSize = 68.0;

              return SizedBox(
                width: btnSize * 2.6,
                height: btnSize * 2.6,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ── Outer ripple ────────────────────────────────────
                    if (!game.comingSoon)
                      Opacity(
                        opacity: _ripple2Opacity.value,
                        child: Transform.scale(
                          scale: _ripple2Scale.value,
                          child: Container(
                            width: btnSize,
                            height: btnSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: game.accentColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ── Inner ripple ────────────────────────────────────
                    if (!game.comingSoon)
                      Opacity(
                        opacity: _ripple1Opacity.value,
                        child: Transform.scale(
                          scale: _ripple1Scale.value,
                          child: Container(
                            width: btnSize,
                            height: btnSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: game.accentColor.withOpacity(0.8),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ── Idle soft glow ring ─────────────────────────────
                    Container(
                      width: btnSize + 14,
                      height: btnSize + 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: game.accentColor.withOpacity(
                          0.08 + (widget.pulseAnim.value - 1.0) * 0.6,
                        ),
                      ),
                    ),

                    // ── Button circle ───────────────────────────────────
                    Transform.scale(
                      scale: _bounceAnim.value * widget.pulseAnim.value,
                      child: Container(
                        width: btnSize,
                        height: btnSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: game.comingSoon
                              ? Colors.black.withOpacity(0.55)
                              : Colors.black.withOpacity(0.55),
                          border: Border.all(
                            color: game.comingSoon
                                ? Colors.white.withOpacity(0.12)
                                : game.accentColor.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: game.comingSoon
                              ? []
                              : [
                                  BoxShadow(
                                    color: game.accentColor.withOpacity(
                                      0.25 +
                                          (widget.pulseAnim.value - 1.0) *
                                              1.5,
                                    ),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                  ),
                                ],
                        ),
                        child: game.comingSoon
                            ? Icon(
                                Icons.lock_rounded,
                                color: Colors.white.withOpacity(0.4),
                                size: 26,
                              )
                            : const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 34,
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const Spacer(),

        // Practice
        _SecondaryAction(
          icon: Icons.shield_outlined,
          label: 'Practice',
          accentColor: game.accentColor,
          onTap: () {},
        ),
      ],
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}