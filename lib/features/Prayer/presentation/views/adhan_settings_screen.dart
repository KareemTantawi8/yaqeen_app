import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:yaqeen_app/core/services/adhan_audio_player_service.dart';
import 'package:yaqeen_app/core/services/location_service.dart';
import 'package:yaqeen_app/core/services/prayer_notification_service.dart';
import 'package:yaqeen_app/core/styles/colors/app_color.dart';
import 'package:yaqeen_app/core/utils/spacing.dart';

class AdhanSettingsScreen extends StatefulWidget {
  const AdhanSettingsScreen({super.key});
  static const routeName = '/adhan-settings';

  @override
  State<AdhanSettingsScreen> createState() => _AdhanSettingsScreenState();
}

class _AdhanSettingsScreenState extends State<AdhanSettingsScreen> {
  bool _masterEnabled = true;
  final Map<String, bool> _prayerToggles = {};
  String _selectedVoiceId = 'makkah';
  bool _isTestPlaying = false;
  bool _isTestLoading = false;
  bool _isSettingsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Mirror the audio player state in the UI
    AdhanAudioPlayerService.instance.player.playerStateStream
        .listen(_onPlayerState);
  }

  void _onPlayerState(PlayerState state) {
    if (!mounted) return;
    setState(() {
      _isTestLoading = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      _isTestPlaying = state.playing && !_isTestLoading;
    });
  }

  Future<void> _loadSettings() async {
    final master = await PrayerNotificationService.areNotificationsEnabled();
    final voiceId =
        await AdhanAudioPlayerService.instance.getSelectedVoiceId();
    for (final p in PrayerNotificationService.prayerNames) {
      _prayerToggles[p] =
          await PrayerNotificationService.getPrayerNotificationEnabled(p);
    }
    if (mounted) {
      setState(() {
        _masterEnabled = master;
        _selectedVoiceId = voiceId;
        _isSettingsLoading = false;
      });
    }
  }

  Future<void> _toggleMaster(bool value) async {
    await PrayerNotificationService.setNotificationsEnabled(value);
    setState(() => _masterEnabled = value);

    if (value) {
      final loc = await LocationService.getLocationWithFallback();
      await PrayerNotificationService.schedulePrayerNotifications(
        latitude: loc['latitude']!,
        longitude: loc['longitude']!,
      );
      _showSnack('تم تفعيل إشعارات أوقات الصلاة');
    } else {
      _showSnack('تم إيقاف إشعارات الصلاة');
    }
  }

  Future<void> _togglePrayer(String prayer, bool value) async {
    await PrayerNotificationService.setPrayerNotificationEnabled(prayer, value);
    setState(() => _prayerToggles[prayer] = value);

    if (value && _masterEnabled) {
      final loc = await LocationService.getLocationWithFallback();
      await PrayerNotificationService.schedulePrayerNotifications(
        latitude: loc['latitude']!,
        longitude: loc['longitude']!,
      );
    }
  }

  Future<void> _selectVoice(String voiceId) async {
    await AdhanAudioPlayerService.instance.saveSelectedVoiceId(voiceId);
    setState(() => _selectedVoiceId = voiceId);

    // Stop any playing adhan and preview the new voice
    await AdhanAudioPlayerService.instance.stop();
    await _playTest(voiceId);
  }

  Future<void> _playTest([String? forceVoiceId]) async {
    final id = forceVoiceId ?? _selectedVoiceId;
    try {
      if (_isTestPlaying && forceVoiceId == null) {
        await AdhanAudioPlayerService.instance.stop();
        return;
      }
      await AdhanAudioPlayerService.instance.playAdhan(voiceId: id);
    } catch (_) {
      _showSnack('تعذّر تشغيل الأذان — حاول مرة أخرى');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal')),
        backgroundColor: AppColors.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'إعدادات الأذان',
          style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isSettingsLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMasterToggleCard(),
                verticalSpace(20),
                if (_masterEnabled) ...[
                  _buildSectionHeader('إشعارات الصلوات'),
                  verticalSpace(8),
                  _buildPrayerTogglesCard(),
                  verticalSpace(24),
                ],
                _buildSectionHeader('صوت الأذان'),
                verticalSpace(8),
                _buildVoiceListCard(),
                verticalSpace(16),
                _buildTestButton(),
                verticalSpace(100),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
        fontFamily: 'Tajawal',
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMasterToggleCard() {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _masterEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: AppColors.primaryColor,
                size: 28,
              ),
            ),
            horizontalSpace(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إشعارات أوقات الصلاة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  verticalSpace(2),
                  Text(
                    _masterEnabled
                        ? 'ستصلك إشعارات عند كل أذان'
                        : 'الإشعارات معطّلة حالياً',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          _masterEnabled ? AppColors.primaryColor : Colors.grey,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _masterEnabled,
              onChanged: _toggleMaster,
              activeColor: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTogglesCard() {
    final prayers = PrayerNotificationService.prayerNames;
    return _buildCard(
      child: Column(
        children: prayers.asMap().entries.map((entry) {
          final i = entry.key;
          final prayer = entry.value;
          final enabled = _prayerToggles[prayer] ?? true;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: enabled
                            ? AppColors.primaryColor.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.mosque,
                        size: 18,
                        color: enabled ? AppColors.primaryColor : Colors.grey,
                      ),
                    ),
                    horizontalSpace(12),
                    Expanded(
                      child: Text(
                        prayer,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w600,
                          color: enabled ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ),
                    Switch(
                      value: enabled,
                      onChanged: _masterEnabled
                          ? (v) => _togglePrayer(prayer, v)
                          : null,
                      activeColor: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
              if (i < prayers.length - 1)
                Divider(
                  height: 1,
                  indent: 68,
                  endIndent: 20,
                  color: Colors.grey[200],
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVoiceListCard() {
    final voices = AdhanAudioPlayerService.voices;
    return _buildCard(
      child: Column(
        children: voices.asMap().entries.map((entry) {
          final i = entry.key;
          final voice = entry.value;
          final id = voice['id']!;
          final name = voice['name']!;
          final isSelected = _selectedVoiceId == id;

          return Column(
            children: [
              InkWell(
                onTap: () => _selectVoice(id),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mosque,
                          color: isSelected ? Colors.white : AppColors.primaryColor,
                          size: 20,
                        ),
                      ),
                      horizontalSpace(14),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.black87,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle,
                            color: AppColors.primaryColor, size: 22),
                    ],
                  ),
                ),
              ),
              if (i < voices.length - 1)
                Divider(
                  height: 1,
                  indent: 74,
                  endIndent: 20,
                  color: Colors.grey[200],
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: (_isTestLoading) ? null : () => _playTest(),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isTestPlaying ? Colors.red[600] : AppColors.primaryColor,
          disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        icon: _isTestLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Icon(
                _isTestPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 26,
              ),
        label: Text(
          _isTestLoading
              ? 'جاري التحميل...'
              : (_isTestPlaying ? 'إيقاف الأذان' : 'تجربة الصوت المختار'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
      ),
    );
  }
}
