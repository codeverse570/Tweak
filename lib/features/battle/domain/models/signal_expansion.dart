import 'package:skillyr/features/battle/domain/models/graph_model.dart';

/// Signal Expansion Problem
///
/// Rule: Start with [1]. Every round, each number n produces [n, n+1].
/// So [1] → [1,2] → [1,2,2,3] → [1,2,2,3,2,3,3,4] → …
///
/// Question: After [rounds] rounds, how many occurrences of [targetValue] exist?
///
/// Core insight: The count of value k after n rounds follows Pascal's triangle /
/// binomial coefficients. Specifically, count(k, n) = C(n, k-1) if 1 ≤ k ≤ n+1.
class SignalExpansionSubProblem extends SubProblem {
  @override
  final String title;
  @override
  final String description;
  @override
  final int timeLimitSeconds;
  @override
  final int correctCost; // stores the correct count as the answer

  final int rounds;
  final int targetValue;

   SignalExpansionSubProblem({
    required this.title,
    required this.description,
    required this.rounds,
    required this.targetValue,
    required this.correctCost,
    this.timeLimitSeconds = 60,
  });

  /// Compute how many times [target] appears after [n] expansion rounds.
  /// Starting array: [1].
  ///
  /// After n rounds the array has 2^n elements.
  /// The value k appears C(n, k-1) times (0-indexed binomial), valid for
  /// 1 ≤ k ≤ n+1. Everything outside that range has count 0.
  static int solve(int rounds, int target) {
    if (target < 1 || target > rounds + 1) return 0;
    // C(rounds, target - 1)
    return _binomial(rounds, target - 1);
  }

  static int _binomial(int n, int k) {
    if (k < 0 || k > n) return 0;
    if (k == 0 || k == n) return 1;
    // Use the smaller side for efficiency
    if (k > n - k) k = n - k;
    int result = 1;
    for (int i = 0; i < k; i++) {
      result = result * (n - i) ~/ (i + 1);
    }
    return result;
  }

  @override
  bool isCorrect(dynamic answer) {
    if (answer is Map) return answer['answer'] == correctCost;
    if (answer is int) return answer == correctCost;
    return false;
  }

  /// Helper: generate the first few expansion steps for display purposes.
  /// Returns up to [maxSteps] arrays (capped to avoid huge arrays).
  static List<List<int>> generateSteps(int steps, {int maxSteps = 5}) {
    final cap = steps.clamp(0, maxSteps);
    List<List<int>> result = [[1]];
    for (int r = 0; r < cap; r++) {
      final prev = result.last;
      final next = <int>[];
      for (final n in prev) {
        next.add(n);
        next.add(n + 1);
      }
      result.add(next);
    }
    return result;
  }
}

// ── Sub-problem 1 ─────────────────────────────────────────────────────────────
// After 5 rounds, how many 4s? → C(5,3) = 10
final signalSub1 = SignalExpansionSubProblem(
  title: 'Sub-Problem 1 of 4',
  description: '',
  rounds: 5,
  targetValue: 4,
  correctCost: SignalExpansionSubProblem.solve(5, 4),
  timeLimitSeconds: 60*60,
);

// ── Sub-problem 2 ─────────────────────────────────────────────────────────────
// After 4 rounds, how many 3s? → C(4,2) = 6
final signalSub2 = SignalExpansionSubProblem(
  title: 'Sub-Problem 2 of 4',
  description: '',
  rounds: 4,
  targetValue: 3,
  correctCost: SignalExpansionSubProblem.solve(4, 3),
  timeLimitSeconds: 90,
);

// ── Sub-problem 3 ─────────────────────────────────────────────────────────────
// After 6 rounds, how many 5s? → C(6,4) = 15
final signalSub3 = SignalExpansionSubProblem(
  title: 'Sub-Problem 3 of 4',
  description: '',
  rounds: 6,
  targetValue: 5,
  correctCost: SignalExpansionSubProblem.solve(6, 5),
  timeLimitSeconds: 120,
);

// ── Sub-problem 4 ─────────────────────────────────────────────────────────────
// After 6 rounds, how many 3s? → C(6,2) = 15
final signalSub4 = SignalExpansionSubProblem(
  title: 'Sub-Problem 4 of 4',
  description: '',
  rounds: 10,
  targetValue: 3,
  correctCost: SignalExpansionSubProblem.solve(10, 3),
  timeLimitSeconds: 120,
);

final List<SignalExpansionSubProblem> signalExpansionProblems = [
  signalSub1,
  signalSub2,
  signalSub3,
  signalSub4,
];