import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:skillyr/features/battle/data/services/hive_storage.dart';
import 'package:skillyr/features/battle/presentation/providers/battle_provider.dart';
import 'package:skillyr/features/battle/presentation/screens/battle_screen.dart';

import 'package:skillyr/features/home/presentation/screens/home_screen.dart';

import 'package:skillyr/features/auth/presentation/providers/auth_provider.dart';
import 'package:skillyr/features/auth/presentation/screens/auth_screen.dart';
import 'package:skillyr/features/auth/data/services/supabase_auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive
  await HiveStorage.instance.init();

  // Supabase
 await Supabase.initialize( url: 'https://bdapfofkohruzxjffgxw.supabase.co', publishableKey: 'sb_publishable_yX5fciAgov_15rUuhtfyYg_01pkO0a0', );

  runApp(const SkillyrApp());
}

class SkillyrApp extends StatelessWidget {
  const SkillyrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(
        SupabaseAuthService(
          webClientId:
              '142409091643-is28hdgftcfvccs1kvf6lu5douq5pqqh.apps.googleusercontent.com',
        ),
      ),
      child: MaterialApp(
        title: 'Skillyr',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0A14),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7C3AED),
            secondary: Color(0xFF34D399),
            surface: Color(0xFF13131F),
            error: Color(0xFFEF4444),
          ),
          fontFamily: 'SF Pro Display',
        ),
        home: const RootGate(),
      ),
    );
  }
}

/// Shows AuthScreen if user isn't logged in,
/// otherwise goes to HomeScreen.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isAuthenticated) {
      return const HomeScreen();
    }

    return const AuthScreen();
  }
}

/// Battle screen wrapper
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