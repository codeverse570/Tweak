import 'package:flutter/material.dart';
import 'package:skillyr/features/home/domain/models/game_item.dart';

class PlayRow extends StatefulWidget {
  final GameItem game;
  final Animation<double> pulseAnim;
  final Animation<double> pressAnim;
  final double scale;
  final VoidCallback onPlay;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onRules;

  const PlayRow({
    required this.game,
    required this.pulseAnim,
    required this.pressAnim,
    required this.scale,
    required this.onPlay,
    required this.onTapDown,
    required this.onTapUp,
    required this.onRules,
  });

  @override
  State<PlayRow> createState() => _PlayRowState();
}

class _PlayRowState extends State<PlayRow> with TickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  late final AnimationController _ripple1Ctrl;
  late final Animation<double> _ripple1Scale;
  late final Animation<double> _ripple1Opacity;

  late final AnimationController _ripple2Ctrl;
  late final Animation<double> _ripple2Scale;
  late final Animation<double> _ripple2Opacity;

  @override
  void initState() {
    super.initState();

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
    await Future.delayed(const Duration(milliseconds: 80));
    if (mounted) _ripple2Ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final s = widget.scale;

    // Button size scales with the global factor, clamped for usability
    final double btnSize = (68.0 * s).clamp(52.0, 84.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Rules
        _SecondaryAction(
          icon: Icons.help_outline_rounded,
          label: 'Rules',
          accentColor: game.accentColor,
          scale: s,
          onTap: widget.onRules,
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
              return SizedBox(
                width: btnSize * 2.6,
                height: btnSize * 2.6,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ripple
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

                    // Inner ripple
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

                    // Idle soft glow ring
                    Container(
                      width: btnSize + 14 * s,
                      height: btnSize + 14 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: game.accentColor.withOpacity(
                          0.08 + (widget.pulseAnim.value - 1.0) * 0.6,
                        ),
                      ),
                    ),

                    // Button circle
                    Transform.scale(
                      scale: _bounceAnim.value * widget.pulseAnim.value,
                      child: Container(
                        width: btnSize,
                        height: btnSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.55),
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
                                size: 26 * s,
                              )
                            : Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: (34 * s).clamp(24.0, 42.0),
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
          scale: s,
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
  final double scale;
  final VoidCallback onTap;

  const _SecondaryAction({
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46 * s,
            height: 46 * s,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(13 * s),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Icon(icon, color: Colors.white, size: 22 * s),
          ),
          SizedBox(height: 4 * s),
          Text(
            label,
            style: TextStyle(
              color: Colors.white60,
              fontSize: (9 * s).clamp(7.0, 11.0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
