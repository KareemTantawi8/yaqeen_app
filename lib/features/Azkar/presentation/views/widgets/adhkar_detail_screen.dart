import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../data/model/adhkar_category_model.dart';
import '../../../data/model/adhkar_item_model.dart';

class AdhkarDetailScreen extends StatefulWidget {
  final AdhkarCategoryModel category;
  final AdhkarItemModel item;
  final int categoryIndex;
  final int itemIndex;

  const AdhkarDetailScreen({
    super.key,
    required this.category,
    required this.item,
    required this.categoryIndex,
    required this.itemIndex,
  });

  @override
  State<AdhkarDetailScreen> createState() => _AdhkarDetailScreenState();
}

class _AdhkarDetailScreenState extends State<AdhkarDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  bool _hasAudioError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _loadAudio();
  }

  void _setupAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.ready) {
            _isLoadingAudio = false;
            _hasAudioError = false;
          } else if (state.processingState == ProcessingState.loading) {
            _isLoadingAudio = true;
          } else if (state.processingState == ProcessingState.idle) {
            _isLoadingAudio = false;
          }
        });
      }
    });

    _audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      }
    });

    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
  }

  Future<void> _loadAudio() async {
    if (widget.item.audio == null || widget.item.audio!.isEmpty) {
      return;
    }

    try {
      setState(() {
        _isLoadingAudio = true;
        _hasAudioError = false;
      });

      String audioUrl = widget.item.audio!;
      
      // If the audio URL is relative, construct the full URL
      if (!audioUrl.startsWith('http')) {
        const baseAudioUrl = 'https://raw.githubusercontent.com/rn0x/Adhkar-json/refs/heads/main';
        audioUrl = '$baseAudioUrl$audioUrl';
      }

      debugPrint('Loading audio from: $audioUrl');
      await _audioPlayer.setUrl(audioUrl);
      
      setState(() {
        _isLoadingAudio = false;
      });
    } catch (e) {
      debugPrint('Error loading audio: $e');
      setState(() {
        _isLoadingAudio = false;
        _hasAudioError = true;
      });
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
    }
  }

  AdhkarItemModel? _getPreviousItem() {
    if (widget.itemIndex > 0) {
      return widget.category.items[widget.itemIndex - 1];
    }
    return null;
  }

  AdhkarItemModel? _getNextItem() {
    if (widget.itemIndex < widget.category.items.length - 1) {
      return widget.category.items[widget.itemIndex + 1];
    }
    return null;
  }

  void _navigateToItem(AdhkarItemModel item, int newIndex) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AdhkarDetailScreen(
          category: widget.category,
          item: item,
          categoryIndex: widget.categoryIndex,
          itemIndex: newIndex,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _copyToClipboard() async {
    try {
      final textToCopy = '${widget.category.category}\n\n${widget.item.text}\n\nعدد المرات: ${widget.item.count}';
      await Clipboard.setData(ClipboardData(text: textToCopy));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'تم نسخ الذكر بنجاح',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error copying to clipboard: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء النسخ',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPrevious = _getPreviousItem() != null;
    final hasNext = _getNextItem() != null;
    final hasAudio = widget.item.audio != null && 
                      widget.item.audio!.isNotEmpty && 
                      !_hasAudioError;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with responsive padding
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.015,
              ),
              child: Row(
                children: [
                  // Back button
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    shadowColor: AppColors.primaryColor.withOpacity(0.1),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title
                  Expanded(
                    child: Text(
                      widget.category.category,
                      style: TextStyle(
                        color: const Color(0xFF1A2221),
                        fontSize: screenWidth * 0.05,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Copy button
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    shadowColor: AppColors.primaryColor.withOpacity(0.1),
                    child: InkWell(
                      onTap: _copyToClipboard,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.copy_outlined,
                          color: AppColors.primaryColor,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Item counter badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor,
                              AppColors.primaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'الذكر ${widget.itemIndex + 1} من ${widget.category.items.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    verticalSpace(24),

                    // Main content card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.06),
                      child: Column(
                        children: [
                          // Adhkar text
                          Text(
                            widget.item.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF1A2221),
                              fontSize: screenWidth * 0.048,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                              height: 2.0,
                              letterSpacing: 0.3,
                            ),
                          ),

                          // Repeat count badge
                          if (widget.item.count > 1) ...[
                            verticalSpace(20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.primaryColor.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.repeat,
                                    color: AppColors.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'يُكرر ${widget.item.count} مرات',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 15,
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Audio player (if available)
                    if (hasAudio) ...[
                      verticalSpace(20),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryColor.withOpacity(0.1),
                              AppColors.primaryColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Play/Pause button
                            Material(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(50),
                              elevation: 4,
                              shadowColor: AppColors.primaryColor.withOpacity(0.4),
                              child: InkWell(
                                onTap: _isLoadingAudio ? null : _togglePlayPause,
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primaryColor,
                                        AppColors.primaryColor.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                  child: _isLoadingAudio
                                      ? const Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          _isPlaying ? Icons.pause : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 36,
                                        ),
                                ),
                              ),
                            ),

                            // Progress bar
                            if (_duration.inSeconds > 0) ...[
                              verticalSpace(16),
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 14,
                                  ),
                                  activeTrackColor: AppColors.primaryColor,
                                  inactiveTrackColor: AppColors.primaryColor.withOpacity(0.2),
                                  thumbColor: AppColors.primaryColor,
                                  overlayColor: AppColors.primaryColor.withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: _position.inSeconds.toDouble(),
                                  max: _duration.inSeconds.toDouble(),
                                  onChanged: (value) {
                                    _audioPlayer.seek(Duration(seconds: value.toInt()));
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_position),
                                      style: TextStyle(
                                        color: AppColors.primaryColor.withOpacity(0.7),
                                        fontSize: 12,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(_duration),
                                      style: TextStyle(
                                        color: AppColors.primaryColor.withOpacity(0.7),
                                        fontSize: 12,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    verticalSpace(24),

                    // Navigation buttons
                    Row(
                      children: [
                        // Previous button
                        Expanded(
                          child: _NavigationButton(
                            label: 'السابق',
                            icon: Icons.arrow_forward,
                            onTap: hasPrevious
                                ? () {
                                    final prevItem = _getPreviousItem()!;
                                    _navigateToItem(prevItem, widget.itemIndex - 1);
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Next button
                        Expanded(
                          child: _NavigationButton(
                            label: 'التالي',
                            icon: Icons.arrow_back,
                            onTap: hasNext
                                ? () {
                                    final nextItem = _getNextItem()!;
                                    _navigateToItem(nextItem, widget.itemIndex + 1);
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),

                    verticalSpace(16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _NavigationButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    
    return Material(
      color: isEnabled 
          ? Colors.white 
          : Colors.grey[100],
      borderRadius: BorderRadius.circular(16),
      elevation: isEnabled ? 2 : 0,
      shadowColor: AppColors.primaryColor.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEnabled 
                  ? AppColors.primaryColor.withOpacity(0.3)
                  : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isEnabled 
                    ? AppColors.primaryColor 
                    : Colors.grey[400],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isEnabled 
                      ? AppColors.primaryColor 
                      : Colors.grey[400],
                  fontSize: 15,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
