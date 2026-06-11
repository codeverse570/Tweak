import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skillyr/features/home/domain/models/game_item.dart';

class RulesPanel extends StatefulWidget {
  final GameItem game;
  final VoidCallback onClose;
  final double scale;

  const RulesPanel(
      {required this.game, required this.onClose, required this.scale});

  @override
  State<RulesPanel> createState() => _RulesPanelState();
}

class _RulesPanelState extends State<RulesPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<double>> _slideAnims;

  static const _rules = [
    (
      icon: Icons.timer_rounded,
      title: 'Sub-Problem Timers',
      body:
          'Each battle contains multiple sub-problems, each with its own independent countdown timer.',
    ),
    (
      icon: Icons.link_rounded,
      title: 'Linked Sub-Problems',
      body:
          'Sub-problems within a battle are connected — they all relate to the same overarching problem.',
    ),
    (
      icon: Icons.block_rounded,
      title: 'No Time Carry-Over',
      body:
          'Unused time from one sub-problem is never carried forward. Each timer resets fresh.',
    ),
    (
      icon: Icons.repeat_rounded,
      title: 'Max 3 Attempts',
      body:
          'Each sub-problem allows up to 3 attempts. The exact limit may vary depending on the problem.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    const staggerStep = 0.18;
    _fadeAnims = List.generate(_rules.length, (i) {
      final start = i * staggerStep;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    _slideAnims = List.generate(_rules.length, (i) {
      final start = i * staggerStep;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 28.0, end: 0.0).animate(
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
            // Subtle radial glow
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.4,
                    colors: [
                      game.accentColor.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Faint grid
            Positioned.fill(
              child:
                  CustomPaint(painter: _GridPainter(game.accentColor)),
            ),

            // Content
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20 * s, 20 * s, 20 * s, 20 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 38 * s,
                        height: 38 * s,
                        decoration: BoxDecoration(
                          color: game.accentColor.withOpacity(0.18),
                          borderRadius:
                              BorderRadius.circular(10 * s),
                          border: Border.all(
                            color: game.accentColor.withOpacity(0.4),
                          ),
                        ),
                        child: Icon(Icons.menu_book_rounded,
                            color: game.accentColor, size: 20 * s),
                      ),
                      SizedBox(width: 12 * s),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HOW TO PLAY',
                              style: TextStyle(
                                color: game.accentColor,
                                fontSize:
                                    (10 * s).clamp(8.0, 12.0),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.8,
                              ),
                            ),
                            SizedBox(height: 2 * s),
                            Text(
                              game.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    (16 * s).clamp(12.0, 20.0),
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          width: 34 * s,
                          height: 34 * s,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color:
                                    Colors.white.withOpacity(0.18)),
                          ),
                          child: Icon(Icons.close_rounded,
                              color: Colors.white, size: 16 * s),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 14 * s),
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

                  // Rule rows
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _staggerCtrl,
                      builder: (context, _) {
                        return Column(
                          children:
                              List.generate(_rules.length, (i) {
                            final rule = _rules[i];
                            return Opacity(
                              opacity: _fadeAnims[i].value,
                              child: Transform.translate(
                                offset: Offset(
                                    0, _slideAnims[i].value),
                                child: _RuleRow(
                                  index: i + 1,
                                  icon: rule.icon,
                                  title: rule.title,
                                  body: rule.body,
                                  accentColor: game.accentColor,
                                  accentLight: game.accentLight,
                                  scale: s,
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),

                  // Footer
                  Center(
                    child: Text(
                      'Tap ✕ to go back',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: (10 * s).clamp(8.0, 12.0),
                        fontWeight: FontWeight.w500,
                      ),
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
// Single rule row
// ─────────────────────────────────────────────────────────────────────────────
class _RuleRow extends StatelessWidget {
  final int index;
  final IconData icon;
  final String title;
  final String body;
  final Color accentColor;
  final Color accentLight;
  final double scale;

  const _RuleRow({
    required this.index,
    required this.icon,
    required this.title,
    required this.body,
    required this.accentColor,
    required this.accentLight,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.only(bottom: 14 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 42 * s,
                height: 42 * s,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12 * s),
                  border: Border.all(
                      color: accentColor.withOpacity(0.35)),
                ),
                child: Icon(icon, color: accentColor, size: 20 * s),
              ),
              SizedBox(height: 4 * s),
              Text(
                '$index',
                style: TextStyle(
                  color: accentColor.withOpacity(0.5),
                  fontSize: (9 * s).clamp(7.0, 11.0),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(width: 14 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2 * s),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (12 * s).clamp(9.0, 15.0),
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  body,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    fontSize: (10.5 * s).clamp(8.5, 13.0),
                    height: 1.5,
                    fontWeight: FontWeight.w400,
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