import 'dart:math';
import 'package:flutter/material.dart';
import 'package:skillyr/core/constants/app_colors.dart';
import 'package:skillyr/features/home/domain/models/game_item.dart';
import 'package:skillyr/features/matchmaking/presentation/screens/matchmaking_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// GamesSection  ── drop-in replacement, same widget name
// ═══════════════════════════════════════════════════════════════════════════════
class GamesSection extends StatefulWidget {
  const GamesSection({super.key});
  @override
  State<GamesSection> createState() => _GamesSectionState();
}

class _GamesSectionState extends State<GamesSection> {
  int _cur = 1; // start on centre card

  void _prev() => setState(() => _cur = (_cur - 1 + games.length) % games.length);
  void _next() => setState(() => _cur = (_cur + 1) % games.length);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── header ────────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Games',
                  style: TextStyle(
                      color: Color(0xFFE2D9F3),
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () {},
                child: const Text('View All',
                    style: TextStyle(
                        color: AppColors.purpleLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── 3-D carousel stage ────────────────────────────────────────────────
        SizedBox(
          height: 400,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // left card
              _Card3D(
                game: games[(_cur - 1 + games.length) % games.length],
                slot: CardSlot.left,
                onTap: _prev,
              ),
              // right card
              _Card3D(
                game: games[(_cur + 1) % games.length],
                slot: CardSlot.right,
                onTap: _next,
              ),
              // centre card — rendered last so it's always on top
              _Card3D(
                game: games[_cur],
                slot: CardSlot.center,
                onTap: () {
                  if (!games[_cur].comingSoon) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => MatchmakingScreen(
                        gameTitle: games[_cur].title,
                        gameEmoji: games[_cur].emoji,
                        accentColor: games[_cur].accentColor,
                        accentLight: games[_cur].accentLight,
                      ),
                    ));
                  }
                },
              ),
              // arrows
              Positioned(
                  left: 8,
                  child: _Arrow(left: true, onTap: _prev)),
              Positioned(
                  right: 8,
                  child: _Arrow(left: false, onTap: _next)),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── dots ──────────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(games.length, (i) {
            final active = i == _cur;
            return GestureDetector(
              onTap: () => setState(() => _cur = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: active ? 18 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withOpacity(0.65)
                      : Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Slot enum
// ═══════════════════════════════════════════════════════════════════════════════
enum CardSlot { left, center, right }

// ═══════════════════════════════════════════════════════════════════════════════
// _Card3D  ── animates between slot positions
// ═══════════════════════════════════════════════════════════════════════════════
class _Card3D extends StatefulWidget {
  final GameItem game;
  final CardSlot slot;
  final VoidCallback onTap;
  const _Card3D({required this.game, required this.slot, required this.onTap});

  @override
  State<_Card3D> createState() => _Card3DState();
}

class _Card3DState extends State<_Card3D> with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final Animation<double>   _floatAnim;
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;
  late final AnimationController _shimmerCtrl;
  late final Animation<double>   _shimmerAnim;
  late final AnimationController _pressCtrl;
  late final Animation<double>   _pressAnim;
  // coming-soon
  late final AnimationController _orbitACtrl, _orbitBCtrl, _ringCtrl;
  late final Animation<double>   _orbitAAnim, _orbitBAnim, _ringScale, _ringOpacity;
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -5, end: 5)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.14)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0)
        .animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));

    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 110));
    _pressAnim = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));

    _orbitACtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();
    _orbitAAnim = Tween<double>(begin: 0, end: 2 * pi).animate(_orbitACtrl);
    _orbitBCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4800))..repeat();
    _orbitBAnim = Tween<double>(begin: 2 * pi, end: 0).animate(_orbitBCtrl);
    _ringCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
    _ringScale   = Tween<double>(begin: 0.7, end: 1.55).animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));
    _ringOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _floatCtrl.dispose(); _pulseCtrl.dispose(); _shimmerCtrl.dispose();
    _pressCtrl.dispose(); _orbitACtrl.dispose(); _orbitBCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  // ── slot-based layout values ──────────────────────────────────────────────
  static const double _centerW  = 192;
  static const double _sideW    = 152;
  static const double _centerH  = 385;
  static const double _sideH    = 305;
  static const double _sideX    = 148; // horizontal offset from centre
  static const double _sideZRot = 0.38; // radians (~22°)
  static const double _perspective = 0.0012;

  @override
  Widget build(BuildContext context) {
    final g        = widget.game;
    final isCenter = widget.slot == CardSlot.center;
    final isLeft   = widget.slot == CardSlot.left;

    final double xOff   = isCenter ? 0 : (isLeft ? -_sideX : _sideX);
    final double yRot   = isCenter ? 0 : (isLeft ? _sideZRot : -_sideZRot);
    final double width  = isCenter ? _centerW : _sideW;
    final double height = isCenter ? _centerH : _sideH;
    final double opacity = isCenter ? 1.0 : 0.75;

    // Build the 3-D matrix: perspective + rotateY
    final Matrix4 matrix = Matrix4.identity()
      ..setEntry(3, 2, _perspective)
      ..rotateY(yRot);

    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnim, _shimmerAnim, _pulseAnim, _pressAnim]),
      builder: (context, _) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(xOff, 0.0, isCenter ? 0.0 : -80.0),
          child: Opacity(
            opacity: opacity,
            child: GestureDetector(
              onTapDown:   (_) => _pressCtrl.forward(),
              onTapUp:     (_) { _pressCtrl.reverse(); widget.onTap(); },
              onTapCancel: ()  => _pressCtrl.reverse(),
              child: Transform.scale(
                scale: _pressAnim.value,
                child: Transform(
                  alignment: isCenter ? Alignment.center
                      : (isLeft ? Alignment.centerRight : Alignment.centerLeft),
                  transform: matrix,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: _buildCardContent(g, isCenter, width, height),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(GameItem g, bool isCenter, double w, double h) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [g.gradFrom, g.gradTo],
        ),
        border: Border.all(color: g.accentColor.withOpacity(0.35), width: 1),
        boxShadow: isCenter
            ? [
                BoxShadow(color: g.accentColor.withOpacity(0.3),  blurRadius: 40, spreadRadius: 2),
                BoxShadow(color: Colors.black.withOpacity(0.55),  blurRadius: 50, offset: const Offset(0, 20)),
              ]
            : [
                BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 24, offset: const Offset(0, 10)),
              ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // radial glow top
          Positioned(
            top: -30, left: 0, right: 0, height: 160,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.0,
                  colors: [g.accentColor.withOpacity(0.22), Colors.transparent],
                ),
              ),
            ),
          ),
          // shimmer sweep
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(
                  painter: _ShimmerPainter(progress: _shimmerAnim.value, color: g.accentColor),
                ),
              ),
            ),
          ),
          // body
          Padding(
            padding: EdgeInsets.fromLTRB(
                isCenter ? 14 : 10,
                isCenter ? 14 : 12,
                isCenter ? 14 : 10,
                isCenter ? 14 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
                  decoration: BoxDecoration(
                    color: g.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(g.category,
                      style: TextStyle(
                          color: g.accentLight,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6)),
                ),
                SizedBox(height: isCenter ? 12 : 8),
                // floating emoji
                Transform.translate(
                  offset: Offset(0, isCenter ? _floatAnim.value : 0),
                  child: Container(
                    width: isCenter ? 74 : 58,
                    height: isCenter ? 74 : 58,
                    decoration: BoxDecoration(
                      color: g.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: g.accentColor.withOpacity(0.25), blurRadius: isCenter ? 24 : 14)],
                    ),
                    alignment: Alignment.center,
                    child: Text(g.emoji, style: TextStyle(fontSize: isCenter ? 38 : 28)),
                  ),
                ),
                SizedBox(height: isCenter ? 10 : 7),
                // title
                Text(g.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: const Color(0xFFEDE9FE),
                        fontSize: isCenter ? 17 : 12,
                        fontWeight: FontWeight.w800,
                        height: 1.15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                // center-only content
                if (isCenter) ...[
                  const SizedBox(height: 4),
                  Text(g.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 9, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  // rating
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.star_rounded, color: g.accentColor, size: 13),
                    const SizedBox(width: 4),
                    Text('RATING',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1)),
                  ]),
                  const SizedBox(height: 2),
                  Text(g.rating,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.0)),
                  Text(g.rankLabel,
                      style: TextStyle(color: g.accentLight, fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  // stats strip
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: g.stats.asMap().entries.map((e) {
                        final isLast = e.key == g.stats.length - 1;
                        return Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              border: Border(
                                right: isLast
                                    ? BorderSide.none
                                    : BorderSide(color: Colors.white.withOpacity(0.07), width: 1),
                              ),
                            ),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Text(e.value.value,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                              if (e.value.label.isNotEmpty)
                                Text(e.value.label,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.35),
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w500)),
                            ]),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (!g.comingSoon) ...[
                    const SizedBox(height: 10),
                    // avatars + online count
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ...List.generate(3, (i) => Transform.translate(
                        offset: Offset(i * -6.0, 0),
                        child: Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: g.accentColor.withOpacity(0.4 - i * 0.1),
                            border: Border.all(color: g.accentColor.withOpacity(0.5), width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(['A', 'B', 'C'][i],
                              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                        ),
                      )),
                      const SizedBox(width: 8),
                      Text('${g.playerCount} online',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
                    ]),
                    const SizedBox(height: 10),
                    // pulsing play button
                    Transform.scale(
                      scale: _pulseAnim.value,
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [g.accentColor, g.accentLight]),
                          boxShadow: [
                            BoxShadow(
                                color: g.accentColor.withOpacity(0.5),
                                blurRadius: 16 + (_pulseAnim.value - 1.0) / 0.14 * 16),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ] else ...[
                  // side card: mini rating
                  const SizedBox(height: 5),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.star_rounded, color: g.accentLight, size: 10),
                    const SizedBox(width: 3),
                    Text(g.rating,
                        style: TextStyle(color: g.accentLight, fontSize: 10, fontWeight: FontWeight.w700)),
                  ]),
                ],
              ],
            ),
          ),
          // ── coming-soon overlay (centre only) ──────────────────────────────
          if (g.comingSoon && isCenter)
            Positioned.fill(
              child: _ComingSoonOverlay(
                game:        g,
                ringScale:   _ringScale,
                ringOpacity: _ringOpacity,
                floatAnim:   _floatAnim,
                orbitAAnim:  _orbitAAnim,
                orbitBAnim:  _orbitBAnim,
                notified:    _notified,
                onNotify: () {
                  setState(() => _notified = true);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text("We'll notify you when Mathematics Arena launches!"),
                    backgroundColor: g.accentColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 3),
                  ));
                },
              ),
            ),
          // ── "COMING SOON" pill on side cards ──────────────────────────────
          if (g.comingSoon && !isCenter)
            Positioned(
              bottom: 12, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [g.accentColor, g.accentLight]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('COMING SOON',
                      style: TextStyle(
                          color: Colors.white, fontSize: 7.5,
                          fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Coming-soon overlay
// ═══════════════════════════════════════════════════════════════════════════════
class _ComingSoonOverlay extends StatelessWidget {
  final GameItem game;
  final Animation<double> ringScale, ringOpacity, floatAnim, orbitAAnim, orbitBAnim;
  final bool notified;
  final VoidCallback onNotify;
  const _ComingSoonOverlay({
    required this.game, required this.ringScale, required this.ringOpacity,
    required this.floatAnim, required this.orbitAAnim, required this.orbitBAnim,
    required this.notified, required this.onNotify,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ringScale, ringOpacity, floatAnim, orbitAAnim, orbitBAnim]),
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.05), Colors.black.withOpacity(0.88)],
          ),
        ),
        child: Stack(children: [
          // SOON badge
          Positioned(
            top: 10, right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [game.accentColor, game.accentLight]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: game.accentColor.withOpacity(0.45), blurRadius: 10)],
              ),
              child: const Text('SOON',
                  style: TextStyle(color: Colors.white, fontSize: 9,
                      fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // icon + orbit + ring
              SizedBox(width: 96, height: 96,
                child: Stack(alignment: Alignment.center, children: [
                  Transform.scale(
                    scale: ringScale.value,
                    child: Opacity(
                      opacity: ringOpacity.value,
                      child: Container(width: 68, height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: game.accentColor, width: 2),
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, floatAnim.value),
                    child: Container(
                      width: 62, height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                            colors: [game.accentColor, game.accentLight]),
                        boxShadow: [BoxShadow(color: game.accentColor.withOpacity(0.5), blurRadius: 20)],
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                  Transform.rotate(
                    angle: orbitAAnim.value,
                    child: Transform.translate(
                      offset: const Offset(0, -38),
                      child: Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, color: game.accentLight,
                          boxShadow: [BoxShadow(color: game.accentLight.withOpacity(0.8), blurRadius: 6)],
                        ),
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: orbitBAnim.value,
                    child: Transform.translate(
                      offset: const Offset(0, -46),
                      child: Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent.withOpacity(0.9),
                          boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.7), blurRadius: 5)],
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              ShaderMask(
                shaderCallback: (b) => LinearGradient(
                  colors: [Colors.white, game.accentLight, Colors.white],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(b),
                child: const Text('COMING SOON',
                    style: TextStyle(color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w900, letterSpacing: 2.5)),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text('Mathematics battles are under development',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10, height: 1.5, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: notified ? null : onNotify,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: notified ? game.accentColor.withOpacity(0.25) : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: notified ? game.accentColor.withOpacity(0.6) : Colors.white.withOpacity(0.15),
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(notified ? Icons.check_circle_rounded : Icons.notifications_none_rounded,
                        size: 13,
                        color: notified ? game.accentLight : Colors.white.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    Text(notified ? 'Notified!' : 'Notify me',
                        style: TextStyle(
                            color: notified ? game.accentLight : Colors.white.withOpacity(0.7),
                            fontSize: 10, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Nav arrow
// ═══════════════════════════════════════════════════════════════════════════════
class _Arrow extends StatelessWidget {
  final bool left;
  final VoidCallback onTap;
  const _Arrow({required this.left, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.07),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Icon(
        left ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
        color: Colors.white.withOpacity(0.65), size: 20,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shimmer painter
// ═══════════════════════════════════════════════════════════════════════════════
class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _ShimmerPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final x = progress * size.width;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          color.withOpacity(0.07),
          Colors.white.withOpacity(0.06),
          color.withOpacity(0.07),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(x - 60, 0, 120, size.height));
    canvas.drawRect(Rect.fromLTWH(x - 60, 0, 120, size.height), paint);
  }
  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}