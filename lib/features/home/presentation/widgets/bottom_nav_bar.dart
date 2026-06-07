import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skillyr/core/constants/app_colors.dart';

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
 
const _navItems = [
  _NavItem(Icons.explore_outlined, 'Explore'),
  _NavItem(Icons.emoji_events_outlined, 'Leaderboard'),
  _NavItem(Icons.bookmark_border_rounded, 'Bookmarks'),
  _NavItem(Icons.settings_outlined, 'Settings'),
];
 
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
 
  const BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBg,
        border: Border(
          top: BorderSide(color: AppColors.navBorder, width: 1),
        ),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          _navItems.length,
          (i) => GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selectedIndex == i
                    ? AppColors.purple.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _navItems[i].icon,
                    size: 22,
                    color: selectedIndex == i
                        ? AppColors.purpleLight
                        : AppColors.navInactive,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _navItems[i].label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: selectedIndex == i
                          ? AppColors.purpleLight
                          : AppColors.navInactive,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 