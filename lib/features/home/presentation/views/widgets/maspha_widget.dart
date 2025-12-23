import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MesphaWidget extends StatefulWidget {
  const MesphaWidget({super.key});

  @override
  State<MesphaWidget> createState() => _MesphaWidgetState();
}

class _MesphaWidgetState extends State<MesphaWidget>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    HapticFeedback.lightImpact();
    setState(() {
      _count++;
    });
  }

  void _resetCounter() {
    HapticFeedback.mediumImpact();
    setState(() {
      _count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double imageSize = constraints.maxWidth * 0.8;

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background image
              Image.asset(
                'assets/images/zikirmatik_image.png',
                width: imageSize,
                height: imageSize,
                fit: BoxFit.contain,
              ),

              // Counter display overlay
              Positioned(
                top: imageSize * 0.22, // Adjusted to match LCD area
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '$_count',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: imageSize * 0.12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              // Count button area
              Positioned(
                bottom: imageSize * 0.15,
                left: imageSize * 0.15,
                child: GestureDetector(
                  onTapDown: (_) => _controller.forward(),
                  onTapUp: (_) {
                    _controller.reverse();
                    _incrementCounter();
                  },
                  onTapCancel: () => _controller.reverse(),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: imageSize * 0.35,
                      height: imageSize * 0.35,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),

              // Reset button area - Adjusted size and position
              Positioned(
                top: imageSize * 0.55, // Adjusted to match reset button
                right: imageSize * 0.15,
                child: GestureDetector(
                  onTap: _resetCounter,
                  child: Container(
                    width: imageSize * 0.2,
                    height: imageSize * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              // Optional: Add debug overlay to see touch areas
              // Uncomment these to see the touch areas
              /*
              Positioned(
                top: imageSize * 0.55,
                right: imageSize * 0.15,
                child: Container(
                  width: imageSize * 0.2,
                  height: imageSize * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              */
            ],
          ),
        );
      },
    );
  }
}
