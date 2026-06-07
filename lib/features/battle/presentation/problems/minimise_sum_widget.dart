import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skillyr/core/constants/app_colors.dart';
import 'package:skillyr/features/battle/domain/models/minimise_sum_model.dart';

class MinimiseSumWidget extends StatefulWidget {
  final MinimiseSumSubProblem problem;
  final ValueChanged<int?>? onAnswerChanged;

  const MinimiseSumWidget({
    super.key,
    required this.problem,
    this.onAnswerChanged,
  });

  @override
  State<MinimiseSumWidget> createState() => _MinimiseSumWidgetState();
}

class _MinimiseSumWidgetState extends State<MinimiseSumWidget> {
  int _answer = 0;
  bool _answerConfirmed = false;
  final ScrollController _scrollController = ScrollController();
  bool _inputVisible = false; // true when input section scrolled into view
  // Add to _MinimiseSumWidgetState:
bool _exampleExpanded = false;
bool _operationExpanded = false;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(MinimiseSumWidget old) {
    super.didUpdateWidget(old);
    if (old.problem != widget.problem) {
      _answer = 0;
      _answerConfirmed = false;
      widget.onAnswerChanged?.call(null);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show floating bar when user hasn't scrolled far enough to see input
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    // Input is near the bottom — float when more than 60% away
    final shouldFloat = current < maxScroll * 0.6;
    if (shouldFloat != !_inputVisible) {
      setState(() => _inputVisible = !shouldFloat);
    }
  }

  void _increment() {
    setState(() {
      _answer++;
      _answerConfirmed = false;
    });
    widget.onAnswerChanged?.call(null);
  }

  void _decrement() {
    if (_answer <= 0) return;
    setState(() {
      _answer--;
      _answerConfirmed = false;
    });
    widget.onAnswerChanged?.call(null);
  }

  void _confirmAnswer() {
    HapticFeedback.mediumImpact();
    setState(() => _answerConfirmed = true);
    widget.onAnswerChanged?.call(_answer);
  }

  void _reset() {
    setState(() {
      _answer = 0;
      _answerConfirmed = false;
    });
    widget.onAnswerChanged?.call(null);
  }

  void _scrollToInput() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final efforts = widget.problem.efforts;

    return Stack(
      children: [
        // ── Main scrollable content ──────────────────────────────────────
        SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Problem card ───────────────────────────────────────────
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
                    // Header bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.purple.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: AppColors.purple.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.local_shipping_outlined,
                                    size: 11, color: AppColors.purpleGlow),
                                SizedBox(width: 4),
                                Text(
                                  'DELIVERY ROUTE',
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
                                color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    // Story text
                 Padding(
  padding: const EdgeInsets.all(14),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ── Scenario ──────────────────────────────────────────────
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13, height: 1.6),
            children: [
              const TextSpan(text: 'A delivery driver must complete '),
              TextSpan(
                text: '${efforts.length} stops',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700),
              ),
              const TextSpan(
                  text:
                      '.Each Stop is associated with a effort. At each stop the dispatcher records the '),
              TextSpan(
                text: 'smallest effort seen so far',
                style: const TextStyle(
                    color: AppColors.purpleGlow,
                    fontWeight: FontWeight.w600),
              ),
              const TextSpan(
                  text:
                      '. Total fatigue = sum of all recorded values. You may perform '),
              TextSpan(
                text: 'at most one operation',
                style: const TextStyle(
                    color: AppColors.orange,
                    fontWeight: FontWeight.w600),
              ),
              const TextSpan(
                  text: ' to minimise it.'),
            ],
          ),
        ),
      ),
      const SizedBox(height: 10),

      // ── How fatigue is calculated — dropdown ───────────────────
      _DropdownSection(
        color: AppColors.purpleGlow,
        icon: Icons.lightbulb_outline,
        label: 'HOW FATIGUE IS CALCULATED',
        expanded: _exampleExpanded,
        onTap: () =>
            setState(() => _exampleExpanded = !_exampleExpanded),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.6),
            children: [
              TextSpan(text: 'Example stops: '),
              TextSpan(
                text: '[5, 3, 4, 2]',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace'),
              ),
              TextSpan(text: '\n'),
              TextSpan(text: 'After stop 1: min effort so far = '),
              TextSpan(
                  text: '5',
                  style: TextStyle(
                      color: AppColors.purpleGlow,
                      fontWeight: FontWeight.w700)),
              TextSpan(text: '\nAfter stop 2: min effort so far = '),
              TextSpan(
                  text: '3',
                  style: TextStyle(
                      color: AppColors.purpleGlow,
                      fontWeight: FontWeight.w700)),
              TextSpan(text: '\nAfter stop 3: min effort so far = '),
              TextSpan(
                  text: '3',
                  style: TextStyle(
                      color: AppColors.purpleGlow,
                      fontWeight: FontWeight.w700)),
              TextSpan(text: '\nAfter stop 4: min effort so far = '),
              TextSpan(
                  text: '2',
                  style: TextStyle(
                      color: AppColors.purpleGlow,
                      fontWeight: FontWeight.w700)),
              TextSpan(text: '\n\nTotal fatigue = '),
              TextSpan(
                text: '5 + 3 + 3 + 2 = 13',
                style: TextStyle(
                    color: AppColors.greenLight,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 8),

      // ── One allowed operation — dropdown ───────────────────────
      _DropdownSection(
        color: AppColors.orange,
        icon: Icons.build_outlined,
        label: 'ONE ALLOWED OPERATION',
        expanded: _operationExpanded,
        onTap: () =>
            setState(() => _operationExpanded = !_operationExpanded),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.6),
            children: [
              TextSpan(
                  text:
                      'Pick any stop i and a later stop j such that j > i. Move j\'s effort onto i, set j\'s effort = 0. '
                      'This can lower future recorded minimums.\n\n'),
              TextSpan(text: 'Same example, select i = stop 2 and j = stop 3:\n'),
              TextSpan(
                text: '[5, 3, 4, 2]',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace'),
              ),
              TextSpan(text: '  → recordered mins at each stop: '),
              TextSpan(
                text: '5, 5, 0, 0',
                style: TextStyle(
                    color: AppColors.purpleGlow,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace'),
              ),
              TextSpan(text: '  →  fatigue = '),
              TextSpan(
                text: '10',
                style: TextStyle(
                    color: AppColors.orange, fontWeight: FontWeight.w600),
              ),
            
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),

      // ── Effort stops ───────────────────────────────────────────
      const Text(
        'EFFORT AT EACH STOP',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 10),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(efforts.length, (i) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              width: 54,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.border.withOpacity(0.6)),
              ),
              child: Column(
                children: [
                  Text(
                    'S${i + 1}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${efforts[i]}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      const SizedBox(height: 14),

      // ── Task box ───────────────────────────────────────────────
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.greenLight.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.greenLight.withOpacity(0.25)),
        ),
        child: Row(
          children: const [
            Icon(Icons.emoji_events_outlined,
                size: 14, color: AppColors.greenLight),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Find the minimum total fatigue possible using at most one operation. Enter your answer below.',
                style: TextStyle(
                  color: AppColors.greenLight,
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

              const SizedBox(height: 8),

              // ── Answer input section (in scroll) ───────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const Text(
                      'YOUR ANSWER',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StepButton(
                          icon: Icons.remove,
                          onTap: _decrement,
                          enabled: _answer > 0,
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: 100,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _answerConfirmed
                                  ? AppColors.greenLight
                                  : AppColors.purpleGlow.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_answerConfirmed
                                        ? AppColors.greenLight
                                        : AppColors.purpleGlow)
                                    .withOpacity(0.1),
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
                        _StepButton(
                          icon: Icons.add,
                          onTap: _increment,
                          enabled: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _confirmAnswer,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 11),
                        decoration: BoxDecoration(
                          color: _answerConfirmed
                              ? AppColors.green.withOpacity(0.15)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _answerConfirmed
                                ? AppColors.greenLight
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _answerConfirmed
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              size: 15,
                              color: _answerConfirmed
                                  ? AppColors.greenLight
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              _answerConfirmed
                                  ? 'Answer locked — $_answer'
                                  : 'Confirm answer',
                              style: TextStyle(
                                color: _answerConfirmed
                                    ? AppColors.greenLight
                                    : AppColors.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _reset,
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Floating answer bar (shown when input not visible) ───────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            offset: _inputVisible ? Offset.zero : const Offset(0, 0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _inputVisible ? 0.0 : 1.0,
              child: GestureDetector(
                onTap: _scrollToInput,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _answerConfirmed
                          ? AppColors.greenLight.withOpacity(0.5)
                          : AppColors.purpleGlow.withOpacity(0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.bg.withOpacity(0.9),
                        blurRadius: 16,
                        offset: const Offset(0, -8),
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Stepper inline
                      _MiniStepButton(
                          icon: Icons.remove,
                          onTap: _decrement,
                          enabled: _answer > 0),
                      const SizedBox(width: 12),
                      Text(
                        '$_answer',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _MiniStepButton(
                          icon: Icons.add,
                          onTap: _increment,
                          enabled: true),
                      const SizedBox(width: 12),
                      const Text(
                        'fatigue',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                      const Spacer(),
                      // Confirm inline
                      GestureDetector(
                        onTap: _confirmAnswer,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: _answerConfirmed
                                ? AppColors.green.withOpacity(0.15)
                                : AppColors.purple.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _answerConfirmed
                                  ? AppColors.greenLight.withOpacity(0.5)
                                  : AppColors.purpleGlow.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            _answerConfirmed ? '✓ Set' : 'Confirm',
                            style: TextStyle(
                              color: _answerConfirmed
                                  ? AppColors.greenLight
                                  : AppColors.purpleGlow,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Scroll hint
                      const Icon(Icons.keyboard_arrow_down,
                          size: 16, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mini step button (for floating bar) ──────────────────────────────────────

class _MiniStepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _MiniStepButton(
      {required this.icon, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled ? AppColors.bg : AppColors.bg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? AppColors.border
                : AppColors.border.withOpacity(0.3),
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: enabled
              ? AppColors.textPrimary
              : AppColors.textMuted.withOpacity(0.3),
        ),
      ),
    );
  }
}

// ── Full step button (for scrolled-in section) ───────────────────────────────

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _StepButton(
      {required this.icon, required this.onTap, required this.enabled});

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
            color: enabled
                ? AppColors.border
                : AppColors.border.withOpacity(0.3),
          ),
        ),
        child: Icon(
          icon,
          color: enabled
              ? AppColors.textPrimary
              : AppColors.textMuted.withOpacity(0.3),
          size: 22,
        ),
      ),
    );
  }
}
class _DropdownSection extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final bool expanded;
  final VoidCallback onTap;
  final Widget child;

  const _DropdownSection({
    required this.color,
    required this.icon,
    required this.label,
    required this.expanded,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Column(
        children: [
          // ── Header tap area ────────────────────────────────────
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(icon, size: 12, color: color),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: color.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Animated body ──────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                      color: color.withOpacity(0.2),
                      height: 12,
                      thickness: 0.5),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}