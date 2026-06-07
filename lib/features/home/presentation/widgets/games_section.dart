import 'package:flutter/material.dart';
import 'package:skillyr/core/constants/app_colors.dart';
import 'package:skillyr/features/home/domain/models/game_item.dart';
import 'package:skillyr/features/home/presentation/widgets/game_card.dart';

class GamesSection extends StatelessWidget {
  const GamesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // ── Responsive breakpoints ──────────────────────────────
        final int crossAxisCount;
        final double childAspectRatio;
        final double crossAxisSpacing;
        final double mainAxisSpacing;
        final double horizontalPadding;
        final double titleFontSize;
        final double viewAllFontSize;

        if (width < 360) {
          // Very small phones (e.g. old Android, iPhone SE)
          crossAxisCount     = 2;
          childAspectRatio   = 0.6;
          crossAxisSpacing   = 8;
          mainAxisSpacing    = 8;
          horizontalPadding  = 12;
          titleFontSize      = 13;
          viewAllFontSize    = 10;
        } else if (width < 480) {
          // Normal phones
          crossAxisCount     = 2;
          childAspectRatio   = 0.65;
          crossAxisSpacing   = 12;
          mainAxisSpacing    = 12;
          horizontalPadding  = 18;
          titleFontSize      = 15;
          viewAllFontSize    = 11;
        } else if (width < 720) {
          // Large phones / small tablets (portrait)
          crossAxisCount     = 3;
          childAspectRatio   = 0.82;
          crossAxisSpacing   = 12;
          mainAxisSpacing    = 12;
          horizontalPadding  = 20;
          titleFontSize      = 15;
          viewAllFontSize    = 11;
        } else if (width < 1024) {
          // Tablets (portrait/landscape)
          crossAxisCount     = 4;
          childAspectRatio   = 0.85;
          crossAxisSpacing   = 14;
          mainAxisSpacing    = 14;
          horizontalPadding  = 24;
          titleFontSize      = 16;
          viewAllFontSize    = 12;
        } else {
          // Large tablets / desktop
          crossAxisCount     = 5;
          childAspectRatio   = 0.88;
          crossAxisSpacing   = 16;
          mainAxisSpacing    = 16;
          horizontalPadding  = 32;
          titleFontSize      = 17;
          viewAllFontSize    = 13;
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Games',
                    style: TextStyle(
                      color: const Color(0xFFE2D9F3),
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: AppColors.purpleLight,
                        fontSize: viewAllFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: mainAxisSpacing),

              // Responsive grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: games.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:   crossAxisCount,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing:  mainAxisSpacing,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) => GameCard(game: games[index]),
              ),
            ],
          ),
        );
      },
    );
  }
}