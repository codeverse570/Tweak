/// Pure data class — no Hive annotations needed (stored as Map via toJson)
class UserStats {
  final int rating;
  final int gems;
  final int totalWins;
  final int totalLosses;
  final int totalTies;
  final int totalBattles;
  final Map<String, ProblemRecord> problemRecords;

  const UserStats({
    this.rating = 1500,
    this.gems = 1500,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.totalTies = 0,
    this.totalBattles = 0,
    this.problemRecords = const {},
  });

  UserStats copyWith({
    int? rating,
    int? gems,
    int? totalWins,
    int? totalLosses,
    int? totalTies,
    int? totalBattles,
    Map<String, ProblemRecord>? problemRecords,
  }) {
    return UserStats(
      rating: rating ?? this.rating,
      gems: gems ?? this.gems,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      totalTies: totalTies ?? this.totalTies,
      totalBattles: totalBattles ?? this.totalBattles,
      problemRecords: problemRecords ?? this.problemRecords,
    );
  }

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'gems': gems,
        'totalWins': totalWins,
        'totalLosses': totalLosses,
        'totalTies': totalTies,
        'totalBattles': totalBattles,
        'problemRecords': problemRecords
            .map((k, v) => MapEntry(k, v.toJson())),
      };

  factory UserStats.fromJson(Map<dynamic, dynamic> json) => UserStats(
        rating: json['rating'] as int? ?? 1500,
        gems: json['gems'] as int? ?? 1500,
        totalWins: json['totalWins'] as int? ?? 0,
        totalLosses: json['totalLosses'] as int? ?? 0,
        totalTies: json['totalTies'] as int? ?? 0,
        totalBattles: json['totalBattles'] as int? ?? 0,
        problemRecords: (json['problemRecords'] as Map? ?? {}).map(
          (k, v) => MapEntry(
            k.toString(),
            ProblemRecord.fromJson(v as Map),
          ),
        ),
      );
}

class ProblemRecord {
  final int attempts;
  final int solves;     // correct answers
  final int? bestCost;  // lowest cost achieved (null = never solved)
  final int? bestTimeMs; // fastest solve in milliseconds

  const ProblemRecord({
    this.attempts = 0,
    this.solves = 0,
    this.bestCost,
    this.bestTimeMs,
  });

  ProblemRecord copyWith({
    int? attempts,
    int? solves,
    int? bestCost,
    int? bestTimeMs,
  }) {
    return ProblemRecord(
      attempts: attempts ?? this.attempts,
      solves: solves ?? this.solves,
      bestCost: bestCost ?? this.bestCost,
      bestTimeMs: bestTimeMs ?? this.bestTimeMs,
    );
  }

  double get solveRate =>
      attempts == 0 ? 0 : (solves / attempts).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
        'attempts': attempts,
        'solves': solves,
        'bestCost': bestCost,
        'bestTimeMs': bestTimeMs,
      };

  factory ProblemRecord.fromJson(Map<dynamic, dynamic> json) => ProblemRecord(
        attempts: json['attempts'] as int? ?? 0,
        solves: json['solves'] as int? ?? 0,
        bestCost: json['bestCost'] as int?,
        bestTimeMs: json['bestTimeMs'] as int?,
      );
}