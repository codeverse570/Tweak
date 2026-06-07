import 'dart:math';
import 'package:flutter/material.dart';
import 'package:skillyr/core/constants/app_colors.dart';
import 'package:skillyr/features/battle/presentation/screens/battle_screen.dart';
import 'package:skillyr/features/physics/presentation/screens/physics_battle_screen.dart';
import 'package:skillyr/main.dart';

class MatchmakingScreen extends StatefulWidget {
  final String gameTitle;
  final String gameEmoji;
  final Color accentColor;
  final Color accentLight;

  const MatchmakingScreen({
    super.key,
    required this.gameTitle,
    required this.gameEmoji,
    required this.accentColor,
    required this.accentLight,
  });

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen>
    with TickerProviderStateMixin {

  // Radar pulse rings
  late final AnimationController _radarCtrl;
  late final List<Animation<double>> _ringScales;
  late final List<Animation<double>> _ringOpacities;

  // Rotating scanner line
  late final AnimationController _scanCtrl;
  late final Animation<double> _scanAnim;

  // Player avatar bounce
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  // Dots loading text
  late final AnimationController _dotsCtrl;
  late final Animation<int> _dotsAnim;

  // Found opponent flash
  late final AnimationController _foundCtrl;
  late final Animation<double> _foundAnim;

  // Blip particles on radar
  late final List<_RadarBlip> _blips;

  bool _opponentFound = false;
  bool _searching = true;

  @override
  void initState() {
    super.initState();

    // Radar rings — 3 staggered rings
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _ringScales = List.generate(3, (i) {
      final start = i * 0.25;
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _radarCtrl,
          curve: Interval(start.clamp(0, 1), (start + 0.75).clamp(0, 1),
              curve: Curves.easeOut),
        ),
      );
    });

    _ringOpacities = List.generate(3, (i) {
      final start = i * 0.25;
      return Tween<double>(begin: 0.8, end: 0.0).animate(
        CurvedAnimation(
          parent: _radarCtrl,
          curve: Interval(start.clamp(0, 1), (start + 0.75).clamp(0, 1),
              curve: Curves.easeIn),
        ),
      );
    });

