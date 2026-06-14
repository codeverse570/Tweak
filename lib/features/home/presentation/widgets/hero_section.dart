import 'dart:math';
import 'package:flutter/material.dart';
import 'package:skillyr/core/constants/app_colors.dart';
import 'package:skillyr/features/home/domain/models/game_item.dart';
import 'package:skillyr/features/home/presentation/widgets/bottom_section.dart';
import 'package:skillyr/features/home/presentation/widgets/leaderboard_panel.dart';
import 'package:skillyr/features/home/presentation/widgets/rule_panel.dart';
import 'package:skillyr/features/matchmaking/presentation/screens/matchmaking_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillyr/features/user/presentation/providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:skillyr/features/user/presentation/providers/user_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Responsive scale helper
//
// Base design width: 390 px (iPhone 14).
// Everything that was a fixed pixel becomes: fixedValue * scale(context).
// Clamped so tablets don't balloon and tiny phones don't shrink too far.
// ─────────────────────────────────────────────────────────────────────────────
double _scale(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  return (w / 390.0).clamp(0.72, 1.35);
}

double _sp(BuildContext context, double size) => size * _scale(context);

// ─────────────────────────────────────────────────────────────────────────────
// Which panel is currently showing on the back of the card
// ─────────────────────────────────────────────────────────────────────────────
enum _BackPanel { rules, leaderboard }

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
    final s = _scale(context);
    final double tileSize = 54.0 * s;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(18 * s, 10 * s, 18 * s, 12 * s),
          child: _HeaderRow(scale: s),
        ),

        Expanded(
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: games.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (ctx, i) => _GameHeroCard(game: games[i], scale: s),
          ),
        ),

        SizedBox(height: 14 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(games.length, (i) {
            final active = i == _currentPage;
            final game = games[i];

            return GestureDetector(
              onTap: () => _pageCtrl.animateToPage(
                i,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(horizontal: 5 * s),
                width: tileSize,
                height: tileSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14 * s),
                  color: active
                      ? game.accentColor.withOpacity(0.18)
                      : Colors.white.withOpacity(0.06),
                  border: Border.all(
                    color: active
                        ? game.accentColor.withOpacity(0.75)
                        : Colors.white.withOpacity(0.12),
                    width: active ? 2 : 1,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: game.accentColor.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: active ? 1.0 : 0.4,
                      child: Text(
                        game.emoji,
                        style: TextStyle(fontSize: 20 * s),
                      ),
                    ),
                    SizedBox(height: 3 * s),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: active ? 1.0 : 0.0,
                      child: Text(
                        game.category,
                        style: TextStyle(
                          color: game.accentColor,
                          fontSize: 7 * s,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 16 * s),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HeaderRow
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderRow extends ConsumerWidget {
  final double scale;
  const _HeaderRow({required this.scale});
  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = scale;

    // ── User data from Supabase ──────────────────────────────────────────
    final progressionAsync = ref.watch(userProgressionProvider);
   final SupabaseClient _client;
    final gems = progressionAsync.valueOrNull?.gems ?? 0;
    final xp   = progressionAsync.valueOrNull?.experience ?? 0;
   
    // Display name from Supabase auth metadata
    final supaUser = Supabase.instance.client.auth.currentUser;
    final meta     = supaUser?.userMetadata ?? {};
    final userName = (meta['full_name'] as String?) ??
        (meta['name'] as String?) ??
        supaUser?.email?.split('@').first ??
        'Player';

    final initials = userName
        .split(' ')
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Avatar + name + gems badge ───────────────────────────────────
        Row(
          children: [
            Container(
              width: 40 * s,
              height: 40 * s,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.purple, AppColors.purpleGlow],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                initials.isEmpty ? '?' : initials,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: 10 * s),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3 * s),
                // ── Gems badge (replaces "Expert") ───────────────────────
                progressionAsync.when(
                  loading: () => _GemsBadge(gems: null, scale: s),
                  error: (_, __) => _GemsBadge(gems: null, scale: s),
                  data: (p) => _GemsBadge(gems: p.gems, scale: s),
                ),
              ],
            ),
          ],
        ),

        // ── XP pill + bell ───────────────────────────────────────────────
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 7 * s),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.purple, AppColors.purpleLight],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt, color: Colors.white, size: 14 * s),
                  SizedBox(width: 4 * s),
                  // Live XP
                  progressionAsync.when(
                    loading: () => Text(
                      '—',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    error: (_, __) => Text(
                      '—',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    data: (p) => Text(
                      _formatXp(p.experience),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10 * s),
            Container(
              width: 36 * s,
              height: 36 * s,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Icon(Icons.notifications_outlined,
                  color: Colors.white, size: 18 * s),
            ),
          ],
        ),
      ],
    );
  }

  String _formatXp(int xp) {
    // print(xp);
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return xp.toString();
  }
}

