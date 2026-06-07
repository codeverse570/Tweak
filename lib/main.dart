import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillyr/features/battle/data/services/hive_storage.dart';
import 'package:skillyr/features/battle/presentation/providers/battle_provider.dart';
import 'package:skillyr/features/battle/presentation/screens/battle_screen.dart';
import 'package:skillyr/features/home/presentation/screens/home_screen.dart';

// Import your existing app widget here
// import 'package:skillyr/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Hive must be initialised before runApp ────────────────────────────────
  await HiveStorage.instance.init();

  runApp(const SkillyrApp());
}

class SkillyrApp extends StatelessWidget {
  const SkillyrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skillyr',
      theme: ThemeData.dark(),
      // BattleProvider is created fresh per battle session.
      // Do NOT wrap the whole app in it — create it at the route level.
      // See BattleScreenWrapper below for the correct pattern.
      home: const HomeScreen(), // replace with your actual home screen
    );
  }
}

/// Wrap BattleScreen with its own BattleProvider so the provider lifecycle
/// is tied to the screen lifecycle (created on push, disposed on pop).
///
/// Usage:
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => const BattleScreenWrapper(),
///   ));
class BattleScreenWrapper extends StatelessWidget {
  const BattleScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BattleProvider(),
      child: const BattleScreen(),
    );
  }
}