// lib/features/physics/data/physics_problems_data.dart

import '../domain/models/physics_problem.dart';

final List<PhysicsProblem> hardcodedPhysicsProblems = [
  PhysicsProblem(
    id: 'phys_001',
    title: 'Rolling Cylinder at Edge',
    description:
        'A solid cylinder of radius R rolls without slipping on a horizontal surface '
        'toward a vertical edge. Solve in two parts.',
    type: PhysicsProblemType.rollingCylinder,
    // ── legacy options kept for the lobby card "N options" counter ───────────
    options: [
      PhysicsOption(id: 'a', label: 'A', expression: '√(5gR/3)', isCorrect: false),
      PhysicsOption(id: 'b', label: 'B', expression: '√(2gR/3)', isCorrect: true),
      PhysicsOption(id: 'c', label: 'C', expression: '√(gR/2)',  isCorrect: false),
      PhysicsOption(id: 'd', label: 'D', expression: '√(4gR/3)', isCorrect: false),
    ],
    explanation:
        'Part 1: The cylinder rolls with v₀ = √(gR/3) by energy conservation on '
        'a frictionless ramp setup.  '
        'Part 2: Using angular momentum conservation about the corner and energy '
        'conservation, it loses contact at θ = cos⁻¹(2/3) ≈ 48.2° where mg·cosθ = mv²/R.',
    animationParams: {
      'radius': 40.0,
      'initialSpeed': 1.5,
      'lossAngleDeg': 48.19,
      'timeLimitSeconds': 90,
    },

    // ── Two sub-problems ─────────────────────────────────────────────────────
    subProblems: [
      SubProblem(
        id: 'phys_001_p1',
        title: 'Part 1 — Speed at the Edge',
        question:
            'The cylinder rolls without slipping with center-of-mass speed v₀ on a '
            'horizontal surface and reaches the vertical edge. '
            'what is v₀?',
        inputType: SubProblemInputType.multipleChoice,
        points: 10,
        options: [
          PhysicsOption(id: 'a', label: 'A', expression: '√(5gR/3)', isCorrect: false),
          PhysicsOption(id: 'b', label: 'B', expression: '√(gR/3)',  isCorrect: true),
          PhysicsOption(id: 'c', label: 'C', expression: '√(gR/2)',  isCorrect: false),
          PhysicsOption(id: 'd', label: 'D', expression: '√(2gR/3)', isCorrect: false),
        ],
      ),
      SubProblem(
        id: 'phys_001_p2',
        title: 'Part 2 — Loss-of-Contact Angle',
        question:
            'Now the cylinder pivots about the corner. Drag it to the angle θ at which '
            'cylinder losses contact with surface. Note:- Answer will be accepted only if θ-1 < User Input < θ+1'
            '',
        inputType: SubProblemInputType.dragAngle,
        points: 100,
        trueAngleDeg: 44,   // cos⁻¹(2/3)
        angleTolerance: 1.0,
      ),
    ],
  ),
];