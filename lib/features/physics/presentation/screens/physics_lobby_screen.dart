// lib/features/physics/presentation/screens/physics_lobby_screen.dart

import 'package:flutter/material.dart';
import '../../data/physics_problems_data.dart';
import '../../domain/models/physics_problem.dart';
import 'physics_battle_screen.dart';

class PhysicsLobbyScreen extends StatelessWidget {
  const PhysicsLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D18),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            _buildSubtitle(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                itemCount: hardcodedPhysicsProblems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _ProblemCard(
                  problem: hardcodedPhysicsProblems[i],
                  index: i,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PhysicsBattleScreen(problemIndex: i),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E2D45), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white54, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'PHYSICS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 3,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0E2A45),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF00B4D8), width: 1),
            ),
            child: Text(
              '${hardcodedPhysicsProblems.length} PROBLEMS',
              style: const TextStyle(
                color: Color(0xFF00B4D8),
                fontSize: 11,
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Text(
        'Challenge your opponent with physics problems.\nAnimate, reason, and outpace.',
        style: TextStyle(
          color: Colors.white38,
          fontSize: 13,
          height: 1.5,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  final PhysicsProblem problem;
  final int index;
  final VoidCallback onTap;

  const _ProblemCard({
    required this.problem,
    required this.index,
    required this.onTap,
  });

  static const _typeIcons = {
    PhysicsProblemType.rollingCylinder: Icons.rotate_right,
    PhysicsProblemType.projectileMotion: Icons.architecture,
    PhysicsProblemType.pendulum: Icons.pending_actions,
  };

  static const _typeLabels = {
    PhysicsProblemType.rollingCylinder: 'ROLLING MOTION',
    PhysicsProblemType.projectileMotion: 'PROJECTILE',
    PhysicsProblemType.pendulum: 'PENDULUM',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1B2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E3050), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF0A2540),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF00B4D8), width: 1.5),
              ),
              child: Icon(
                _typeIcons[problem.type] ?? Icons.science,
                color: const Color(0xFF00B4D8),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _typeLabels[problem.type] ?? 'PHYSICS',
                    style: const TextStyle(
                      color: Color(0xFF00B4D8),
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    problem.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Interactive animation · ${problem.options.length} options',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white24,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}