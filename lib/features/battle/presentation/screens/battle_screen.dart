import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skillyr/core/constants/app_colors.dart';
import 'package:skillyr/features/battle/data/services/problem_queue_service.dart';
import 'package:skillyr/features/battle/domain/models/battle_player.dart';
import 'package:skillyr/features/battle/domain/models/graph_model.dart';
import 'package:skillyr/features/battle/domain/models/minimise_sum_model.dart';
import 'package:skillyr/features/battle/domain/models/seats_model.dart';
import 'package:skillyr/features/battle/domain/models/signal_expansion.dart';
import 'package:skillyr/features/battle/presentation/problems/minimise_sum_widget.dart';
import 'package:skillyr/features/battle/presentation/problems/seats_problem_widget.dart';
import 'package:skillyr/features/battle/presentation/problems/signal_expansion_widget.dart';
import 'package:skillyr/features/battle/presentation/providers/battle_provider.dart';
import '../widgets/battle_header.dart';
import '../widgets/lock_in_button.dart';
import '../widgets/result_overlay.dart';
import '../widgets/game_summary_overlay.dart';
import '../problems/graph_problem_widget.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  List<String> _currentPath = [];
  int? _seatsAnswer;
  int? _miniSumAnswer;
  int? _signalAnswer;

  // ── Snapshot of the round that just locked in ──────────────────────────
  // Stored so ResultOverlay can safely read them even after roundIndex changes
  int _lastYourCost = 0;
  List<String> _lastYourPath = [];
  List<String> _lastCorrectPath = [];
  int _lastCorrectCost = 0;

  bool _canLockIn(GraphProblem problem) =>
      _currentPath.length >= 2 && _currentPath.last == problem.endNode;

  int _totalCost(GraphProblem problem) {
    int cost = 0;
    for (int i = 0; i < _currentPath.length - 1; i++) {
      final a = _currentPath[i];
      final b = _currentPath[i + 1];
      final edge = problem.edges.firstWhere(
        (e) => (e.from == a && e.to == b) || (e.from == b && e.to == a),
        orElse: () => const GraphEdge(from: '', to: '', weight: 0),
      );
      cost += edge.weight;
    }
    return cost;
  }

  void _lockIn(BattleProvider provider, {bool timedOut = false}) {
    switch (provider.currentProblemType) {
      case ProblemType.graph:
        final p = provider.currentProblem as GraphProblem;
        if (!timedOut && !_canLockIn(p)) return;
        // Snapshot before locking
        setState(() {
          _lastYourCost = timedOut ? 0 : _totalCost(p);
          _lastYourPath = timedOut ? [] : List.from(_currentPath);
          _lastCorrectPath = List.from(p.correctPath);
          _lastCorrectCost = p.correctCost;
        });
        HapticFeedback.mediumImpact();
        provider.lockIn(
          answer: {'path': _currentPath, 'cost': _totalCost(p)},
          timedOut: timedOut,
        );
        
      case ProblemType.seats:
        if (!timedOut && _seatsAnswer == null) return;
        final p = provider.currentProblem as SeatsSubProblem;
        setState(() {
          _lastYourCost = timedOut ? 0 : (_seatsAnswer ?? 0);
          _lastYourPath = [];
          _lastCorrectPath = [];
          _lastCorrectCost = p.correctCost;
        });
        HapticFeedback.mediumImpact();
        provider.lockIn(
          answer: {'answer': _seatsAnswer ?? 0},
          timedOut: timedOut,
        );
        case ProblemType.minimiseSum:
  if (!timedOut && _miniSumAnswer == null) return;
  final p = provider.currentProblem as MinimiseSumSubProblem;
  setState(() {
    _lastYourCost = _miniSumAnswer ?? 0;
    _lastCorrectCost = p.correctCost;
    _lastYourPath = [];
    _lastCorrectPath = [];
  });
  HapticFeedback.mediumImpact();
 
  provider.lockIn(
    answer: {'answer': _miniSumAnswer ?? 0},
    timedOut: timedOut,
  );
  case ProblemType.signalExpansion:
  if (!timedOut && _signalAnswer == null) return;
  final p = provider.currentProblem as SignalExpansionSubProblem;
  setState(() {
    _lastYourCost = _signalAnswer ?? 0;
    _lastCorrectCost = p.correctCost;
    _lastYourPath = [];
    _lastCorrectPath = [];
  });
  HapticFeedback.mediumImpact();
  provider.lockIn(
    answer: {'answer': _signalAnswer ?? 0},
    timedOut: timedOut,
  );
    }
    
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BattleProvider>();

    final stats = provider.stats;
    final you = BattlePlayer(
      name: 'You',
      gems: stats.gems,
      score: provider.yourScore,
      isYou: true,
      roundResults: provider.yourRoundResults,
      roundResultsKnown: provider.roundSettled,
    );
    final opponent = BattlePlayer(
      name: 'Arnav',
      gems: 1580,
      score: provider.opponentScore,
      isYou: false,
      roundResults: provider.opponentRoundResults,
      roundResultsKnown: provider.roundSettled,
    );

    // Safe current problem for header timing only
    final currentProblem = provider.currentProblem;

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
                    key: ValueKey(provider.roundIndex),
                    you: you,
                    opponent: opponent,
                    currentRound: provider.roundIndex + 1,
                    totalRounds: provider.problems.length,
                    initialSeconds: currentProblem.timeLimitSeconds,
                    onTimeUp: () => _lockIn(provider, timedOut: true),
                    yourScore: provider.yourScore,
                    opponentScore: provider.opponentScore,
                  ),
                  Expanded(
                    child: switch (provider.currentProblemType) {
                      ProblemType.graph => GraphProblemWidget(
                          key: ValueKey(provider.roundIndex),
                          problem: provider.currentProblem as GraphProblem,
                          onPathChanged: (path) {
                            setState(() => _currentPath = path);
                            if (path.length == 1) provider.markRoundStart();
                          },
                        ),
                      ProblemType.seats => SeatsProblemWidget(
                          key: ValueKey(provider.roundIndex),
                          problem: provider.currentProblem as SeatsSubProblem,
                          onAnswerChanged: (val) {
                            setState(() => _seatsAnswer = val);
                            provider.markRoundStart();
                          },
                        ),
                        ProblemType.minimiseSum => MinimiseSumWidget(
    key: ValueKey(provider.roundIndex),
    problem: provider.currentProblem as MinimiseSumSubProblem,
    onAnswerChanged: (val) {
      setState(() => _miniSumAnswer = val);
      provider.markRoundStart();
    },
  ),
  ProblemType.signalExpansion => SignalExpansionWidget(
    key: ValueKey(provider.roundIndex),
    problem: provider.currentProblem as SignalExpansionSubProblem,
    onAnswerChanged: (val) {
      setState(() => _signalAnswer = val);
      provider.markRoundStart();
    },
  ),
                    },
                  ),
                  LockInButton(
                    enabled: switch (provider.currentProblemType) {
                      ProblemType.graph => _canLockIn(
                              provider.currentProblem as GraphProblem) &&
                          !provider.isLocked,
                      ProblemType.seats =>
                        _seatsAnswer != null && !provider.isLocked,
                      ProblemType.minimiseSum=>
                        _miniSumAnswer!= null && !provider.isLocked,
                        ProblemType.signalExpansion =>
  _signalAnswer != null && !provider.isLocked,

                        
                    },
                    onPressed: () => _lockIn(provider),
                  ),
                ],
              ),

              // ── Result overlay — uses snapshots, never touches currentProblem ──
             if (provider.isLocked && !provider.gameOver)
  Positioned.fill(
    child: ResultOverlay(
      result: provider.yourRoundResults[provider.roundIndex]
          ? AnswerResult.correct
          : AnswerResult.incorrect,
      yourCost: provider.timedOut ? 0 : _lastYourCost,
      correctCost: _lastCorrectCost,
      yourPath: provider.timedOut ? [] : _lastYourPath,
      correctPath: _lastCorrectPath,
      isLastRound:
          provider.roundIndex >= provider.problems.length - 1,
      // Pass labels based on problem type
      yourCostLabel: switch (provider.currentProblemType) {
        ProblemType.graph        => 'Cost',
        ProblemType.seats        => 'Students',
        ProblemType.minimiseSum  => 'Fatigue',
        ProblemType.signalExpansion => 'Count',
      },
      correctCostLabel: switch (provider.currentProblemType) {
        ProblemType.graph        => 'Cost',
        ProblemType.seats        => 'Students',
        ProblemType.minimiseSum  => 'Fatigue',
        ProblemType.signalExpansion => 'Count',
      },
      onNext: () {
       setState(() {
  _currentPath = [];
  _seatsAnswer = null;
  _miniSumAnswer = null;
  _signalAnswer = null;   // ← add this line
});
        provider.nextRound();
      },
    ),
  ),

              // ── Game summary ───────────────────────────────────────────────
              if (provider.gameOver && provider.battleOutcome != null)
                Positioned.fill(
                  child: GameSummaryOverlay(
                    yourScore: provider.yourScore,
                    opponentScore: provider.opponentScore,
                    yourRoundResults: provider.yourRoundResults
                        .map((b) => b ? true : false)
                        .toList(),
                    opponentRoundResults: provider.opponentRoundResults
                        .map((b) => b ? true : false)
                        .toList(),
                    yourGems: provider.stats.gems,
                    yourRating: provider.stats.rating,
                    ratingDelta: provider.battleOutcome!.ratingDelta,
                    gemDelta: provider.battleOutcome!.gemDelta,
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
//   Widget _buildResultOverlay(BattleProvider provider) {
//   final isCorrect = provider.yourRoundResults[provider.roundIndex];
//   final isLast = provider.roundIndex >= provider.problems.length - 1;

//   switch (provider.currentProblemType) {
//     case ProblemType.graph:
//       return ResultOverlay(
//         result: isCorrect ? AnswerResult.correct : AnswerResult.incorrect,
//         yourCost: provider.timedOut ? 0 : _lastYourCost,
//         correctCost: _lastCorrectCost,
//         yourPath: provider.timedOut ? [] : _lastYourPath,
//         correctPath: _lastCorrectPath,
//         isLastRound: isLast,
//         onNext: _onNext(provider),
//       );

//     case ProblemType.seats:
//       return SeatsResultOverlay(
//         result: isCorrect ? AnswerResult.correct : AnswerResult.incorrect,
//         yourAnswer: provider.timedOut ? null : _lastYourCost,   // reused field
//         correctAnswer: _lastCorrectCost,
//         isLastRound: isLast,
//         onNext: _onNext(provider),
//       );
//       case ProblemType.minimiseSum:
//       return SeatsResultOverlay(
//         result: isCorrect ? AnswerResult.correct : AnswerResult.incorrect,
//         yourAnswer: provider.timedOut ? null : _lastYourCost,   // reused field
//         correctAnswer: _lastCorrectCost,
//         isLastRound: isLast,
//         onNext: _onNext(provider),
//       );
//   }
// }

VoidCallback _onNext(BattleProvider provider) => () {
  setState(() {
    _currentPath = [];
    _seatsAnswer = null;
  });
  provider.nextRound();
};
  
}
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.flag_outlined, size: 13, color: AppColors.textMuted),
                SizedBox(width: 4),
                Text(
                  'Report',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}