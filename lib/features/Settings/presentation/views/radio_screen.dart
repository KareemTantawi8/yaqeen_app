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
  String? _loadingRadioId;
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
    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
        if (state.playing) {
          _loadingRadioId = null;
        }
        if (!state.playing &&
            state.processingState == ProcessingState.completed) {
          _currentlyPlayingId = null;
          _loadingRadioId = null;
        }
      });
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
      if (!mounted) return;
      setState(() {
        radios = response.radios;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load radios: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'فشل تحميل الإذاعات. يرجى المحاولة مرة أخرى.';
      });
    }
  }

  Future<void> _toggleRadio(RadioModel radio) async {
    final previousId = _currentlyPlayingId;

    try {
      if (previousId == radio.id && _isPlaying) {
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlayingId = null;
          _loadingRadioId = null;
        });
        return;
      }

      if (_loadingRadioId == radio.id) return;

      setState(() {
        _loadingRadioId = radio.id;
        _currentlyPlayingId = radio.id;
        _isPlaying = false;
      });

      await _audioPlayer.stop();

      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(radio.url),
          headers: const {'User-Agent': 'YaqeenApp/1.0'},
        ),
        preload: false,
      );
      await _audioPlayer.play();
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
                icon: Icons.arrow_forward_ios_sharp,
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
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: radios.length,
                                  itemBuilder: (context, index) {
                                    final radio = radios[index];
                                    final isPlaying =
                                        _currentlyPlayingId == radio.id &&
                                            _isPlaying;
                                    final isItemLoading =
                                        _loadingRadioId == radio.id;
                                    return RadioWidget(
                                      radio: radio,
                                      isPlaying: isPlaying,
                                      isLoading: isItemLoading,
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
