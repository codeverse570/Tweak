import 'dart:async';
import 'package:flutter/material.dart';
import 'package:skillyr/core/constants/app_colors.dart';
import 'package:skillyr/features/battle/domain/models/battle_player.dart';

class BattleHeader extends StatefulWidget {
  final BattlePlayer you;
  final BattlePlayer opponent;
  final int currentRound;
  final int totalRounds;
  final int initialSeconds;
  final VoidCallback? onTimeUp;
  final int yourScore;
  final int opponentScore;

  const BattleHeader({
    super.key,
    required this.you,
    required this.opponent,
    required this.currentRound,
    required this.totalRounds,
    required this.initialSeconds,
    this.onTimeUp,
    required this.yourScore,
    required this.opponentScore,
  });

  @override
  State<BattleHeader> createState() => _BattleHeaderState();
}

class _BattleHeaderState extends State<BattleHeader>
    with SingleTickerProviderStateMixin {
  late int _seconds;
  Timer? _timer;
  late AnimationController _pulseController;
  bool _timeFired = false;

  @override
  void initState() {
    super.initState();
    _seconds = widget.initialSeconds;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 0) {
        t.cancel();
        if (!_timeFired) {
          _timeFired = true;
          widget.onTimeUp?.call();
        }
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String get _timeString {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get _isLowTime => _seconds <= 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundProgressBar(
          current: widget.currentRound,
          total: widget.totalRounds,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _CompactPlayer(player: widget.you, isLeft: true),
              Expanded(
                child: _CompactTimer(
                  timeString: _timeString,
                  isLow: _isLowTime,
                  pulseController: _pulseController,
                ),
              ),
              _CompactPlayer(player: widget.opponent, isLeft: false),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _RoundProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _RoundProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: const BoxDecoration(color: AppColors.surface),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: current / total,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.purple, AppColors.purpleGlow],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactTimer extends StatelessWidget {
  final String timeString;
  final bool isLow;
  final AnimationController pulseController;

  const _CompactTimer({
    required this.timeString,
    required this.isLow,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: pulseController,
        builder: (context, _) {
          final glow = isLow ? pulseController.value : 0.0;
          return Container(
            width: 82,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLow
                    ? Color.lerp(AppColors.orange, AppColors.amber, glow)!
                    : AppColors.border,
                width: 1.5,
              ),
              boxShadow: isLow
                  ? [
                      BoxShadow(
                        color: AppColors.orange.withOpacity(0.25 * glow),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 11,
                  color: isLow ? AppColors.orange : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  timeString,
                  style: TextStyle(
                    color: isLow ? AppColors.orange : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
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

class _CompactPlayer extends StatelessWidget {
  final BattlePlayer player;
  final bool isLeft;

  const _CompactPlayer({required this.player, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: player.isYou
            ? AppColors.purple.withOpacity(0.3)
            : AppColors.surface,
        border: Border.all(
          color: player.isYou ? AppColors.purpleGlow : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.person,
        color: player.isYou ? AppColors.purpleGlow : AppColors.textSecondary,
        size: 17,
      ),
    );

    final info = Column(
      crossAxisAlignment:
          isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          player.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isLeft) ...[
              Text(
                '${player.score}',
                style: const TextStyle(color: AppColors.purpleGlow, fontSize: 10),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.star, color: AppColors.purpleGlow, size: 10),
            ] else ...[
              const Icon(Icons.star, color: AppColors.purpleGlow, size: 10),
              const SizedBox(width: 2),
              Text(
                '${player.score}',
                style: const TextStyle(color: AppColors.purpleGlow, fontSize: 10),
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        _LiveRoundDots(
          results: player.roundResults,
          known: player.roundResultsKnown,
        ),
      ],
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: isLeft
          ? [avatar, const SizedBox(width: 7), info]
          : [info, const SizedBox(width: 7), avatar],
    );
  }
}

/// Live round dots that update as rounds complete
class _LiveRoundDots extends StatelessWidget {
  final List<bool> results;
  final List<bool> known;

  const _LiveRoundDots({required this.results, required this.known});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(results.length, (i) {
        final isKnown = known[i];
        final isWin = results[i];

        Color dotColor;
        Color borderColor;

        if (!isKnown) {
          dotColor = AppColors.surface;
          borderColor = AppColors.border;
        } else if (isWin) {
          dotColor = AppColors.greenLight;
          borderColor = AppColors.greenLight;
        } else {
          dotColor = AppColors.orange.withOpacity(0.4);
          borderColor = AppColors.orange;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
            border: Border.all(color: borderColor),
          ),
        );
      }),
    );
  }
}