import 'package:skillyr/features/battle/data/services/hive_storage.dart';
import 'package:skillyr/features/battle/domain/models/graph_model.dart';
import 'package:skillyr/features/battle/domain/models/minimise_sum_model.dart';
import 'package:skillyr/features/battle/domain/models/seats_model.dart';
import 'package:skillyr/features/battle/domain/models/signal_expansion.dart';

/// Manages which set of sub-problems to show next.
/// Problems cycle in a looped queue: 0, 1, 2, … N-1, 0, 1, …
///
/// Each "battle" is one full run of [battleProblems] (all 4 sub-problems).
/// After a battle completes, advance() moves to the next battle set.
///
/// For MVP all battles use the same [battleProblems] list but the queue
/// pointer is preserved across app restarts via Hive.
/// 
// domain/models/problem_type.dart
enum ProblemType { graph,seats,minimiseSum,signalExpansion}
// data/services/problem_queue_service.dart
class ProblemQueueService {
  ProblemQueueService._();
  static final ProblemQueueService instance = ProblemQueueService._();

  final HiveStorage _storage = HiveStorage.instance;

  // Map each battle index to a problem type (cycles)
  static const List<ProblemType> _typeRotation = [
    ProblemType.graph,
    ProblemType.seats,
    ProblemType.minimiseSum,
     ProblemType.signalExpansion 
  ];

  // Which type is active this battle
  ProblemType get currentProblemType =>
      _typeRotation[currentBattleIndex % _typeRotation.length];

  // Sub-problems for the current type
 List<SubProblem> get currentProblems => switch (currentProblemType) {
  ProblemType.graph           => battleProblems.cast<SubProblem>(),
  ProblemType.seats           => seatsBattleProblems.cast<SeatsSubProblem>(),
  ProblemType.minimiseSum     => minimiseSumProblems.cast<MinimiseSumSubProblem>(),
  ProblemType.signalExpansion => signalExpansionProblems.cast<SignalExpansionSubProblem>(),
};

  int get currentBattleIndex => _storage.readQueuePointer();

  String problemId(int subIndex) {
    final session = currentBattleIndex % _typeRotation.length;
    return '${currentProblemType.name}_${session}_sub_$subIndex';
  }

  Future<void> advance() async {
    final next = currentBattleIndex + 1; // no modulo — keep growing for stats history
    await _storage.writeQueuePointer(next);
  }
}