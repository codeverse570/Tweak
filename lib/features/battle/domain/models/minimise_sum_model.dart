import 'dart:ffi';

import 'dart:math';
import 'package:skillyr/features/battle/domain/models/graph_model.dart';

class MinimiseSumSubProblem extends SubProblem {
  @override
  final String title;
  @override
  final String description;
  @override
  final int timeLimitSeconds;
  @override
  final int correctCost; // the correct minimum sum

  /// The effort array a[0..n-1]
  final List<int> efforts;

   MinimiseSumSubProblem({
    required this.title,
    required this.description,
    required this.efforts,
    required this.correctCost,
    this.timeLimitSeconds = 45,
  });

  /// Compute the minimum prefix-min sum after at most one operation.
  /// Operation: pick i < j, set a[i] += a[j], a[j] = 0.
  /// Greedy insight: zeroing a[j] only helps if a[j] is currently
  /// a prefix minimum. The best move is to zero the second-smallest
  /// prefix minimum by merging it into its predecessor.
  static int solve(List<int> a) {
    return a[0]+ min(a[0],a[1]);
  }

  @override
  bool isCorrect(dynamic answer) {
    if (answer is Map) return answer['answer'] == correctCost;
    if (answer is int) return answer == correctCost;
    return false;
  }
}

// ── Sub-problem 1 ─────────────────────────────────────────────────────────────
// efforts = [3, 1, 4, 2]
// prefix mins (no op) = 3,1,1,1 → sum=6
// zero index 1 (val=1) → [3,0,4,2] prefix mins=3,3,3,2 → sum=11  worse
// zero index 3 (val=2) → [3,1,4,0] prefix mins=3,1,1,0 → sum=5  better? 
// Actually solve([3,1,4,2]) → best=5
final miniSumSub1 = MinimiseSumSubProblem(
  title: 'Sub-Problem 1 of 4',
  description: '',
  efforts: [3, 1, 4, 2],
  correctCost: MinimiseSumSubProblem.solve([3, 1, 4, 2]),
  timeLimitSeconds: 15*60,
);

// ── Sub-problem 2 ─────────────────────────────────────────────────────────────
// efforts = [5, 3, 2, 4, 1]
final miniSumSub2 = MinimiseSumSubProblem(
  title: 'Sub-Problem 2 of 4',
  description: '',
  efforts: [5, 3, 2, 4, 1],
  correctCost: MinimiseSumSubProblem.solve([5, 3, 2, 4, 1]),
  timeLimitSeconds: 2*60,
);

// ── Sub-problem 3 ─────────────────────────────────────────────────────────────
// efforts = [4, 2, 6, 1, 3, 5]
final miniSumSub3 = MinimiseSumSubProblem(
  title: 'Sub-Problem 3 of 4',
  description: '',
  efforts: [4, 6, 6, 1, 3, 5],
  correctCost: MinimiseSumSubProblem.solve([4, 6, 6, 1, 3, 5]),
  timeLimitSeconds: 2*60,
);

// ── Sub-problem 4 ─────────────────────────────────────────────────────────────
// efforts = [6, 4, 2, 5, 1, 3, 7]
final miniSumSub4 = MinimiseSumSubProblem(
  title: 'Sub-Problem 4 of 4',
  description: '',
  efforts: [6, 8, 2, 5, 1, 3, 7],
  correctCost: MinimiseSumSubProblem.solve([6, 8, 2, 5, 1, 3, 7]),
  timeLimitSeconds: 3*60,
);

final List<MinimiseSumSubProblem> minimiseSumProblems = [
  miniSumSub1,
  miniSumSub2,
  miniSumSub3,
  miniSumSub4,
];