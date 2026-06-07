import 'package:flutter/material.dart';
import 'package:skillyr/core/constants/app_colors.dart';

class GameSummaryOverlay extends StatefulWidget {
  final int yourScore;
  final int opponentScore;
  final List<bool> yourRoundResults;
  final List<bool> opponentRoundResults;
  final int yourGems;
  final int yourRating;
  final int ratingDelta;
  final int gemDelta;
  final String opponentName;
  final VoidCallback? onClose;

  const GameSummaryOverlay({
    super.key,
    required this.yourScore,
    required this.opponentScore,
    required this.yourRoundResults,
    required this.opponentRoundResults,
    required this.yourGems,
    required this.yourRating,
    required this.ratingDelta,
    required this.gemDelta,
    required this.opponentName,
    
    this.onClose,
  });

  @override
  State<GameSummaryOverlay> createState() => _GameSummaryOverlayState();
}

class _GameSummaryOverlayState extends State<GameSummaryOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _yourWins =>
      widget.yourRoundResults.where((r) => r).length;
  int get _opponentWins =>
      widget.opponentRoundResults.where((r) => r).length;

  bool get _youWon => widget.yourScore > widget.opponentScore;
  bool get _isTie => widget.yourScore == widget.opponentScore;

  @override
  Widget build(BuildContext context) {
    final Color resultColor = _isTie
        ? AppColors.purpleGlow
        : _youWon
            ? AppColors.greenLight
            : AppColors.orange;

    final String resultTitle =
        _isTie ? 'Draw!' : _youWon ? 'Victory!' : 'Defeat';

    final IconData resultIcon = _isTie
        ? Icons.handshake_outlined
        : _youWon
            ? Icons.emoji_events_rounded
            : Icons.sentiment_dissatisfied_rounded;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        color: AppColors.bg.withOpacity(0.95),
        child: AnimatedBuilder(
          animation: _slideAnim,
          builder: (context, child) =>
              Transform.translate(offset: Offset(0, _slideAnim.value), child: child),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // ── Result banner ──────────────────────────────────────
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: resultColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                            color: resultColor.withOpacity(0.4),
                            width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(resultIcon, color: resultColor, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            resultTitle,
                            style: TextStyle(
                              color: resultColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Score comparison ───────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        _ScoreSide(
                          name: 'You',
                          score: widget.yourScore,
                          wins: _yourWins,
                          isYou: true,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'vs',
                                style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.yourScore} – ${widget.opponentScore}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _ScoreSide(
                          name: widget.opponentName,
                          score: widget.opponentScore,
                          wins: _opponentWins,
                          isYou: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Round breakdown ────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ROUND BREAKDOWN',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(
                          widget.yourRoundResults.length,
                          (i) => _RoundRow(
                            roundNumber: i + 1,
                            yourResult: widget.yourRoundResults[i],
                            opponentResult:
                                widget.opponentRoundResults[i],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Rating + Gems earned ───────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _RewardCard(
                          icon: Icons.diamond,
                          label: 'Gems',
                          value: widget.yourGems,
                          delta: widget.gemDelta,
                          color: AppColors.blueLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RewardCard(
                          icon: Icons.star_rounded,
                          label: 'Rating',
                          value: widget.yourRating, // pass actual rating here
                          delta: widget.ratingDelta,
                          color: AppColors.purpleGlow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── CTA ────────────────────────────────────────────────
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.purple, AppColors.purpleGlow],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purple.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Back to Home',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _ScoreSide extends StatelessWidget {
  final String name;
  final int score;
  final int wins;
  final bool isYou;

  const _ScoreSide({
    required this.name,
    required this.score,
    required this.wins,
    required this.isYou,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isYou
                ? AppColors.purple.withOpacity(0.2)
                : AppColors.surface,
            border: Border.all(
              color:
                  isYou ? AppColors.purpleGlow : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.person,
            color: isYou
                ? AppColors.purpleGlow
                : AppColors.textSecondary,
            size: 22,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          '$wins wins',
          style: const TextStyle(
              color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

class _RoundRow extends StatelessWidget {
  final int roundNumber;
  final bool yourResult;
  final bool opponentResult;

  const _RoundRow({
    required this.roundNumber,
    required this.yourResult,
    required this.opponentResult,
  });

  Widget _dot(bool result) => Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: result
              ? AppColors.greenLight.withOpacity(0.2)
              : AppColors.orange.withOpacity(0.2),
          border: Border.all(
              color: result ? AppColors.greenLight : AppColors.orange),
        ),
        child: Icon(
          result ? Icons.check : Icons.close,
          size: 11,
          color: result ? AppColors.greenLight : AppColors.orange,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _dot(yourResult),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sub-Problem $roundNumber',
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
          _dot(opponentResult),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final int delta;
  final Color color;

  const _RewardCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.delta,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = delta >= 0;
    final deltaText = isPositive ? '+$delta' : '$delta';
    final deltaColor = delta == 0
        ? AppColors.textMuted
        : isPositive
            ? AppColors.greenLight
            : AppColors.orange;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: deltaColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              deltaText,
              style: TextStyle(
                color: deltaColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}