import 'package:flutter/material.dart';
import 'package:skillyr/core/constants/app_colors.dart';
import 'package:skillyr/features/home/presentation/widgets/bottom_nav_bar.dart';
import 'package:skillyr/features/home/presentation/widgets/hero_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNav = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: HeroSection(),   // no scroll wrapper
            ),
            BottomNavBar(
              selectedIndex: _selectedNav,
              onTap: (i) => setState(() => _selectedNav = i),
            ),
          ],
        ),
      ),
    );
  }
}