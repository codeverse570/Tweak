import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skillyr/core/constants/app_colors.dart';
import 'package:skillyr/features/battle/domain/models/seats_model.dart';

class SeatsProblemWidget extends StatefulWidget {
  final SeatsSubProblem problem;
  final ValueChanged<int?>? onAnswerChanged;

  const SeatsProblemWidget({
    super.key,
    required this.problem,
    this.onAnswerChanged,
  });

  @override
  State<SeatsProblemWidget> createState() => _SeatsProblemWidgetState();
}

class _SeatsProblemWidgetState extends State<SeatsProblemWidget> {
  int _answer = 0;
  final int _preOccupied = 0; // computed in initState

  late int _totalPreOccupied;

  @override
  void initState() {
    super.initState();
    _totalPreOccupied = widget.problem.gaps.length + 1;
    _answer = _totalPreOccupied; // start from pre-occupied count
  }

  @override
  void didUpdateWidget(SeatsProblemWidget old) {
    super.didUpdateWidget(old);
    if (old.problem != widget.problem) {
      _totalPreOccupied = widget.problem.gaps.length + 1;
      _answer = _totalPreOccupied;
      widget.onAnswerChanged?.call(null);
    }
  }

  void _increment() {
    setState(() => _answer++);
    widget.onAnswerChanged?.call(_answer);
  }

  void _decrement() {
    if (_answer <= _totalPreOccupied) return;
    setState(() => _answer--);
    widget.onAnswerChanged?.call(_answer);
  }

  @override
  Widget build(BuildContext context) {
    final gaps = widget.problem.gaps;
    final totalSeats = gaps.fold(0, (s, g) => s + g) + _totalPreOccupied;

    return Column(
      children: [
        // ── Problem statement card ───────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top label bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.purple.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.chair_alt_rounded,
                              size: 11, color: AppColors.purpleGlow),
                          SizedBox(width: 4),
                          Text(
                            'SEATS PROBLEM',
                            style: TextStyle(
                              color: AppColors.purpleGlow,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.problem.title,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Problem body
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Context sentence
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.5),
                        children: [
                          const TextSpan(text: 'A classroom has '),
                          TextSpan(
                            text: '$totalSeats seats',
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(
                              text:
                                  ' in a row. The first and last seats are already occupied. '),
                          const TextSpan(
                              text:
                                  'No two students can sit next to each other.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Gap visualization row
                    const Text(
                      'EMPTY SEATS BETWEEN STUDENTS',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _GapVisualizer(gaps: gaps),
                    const SizedBox(height: 14),

                    // Task
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.orange.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.help_outline,
                              size: 14, color: AppColors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'What is the minimum total number of students '
                              'seated when no more can be added?',
                              style: TextStyle(
                                color: AppColors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // ── Answer input ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Text(
                'YOUR ANSWER',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decrement
                  _StepButton(
                    icon: Icons.remove,
                    onTap: _decrement,
                    enabled: _answer > _totalPreOccupied,
                  ),
                  const SizedBox(width: 20),
                  // Answer display
                  Container(
                    width: 100,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.purpleGlow.withOpacity(0.5),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purpleGlow.withOpacity(0.1),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$_answer',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Increment
                  _StepButton(
                    icon: Icons.add,
                    onTap: _increment,
                    enabled: true,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Min possible: $_totalPreOccupied (pre-occupied only)',
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Gap visualizer ────────────────────────────────────────────────────────────

class _GapVisualizer extends StatefulWidget {
  final List<int> gaps;

  const _GapVisualizer({required this.gaps});

  @override
  State<_GapVisualizer> createState() => _GapVisualizerState();
}

class _GapVisualizerState extends State<_GapVisualizer> {
  final ScrollController _controller = ScrollController();

  void _scrollLeft() {
    final target = (_controller.offset - 160)
        .clamp(0.0, _controller.position.maxScrollExtent);

    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    final target = (_controller.offset + 160)
        .clamp(0.0, _controller.position.maxScrollExtent);

    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    // First student
    items.add(_StudentDot(fixed: true));

    for (int i = 0; i < widget.gaps.length; i++) {
      items.add(const SizedBox(width: 6));
      items.add(_GapPill(count: widget.gaps[i]));
      items.add(const SizedBox(width: 6));
      items.add(_StudentDot(fixed: true));
    }

    return Row(
      children: [
        _ArrowButton(
          icon: Icons.chevron_left,
          onTap: _scrollLeft,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: ClipRect(
            child: SingleChildScrollView(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(children: items),
            ),
          ),
        ),

        const SizedBox(width: 8),

        _ArrowButton(
          icon: Icons.chevron_right,
          onTap: _scrollRight,
        ),
      ],
    );
  }
}
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _StudentDot extends StatelessWidget {
  final bool fixed;
  const _StudentDot({this.fixed = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.green.withOpacity(0.15),
        border: Border.all(color: AppColors.greenLight, width: 1.5),
      ),
      child: const Icon(Icons.person, size: 14, color: AppColors.greenLight),
    );
  }
}

class _GapPill extends StatelessWidget {
  final int count;
  const _GapPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // dashes to suggest empty seats
          ...List.generate(
              count.clamp(0, 5),
              (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textMuted.withOpacity(0.35),
                      ),
                    ),
                  )),
          if (count > 5) ...[
            const SizedBox(width: 2),
            Text(
              '+${count - 5}',
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step button ───────────────────────────────────────────────────────────────

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: enabled ? AppColors.surface : AppColors.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled ? AppColors.border : AppColors.border.withOpacity(0.3),
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.textPrimary : AppColors.textMuted.withOpacity(0.3),
          size: 22,
        ),
      ),
    );
  }
}