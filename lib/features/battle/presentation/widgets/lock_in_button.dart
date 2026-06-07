import 'package:flutter/material.dart';
import 'package:skillyr/core/constants/app_colors.dart';


class LockInButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback? onPressed;
  final String label;

  const LockInButton({
    super.key,
    required this.enabled,
    this.onPressed,
    this.label = 'Lock in Answer',
  });

  @override
  State<LockInButton> createState() => _LockInButtonState();
}

class _LockInButtonState extends State<LockInButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onPressed : null,
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: widget.enabled
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: const [
                          AppColors.purple,
                          AppColors.purpleGlow,
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          AppColors.surface,
                          AppColors.surface,
                        ],
                      ),
                boxShadow: widget.enabled
                    ? [
                        BoxShadow(
                          color: AppColors.purple.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    // Shimmer overlay when enabled
                    if (widget.enabled)
                      AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, _) {
                          return Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(
                                      -2 + 4 * _shimmerController.value, 0),
                                  end: Alignment(
                                      -1 + 4 * _shimmerController.value, 0),
                                  colors: [
                                    Colors.white.withOpacity(0),
                                    Colors.white.withOpacity(0.08),
                                    Colors.white.withOpacity(0),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    // Label
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.label,
                            style: TextStyle(
                              color: widget.enabled
                                  ? Colors.white
                                  : AppColors.textMuted,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: widget.enabled
                                ? Colors.white
                                : AppColors.textMuted,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}