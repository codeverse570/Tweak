import 'dart:math';
import 'package:flutter/material.dart';
import 'package:skillyr/core/constants/app_colors.dart';
import 'package:skillyr/features/home/domain/models/game_item.dart';
import 'package:skillyr/features/matchmaking/presentation/screens/matchmaking_screen.dart';

class GameCard extends StatefulWidget {
  final GameItem game;
  const GameCard({super.key, required this.game});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> with TickerProviderStateMixin {
  // 1. Floating icon
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  // 2. Shimmer line
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerAnim;

  // 3. Play button pulse
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // 4. Press scale
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTap: () {
         if (widget.game.title.toLowerCase() == 'mathematics arena') {
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => MatchmakingScreen(
        gameTitle: widget.game.title,
        gameEmoji: widget.game.emoji,
        accentColor: widget.game.accentColor,
        accentLight: widget.game.accentLight,
      ),
    ),
  );
},
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _floatAnim,
          _shimmerAnim,
          _pulseAnim,
          _pressAnim,
        ]),
        builder: (context, _) {
          return Transform.scale(
            scale: _pressAnim.value,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.game.accentColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.game.accentColor.withOpacity(0.08),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  // ── Background radial glow (top) ──
                  Positioned(
                    top: -20,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topCenter,
                          radius: 1.0,
                          colors: [
                            widget.game.accentColor.withOpacity(0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Shimmer line (diagonal sweep, no ShaderMask) ──
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CustomPaint(
                          painter: _ShimmerPainter(
                            progress: _shimmerAnim.value,
                            color: widget.game.accentColor,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Main content ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Floating icon
                        Transform.translate(
                          offset: Offset(0, _floatAnim.value),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: widget.game.accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.game.accentColor.withOpacity(
                                    0.15 + (_floatAnim.value + 4) / 8 * 0.2,
                                  ),
                                  blurRadius:
                                      10 + (_floatAnim.value + 4) / 8 * 10,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              widget.game.emoji,
                              style: const TextStyle(fontSize: 38),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Title
                        Text(
                          widget.game.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFEDE9FE),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 5),

                        // Description
                        Text(
                          widget.game.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 9,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 6),

                        // Players
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.emoji_events,
                                color: AppColors.amber, size: 10),
                            const SizedBox(width: 3),
                            Text(
                              widget.game.playerCount,
                              style: TextStyle(
                                color: widget.game.accentLight,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Pulsing play button
                        Transform.scale(
                          scale: _pulseAnim.value,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.game.accentColor,
                                  widget.game.accentLight,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.game.accentColor.withOpacity(
                                    0.3 +
                                        (_pulseAnim.value - 1.0) / 0.15 * 0.25,
                                  ),
                                  blurRadius: 8 +
                                      (_pulseAnim.value - 1.0) / 0.15 * 12,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              if (widget.game.title.toLowerCase() == 'mathematics arena')
  Positioned.fill(
    child: _ComingSoonOverlay(game: widget.game),
  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Shimmer CustomPainter — safe, no ShaderMask ───────────────────────────────
class _ShimmerPainter extends CustomPainter {
  final double progress; // -1.0 → 2.0
  final Color color;

  const _ShimmerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final x = progress * size.width;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          color.withOpacity(0.08),
          Colors.white.withOpacity(0.07),
          color.withOpacity(0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(x - 60, 0, 120, size.height));
    canvas.drawRect(Rect.fromLTWH(x - 60, 0, 120, size.height), paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}
class _ComingSoonOverlay extends StatefulWidget {
  final GameItem game;
  const _ComingSoonOverlay({required this.game});

  @override
  State<_ComingSoonOverlay> createState() => _ComingSoonOverlayState();
}

class _ComingSoonOverlayState extends State<_ComingSoonOverlay>
    with TickerProviderStateMixin {
  // Shimmer on "COMING SOON" text
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerAnim;

  // Icon float
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  // Pulse ring (ripple)
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  // Orbit dot A
  late final AnimationController _orbitACtrl;
  late final Animation<double> _orbitAAnim;

  // Orbit dot B
  late final AnimationController _orbitBCtrl;
  late final Animation<double> _orbitBAnim;

  // Notify button press
  late final AnimationController _notifyCtrl;
  late final Animation<double> _notifyAnim;
  bool _notified = false;

  @override
  void initState() {
    super.initState();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _pulseScale = Tween<double>(begin: 0.7, end: 1.5).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );

    _orbitACtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _orbitAAnim = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _orbitACtrl, curve: Curves.linear),
    );

    _orbitBCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    )..repeat();
    _orbitBAnim = Tween<double>(begin: 2 * pi, end: 0).animate(
      CurvedAnimation(parent: _orbitBCtrl, curve: Curves.linear),
    );

    _notifyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _notifyAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _notifyCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _orbitACtrl.dispose();
    _orbitBCtrl.dispose();
    _notifyCtrl.dispose();
    super.dispose();
  }

  void _handleNotifyTap() {
    if (_notified) return;
    _notifyCtrl.forward().then((_) => _notifyCtrl.reverse());
    setState(() => _notified = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("We'll notify you when Mathematics Arena launches!"),
        backgroundColor: widget.game.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _shimmerAnim,
        _floatAnim,
        _pulseScale,
        _pulseOpacity,
        _orbitAAnim,
        _orbitBAnim,
        _notifyAnim,
      ]),
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.88),
              ],
            ),
          ),
          child: Stack(
            children: [
              // ── Top-right "SOON" badge ──
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.game.accentColor,
                        widget.game.accentLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.game.accentColor.withOpacity(0.45),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Text(
                    'SOON',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              // ── Center content ──
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Icon with pulse ring + orbit dots ──
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulse ripple ring
                          Transform.scale(
                            scale: _pulseScale.value,
                            child: Opacity(
                              opacity: _pulseOpacity.value,
                              child: Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: widget.game.accentColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Floating icon container
                          Transform.translate(
                            offset: Offset(0, _floatAnim.value),
                            child: Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    widget.game.accentColor,
                                    widget.game.accentLight,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.game.accentColor
                                        .withOpacity(0.4),
                                    blurRadius: 18,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),

                          // Orbit dot A (faster, clockwise)
                          Transform.rotate(
                            angle: _orbitAAnim.value,
                            child: Transform.translate(
                              offset: const Offset(0, -36),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.game.accentLight,
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.game.accentLight
                                          .withOpacity(0.8),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Orbit dot B (slower, counter-clockwise)
                          Transform.rotate(
                            angle: _orbitBAnim.value,
                            child: Transform.translate(
                              offset: const Offset(0, -44),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueAccent.withOpacity(0.9),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.blueAccent.withOpacity(0.7),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Animated shimmer "COMING SOON" ──
                    ShaderMask(
                      shaderCallback: (bounds) {
                        final x = _shimmerAnim.value;
                        return LinearGradient(
                          begin: Alignment(x - 0.4, 0),
                          end: Alignment(x + 0.4, 0),
                          colors: [
                            Colors.white,
                            widget.game.accentLight,
                            Colors.white,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds);
                      },
                      child: const Text(
                        'COMING SOON',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Mathematics battles are under development',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                   
                    // ── Notify me button ──
                    GestureDetector(
                      onTap: _handleNotifyTap,
                      child: Transform.scale(
                        scale: _notifyAnim.value,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _notified
                                ? widget.game.accentColor.withOpacity(0.25)
                                : Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _notified
                                  ? widget.game.accentColor.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _notified
                                    ? Icons.check_circle_rounded
                                    : Icons.notifications_none_rounded,
                                size: 13,
                                color: _notified
                                    ? widget.game.accentLight
                                    : Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _notified ? 'Notified!' : 'Notify me',
                                style: TextStyle(
                                  color: _notified
                                      ? widget.game.accentLight
                                      : Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Small release date cell ───────────────────────────────────────────────────
class _ReleaseBadgeCell extends StatelessWidget {
  final String top;
  final String bottom;
  final Color accentColor;
  final Color accentLight;

  const _ReleaseBadgeCell({
    required this.top,
    required this.bottom,
    required this.accentColor,
    required this.accentLight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 32,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.18),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentColor.withOpacity(0.35)),
          ),
          alignment: Alignment.center,
          child: Text(
            top,
            style: TextStyle(
              color: accentLight,
              fontSize: top.length > 2 ? 11 : 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          bottom,
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}