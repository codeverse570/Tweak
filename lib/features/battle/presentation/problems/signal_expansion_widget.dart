import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skillyr/core/constants/app_colors.dart';
import 'package:skillyr/features/battle/domain/models/signal_expansion.dart';
// import 'package:skillyr/features/battle/domain/models/signal_expansion_model.dart';

class SignalExpansionWidget extends StatefulWidget {
  final SignalExpansionSubProblem problem;
  final ValueChanged<int?>? onAnswerChanged;

  const SignalExpansionWidget({
    super.key,
    required this.problem,
    this.onAnswerChanged,
  });

  @override
  State<SignalExpansionWidget> createState() => _SignalExpansionWidgetState();
}

class _SignalExpansionWidgetState extends State<SignalExpansionWidget> {
  int _answer = 0;
  bool _answerConfirmed = false;
  bool _exampleExpanded = false;
  bool _ruleExpanded = false;

  final ScrollController _scrollController = ScrollController();
  bool _inputVisible = false;

  // Precompute expansion steps for display (up to 3 steps shown inline)
  late final List<List<int>> _exampleSteps;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Show 3 steps of expansion from [1] as an example illustration
    _exampleSteps = SignalExpansionSubProblem.generateSteps(3, maxSteps: 3);
  }

  @override
  void didUpdateWidget(SignalExpansionWidget old) {
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
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
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
    final p = widget.problem;

    return Stack(
      children: [
        // ── Main scrollable content ────────────────────────────────────────
        SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Problem card ─────────────────────────────────────────────
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
                    // ── Header bar ─────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        border:
                            Border(bottom: BorderSide(color: AppColors.border)),
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
                                Icon(Icons.wifi_tethering,
                                    size: 11, color: AppColors.purpleGlow),
                                SizedBox(width: 4),
                                Text(
                                  'SIGNAL EXPANSION',
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
                            p.title,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    // ── Body ──────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Scenario ─────────────────────────────────────
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.border.withOpacity(0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        height: 1.6),
                                    children: [
                                      const TextSpan(text: 'You start with '),
                                      TextSpan(
                                        text: '[1]',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const TextSpan(
                                          text:
                                              '. Every second, each number '),
                                      TextSpan(
                                        text: 'n',
                                        style: const TextStyle(
                                            color: AppColors.purpleGlow,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.italic),
                                      ),
                                      const TextSpan(text: ' creates '),
                                      TextSpan(
                                        text: 'n',
                                        style: const TextStyle(
                                            color: AppColors.purpleGlow,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'n+1',
                                        style: const TextStyle(
                                            color: AppColors.orange,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const TextSpan(text: '.'),
                                       TextSpan(
                                        text: ' Hint:- use Binomial Theorem For coefficient.',
                                        style: const TextStyle(
                                            color: Color.fromARGB(255, 172, 123, 240),
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ── Rule dropdown ─────────────────────────────────
                          _DropdownSection(
                            color: AppColors.purpleGlow,
                            icon: Icons.rule_outlined,
                            label: 'EXPANSION RULE',
                            expanded: _ruleExpanded,
                            onTap: () => setState(
                                () => _ruleExpanded = !_ruleExpanded),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Each number splits into two:',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      height: 1.5),
                                ),
                                const SizedBox(height: 8),
                                _RuleRow(value: 'n', produces: ['n', 'n+1']),
                                const SizedBox(height: 6),
                                // Show concrete examples
                                _RuleRow(value: '1', produces: ['1', '2']),
                                const SizedBox(height: 4),
                                _RuleRow(value: '2', produces: ['2', '3']),
                                const SizedBox(height: 4),
                                _RuleRow(value: '3', produces: ['3', '4']),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ── Example dropdown ──────────────────────────────
                          _DropdownSection(
                            color: AppColors.orange,
                            icon: Icons.play_circle_outline,
                            label: 'EXAMPLE (FIRST 3 ROUNDS)',
                            expanded: _exampleExpanded,
                            onTap: () => setState(
                                () => _exampleExpanded = !_exampleExpanded),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (int i = 0;
                                    i < _exampleSteps.length;
                                    i++) ...[
                                  _ExpansionStepRow(
                                    round: i,
                                    array: _exampleSteps[i],
                                    isLast:
                                        i == _exampleSteps.length - 1,
                                  ),
                                  if (i < _exampleSteps.length - 1)
                                    _ArrowDivider(),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Question box ──────────────────────────────────
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.purple.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.purple.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.help_outline,
                                        size: 14,
                                        color: AppColors.purpleGlow),
                                    SizedBox(width: 6),
                                    Text(
                                      'QUESTION',
                                      style: TextStyle(
                                        color: AppColors.purpleGlow,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                        height: 1.6),
                                    children: [
                                      const TextSpan(text: 'After '),
                                      TextSpan(
                                        text: '${p.rounds} rounds',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const TextSpan(text: ', how many '),
                                      TextSpan(
                                        text: '${p.targetValue}s',
                                        style: const TextStyle(
                                          color: AppColors.orange,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const TextSpan(text: ' exist?'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ── Hint chip ─────────────────────────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.greenLight.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.greenLight
                                      .withOpacity(0.2)),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.lightbulb_outline,
                                    size: 12,
                                    color: AppColors.greenLight),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Core skills: pattern growth · recurrence recognition',
                                    style: TextStyle(
                                      color: AppColors.greenLight,
                                      fontSize: 11,
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
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Answer input section ───────────────────────────────────────
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

        // ── Floating answer bar ────────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _inputVisible ? 0.0 : 1.0,
            child: IgnorePointer(
              ignoring: _inputVisible,
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
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                          children: [
                            const TextSpan(text: 'count of '),
                            TextSpan(
                              text: '${widget.problem.targetValue}s',
                              style: const TextStyle(
                                  color: AppColors.orange,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
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

// ── Rule row widget ───────────────────────────────────────────────────────────

class _RuleRow extends StatelessWidget {
  final String value;
  final List<String> produces;

  const _RuleRow({required this.value, required this.produces});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.purpleGlow.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.purpleGlow.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.purpleGlow,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 8),
        ...produces.map((p) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: AppColors.orange.withOpacity(0.3)),
                ),
                child: Text(
                  p,
                  style: const TextStyle(
                    color: AppColors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

// ── Expansion step row ────────────────────────────────────────────────────────

class _ExpansionStepRow extends StatelessWidget {
  final int round;
  final List<int> array;
  final bool isLast;

  const _ExpansionStepRow({
    required this.round,
    required this.array,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    // Cap display at 16 elements
    final display = array.length > 16 ? array.sublist(0, 16) : array;
    final overflow = array.length > 16;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 52,
          child: Text(
            'Round $round',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              ...display.map((n) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: isLast
                          ? AppColors.orange.withOpacity(0.08)
                          : AppColors.bg,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: isLast
                            ? AppColors.orange.withOpacity(0.3)
                            : AppColors.border.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      '$n',
                      style: TextStyle(
                        color: isLast
                            ? AppColors.orange
                            : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  )),
              if (overflow)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(5),
                    border:
                        Border.all(color: AppColors.border.withOpacity(0.4)),
                  ),
                  child: Text(
                    '…+${array.length - 16}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Arrow divider ─────────────────────────────────────────────────────────────

class _ArrowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: const [
          SizedBox(width: 52),
          Icon(Icons.keyboard_arrow_down,
              size: 16, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

// ── Dropdown section (reused pattern) ────────────────────────────────────────

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
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    child: Icon(Icons.keyboard_arrow_down,
                        size: 16, color: color.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ),
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

// ── Step buttons ──────────────────────────────────────────────────────────────

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