// lib/features/physics/presentation/screens/physics_battle_screen.dart
//
// Two-part sub-problem flow:
//   Sub-problem 1 (10 pts)  → animation rolls to edge → MCQ answer
//   Sub-problem 2 (100 pts) → drag-angle → lock in
//
// Submit logic for Part 2:
//   • WRONG  → animation freezes with red feedback; ResultOverlay appears
//              immediately via onSubmitResult(false) callback.
//   • CORRECT → pivot + fall animation plays; ResultOverlay appears after
//               animation completes via onSubmitResult(true) callback.
//
// The screen advances automatically after each sub-problem result is
// dismissed via the "Next" button on the ResultOverlay.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skillyr/core/constants/app_colors.dart';
import 'package:skillyr/features/battle/domain/models/battle_player.dart';
import 'package:skillyr/features/battle/presentation/widgets/battle_header.dart';
import 'package:skillyr/features/battle/presentation/widgets/result_overlay.dart';
import 'package:skillyr/features/battle/presentation/widgets/game_summary_overlay.dart';
import '../../data/physics_problems_data.dart';
import '../../domain/models/physics_problem.dart';
import '../widgets/rolling_cylinder_animation.dart';

// ─── Tolerance for drag-angle sub-problem ────────────────────────────────────
const double _kTolerance = 5.0;

class PhysicsBattleScreen extends StatefulWidget {
  final int problemIndex;

  const PhysicsBattleScreen({super.key, this.problemIndex = 0});

  @override
  State<PhysicsBattleScreen> createState() => _PhysicsBattleScreenState();
}

class _PhysicsBattleScreenState extends State<PhysicsBattleScreen> {
  final GlobalKey<RollingCylinderAnimationState> _animKey = GlobalKey();

  late PhysicsProblem _problem;
  bool _answerSubmitted = false;

  // ── Sub-problem tracking ──────────────────────────────────────────────────
  int _subIndex   = 0;
  int _totalScore = 0;

  // ── State per current sub-problem ─────────────────────────────────────────
  bool _isLocked  = false;
  bool _timedOut  = false;
  bool _gameOver  = false;

  // MCQ
  String? _selectedOptionId;

  // Drag-angle
  double? _submittedAngle;

  // For Part 2: ResultOverlay is deferred until the animation fires the
  // onSubmitResult callback.  _animSubmitDone flips to true when that fires.
  bool _animSubmitDone = false;

  // ── Per-round scores for BattleHeader dots ─────────────────────────────────
  final List<bool> _roundResults      = [];
  final List<bool> _roundResultsKnown = [];

  // ── Simulated opponent results ─────────────────────────────────────────────
  // In a real game these come from the server; here we generate them at init.
  final List<bool> _opponentRoundResults = [];
  int _opponentScore = 0;

  @override
  void initState() {
    super.initState();
    _problem = hardcodedPhysicsProblems[widget.problemIndex];
    for (int i = 0; i < _problem.subProblems.length; i++) {
      _roundResults.add(false);
      _roundResultsKnown.add(false);
      // Simulate opponent: wins roughly half the rounds
      final opponentWon = i.isEven;
      _opponentRoundResults.add(opponentWon);
      if (opponentWon) {
        _opponentScore += _problem.subProblems[i].points;
      }
    }
  }

  SubProblem get _currentSub => _problem.subProblems[_subIndex];

  bool get _isCorrect {
    final sub = _currentSub;
    if (sub.inputType == SubProblemInputType.multipleChoice) {
      if (_selectedOptionId == null) return false;
      return sub.options.any((o) => o.id == _selectedOptionId && o.isCorrect);
    } else {
      if (_submittedAngle == null) return false;
      return (_submittedAngle! - sub.trueAngleDeg).abs() <= sub.angleTolerance;
    }
  }

  // Whether the ResultOverlay should be shown right now.
  bool get _showResultOverlay {
    if (!_isLocked || _gameOver) return false;
    final isDragAngle =
        _currentSub.inputType == SubProblemInputType.dragAngle;
    // For MCQ, show immediately once locked.
    // For drag-angle, wait until the animation callback fires.
    return isDragAngle ? _animSubmitDone : true;
  }

  // ── Lock in ───────────────────────────────────────────────────────────────