    // Scanner rotation
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _scanAnim = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.linear),
    );

    // Avatar bounce
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    // Dots
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _dotsAnim = IntTween(begin: 0, end: 3).animate(_dotsCtrl);

    // Found flash
    _foundCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _foundAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _foundCtrl, curve: Curves.elasticOut),
    );

    // Random blips on radar
    final rng = Random();
    _blips = List.generate(
      5,
      (i) => _RadarBlip(
        angle: rng.nextDouble() * 2 * pi,
        radius: 0.3 + rng.nextDouble() * 0.55,
        triggerAt: rng.nextDouble(),
        size: 3 + rng.nextDouble() * 3,
      ),
    );

    // Simulate finding opponent after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _opponentFound = true;
          _searching = false;
        });
        _foundCtrl.forward();
        _radarCtrl.stop();
        _scanCtrl.stop();

        // Navigate after showing found state
       Future.delayed(const Duration(seconds: 2), () {
  Widget destination;

  if (widget.gameTitle.toLowerCase() == 'competitive intuition') {
    destination = const BattleScreenWrapper();
  } else if (widget.gameTitle.toLowerCase() == 'physics duel') {
    destination = const PhysicsBattleScreen();
  } else {
    destination = const BattleScreenWrapper(); // fallback
  }

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => destination,
    ),
  );
});
      }
    });
  }

  @override
  void dispose() {
    _radarCtrl.dispose();
    _scanCtrl.dispose();
    _bounceCtrl.dispose();
    _dotsCtrl.dispose();
    _foundCtrl.dispose();
    super.dispose();
  }

  String get _dotsText {
    final count = _dotsAnim.value;
    return '.' * count + ' ' * (3 - count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.gameTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _radarCtrl,
          _scanAnim,
          _bounceAnim,
          _dotsAnim,
          _foundAnim,
        ]),
        builder: (context, _) {
          return Column(
            children: [
              const SizedBox(height: 32),

              // Game badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.gameEmoji,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      widget.gameTitle,
                      style: TextStyle(
                        color: widget.accentLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Radar
              SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse rings
                    ...List.generate(3, (i) {
                      return Transform.scale(
                        scale: _ringScales[i].value,
                        child: Opacity(
                          opacity: _ringOpacities[i].value,
                          child: Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.accentColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    // Static grid circles
                    ...([0.4, 0.65, 1.0]).map((r) => Container(
                          width: 260 * r,
                          height: 260 * r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.accentColor.withOpacity(0.12),
                              width: 1,
                            ),
                          ),
                        )),

                    // Cross hairs
                    Container(
                      width: 260,
                      height: 1,
                      color: widget.accentColor.withOpacity(0.1),
                    ),
                    Container(
                      width: 1,
                      height: 260,
                      color: widget.accentColor.withOpacity(0.1),
                    ),

                    // Scanner sweep
                    if (_searching)
                      CustomPaint(
                        size: const Size(260, 260),
                        painter: _ScannerPainter(
                          angle: _scanAnim.value,
                          color: widget.accentColor,
                        ),
                      ),

                    // Radar blips
                    if (_searching)
                      ...(_blips.map((blip) {
                        final scanProgress =
                            (_scanAnim.value / (2 * pi)) % 1.0;
                        final blipAngle = blip.angle / (2 * pi);
                        final diff = (scanProgress - blipAngle + 1) % 1.0;
                        final visible = diff < 0.25;
                        final opacity = visible ? (1 - diff / 0.25) * 0.9 : 0.0;

                        final cx = 130 + blip.radius * 110 * cos(blip.angle);
                        final cy = 130 + blip.radius * 110 * sin(blip.angle);

                        return Positioned(
                          left: cx - blip.size / 2,
                          top: cy - blip.size / 2,
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              width: blip.size,
                              height: blip.size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.accentLight,
                              ),
                            ),
                          ),
                        );
                      })),

                    // Center avatar — bouncing
                    Transform.translate(
                      offset: Offset(0, _opponentFound ? 0 : _bounceAnim.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: _opponentFound ? 80 : 64,
                        height: _opponentFound ? 80 : 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [widget.accentColor, widget.accentLight],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accentColor.withOpacity(
                                  _opponentFound ? 0.6 : 0.3),
                              blurRadius: _opponentFound ? 24 : 12,
                              spreadRadius: _opponentFound ? 4 : 0,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.gameEmoji,
                          style: TextStyle(
                              fontSize: _opponentFound ? 36 : 28),
                        ),
                      ),
                    ),

                    // Found checkmark overlay
                    if (_opponentFound)
                      Positioned(
                        bottom: 80,
                        right: 80,
                        child: Transform.scale(
                          scale: _foundAnim.value,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Status text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _opponentFound
                    ? Column(
                        key: const ValueKey('found'),
                        children: [
                          Text(
                            'Opponent Found!',
                            style: TextStyle(
                              color: widget.accentLight,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Get ready to battle...',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        key: const ValueKey('searching'),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Finding opponent',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(
                                width: 28,
                                child: Text(
                                  _dotsText,
                                  style: TextStyle(
                                    color: widget.accentLight,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Scanning for nearby players',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),

              const Spacer(),

              // Cancel button
              if (!_opponentFound)
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        border:
                            Border.all(color: AppColors.border, width: 1),
                      ),
                      child: const Text(
                        'Cancel Search',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Scanner sweep painter ─────────────────────
class _ScannerPainter extends CustomPainter {
  final double angle;
  final Color color;
  const _ScannerPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: angle - 1.2,
        endAngle: angle,
        colors: [
          Colors.transparent,
          color.withOpacity(0.0),
          color.withOpacity(0.25),
          color.withOpacity(0.5),
        ],
        stops: const [0.0, 0.5, 0.85, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);

    // Scanner line
    final linePaint = Paint()
      ..color = color.withOpacity(0.9)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      center,
      Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(_ScannerPainter old) => old.angle != angle;
}

// ── Radar blip data ───────────────────────────
class _RadarBlip {
  final double angle;
  final double radius;
  final double triggerAt;
  final double size;

  const _RadarBlip({
    required this.angle,
    required this.radius,
    required this.triggerAt,
    required this.size,
  });
}