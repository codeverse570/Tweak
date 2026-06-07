import 'package:skillyr/features/battle/data/services/hive_storage.dart';
import 'package:skillyr/features/battle/domain/models/battle_outcome.dart';
import 'package:skillyr/features/battle/domain/models/user_stats.dart';

/// Manages persistent user stats (rating, gems, win/loss, per-problem records).
/// All reads/writes go through [HiveStorage]; this class owns the business logic.
class UserStatsService {
  UserStatsService._();
  static final UserStatsService instance = UserStatsService._();

  final HiveStorage _storage = HiveStorage.instance;

  // In-memory cache — kept in sync with Hive on every write
  UserStats? _cache;

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Returns current stats, loading from Hive on first call.
  UserStats get stats {
    if (_cache != null) return _cache!;
    final raw = _storage.readUserProfile();
    _cache = raw != null ? UserStats.fromJson(raw) : const UserStats();
    return _cache!;
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Apply a completed battle outcome and persist.
  Future<UserStats> applyBattleOutcome(BattleOutcome outcome) async {
    var s = stats;

    // 1. Win / loss / tie counters
    if (outcome.isWin) {
      s = s.copyWith(totalWins: s.totalWins + 1);
    } else if (outcome.isLoss) {
      s = s.copyWith(totalLosses: s.totalLosses + 1);
    } else {
      s = s.copyWith(totalTies: s.totalTies + 1);
    }
    s = s.copyWith(totalBattles: s.totalBattles + 1);

    // 2. Rating & gems (floor at 0 for gems, 100 for rating)
    final newRating = (s.rating + outcome.ratingDelta).clamp(100, 9999);
    final newGems = (s.gems + outcome.gemDelta).clamp(0, 999999);
    s = s.copyWith(rating: newRating, gems: newGems);

    // 3. Per-problem records
    final updatedRecords = Map<String, ProblemRecord>.from(s.problemRecords);
    for (int i = 0; i < outcome.problemIds.length; i++) {
      final id = outcome.problemIds[i];
      final wasCorrect = outcome.yourRoundCorrect[i];
      final cost = outcome.yourRoundCosts[i];
      final timeMs = outcome.yourRoundTimesMs[i];

      final existing = updatedRecords[id] ?? const ProblemRecord();

      // Best cost: only update if solved correctly
      int? newBestCost = existing.bestCost;
      if (wasCorrect && cost != null) {
        newBestCost = newBestCost == null
            ? cost
            : (cost < newBestCost ? cost : newBestCost);
      }

      // Best time: only update if solved correctly
      int? newBestTime = existing.bestTimeMs;
      if (wasCorrect && timeMs != null) {
        newBestTime = newBestTime == null
            ? timeMs
            : (timeMs < newBestTime ? timeMs : newBestTime);
      }

      updatedRecords[id] = existing.copyWith(
        attempts: existing.attempts + 1,
        solves: wasCorrect ? existing.solves + 1 : existing.solves,
        bestCost: newBestCost,
        bestTimeMs: newBestTime,
      );
    }

    s = s.copyWith(problemRecords: updatedRecords);

    // 4. Persist
    await _persist(s);
    return s;
  }

  /// Overwrite specific fields directly (e.g. from settings/profile screen).
  Future<void> updateProfile({int? rating, int? gems}) async {
    var s = stats;
    if (rating != null) s = s.copyWith(rating: rating);
    if (gems != null) s = s.copyWith(gems: gems);
    await _persist(s);
  }

  /// Wipe all stats — dev/testing only.
  Future<void> reset() async {
    _cache = const UserStats();
    await _storage.writeUserProfile(const UserStats().toJson());
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _persist(UserStats s) async {
    _cache = s;
    await _storage.writeUserProfile(s.toJson());
  }
}