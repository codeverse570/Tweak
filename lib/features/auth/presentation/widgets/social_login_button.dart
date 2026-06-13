import 'dart:math' as math;
import 'package:flutter/material.dart';

enum SocialProvider { google, email }

/// Polished outlined button for social/email sign-in with press-scale animation.
class SocialLoginButton extends StatefulWidget {
  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final SocialProvider provider;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.forward();
  void _onTapUp(_) {
    _ctrl.reverse();
    if (!widget.isLoading) widget.onTap();
  }
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A2A3A), width: 1.2),
            color: const Color(0xFF13131F),
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ProviderIcon(provider: widget.provider),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ProviderIcon extends StatelessWidget {
  const _ProviderIcon({required this.provider});
  final SocialProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider == SocialProvider.email) {
      return const Icon(
        Icons.mail_outline_rounded,
        color: Color(0xFF8B5CF6),
        size: 20,
      );
    }
    return CustomPaint(size: const Size(20, 20), painter: _GooglePainter());
  }
}

/// Hand-drawn Google "G" ring — no asset dependency.
class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    void arc(Color color, double start, double sweep) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.butt,
      );
    }

    arc(const Color(0xFF4285F4), -0.25 * math.pi, 0.5 * math.pi);
    arc(const Color(0xFF34A853),  0.25 * math.pi, 0.5 * math.pi);
    arc(const Color(0xFFFBBC05),  0.75 * math.pi, 0.5 * math.pi);
    arc(const Color(0xFFEA4335),  1.25 * math.pi, 0.5 * math.pi);

    canvas.drawLine(
      Offset(c.dx, c.dy),
      Offset(c.dx + r * 0.85, c.dy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}