import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../data/models/adhan_model.dart';
import '../../data/repo/adhan_service.dart';
import '../../../../../core/services/location_service.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/fonts/font_family_helper.dart';
import '../../../../../core/styles/fonts/font_styles.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../../../core/common/widgets/default_app_bar.dart';
import '../../../../../core/utils/spacing.dart';
import 'package:intl/intl.dart';

class AdhanFullScreen extends StatefulWidget {
  const AdhanFullScreen({super.key});
  static const String routeName = '/adhan-full';

  @override
  State<AdhanFullScreen> createState() => _AdhanFullScreenState();
}

class _AdhanFullScreenState extends State<AdhanFullScreen> {
  AdhanModel? _adhanData;
  bool _isLoading = true;
  String? _errorMessage;
  double? _currentLatitude;
  double? _currentLongitude;
  String _locationDescription = '';
  int _selectedMethod = 4; // Default: Umm al-Qura
  
  Timer? _countdownTimer;
  String _countdown = '00:00:00';
  Map<String, dynamic>? _nextPrayer;
  
  // Audio player for Adhan
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAdhan = false;
  bool _isLoadingAdhan = false;
  String _selectedAdhanSound = 'makkah';
  String _selectedAdhanName = 'أذان مكة المكرمة';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadSelectedAdhanSound();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingAdhan = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlayingAdhan = false;
        });
      }
    });
  }

  Future<void> _loadSelectedAdhanSound() async {
    final selectedId = await AdhanService.getSelectedAdhanSound();
    final selectedName = await AdhanService.getSelectedAdhanName();
    
    if (mounted) {
      setState(() {
        _selectedAdhanSound = selectedId;
        _selectedAdhanName = selectedName;
      });
    }
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get location with fallback
      final location = await LocationService.getLocationWithFallback();
      
      setState(() {
        _currentLatitude = location['latitude'];
        _currentLongitude = location['longitude'];
        _locationDescription = LocationService.getLocationDescription(
          location['latitude']!,
          location['longitude']!,
        );
      });

      // Load adhan times
      await _loadAdhanTimes();
    } catch (e) {
      debugPrint('Failed to initialize location: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل تحميل الموقع';
      });
    }
  }

  Future<void> _loadAdhanTimes({bool useCache = true}) async {
    if (_currentLatitude == null || _currentLongitude == null) {
      await _initializeLocation();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await AdhanService.getAdhanByLocation(
        latitude: _currentLatitude!,
        longitude: _currentLongitude!,
        method: _selectedMethod,
        useCache: useCache,
      );
      
      setState(() {
        _adhanData = data;
        _nextPrayer = AdhanService.getNextPrayer(data.timings);
        _isLoading = false;
      });

      // Start countdown timer
      _startCountdownTimer();
    } catch (e) {
      debugPrint('Error loading adhan times: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_adhanData != null && mounted) {
        final next = AdhanService.getNextPrayer(_adhanData!.timings);
        setState(() {
          _nextPrayer = next;
          _countdown = next['countdown'];
        });
      }
    });
  }

  Future<void> _changeCalculationMethod() async {
    final method = await showDialog<int>(
      context: context,
      builder: (context) => _buildMethodDialog(),
    );

    if (method != null && method != _selectedMethod) {
      setState(() {
        _selectedMethod = method;
      });
      await _loadAdhanTimes(useCache: false);
    }
  }

  Future<void> _playAdhan() async {
    try {
      if (_isPlayingAdhan) {
        await _audioPlayer.stop();
        setState(() {
          _isPlayingAdhan = false;
          _isLoadingAdhan = false;
        });
      } else {
        setState(() {
          _isLoadingAdhan = true;
        });
        
        final adhanUrl = await AdhanService.getSelectedAdhanUrl();
        debugPrint('Playing Adhan from URL: $adhanUrl');
        
        // Configure audio player for iOS
        await _audioPlayer.setReleaseMode(ReleaseMode.stop);
        await _audioPlayer.setVolume(1.0);
        
        // Play audio
        await _audioPlayer.play(UrlSource(adhanUrl));
        
        setState(() {
          _isLoadingAdhan = false;
        });
      }
    } catch (e) {
      debugPrint('Error playing Adhan: $e');
      setState(() {
        _isLoadingAdhan = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تشغيل الأذان. تحقق من الاتصال بالإنترنت'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showAdhanSoundSelector() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => _buildAdhanSoundDialog(),
    );

    if (selected != null && selected != _selectedAdhanSound) {
      await AdhanService.saveSelectedAdhanSound(selected);
      await _loadSelectedAdhanSound();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم اختيار: $_selectedAdhanName'),
            backgroundColor: AppColors.primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildAdhanSoundDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(
            Icons.volume_up,
            color: AppColors.primaryColor,
          ),
          horizontalSpace(12),
          Text(
            'اختر صوت الأذان',
            style: TextStyles.font20PrimaryText.copyWith(
              fontFamily: FontFamilyHelper.fontFamily1,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: AdhanService.adhanSounds.length,
          itemBuilder: (context, index) {
            final soundEntry = AdhanService.adhanSounds.entries.elementAt(index);
            final soundId = soundEntry.key;
            final soundData = soundEntry.value;
            final isSelected = _selectedAdhanSound == soundId;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.primaryColor 
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mosque,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 20,
                  ),
                ),
                title: Text(
                  soundData['name']!,
                  style: TextStyles.font16PrimaryText.copyWith(
                    fontFamily: FontFamilyHelper.fontFamily1,
                    color: isSelected ? AppColors.primaryColor : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: AppColors.primaryColor,
                      )
                    : null,
                onTap: () {
                  Navigator.pop(context, soundId);
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'إلغاء',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const DefaultAppBar(
                    title: 'مواقيت الأذان',
                    icon: Icons.arrow_back,
                  ),
                  verticalSpace(12),
                  
                  // Location and method info
                  _buildLocationInfo(),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
                horizontalSpace(8),
                Expanded(
                  child: Text(
                    _locationDescription.isNotEmpty
                        ? _locationDescription
                        : 'جاري تحديد الموقع...',
                    style: TextStyles.font14PrimaryText.copyWith(
                      color: AppColors.primaryColor,
                      fontFamily: FontFamilyHelper.fontFamily1,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        horizontalSpace(8),
        
        // Settings button
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: _changeCalculationMethod,
            icon: Icon(
              Icons.settings,
              color: AppColors.primaryColor,
            ),
            tooltip: 'طريقة الحساب',
          ),
        ),
        
        horizontalSpace(8),
        
        // Adhan sound selector button
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: _showAdhanSoundSelector,
            icon: Icon(
              Icons.volume_up,
              color: AppColors.primaryColor,
            ),
            tooltip: 'اختيار صوت الأذان',
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_adhanData == null) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return RefreshIndicator(
      onRefresh: () => _loadAdhanTimes(useCache: false),
      color: AppColors.primaryColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Next prayer card
          FadeInDown(
            child: _buildNextPrayerCard(),
          ),
          
          verticalSpace(16),
          
          // Adhan audio player card
          FadeIn(
            child: _buildAdhanPlayerCard(),
          ),
          
          verticalSpace(24),
          
          // Date info
          FadeIn(
            child: _buildDateCard(),
          ),
          
          verticalSpace(24),
          
          // Prayer times list
          Text(
            'مواقيت الصلاة',
            style: TextStyles.font20PrimaryText.copyWith(
              fontFamily: FontFamilyHelper.fontFamily1,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalSpace(12),
          
          ...List.generate(5, (index) {
            return FadeInUp(
              delay: Duration(milliseconds: 100 * index),
              duration: const Duration(milliseconds: 400),
              child: _buildPrayerTimeCard(index),
            );
          }),
          
          verticalSpace(16),
          
          // Sunrise card
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            duration: const Duration(milliseconds: 400),
            child: _buildSunriseCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    if (_nextPrayer == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'الصلاة القادمة',
            style: TextStyles.font16PrimaryText.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontFamily: FontFamilyHelper.fontFamily1,
            ),
          ),
          verticalSpace(12),
          
          Text(
            _nextPrayer!['name'],
            style: TextStyles.font24WhiteText.copyWith(
              fontFamily: FontFamilyHelper.fontFamily1,
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
          
          verticalSpace(8),
          
          Text(
            _nextPrayer!['time'],
            style: TextStyles.font24WhiteText.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          verticalSpace(16),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer,
                  color: Colors.white,
                  size: 20,
                ),
                horizontalSpace(8),
                Text(
                  'باقي $_countdown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdhanPlayerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.volume_up,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
              horizontalSpace(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'صوت الأذان',
                      style: TextStyles.font18PrimaryText.copyWith(
                        fontFamily: FontFamilyHelper.fontFamily1,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    verticalSpace(4),
                    Text(
                      _selectedAdhanName,
                      style: TextStyles.font14PrimaryText.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          verticalSpace(16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Play/Stop button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoadingAdhan ? null : _playAdhan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPlayingAdhan 
                        ? Colors.red 
                        : AppColors.primaryColor,
                    disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isLoadingAdhan
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _isPlayingAdhan ? Icons.stop : Icons.play_arrow,
                          color: Colors.white,
                        ),
                  label: Text(
                    _isLoadingAdhan 
                        ? 'جاري التحميل...'
                        : (_isPlayingAdhan ? 'إيقاف' : 'تشغيل الأذان'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              horizontalSpace(12),
              
              // Change sound button
              ElevatedButton.icon(
                onPressed: _showAdhanSoundSelector,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
                icon: Icon(
                  Icons.music_note,
                  color: AppColors.primaryColor,
                ),
                label: Text(
                  'تغيير',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE، d MMMM yyyy', 'ar');
    final formattedDate = formatter.format(now);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today,
              color: AppColors.primaryColor,
              size: 24,
            ),
          ),
          horizontalSpace(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: TextStyles.font16PrimaryText.copyWith(
                    fontFamily: FontFamilyHelper.fontFamily1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                verticalSpace(4),
                Text(
                  _adhanData!.date,
                  style: TextStyles.font14PrimaryText.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeCard(int index) {
    final prayers = [
      {
        'name': 'الفجر',
        'time': _adhanData!.timings.fajr,
        'icon': AppImages.cloudefog,
      },
      {
        'name': 'الظهر',
        'time': _adhanData!.timings.dhuhr,
        'icon': AppImages.sunnyImage,
      },
      {
        'name': 'العصر',
        'time': _adhanData!.timings.asr,
        'icon': AppImages.sunImage,
      },
      {
        'name': 'المغرب',
        'time': _adhanData!.timings.maghrib,
        'icon': AppImages.cloudSunnyImage,
      },
      {
        'name': 'العشاء',
        'time': _adhanData!.timings.isha,
        'icon': AppImages.moonImage,
      },
    ];

    final prayer = prayers[index];
    final isNextPrayer = _nextPrayer?['name'] == prayer['name'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNextPrayer
            ? AppColors.primaryColor.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNextPrayer
              ? AppColors.primaryColor
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Prayer icon
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              prayer['icon'] as String,
              fit: BoxFit.contain,
            ),
          ),
          horizontalSpace(16),
          
          // Prayer name
          Expanded(
            child: Text(
              prayer['name'] as String,
              style: TextStyles.font20PrimaryText.copyWith(
                fontFamily: FontFamilyHelper.fontFamily1,
                color: isNextPrayer
                    ? AppColors.primaryColor
                    : Colors.black87,
                fontWeight: isNextPrayer
                    ? FontWeight.bold
                    : FontWeight.w600,
              ),
            ),
          ),
          
          // Prayer time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isNextPrayer
                  ? AppColors.primaryColor
                  : AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              prayer['time'] as String,
              style: TextStyle(
                color: isNextPrayer ? Colors.white : AppColors.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunriseCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.wb_sunny,
              color: Colors.amber,
            ),
          ),
          horizontalSpace(16),
          
          Expanded(
            child: Text(
              'الشروق',
              style: TextStyles.font20PrimaryText.copyWith(
                fontFamily: FontFamilyHelper.fontFamily1,
                color: Colors.amber[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _adhanData!.timings.sunrise,
              style: TextStyle(
                color: Colors.amber[800],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryColor),
          verticalSpace(16),
          Text(
            'جاري تحميل مواقيت الأذان...',
            style: TextStyles.font16PrimaryText.copyWith(
              color: Colors.grey[600],
              fontFamily: FontFamilyHelper.fontFamily1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            verticalSpace(16),
            Text(
              _errorMessage ?? 'حدث خطأ',
              style: TextStyles.font16PrimaryText.copyWith(
                color: Colors.grey[600],
                fontFamily: FontFamilyHelper.fontFamily1,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace(24),
            ElevatedButton(
              onPressed: _initializeLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        'طريقة الحساب',
        style: TextStyles.font20PrimaryText.copyWith(
          fontFamily: FontFamilyHelper.fontFamily1,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: AdhanService.calculationMethods.length,
          itemBuilder: (context, index) {
            final methodId = AdhanService.calculationMethods.keys.elementAt(index);
            final methodName = AdhanService.calculationMethods[methodId]!;
            final isSelected = _selectedMethod == methodId;

            return ListTile(
              title: Text(
                methodName,
                style: TextStyles.font16PrimaryText.copyWith(
                  fontFamily: FontFamilyHelper.fontFamily1,
                  color: isSelected ? AppColors.primaryColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              leading: Radio<int>(
                value: methodId,
                groupValue: _selectedMethod,
                activeColor: AppColors.primaryColor,
                onChanged: (value) {
                  Navigator.pop(context, value);
                },
              ),
              onTap: () {
                Navigator.pop(context, methodId);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'إلغاء',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

