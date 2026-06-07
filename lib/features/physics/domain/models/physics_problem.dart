// lib/features/physics/domain/models/physics_problem.dart

enum PhysicsProblemType {
  rollingCylinder,
  projectileMotion,
  pendulum,
}

class PhysicsOption {
  final String id;
  final String label;
  final String expression; // LaTeX-like string for display
  final bool isCorrect;

  const PhysicsOption({
    required this.id,
    required this.label,
    required this.expression,
    required this.isCorrect,
  });
}

/// A sub-problem is one step inside a multi-part PhysicsProblem.
/// Each sub-problem can be answered differently:
///   - [SubProblemInputType.multipleChoice] → tap one of the [options]
///   - [SubProblemInputType.dragAngle]      → drag the cylinder angle dial
class SubProblem {
  final String id;
  final String title;
  final String question;
  final SubProblemInputType inputType;
  final int points;

  /// Only used when [inputType] == [SubProblemInputType.multipleChoice]
  final List<PhysicsOption> options;

  /// Only used when [inputType] == [SubProblemInputType.dragAngle]
  final double trueAngleDeg;
  final double angleTolerance;

  const SubProblem({
    required this.id,
    required this.title,
    required this.question,
    required this.inputType,
    required this.points,
    this.options = const [],
    this.trueAngleDeg = 0.0,
    this.angleTolerance = 5.0,
  });
}

enum SubProblemInputType { multipleChoice, dragAngle }

class PhysicsProblem {
  final String id;
  final String title;
  final String description;
  final PhysicsProblemType type;

  /// Legacy flat options (kept for compatibility with PhysicsLobbyScreen card display)
  final List<PhysicsOption> options;

  final String explanation;
  final Map<String, dynamic> animationParams;

  /// Multi-part sub-problems.  When non-empty the battle screen uses these
  /// instead of the legacy [options].
  final List<SubProblem> subProblems;

  const PhysicsProblem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.options,
    required this.explanation,
    this.animationParams = const {},
    this.subProblems = const [],
  });
}