import 'package:flutter/material.dart';
import 'package:skillyr/core/constants/app_colors.dart';

enum AnswerResult { correct, incorrect, pending }

class ResultOverlay extends StatefulWidget {
  final AnswerResult result;
  final int yourCost;
  final int correctCost;
  final List<String> yourPath;
  final List<String> correctPath;
  final bool isLastRound;
  final VoidCallback? onNext;

  // Optional labels for non-graph problems
  final String yourCostLabel;
  final String correctCostLabel;
  final bool timedOut;

  const ResultOverlay({
    super.key,
    required this.result,
    required this.yourCost,
    required this.correctCost,
    required this.yourPath,
    required this.correctPath,
    required this.isLastRound,
    this.onNext,
    this.yourCostLabel = 'Cost',       // graph default
    this.correctCostLabel = 'Cost', 
    this.timedOut = false   // graph default
  });

  @override
  State<ResultOverlay> createState() => _ResultOverlayState();
}

class _ResultOverlayState extends State<ResultOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim =
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isPathBased => widget.yourPath.isNotEmpty || widget.correctPath.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.result == AnswerResult.correct;
    final color = isCorrect ? AppColors.greenLight : AppColors.orange;
    final icon =
        isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final title = isCorrect ? 'Correct!' : 'Not quite!';
    final buttonLabel =
        widget.isLastRound ? 'See Results →' : 'Next Sub-Problem →';

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        color: AppColors.bg.withOpacity(0.9),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: color.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 52),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Answer display ─────────────────────────────────────
                  if (widget.timedOut)
                    _TimeOutRow()
                  else if (_isPathBased)
                    _PathRow(
                      label: 'Your Path',
                      path: widget.yourPath,
                      cost: widget.yourCost,
                      costLabel: widget.yourCostLabel,
                      color: isCorrect
                          ? AppColors.greenLight
                          : AppColors.textSecondary,
                    )
                  else
                    _NumericRow(
                      label: 'Your Answer',
                      value: widget.yourCost,
                      valueLabel: widget.yourCostLabel,
                      color: isCorrect
                          ? AppColors.greenLight
                          : AppColors.textSecondary,
                    ),

                  // ── Correct answer (only on wrong) ─────────────────────
                  if (!isCorrect) ...[
                    const SizedBox(height: 10),
                    if (_isPathBased)
                      _PathRow(
                        label: 'Optimal Path',
                        path: widget.correctPath,
                        cost: widget.correctCost,
                        costLabel: widget.correctCostLabel,
                        color: AppColors.greenLight,
                      )
                    else
                      _NumericRow(
                        label: 'Correct Answer',
                        value: widget.correctCost,
                        valueLabel: widget.correctCostLabel,
                        color: AppColors.greenLight,
                      ),
                  ],

                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: widget.onNext,
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.purple, AppColors.purpleGlow],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          buttonLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Numeric answer row (seats, minimise sum, etc.) ────────────────────────────

class _NumericRow extends StatelessWidget {
  final String label;
  final int value;
  final String valueLabel;
  final Color color;

  const _NumericRow({
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valueLabel,
                  style: TextStyle(
                    color: color.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Path row (graph problems) ─────────────────────────────────────────────────

class _PathRow extends StatelessWidget {
  final String label;
  final List<String> path;
  final int cost;
  final String costLabel;
  final Color color;

  const _PathRow({
    required this.label,
    required this.path,
    required this.cost,
    required this.costLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  path.join(' → '),
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$costLabel: $cost',
              style: TextStyle(
                color: color,
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

// ── Timeout row ───────────────────────────────────────────────────────────────

class _TimeOutRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: const [
          Icon(Icons.timer_off, color: AppColors.orange, size: 16),
          SizedBox(width: 8),
          Text(
            'Time ran out — no answer submitted',
            style: TextStyle(
              color: AppColors.orange,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}