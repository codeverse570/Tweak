import 'package:flutter/material.dart';
import 'package:skillyr/core/constants/app_colors.dart';

class HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0A3A), Color(0xFF120826), AppColors.bg],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      child: Column(
        children: [
          _HeaderRow(),
          const SizedBox(height: 16),
          _DailyTaskCard(),
        ],
      ),
    );
  }
}
 
class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar + user info
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.purpleGlow.withOpacity(0.3),
                      width: 1,
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
        // XP pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
      ],
    );
  }
}
 
class _DailyTaskCard extends StatefulWidget {
  @override
  State<_DailyTaskCard> createState() => _DailyTaskCardState();
}

class _DailyTaskCardState extends State<_DailyTaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _pulse, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double currentWins = 60;
    const double maxWins = 110;

    final milestones = [
      {'value': 10.0, 'label': '10'},
      {'value': 50.0, 'label': '50'},
      {'value': 100.0, 'label': '100+'},
    ];

    // Index of the last milestone the user has reached (the one that pulses)
    int activeIndex = -1;
    for (int i = 0; i < milestones.length; i++) {
      if (currentWins >= (milestones[i]['value'] as double)) activeIndex = i;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Win Progress',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${currentWins.toInt()} wins',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Animated track ──
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  const double iconSize = 20.0;
                  const double iconGap = 6.0;
                  final double trackW =
                      constraints.maxWidth - iconSize - iconGap;
                  final double progress =
                      (currentWins / maxWins).clamp(0.0, 1.0);
                  final double fillW = trackW * progress;

                  // Pulse values
                  final double pulseScale = _anim.value;
                  const double dotR = 6.0; // dot radius
                  const double dotD = dotR * 2;

                  return SizedBox(
                    height: 28, // track + label space
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Track background
                        Positioned(
                          left: 0,
                          top: dotR - 2.5,
                          width: trackW,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: AppColors.border,
                            ),
                          ),
                        ),

                        // Filled portion
                        Positioned(
                          left: 0,
                          top: dotR - 2.5,
                          width: fillW,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: const LinearGradient(
                                colors: [AppColors.purple, AppColors.purpleGlow],
                              ),
                            ),
                          ),
                        ),

                        // Milestone dots + labels
                        for (int i = 0; i < milestones.length; i++) ...[
                          () {
                            final double frac =
                                (milestones[i]['value'] as double) / maxWins;
                            final double cx = trackW * frac;
                            final bool reached =
                                currentWins >= (milestones[i]['value'] as double);
                            final bool isActive = i == activeIndex;

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Expanding pulse ring
                                if (isActive)
                                  Positioned(
                                    left: cx -
                                        dotR -
                                        4 -
                                        pulseScale * 5,
                                    top: -4 - pulseScale * 5,
                                    child: Container(
                                      width: dotD + 8 + pulseScale * 10,
                                      height: dotD + 8 + pulseScale * 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.purpleGlow
                                              .withOpacity(
                                                  0.55 - pulseScale * 0.45),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),

                                // Dot
                                Positioned(
                                  left: cx - dotR,
                                  top: 0,
                                  child: Container(
                                    width: dotD,
                                    height: dotD,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: reached
                                          ? AppColors.purpleGlow
                                          : AppColors.surface,
                                      border: Border.all(
                                        color: reached
                                            ? AppColors.purpleGlow
                                            : AppColors.border,
                                        width: 1.5,
                                      ),
                                      boxShadow: isActive
                                          ? [
                                              BoxShadow(
                                                color: AppColors.purpleGlow
                                                    .withOpacity(
                                                        0.25 +
                                                            pulseScale * 0.35),
                                                blurRadius:
                                                    6 + pulseScale * 6,
                                                spreadRadius: 0,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: reached
                                        ? const Icon(Icons.check,
                                            size: 7, color: AppColors.white)
                                        : null,
                                  ),
                                ),

                                // Label below dot
                                Positioned(
                                  left: cx - 10,
                                  top: dotD + 3,
                                  child: SizedBox(
                                    width: 24,
                                    child: Text(
                                      milestones[i]['label'] as String,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: reached
                                            ? AppColors.purpleGlow
                                            : AppColors.textMuted,
                                        fontSize: 7,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }(),
                        ],

                        // Trophy at the end
                        Positioned(
                          right: 0,
                          top: -1,
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: currentWins >= 100
                                ? AppColors.orange
                                : AppColors.textMuted,
                            size: iconSize,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}