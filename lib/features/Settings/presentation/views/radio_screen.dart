import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/common/widgets/custom_loading_widget.dart';
import '../../../../core/common/widgets/default_app_bar.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/utils/spacing.dart';
import '../../data/models/radio_model.dart';
import '../../data/repo/radio_load_data.dart';
import 'widgets/radio_widget.dart';

class RadioScreen extends StatefulWidget {
  static const String routeName = '/radio';
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  List<RadioModel> radios = [];
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;
  String? _loadingRadioId; // Track which radio is loading
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    loadRadios();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() {
    // Listen to player state changes (loading, playing, etc.)
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          
          // Clear loading state when audio starts playing or fails
          if (state.processingState == ProcessingState.ready && state.playing) {
            _loadingRadioId = null;
          } else if (state.processingState == ProcessingState.idle) {
            _loadingRadioId = null;
          }
          
          // Clear playing state when completed
          if (!_isPlaying && state.processingState == ProcessingState.completed) {
            _currentlyPlayingId = null;
            _loadingRadioId = null;
          }
        });
      }
    });

    // Listen to playing state changes
    _audioPlayer.playingStream.listen((playing) {
      if (mounted) {
        setState(() {
          _isPlaying = playing;
          if (playing) {
            _loadingRadioId = null; // Clear loading when playing starts
          }
        });
      }
    });

    // Listen to processing state for loading indication
    _audioPlayer.processingStateStream.listen((processingState) {
      if (mounted) {
        setState(() {
          if (processingState == ProcessingState.loading) {
            // Keep loading state
          } else if (processingState == ProcessingState.ready) {
            _loadingRadioId = null;
          } else if (processingState == ProcessingState.idle) {
            _loadingRadioId = null;
          }
        });
      }
    });
  }

  Future<void> loadRadios() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = null;
      });

      final response = await RadioLoadData.loadRadios();
      setState(() {
        radios = response.radios;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load radios: $e');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'فشل تحميل الإذاعات. يرجى المحاولة مرة أخرى.';
      });
    }
  }

  Future<void> _toggleRadio(RadioModel radio) async {
    try {
      // If clicking the same radio that's playing, pause it
      if (_currentlyPlayingId == radio.id && _isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _currentlyPlayingId = null;
          _loadingRadioId = null;
        });
        return;
      }

      // Set loading state immediately for UI feedback
      setState(() {
        _loadingRadioId = radio.id;
        _currentlyPlayingId = radio.id;
        _isPlaying = false;
      });

      // If clicking a different radio, stop current and play new one
      if (_currentlyPlayingId != null && _currentlyPlayingId != radio.id) {
        await _audioPlayer.stop();
      }

      // Play the selected radio
      await _audioPlayer.setUrl(radio.url);
      await _audioPlayer.play();
      
      // Update state after play is called
      if (mounted) {
        setState(() {
          _currentlyPlayingId = radio.id;
        });
      }
    } catch (e) {
      debugPrint('Error playing radio: $e');
      if (mounted) {
        setState(() {
          _loadingRadioId = null;
          if (_currentlyPlayingId == radio.id) {
            _currentlyPlayingId = null;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'فشل تشغيل الإذاعة. يرجى المحاولة مرة أخرى.',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: AppColors.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const DefaultAppBar(
                title: 'الإذاعات الإسلامية',
                icon: Icons.arrow_back,
              ),
              verticalSpace(16),
              Expanded(
                child: isLoading
                    ? const CustomLoadingWidget(
                        message: 'جاري تحميل الإذاعات...',
                        size: 100.0,
                      )
                    : hasError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: AppColors.errorColor,
                                ),
                                verticalSpace(16),
                                Text(
                                  errorMessage ?? 'حدث خطأ',
                                  style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16,
                                    fontFamily: 'Tajawal',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                verticalSpace(24),
                                ElevatedButton(
                                  onPressed: loadRadios,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'إعادة المحاولة',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : radios.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا توجد إذاعات متاحة',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: loadRadios,
                                color: AppColors.primaryColor,
                                child: ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: radios.length,
                                  itemBuilder: (context, index) {
                                    final radio = radios[index];
                                    final isPlaying =
                                        _currentlyPlayingId == radio.id && _isPlaying;
                                    final isLoading =
                                        _loadingRadioId == radio.id;
                                    return RadioWidget(
                                      radio: radio,
                                      isPlaying: isPlaying,
                                      isLoading: isLoading,
                                      onTap: () => _toggleRadio(radio),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 