  void _lockIn({bool timedOut = false}) {
    if (_isLocked) return;
    if (_currentSub.inputType == SubProblemInputType.multipleChoice &&
        _selectedOptionId == null && !timedOut) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isLocked      = true;
      _timedOut      = timedOut;
      _animSubmitDone = false;
       _answerSubmitted = !timedOut; // reset for this round
    });

    if (_currentSub.inputType == SubProblemInputType.dragAngle) {
      if (timedOut) {
        // Timed out — treat as wrong immediately, no animation needed.
        setState(() {
          _roundResults[_subIndex]      = false; // timed out = wrong
          _roundResultsKnown[_subIndex] = true;
          _animSubmitDone               = true;
        });
      } else {
        // Ask the animation to evaluate and play (or not).
        // _onAnimSubmitResult will be called back by the game.
        _animKey.currentState?.submitAngle();
      }
    } else {
      // MCQ: finalise immediately, overlay shows right away.
      setState(() {
        _roundResults[_subIndex]      = _isCorrect;
        _roundResultsKnown[_subIndex] = true;
        if (_isCorrect) _totalScore  += _currentSub.points;
      });
    }
  }

  /// Called by [RollingCylinderAnimation] after the submit logic resolves.
  /// [correct] == true  → animation played fully.
  /// [correct] == false → cylinder frozen with red feedback.
  ///
  /// May be called from inside the Flame game loop (non-Flutter thread),
  /// so we schedule via addPostFrameCallback to safely call setState.
  void _onAnimSubmitResult(bool correct) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _roundResults[_subIndex]      = correct;
        _roundResultsKnown[_subIndex] = true;
        if (correct) _totalScore     += _currentSub.points;
        _animSubmitDone               = true;
      });
    });
  }

  void _onAngleSubmitted(double angle) {
    // Store the angle so _isCorrect can evaluate it.
    setState(() => _submittedAngle = angle);
  }

  // ── Advance to next sub-problem or game-over ───────────────────────────────

  void _onNext() {
    if (_subIndex < _problem.subProblems.length - 1) {
      setState(() {
        _subIndex        = _subIndex + 1;
        _isLocked        = false;
        _timedOut        = false;
        _selectedOptionId = null;
        _submittedAngle  = null;
        _animSubmitDone  = false;
        _answerSubmitted = false;
      });
      _animKey.currentState?.startSubProblem2();
    } else {
      setState(() => _gameOver = true);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final you = BattlePlayer(
      name: 'You',
      gems: 1200,
      score: _roundResults.where((r) => r).length,
      isYou: true,
      roundResults: List<bool>.from(_roundResults),
      roundResultsKnown: List<bool>.from(_roundResultsKnown),
    );
    final opponent = BattlePlayer(
      name: 'Arnav',
      gems: 1580,
      score: 0,
      isYou: false,
      roundResults: List.filled(_problem.subProblems.length, false),
      roundResultsKnown: List.filled(_problem.subProblems.length, false),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _TopBar(),
                  BattleHeader(
                    key: ValueKey('physics_header_$_subIndex'),
                    you: you,
                    opponent: opponent,
                    currentRound: _subIndex + 1,
                    totalRounds: _problem.subProblems.length,
                    initialSeconds:
                       _subIndex == 0 ? 240 : 1500,
                    onTimeUp: () => _lockIn(timedOut: true),
                    yourScore: you.score,
                    opponentScore: 0,
                  ),

                  // ── Sub-problem header (points pill + title) ──────────────
                  _SubProblemHeader(
                    sub: _currentSub,
                    subIndex: _subIndex,
                    totalSubs: _problem.subProblems.length,
                  ),

                  // ── Problem statement ─────────────────────────────────────
                  _ProblemStatement(description: _currentSub.question),

                  // ── Animation canvas ──────────────────────────────────────
                  Expanded(
                    child: _subIndex == 0
                        ? _SubProblem1Body(
                            animKey: _animKey,
                            sub: _currentSub,
                            selectedOptionId: _selectedOptionId,
                            isLocked: _isLocked,
                            onOptionSelected: (id) {
                              if (_isLocked) return;
                              setState(() => _selectedOptionId = id);
                            },
                            onLockIn: _lockIn,
                          )
                        : _SubProblem2Body(
                            animKey: _animKey,
                            sub: _currentSub,
                            onAngleSubmitted: _onAngleSubmitted,
                            onSubmitResult: _onAnimSubmitResult,
                            isLocked: _isLocked,
                            isCorrect: _isLocked ? _isCorrect : null,
                            onLockIn: _lockIn,
                            animationHeight: MediaQuery.of(context).size.height * 0.35,
                          ),
                  ),
                ],
              ),

              // ── Result overlay ────────────────────────────────────────────
          if (_showResultOverlay)
  Positioned.fill(
    child: ResultOverlay(
      result: _isCorrect ? AnswerResult.correct : AnswerResult.incorrect,
      timedOut: _timedOut, // THIS drives TimeOutRow directly, no inference
      
      yourCost: _currentSub.inputType == SubProblemInputType.dragAngle
          ? (_timedOut ? 0 : (_submittedAngle?.round() ?? 0))
          : (_timedOut ? 0 : 1),

      correctCost: _currentSub.inputType == SubProblemInputType.dragAngle
          ? _currentSub.trueAngleDeg.round()
          : 1,

      yourPath: const [],
      correctPath: const [],
      isLastRound: _subIndex == _problem.subProblems.length - 1,

      yourCostLabel: _currentSub.inputType == SubProblemInputType.dragAngle
          ? 'Your angle'
          : _timedOut || _selectedOptionId == null
              ? 'Your answer'
              : _currentSub.options
                  .firstWhere((o) => o.id == _selectedOptionId,
                      orElse: () => _currentSub.options.first)
                  .expression,

      correctCostLabel: _currentSub.inputType == SubProblemInputType.dragAngle
          ? 'True angle'
          : _currentSub.options
              .firstWhere((o) => o.isCorrect,
                  orElse: () => _currentSub.options.first)
              .expression,

      onNext: _onNext,
    ),
  ),

              // ── Game over ─────────────────────────────────────────────────
              if (_gameOver)
                Positioned.fill(
                  child: GameSummaryOverlay(
                    yourScore: _totalScore,
                    opponentScore: _opponentScore,
                    yourRoundResults: List<bool>.from(_roundResults),
                    opponentRoundResults:
                        List<bool>.from(_opponentRoundResults),
                    yourGems: 1200,
                    yourRating: 1420,
                    ratingDelta: _totalScore > _opponentScore
                        ? 18
                        : _totalScore == _opponentScore
                            ? 0
                            : -12,
                    gemDelta: _totalScore > _opponentScore
                        ? 30
                        : _totalScore == _opponentScore
                            ? 5
                            : -10,
                    opponentName: 'Arnav',
                    onClose: () => Navigator.maybePop(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _replayAll() {
    setState(() {
      _subIndex         = 0;
      _totalScore       = 0;
      _opponentScore    = 0;
      _isLocked         = false;
      _timedOut         = false;
      _gameOver         = false;
      _selectedOptionId = null;
      _submittedAngle   = null;
      _animSubmitDone   = false;
      for (int i = 0; i < _roundResults.length; i++) {
        _roundResults[i]      = false;
        _roundResultsKnown[i] = false;
        final opponentWon = i.isEven;
        _opponentRoundResults[i] = opponentWon;
      }
    });
    _animKey.currentState?.replay();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-problem header pill
// ─────────────────────────────────────────────────────────────────────────────

class _SubProblemHeader extends StatelessWidget {
  final SubProblem sub;
  final int subIndex;
  final int totalSubs;

  const _SubProblemHeader({
    required this.sub,
    required this.subIndex,
    required this.totalSubs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 0),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'PART ${subIndex + 1} / $totalSubs',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              sub.title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.purple.withOpacity(0.40)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    size: 11, color: AppColors.purpleGlow),
                const SizedBox(width: 3),
                Text(
                  '${sub.points} pts',
                  style: const TextStyle(
                    color: AppColors.purpleGlow,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
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

// ─────────────────────────────────────────────────────────────────────────────
// Sub-problem 1 body — animation rolls to edge + MCQ options
// ─────────────────────────────────────────────────────────────────────────────

class _SubProblem1Body extends StatelessWidget {
  final GlobalKey<RollingCylinderAnimationState> animKey;
  final SubProblem sub;
  final String? selectedOptionId;
  final bool isLocked;
  final void Function(String id) onOptionSelected;
  final VoidCallback onLockIn;

  const _SubProblem1Body({
    required this.animKey,
    required this.sub,
    required this.selectedOptionId,
    required this.isLocked,
    required this.onOptionSelected,
    required this.onLockIn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: RollingCylinderAnimation(
            key: animKey,
            subProblemPhase: SubProblemPhase.rollingOnly,
            onAngleSubmitted: (_) {},
            answerCorrect: null,
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sub.options.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.4,
                ),
                itemBuilder: (context, index) {
                  final opt = sub.options[index];
                  return _SquareOptionTile(
                    option: opt,
                    isSelected: selectedOptionId == opt.id,
                    isLocked: isLocked,
                    onTap: () => onOptionSelected(opt.id),
                  );
                },
              ),
              const SizedBox(height: 10),
              if (!isLocked)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedOptionId != null ? onLockIn : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      disabledBackgroundColor:
                          AppColors.purple.withOpacity(0.3),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'LOCK IN ANSWER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 13,
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Single MCQ option tile (square variant)
// ─────────────────────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final PhysicsOption option;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    Color textColor;

    if (isLocked) {
      if (option.isCorrect) {
        borderColor = AppColors.greenLight;
        bgColor = AppColors.greenLight.withOpacity(0.08);
        textColor = AppColors.greenLight;
      } else if (isSelected && !option.isCorrect) {
        borderColor = AppColors.orange;
        bgColor = AppColors.orange.withOpacity(0.08);
        textColor = AppColors.orange;
      } else {
        borderColor = AppColors.border;
        bgColor = AppColors.surface;
        textColor = AppColors.textMuted;
      }
    } else {
      borderColor = isSelected ? AppColors.purple : AppColors.border;
      bgColor = isSelected
          ? AppColors.purple.withOpacity(0.10)
          : AppColors.surface;
      textColor = isSelected
          ? AppColors.textPrimary
          : AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: borderColor, width: isSelected ? 2 : 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                option.id.toUpperCase(),
                style: TextStyle(
                  color: borderColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                option.expression,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SquareOptionTile extends StatelessWidget {
  final PhysicsOption option;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const _SquareOptionTile({
    required this.option,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    Color textColor;

    if (isLocked) {
      if (option.isCorrect) {
        borderColor = AppColors.greenLight;
        bgColor = AppColors.greenLight.withOpacity(0.12);
        textColor = AppColors.greenLight;
      } else if (isSelected) {
        borderColor = AppColors.orange;
        bgColor = AppColors.orange.withOpacity(0.12);
        textColor = AppColors.orange;
      } else {
        borderColor = AppColors.border;
        bgColor = AppColors.surface;
        textColor = AppColors.textMuted;
      }
    } else {
      borderColor = isSelected ? AppColors.purple : AppColors.border;
      bgColor = isSelected
          ? AppColors.purple.withOpacity(0.12)
          : AppColors.surface;
      textColor = isSelected ? AppColors.purpleGlow : AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: borderColor, width: isSelected ? 1.8 : 1),
        ),
        child: Text(
          option.expression,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-problem 2 body — full drag-angle animation
// ─────────────────────────────────────────────────────────────────────────────

class _SubProblem2Body extends StatelessWidget {
  final GlobalKey<RollingCylinderAnimationState> animKey;
  final SubProblem sub;
  final void Function(double) onAngleSubmitted;
  final void Function(bool correct) onSubmitResult;
  final bool isLocked;
  final bool? isCorrect;
  final VoidCallback onLockIn;
final double animationHeight;
  const _SubProblem2Body({
    required this.animKey,
    required this.sub,
    required this.onAngleSubmitted,
    required this.onSubmitResult,
    required this.isLocked,
    required this.isCorrect,
    required this.onLockIn,
    this.animationHeight = 260,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RollingCylinderAnimation(
          key: animKey,
          subProblemPhase: SubProblemPhase.angleOnly,
          onAngleSubmitted: onAngleSubmitted,
          onSubmitResult: onSubmitResult,
          answerCorrect: isCorrect,
          trueAngleDeg: sub.trueAngleDeg,
          angleTolerance: sub.angleTolerance,
          animationHeight: animationHeight
        ),
        if (!isLocked)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onLockIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAB47BC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'LOCK IN ANGLE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Problem statement card
// ─────────────────────────────────────────────────────────────────────────────

class _ProblemStatement extends StatelessWidget {
  final String description;
  const _ProblemStatement({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 4),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.purple.withOpacity(0.35)),
                ),
                child: const Text(
                  'QUESTION',
                  style: TextStyle(
                    color: AppColors.purpleGlow,
                    fontSize: 9,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.science_outlined,
                    size: 12, color: AppColors.purple),
                const SizedBox(width: 5),
                const Text(
                  'Physics',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}