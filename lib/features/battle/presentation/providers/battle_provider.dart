import 'package:flutter/foundation.dart';
import 'package:skillyr/features/battle/data/services/problem_queue_service.dart';
import 'package:skillyr/features/battle/data/services/user_stats_service.dart';
import 'package:skillyr/features/battle/domain/models/battle_outcome.dart';
import 'package:skillyr/features/battle/domain/models/graph_model.dart';
import 'package:skillyr/features/battle/domain/models/user_stats.dart';

class BattleProvider extends ChangeNotifier {
  BattleProvider() {
    _init();
  }

  final ProblemQueueService _queue = ProblemQueueService.instance;
  final UserStatsService _statsService = UserStatsService.instance;

  late List<SubProblem> _problems;
  int _roundIndex = 0;
  bool _isLocked = false;
  bool _timedOut = false;
  bool _gameOver = false;

  final List<bool> _yourCorrect = [];
  final List<bool> _opponentCorrect = [];
  final List<int?> _yourCosts = [];
  final List<int?> _yourTimesMs = [];
  final List<DateTime?> _roundStartTimes = [];

  int _yourScore = 0;
  int _opponentScore = 0;
  BattleOutcome? _battleOutcome;

  static const List<bool> _opponentSimResults = [true, false, true, true];

  void _init() {
    _problems = _queue.currentProblems;
    for (int i = 0; i < _problems.length; i++) {
      _yourCorrect.add(false);
      _opponentCorrect.add(false);
      _yourCosts.add(null);
      _yourTimesMs.add(null);
      _roundStartTimes.add(null);
    }
    _roundStartTimes[0] = DateTime.now();
  }

  // ── Getters ───────────────────────────────────────────────────────────────

  List<SubProblem> get problems => _problems;
  SubProblem get currentProblem => _problems[_roundIndex];
  int get roundIndex => _roundIndex;
  bool get isLocked => _isLocked;
  bool get timedOut => _timedOut;
  bool get gameOver => _gameOver;
  int get yourScore => _yourScore;
  int get opponentScore => _opponentScore;
  BattleOutcome? get battleOutcome => _battleOutcome;
  ProblemType get currentProblemType => _queue.currentProblemType;
  UserStats get stats => _statsService.stats;

  List<bool> get yourRoundResults => List.unmodifiable(_yourCorrect);
  List<bool> get opponentRoundResults => List.unmodifiable(_opponentCorrect);
  List<bool> get roundSettled => List.generate(
        _problems.length,
        (i) => i < _roundIndex || (i == _roundIndex && _isLocked),
      );

  // ── Actions ───────────────────────────────────────────────────────────────

  void markRoundStart() {
    _roundStartTimes[_roundIndex] = DateTime.now();
  }

  /// Generic lockIn — answer is whatever the problem type needs.
  /// Graph:  {'path': List<String>, 'cost': int}
  /// Seats:  {'answer': int}
  void lockIn({
    required Map<String, dynamic> answer,
    bool timedOut = false,
  }) {
    if (_isLocked) return;
    
    final bool correct = !timedOut && currentProblem.isCorrect(answer);

    // Extract cost for stats (null for seats or timed-out)
    final int? cost = timedOut
        ? null
        : (answer['cost'] as int?) ?? (answer['answer'] as int?);

    final oppCorrect =
        _opponentSimResults[_roundIndex % _opponentSimResults.length];

    int? elapsedMs;
    final start = _roundStartTimes[_roundIndex];
    if (!timedOut && start != null) {
      elapsedMs = DateTime.now().difference(start).inMilliseconds;
    }

    _yourCorrect[_roundIndex] = correct;
    _opponentCorrect[_roundIndex] = oppCorrect;
    _yourCosts[_roundIndex] = cost;
    _yourTimesMs[_roundIndex] = elapsedMs;

    if (correct) _yourScore += 100;
    if (oppCorrect) _opponentScore += 100;

    _isLocked = true;
    _timedOut = timedOut;

    notifyListeners();
  }

  Future<void> nextRound() async {
    if (_roundIndex >= _problems.length - 1) {
      await _finishBattle();
      return;
    }
    _roundIndex++;
    _isLocked = false;
    _timedOut = false;
    _roundStartTimes[_roundIndex] = DateTime.now();
    notifyListeners();
  }

  Future<void> _finishBattle() async {
    final result = _yourScore > _opponentScore
        ? 'win'
        : _yourScore < _opponentScore
            ? 'loss'
            : 'tie';

    final ids = List.generate(_problems.length, (i) => _queue.problemId(i));

    final outcome = BattleOutcome(
      result: result,
      yourScore: _yourScore,
      opponentScore: _opponentScore,
      yourRoundCorrect: List.from(_yourCorrect),
      yourRoundCosts: List.from(_yourCosts),
      yourRoundTimesMs: List.from(_yourTimesMs),
      problemIds: ids,
    );

    await _statsService.applyBattleOutcome(outcome);
    Future.delayed(const Duration(seconds: 2), () async {
  
    await _queue.advance();
  });
    

    _battleOutcome = outcome;
    _gameOver = true;
    notifyListeners();
  }
}