import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Cinematic hero section for the auth screen.
/// Renders the TWEAK logo above a pulsing dual-ring plasma effect,
/// with three faint floating category icons in the background.
class AuthHeader extends StatefulWidget {
  const AuthHeader({super.key});

  @override
  State<AuthHeader> createState() => _AuthHeaderState();
}

class _AuthHeaderState extends State<AuthHeader>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _rotateCtrl;
  late final AnimationController _floatCtrl;

  late final Animation<double> _pulse;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _float = CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Background: faint category glows ──────────────────────────
          Positioned(
            left: 24,
            top: 32,
            child: _FaintCategoryIcon(
              emoji: '⚔️',
              color: const Color(0xFFFF4B4B),
              float: _float,
              phaseOffset: 0.0,
            ),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: _FaintCategoryIcon(
              emoji: '🔭',
              color: const Color(0xFF5B8AF5),
              float: _float,
              phaseOffset: 0.33,
            ),
          ),
          Positioned(
            right: 48,
            bottom: 28,
            child: _FaintCategoryIcon(
              emoji: '∑',
              color: const Color(0xFF34D399),
              float: _float,
              phaseOffset: 0.66,
            ),
          ),

          // ── Energy rings ──────────────────────────────────────────────
          AnimatedBuilder(
            animation: Listenable.merge([_pulseCtrl, _rotateCtrl]),
            builder: (_, __) {
              return CustomPaint(
                size: const Size(220, 220),
                painter: _EnergyRingPainter(
                  pulse: _pulse.value,
                  rotation: _rotateCtrl.value * 2 * math.pi,
                ),
              );
            },
          ),

          // ── Logo ──────────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _float,
            builder: (_, child) {
              return Transform.translate(
                offset: Offset(0, -4 + _float.value * 8),
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TweakLogo(),
                const SizedBox(height: 10),
                const Text(
                  'TRAIN  ·  THINK  ·  TWEAK  ·  WIN',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 10.5,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TWEAK wordmark with per-letter color accent ───────────────────────────

class _TweakLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const letters = ['T', 'W', 'E', 'A', 'K'];
    const colors = [
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
      Color(0xFF8B5CF6), // purple accent on E
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(letters.length, (i) {
        return Text(
          letters[i],
          style: TextStyle(
            color: colors[i],
            fontSize: 44,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
            height: 1,
          ),
        );
      }),
    );
  }
}

// ─── Faint background category icon ───────────────────────────────────────

class _FaintCategoryIcon extends StatelessWidget {
  const _FaintCategoryIcon({
    required this.emoji,
    required this.color,
    required this.float,
    required this.phaseOffset,
  });

  final String emoji;
  final Color color;
  final Animation<double> float;
  final double phaseOffset;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: float,
      builder: (_, child) {
        // Each icon floats at a different phase
        final phase = (float.value + phaseOffset) % 1.0;
        final dy = math.sin(phase * math.pi) * 10 - 5;
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.14),
              color.withOpacity(0.0),
            ],
          ),
          border: Border.all(color: color.withOpacity(0.18), width: 1),
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: 28,
              color: color.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Energy ring painter ──────────────────────────────────────────────────

class _EnergyRingPainter extends CustomPainter {
  const _EnergyRingPainter({
    required this.pulse,
    required this.rotation,
  });

  final double pulse;
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer soft glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7C3AED).withOpacity(0.18 + pulse * 0.12),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: size.width * 0.5),
      );
    canvas.drawCircle(center, size.width * 0.5, glowPaint);

    // Ring 1 — solid thin ring
    final ring1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF7C3AED).withOpacity(0.35 + pulse * 0.25);
    canvas.drawCircle(center, size.width * 0.44, ring1);

    // Ring 2 — dashed rotating ring
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    final ring2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFF34D399).withOpacity(0.22 + pulse * 0.18);

    _drawDashedCircle(canvas, center, size.width * 0.38, ring2, 40);
    canvas.restore();

    // Inner ring — static
    final innerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(0xFF8B5CF6).withOpacity(0.15 + pulse * 0.1);
    canvas.drawCircle(center, size.width * 0.30, innerRing);
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    int segments,
  ) {
    const gapFraction = 0.4;
    for (var i = 0; i < segments; i++) {
      final startAngle = (i / segments) * 2 * math.pi;
      final sweepAngle = (1 - gapFraction) / segments * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_EnergyRingPainter old) =>
      old.pulse != pulse || old.rotation != rotation;
}