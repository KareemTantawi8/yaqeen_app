import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../data/models/radio_model.dart';

class RadioWidget extends StatefulWidget {
  const RadioWidget({
    super.key,
    required this.radio,
    required this.isPlaying,
    required this.isLoading,
    required this.onTap,
  });

  final RadioModel radio;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  State<RadioWidget> createState() => _RadioWidgetState();
}

class _RadioWidgetState extends State<RadioWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isPlaying || widget.isLoading;
    
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onTap,
      child: Opacity(
        opacity: widget.isLoading ? 0.7 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withOpacity(0.8),
                    ]
                  : [
                      Colors.white,
                      const Color(0xFFF5F9F8),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? AppColors.primaryColor.withOpacity(0.3)
                    : AppColors.primaryColor.withOpacity(0.1),
                blurRadius: isActive ? 20 : 10,
                offset: const Offset(0, 4),
                spreadRadius: isActive ? 2 : 1,
              ),
            ],
            border: Border.all(
              color: isActive
                  ? AppColors.primaryColor.withOpacity(0.5)
                  : AppColors.primaryColor.withOpacity(0.1),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Radio Icon with Animation
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isActive)
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_animationController.value * 0.3),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                    if (widget.isLoading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      Icon(
                        Icons.radio,
                        color: isActive
                            ? Colors.white
                            : AppColors.primaryColor,
                        size: 32,
                      ),
                  ],
                ),
              ),
            horizontalSpace(16),
              // Radio Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.radio.name,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF1A2221),
                        fontSize: 16,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.isLoading) ...[
                      verticalSpace(8),
                      Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                          horizontalSpace(8),
                          Text(
                            'جاري التحميل...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ] else if (widget.isPlaying) ...[
                      verticalSpace(8),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          horizontalSpace(8),
                          Text(
                            'جاري التشغيل...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Play/Pause Button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : AppColors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isActive
                          ? Colors.white.withOpacity(0.5)
                          : AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                        ),
                      )
                    : Icon(
                        widget.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: isActive
                            ? AppColors.primaryColor
                            : Colors.white,
                        size: 28,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

