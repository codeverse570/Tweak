/// Represents the outcome of a completed battle (all sub-problems done)
class BattleOutcome {
  /// 'win' | 'loss' | 'tie'
  final String result;

  /// Your total score across all sub-problems
  final int yourScore;

  /// Opponent's total score
  final int opponentScore;

  /// Per-sub-problem: did you solve it correctly?
  final List<bool> yourRoundCorrect;

  /// Per-sub-problem: cost you submitted (null if timed out)
  final List<int?> yourRoundCosts;

  /// Per-sub-problem: time taken in milliseconds (null if timed out)
  final List<int?> yourRoundTimesMs;

  /// The problem IDs that were played (maps to GraphProblem index)
  final List<String> problemIds;

  const BattleOutcome({
    required this.result,
    required this.yourScore,
    required this.opponentScore,
    required this.yourRoundCorrect,
    required this.yourRoundCosts,
    required this.yourRoundTimesMs,
    required this.problemIds,
  });

  bool get isWin => result == 'win';
  bool get isLoss => result == 'loss';
  bool get isTie => result == 'tie';

  /// Elo-lite rating delta
  int get ratingDelta {
    if (isTie) return 0;
    return isWin ? 18 : -12;
  }

  /// Gem reward
  int get gemDelta {
    if (isTie) return 5;
    return isWin ? 20 : -10;
  }
}