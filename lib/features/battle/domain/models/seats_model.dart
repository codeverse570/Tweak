import 'package:skillyr/features/battle/domain/models/graph_model.dart';

class SeatsSubProblem extends SubProblem {
  @override
  final String title;
  @override
  final String description;
  @override
  final int timeLimitSeconds;

  /// Empty seats between each pair of consecutive occupied seats.
  /// First and last seat are always occupied (not included in gaps).
  /// e.g. gaps = [3, 2] → 1 _ _ _ 1 _ _ 1
  final List<int> gaps;

  /// The correct minimum total students (pre-occupied + added)
  @override
  final int correctCost; // reused as "correct answer"

   SeatsSubProblem({
    required this.title,
    required this.description,
    required this.gaps,
    required this.correctCost,
    this.timeLimitSeconds = 40,
  });

  /// For each gap of size g, minimum students to block it = floor(g / 2)
  static int minStudentsToAdd(List<int> gaps) {
    return gaps.fold(0, (sum, g) => sum + (g / 2).floor());
  }

  /// Total = pre-occupied (gaps.length + 1) + added
  static int totalStudents(List<int> gaps) {
    return (gaps.length + 1) + minStudentsToAdd(gaps);
  }

  @override
  bool isCorrect(dynamic answer) {
    if (answer is int) return answer == correctCost;
    if (answer is Map) return answer['answer'] == correctCost;
    return false;
  }
}

// ── Sub-problem 1: simple warm-up ────────────────────────────────────────────
// Row: 1 _ _ _ 1 _ _ 1   gaps=[3,2]
// Add: floor(3/2)=1 in gap1, floor(2/2)=1 in gap2 → +2 students
// Total = 3 pre-occupied + 2 added = 5
final seatsSubProblem1 = SeatsSubProblem(
  title: 'Sub-Problem 1 of 4',
  description: 'Minimum total students when gaps between occupied seats are given.',
  gaps: [3, 2],
  correctCost: 4, // 3 pre-occupied + 2 added
  timeLimitSeconds: 5*60,
);

// ── Sub-problem 2 ────────────────────────────────────────────────────────────
// gaps=[4, 1, 4]  pre-occupied=4
// add: floor(4/2)=2, floor(1/2)=0, floor(4/2)=2 → +4
// Total = 4 + 4 = 8
final seatsSubProblem2 = SeatsSubProblem(
  title: 'Sub-Problem 2 of 4',
  description: 'Minimum total students when gaps between occupied seats are given.',
  gaps: [4, 1, 4],
  correctCost: 6,
  timeLimitSeconds: 40,
);

// ── Sub-problem 3 ────────────────────────────────────────────────────────────
// gaps=[5, 3, 5, 2]  pre-occupied=5
// add: 2+1+2+1=6
// Total = 5 + 6 = 11
final seatsSubProblem3 = SeatsSubProblem(
  title: 'Sub-Problem 3 of 4',
  description: 'Minimum total students when gaps between occupied seats are given.',
  gaps: [5, 3, 5, 2],
  correctCost: 10,
  timeLimitSeconds: 45,
);

// ── Sub-problem 4 ────────────────────────────────────────────────────────────
// gaps=[6, 1, 3, 6, 1]  pre-occupied=6
// add: 3+0+1+3+0=7
// Total = 6 + 7 = 13
final seatsSubProblem4 = SeatsSubProblem(
  title: 'Sub-Problem 4 of 4',
  description: 'Minimum total students when gaps between occupied seats are given.',
  gaps: [25,30, 15, 20, 2],
  correctCost: 48,
  timeLimitSeconds: 60,
);

final List<SeatsSubProblem> seatsBattleProblems = [
  seatsSubProblem1,
  seatsSubProblem2,
  seatsSubProblem3,
  seatsSubProblem4,
];