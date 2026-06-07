class BattlePlayer {
  final String name;
  final int gems;
  final int score;
  final bool isYou;
  /// true = win, false = loss for each completed round
  final List<bool> roundResults;
  /// Whether each round has a known result yet (to show pending dots)
  final List<bool> roundResultsKnown;

  const BattlePlayer({
    required this.name,
    required this.gems,
    required this.score,
    required this.isYou,
    required this.roundResults,
    required this.roundResultsKnown,
  });
}