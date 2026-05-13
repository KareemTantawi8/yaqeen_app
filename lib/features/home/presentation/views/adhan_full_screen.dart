import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/adhan_model.dart';
import '../../data/repo/adhan_service.dart';
import '../../../../../core/services/adhan_audio_player_service.dart';
import '../../../../../core/services/location_service.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/styles/fonts/font_family_helper.dart';
import '../../../../../core/styles/fonts/font_styles.dart';
import '../../../../../core/styles/images/app_image.dart';
import '../../../../../core/common/widgets/default_app_bar.dart';
import '../../../../../core/utils/spacing.dart';
import 'package:intl/intl.dart';
import '../../../Prayer/presentation/views/adhan_settings_screen.dart';

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
  int _selectedMethod = 4;

  Timer? _countdownTimer;
  String _countdown = '00:00:00';
  Map<String, dynamic>? _nextPrayer;

  // Audio state mirrors the singleton service
  bool _isPlayingAdhan = false;
  bool _isLoadingAdhan = false;
  String _selectedVoiceName = 'أذان مكة المكرمة';

  bool _autoPlayRequested = false;

  final _service = AdhanAudioPlayerService.instance;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadVoiceName();

    // Mirror audio player state
    _service.player.playerStateStream.listen(_onPlayerState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check for auto-play argument (passed when opening from a notification tap)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['autoPlay'] == true && !_autoPlayRequested) {
      _autoPlayRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _playAdhan());
    }
  }

  void _onPlayerState(PlayerState state) {
    if (!mounted) return;
    setState(() {
      _isLoadingAdhan = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      _isPlayingAdhan = state.playing && !_isLoadingAdhan;
    });
  }

  Future<void> _loadVoiceName() async {
    final id = await _service.getSelectedVoiceId();
    final voice = _service.getVoiceById(id);
    if (mounted) {
      setState(() => _selectedVoiceName = voice['name'] ?? 'أذان مكة المكرمة');
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final location = await LocationService.getLocationWithFallback();
      setState(() {
        _currentLatitude = location['latitude'];
        _currentLongitude = location['longitude'];
        _locationDescription = LocationService.getLocationDescription(
          location['latitude']!,
          location['longitude']!,
        );
      });
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
        _nextPrayer = AdhanService.getNextPrayer(
          data.timings,
          latitude: _currentLatitude!,
          longitude: _currentLongitude!,
          calculationMethodId: _selectedMethod,
        );
        _isLoading = false;
      });
      _startCountdownTimer();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) {
      if (_adhanData != null &&
          mounted &&
          _currentLatitude != null &&
          _currentLongitude != null) {
        final next = AdhanService.getNextPrayer(
          _adhanData!.timings,
          latitude: _currentLatitude!,
          longitude: _currentLongitude!,
          calculationMethodId: _selectedMethod,
        );
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
      builder: (_) => _buildMethodDialog(),
    );
    if (method != null && method != _selectedMethod) {
      setState(() => _selectedMethod = method);
      await _loadAdhanTimes(useCache: false);
    }
  }

  Future<void> _playAdhan() async {
    try {
      if (_isPlayingAdhan) {
        await _service.stop();
        return;
      }
      await _service.playAdhan();
    } catch (e) {
      debugPrint('Error playing Adhan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذّر تشغيل الأذان — حاول مرة أخرى',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openAdhanSettings() {
    Navigator.of(context)
        .pushNamed(AdhanSettingsScreen.routeName)
        .then((_) => _loadVoiceName());
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  _buildLocationInfo(),
                ],
              ),
            ),

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
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on,
                    color: AppColors.primaryColor, size: 20),
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
        // Calculation method
        _buildIconBtn(Icons.settings, _changeCalculationMethod,
            tooltip: 'طريقة الحساب'),
        horizontalSpace(8),
        // Adhan settings (voice + notifications)
        _buildIconBtn(Icons.notifications_active_outlined, _openAdhanSettings,
            tooltip: 'إعدادات الأذان'),
      ],
    );
  }

  Widget _buildIconBtn(
    IconData icon,
    VoidCallback onTap, {
    String? tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.primaryColor),
        tooltip: tooltip,
      ),
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
          FadeInDown(child: _buildNextPrayerCard()),
          verticalSpace(16),
          FadeIn(child: _buildAdhanPlayerCard()),
          verticalSpace(24),
          FadeIn(child: _buildDateCard()),
          verticalSpace(24),
          Text(
            'مواقيت الصلاة',
            style: TextStyles.font20PrimaryText.copyWith(
              fontFamily: FontFamilyHelper.fontFamily1,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalSpace(12),
          ...List.generate(
            5,
            (i) => FadeInUp(
              delay: Duration(milliseconds: 100 * i),
              duration: const Duration(milliseconds: 400),
              child: _buildPrayerTimeCard(i),
            ),
          ),
          verticalSpace(16),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, color: Colors.white, size: 20),
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
                child: Icon(Icons.volume_up,
                    color: AppColors.primaryColor, size: 24),
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
                      _selectedVoiceName,
                      style: TextStyles.font14PrimaryText
                          .copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(16),
          Row(
            children: [
              // Play / Stop button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoadingAdhan ? null : _playAdhan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPlayingAdhan
                        ? Colors.red
                        : AppColors.primaryColor,
                    disabledBackgroundColor:
                        AppColors.primaryColor.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isLoadingAdhan
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
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
              // Settings button
              ElevatedButton.icon(
                onPressed: _openAdhanSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: AppColors.primaryColor, width: 1.5),
                  ),
                ),
                icon: Icon(Icons.settings, color: AppColors.primaryColor),
                label: Text(
                  'إعدادات',
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
            child: Icon(Icons.calendar_today,
                color: AppColors.primaryColor, size: 24),
          ),
          horizontalSpace(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatter.format(now),
                  style: TextStyles.font16PrimaryText.copyWith(
                    fontFamily: FontFamilyHelper.fontFamily1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                verticalSpace(4),
                Text(
                  _adhanData!.date,
                  style: TextStyles.font14PrimaryText
                      .copyWith(color: Colors.grey[600]),
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
      {'name': 'الفجر', 'time': _adhanData!.timings.fajr, 'icon': AppImages.cloudefog},
      {'name': 'الظهر', 'time': _adhanData!.timings.dhuhr, 'icon': AppImages.sunnyImage},
      {'name': 'العصر', 'time': _adhanData!.timings.asr, 'icon': AppImages.sunImage},
      {'name': 'المغرب', 'time': _adhanData!.timings.maghrib, 'icon': AppImages.cloudSunnyImage},
      {'name': 'العشاء', 'time': _adhanData!.timings.isha, 'icon': AppImages.moonImage},
    ];

    final prayer = prayers[index];
    final isNext = _nextPrayer?['name'] == prayer['name'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.primaryColor.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNext ? AppColors.primaryColor : Colors.transparent,
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
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(prayer['icon'] as String, fit: BoxFit.contain),
          ),
          horizontalSpace(16),
          Expanded(
            child: Text(
              prayer['name'] as String,
              style: TextStyles.font20PrimaryText.copyWith(
                fontFamily: FontFamilyHelper.fontFamily1,
                color: isNext ? AppColors.primaryColor : Colors.black87,
                fontWeight:
                    isNext ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isNext
                  ? AppColors.primaryColor
                  : AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              prayer['time'] as String,
              style: TextStyle(
                color: isNext ? Colors.white : AppColors.primaryColor,
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
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
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
            child: const Icon(Icons.wb_sunny, color: Colors.amber),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    horizontal: 32, vertical: 12),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            final methodId =
                AdhanService.calculationMethods.keys.elementAt(index);
            final methodName = AdhanService.calculationMethods[methodId]!;
            final isSelected = _selectedMethod == methodId;

            return ListTile(
              title: Text(
                methodName,
                style: TextStyles.font16PrimaryText.copyWith(
                  fontFamily: FontFamilyHelper.fontFamily1,
                  color: isSelected ? AppColors.primaryColor : Colors.black87,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              leading: Radio<int>(
                value: methodId,
                groupValue: _selectedMethod,
                activeColor: AppColors.primaryColor,
                onChanged: (v) => Navigator.pop(context, v),
              ),
              onTap: () => Navigator.pop(context, methodId),
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
