import 'package:flutter/material.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/utils/spacing.dart';

class PrayerTimesLoadingSkeleton extends StatefulWidget {
  const PrayerTimesLoadingSkeleton({super.key});

  @override
  State<PrayerTimesLoadingSkeleton> createState() => _PrayerTimesLoadingSkeletonState();
}

class _PrayerTimesLoadingSkeletonState extends State<PrayerTimesLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            // Hijri Date Skeleton
            _buildShimmerBox(
              width: 200,
              height: 20,
              gradientPosition: _animation.value,
            ),
            verticalSpace(24),

            // Prayer Name Skeleton
            _buildShimmerBox(
              width: 100,
              height: 24,
              gradientPosition: _animation.value,
            ),
            verticalSpace(12),

            // Time Skeleton
            _buildShimmerBox(
              width: 120,
              height: 48,
              gradientPosition: _animation.value,
            ),
            verticalSpace(8),

            // Next Prayer Text Skeleton
            _buildShimmerBox(
              width: 180,
              height: 16,
              gradientPosition: _animation.value,
            ),
            verticalSpace(16),

            // Prayer Time Cards Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                5,
                (index) => _buildPrayerCardSkeleton(_animation.value),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double gradientPosition,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.5, 1.0],
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.2),
          ],
          transform: GradientRotation(gradientPosition),
        ),
      ),
    );
  }

  Widget _buildPrayerCardSkeleton(double gradientPosition) {
    return Column(
      children: [
        // Prayer Name
        _buildShimmerBox(
          width: 40,
          height: 12,
          gradientPosition: gradientPosition,
        ),
        verticalSpace(8),
        // Icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.4),
                Colors.white.withOpacity(0.2),
              ],
              transform: GradientRotation(gradientPosition),
            ),
          ),
        ),
        verticalSpace(8),
        // Time
        _buildShimmerBox(
          width: 40,
          height: 12,
          gradientPosition: gradientPosition,
        ),
      ],
    );
  }
}

class ModernLoadingIndicator extends StatefulWidget {
  const ModernLoadingIndicator({super.key});

  @override
  State<ModernLoadingIndicator> createState() => _ModernLoadingIndicatorState();
}

class _ModernLoadingIndicatorState extends State<ModernLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * 3.14159,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                    gradient: SweepGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.8),
                        Colors.white.withOpacity(0.8),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
          // Inner circle
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_controller.value * 1.5 * 3.14159,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2.5,
                    ),
                    gradient: SweepGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
          // Center dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PulsatingDots extends StatefulWidget {
  const PulsatingDots({super.key});

  @override
  State<PulsatingDots> createState() => _PulsatingDotsState();
}

class _PulsatingDotsState extends State<PulsatingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 + (0.5 * (1 - (animationValue - 0.5).abs() * 2));
            final opacity = 0.3 + (0.7 * (1 - (animationValue - 0.5).abs() * 2));

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(opacity),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(opacity * 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