// ─── Gems badge ──────────────────────────────────────────────────────────────

class _GemsBadge extends StatelessWidget {
  final int? gems;  // null → loading/error state
  final double scale;
  const _GemsBadge({required this.gems, required this.scale});

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 2 * s),
      decoration: BoxDecoration(
        color: AppColors.purple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.purpleGlow.withOpacity(0.3)),
      ),
      child: Text(
        gems == null ? '💎 —' : '💎 $gems',
        style: TextStyle(
          color: const Color.fromARGB(255, 135, 132, 138),
          fontSize: 9 * s,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GameHeroCard  — cinematic full-width card for one game
// ─────────────────────────────────────────────────────────────────────────────
class _GameHeroCard extends StatefulWidget {
  final GameItem game;
  final double scale;
  const _GameHeroCard({required this.game, required this.scale});

  @override
  State<_GameHeroCard> createState() => _GameHeroCardState();
}

class _GameHeroCardState extends State<_GameHeroCard>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerAnim;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  late final AnimationController _pressCtrl;
  late final Animation<double> _pressAnim;

  late final AnimationController _timerCtrl;
  int _remainingSecs = 18 * 3600 + 24 * 60 + 10;

  late final AnimationController _flipCtrl;
  late final Animation<double> _flipAnim;

  bool _isFlipped = false;
  _BackPanel _activeBackPanel = _BackPanel.rules; // which panel shows on back

  @override
  bool get wantKeepAlive => true;

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

    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _flipAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    _pressCtrl.dispose();
    _timerCtrl.dispose();
    _flipCtrl.dispose();
    super.dispose();
  }

  // ── Flip helpers ──────────────────────────────────────────────────────────

  /// Open the back with the given panel, or close if already showing that panel.
  void _flipTo(_BackPanel panel) {
    if (_isFlipped && _activeBackPanel == panel) {
      // Already showing this panel → flip back to front
      _flipCtrl.reverse();
      setState(() => _isFlipped = false);
    } else if (_isFlipped) {
      // Showing a different panel → snap swap: reverse, swap, forward
      _flipCtrl.reverse().then((_) {
        if (mounted) {
          setState(() => _activeBackPanel = panel);
          _flipCtrl.forward();
        }
      });
    } else {
      // Front is showing → flip to back
      setState(() {
        _activeBackPanel = panel;
        _isFlipped = true;
      });
      _flipCtrl.forward();
    }
  }

  void _toggleRules() => _flipTo(_BackPanel.rules);
  void _toggleLeaderboard() => _flipTo(_BackPanel.leaderboard);

  void _closeBack() {
    _flipCtrl.reverse();
    setState(() => _isFlipped = false);
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
    final s = widget.scale;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14 * s),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _shimmerAnim,
          _pulseAnim,
          _pressAnim,
          _flipAnim,
        ]),
        builder: (context, _) {
          final angle = _flipAnim.value * pi;
          final isFrontVisible = angle <= pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24 * s),
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
              child: Transform(
                alignment: Alignment.center,
                transform: isFrontVisible
                    ? Matrix4.identity()
                    : (Matrix4.identity()..rotateY(pi)),
                child: isFrontVisible
                    ? _buildFront(game, s)
                    : _buildBack(game, s),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFront(GameItem game, double s) {
    return LayoutBuilder(builder: (context, constraints) {
      final cardH = constraints.maxHeight;
      final cardW = constraints.maxWidth;

      final emojiSize = (cardW * 0.38).clamp(80.0, 180.0);
      final emojiBottom = cardH * 0.28;
      final titleFontSize = (cardW * 0.072).clamp(18.0, 32.0);
      final sideActionsTop = cardH * 0.12;

      return Stack(
        children: [
          _CinematicBackground(
              game: game, emojiSize: emojiSize, emojiBottom: emojiBottom),

          // Cinematic gradient overlay
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

          // Side actions — now passes leaderboard callback
          Positioned(
            right: 12 * s,
            top: sideActionsTop,
            child: _SideActions(
              accentColor: game.accentColor,
              scale: s,
              onLeaderboard: _toggleLeaderboard,
            ),
          ),

          // Category badge
          Positioned(
            top: 16 * s,
            left: 0,
            right: 0,
            child: Center(
              child: _CategoryBadge(
                label: game.category,
                accentColor: game.accentColor,
                scale: s,
              ),
            ),
          ),

          // Title + description block
          Positioned(
            left: 16 * s,
            right: 70 * s,
            top: cardH * 0.08,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) {
                    final x = _shimmerAnim.value;
                    return LinearGradient(
                      begin: Alignment(x - 0.6, 0),
                      end: Alignment(x + 0.6, 0),
                      colors: [
                        Colors.white,
                        game.accentLight,
                        Colors.white
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ).createShader(bounds);
                  },
                  child: Text(
                    game.title.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 10 * s),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5 * s),
                      width: 6 * s,
                      height: 6 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: game.accentColor,
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Expanded(
                      child: Text(
                        game.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: (12 * s).clamp(9.0, 14.0),
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

          // Bottom section
          Positioned(
            left: 0,
            right: 0,
            bottom: -20,
            child: BottomSection(
              game: game,
              timerStr: _timerStr,
              pulseAnim: _pulseAnim,
              pressAnim: _pressAnim,
              scale: s,
              onPlay: _handlePlay,
              onTapDown: () => _pressCtrl.forward(),
              onTapUp: () => _pressCtrl.reverse(),
              onRules: _toggleRules,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBack(GameItem game, double s) {
    switch (_activeBackPanel) {
      case _BackPanel.rules:
        return RulesPanel(game: game, onClose: _closeBack, scale: s);
      case _BackPanel.leaderboard:
        return LeaderboardPanel(game: game, onClose: _closeBack, scale: s);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cinematic background — emoji art + radial glow
// ─────────────────────────────────────────────────────────────────────────────
class _CinematicBackground extends StatelessWidget {
  final GameItem game;
  final double emojiSize;
  final double emojiBottom;

  const _CinematicBackground({
    required this.game,
    required this.emojiSize,
    required this.emojiBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [game.gradFrom, game.gradTo],
                ),
              ),
            ),
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
            Positioned(
              bottom: emojiBottom,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  game.emoji,
                  style: TextStyle(fontSize: emojiSize),
                ),
              ),
            ),
            ..._buildParticles(
              game.accentColor,
              constraints.maxWidth,
              constraints.maxHeight,
            ),
          ],
        );
      }),
    );
  }

  List<Widget> _buildParticles(Color color, double w, double h) {
    final rng = Random(42);
    return List.generate(12, (i) {
      final left = rng.nextDouble() * w;
      final top = rng.nextDouble() * (h * 0.6);
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
  final double scale;
  const _CategoryBadge(
      {required this.label,
      required this.accentColor,
      required this.scale});

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 14 * s, vertical: 5 * s),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accentColor,
          fontSize: (11 * s).clamp(8.0, 14.0),
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Side action buttons  — now accepts onLeaderboard callback
// ─────────────────────────────────────────────────────────────────────────────
class _SideActions extends StatelessWidget {
  final Color accentColor;
  final double scale;
  final VoidCallback onLeaderboard;

  const _SideActions({
    required this.accentColor,
    required this.scale,
    required this.onLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SideActionBtn(
          icon: Icons.bar_chart_rounded,
          label: 'Rank',
          accentColor: accentColor,
          scale: scale,
          onTap: () {},
        ),
        SizedBox(height: 16 * scale),
        _SideActionBtn(
          icon: Icons.emoji_events_rounded,
          label: 'Top Players',
          accentColor: accentColor,
          scale: scale,
          onTap: onLeaderboard, // ← wired up
        ),
        SizedBox(height: 16 * scale),
        _SideActionBtn(
          icon: Icons.card_giftcard_rounded,
          label: 'Rewards',
          accentColor: accentColor,
          scale: scale,
          onTap: () {},
        ),
      ],
    );
  }
}

class _SideActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final double scale;
  final VoidCallback onTap;

  const _SideActionBtn({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44 * s,
            height: 44 * s,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(12 * s),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Icon(icon, color: Colors.white, size: 20 * s),
          ),
          SizedBox(height: 4 * s),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: (8 * s).clamp(6.0, 10.0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}