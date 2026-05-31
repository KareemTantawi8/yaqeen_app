import 'dart:async';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:yaqeen_app/core/services/adhan_audio_player_service.dart';
import 'package:yaqeen_app/core/styles/colors/app_color.dart';
import 'package:yaqeen_app/core/styles/fonts/font_family_helper.dart';
import 'package:yaqeen_app/core/styles/fonts/font_styles.dart';
import 'package:yaqeen_app/core/utils/spacing.dart';

class AdhanAlertPopup extends StatefulWidget {
  static const String routeName = '/adhan-alert';
  final String prayerName;
  const AdhanAlertPopup({super.key, required this.prayerName});

  @override
  State<AdhanAlertPopup> createState() => _AdhanAlertPopupState();
}

class _AdhanAlertPopupState extends State<AdhanAlertPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  static const Color _deepGreen = Color(0xFF0C2F2A);
  static const Color _mint = Color(0xFFEAF9F4);
  static const Color _gold = Color(0xFFF4D27A);
  static const Color _surface = Color(0xFFF8FFFC);

  bool _isPlaying = false;
  bool _isLoading = false;

  final _service = AdhanAudioPlayerService.instance;
  StreamSubscription? _playerSub;
  StreamSubscription? _clockSub;
  String _timeStr = '';

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _playerSub = _service.player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isLoading =
            state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
        _isPlaying = state.playing && !_isLoading;
      });
    });

    _timeStr = _formatNow();
    _clockSub = Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) setState(() => _timeStr = _formatNow());
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _toggleAdhan();
    });
  }

  String _formatNow() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h : $m';
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _playerSub?.cancel();
    _clockSub?.cancel();
    super.dispose();
  }

  Future<void> _toggleAdhan() async {
    if (_isLoading) return;
    try {
      if (_isPlaying) {
        await _service.stop();
      } else {
        await _service.playAdhan();
      }
    } catch (e) {
      debugPrint('AdhanAlertPopup: $e');
    }
  }

  Future<void> _close() async {
    await _service.stop();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final prayerName = widget.prayerName.trim().isEmpty
        ? 'الأذان'
        : widget.prayerName.trim();

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _service.stop();
      },
      child: Container(
        width: size.width,
        height: size.height,
        color: _deepGreen,
        child: Stack(
          children: [
            const Positioned.fill(child: _PremiumBackground()),
            Positioned(
              top: -120,
              right: -105,
              child: _GlowOrb(size: 280, color: _gold.withValues(alpha: 0.12)),
            ),
            Positioned(
              bottom: 210,
              left: -130,
              child: _GlowOrb(size: 310, color: _mint.withValues(alpha: 0.12)),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                child: Column(
                  children: [
                    FadeIn(
                      duration: const Duration(milliseconds: 500),
                      child: _buildTopBar(),
                    ),
                    Expanded(
                      child: Center(
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 650),
                          child: _buildHeroContent(prayerName),
                        ),
                      ),
                    ),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 650),
                      child: _buildActionPanel(prayerName),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ClockPill(time: _timeStr),
        GestureDetector(
          onTap: _close,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroContent(String prayerName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMosqueEmblem(),
        verticalSpace(34),
        Text(
          'حان وقت صلاة',
          textDirection: TextDirection.rtl,
          style: TextStyles.font18WhiteText.copyWith(
            color: Colors.white.withValues(alpha: 0.76),
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        verticalSpace(8),
        Text(
          prayerName,
          textDirection: TextDirection.rtl,
          style: TextStyles.font48WhiteText.copyWith(
            fontSize: 72,
            height: 1,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.none,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
        verticalSpace(18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Text(
            'الله أكبر',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: _gold,
              fontSize: 28,
              height: 1.15,
              fontFamily: FontFamilyHelper.fontFamily2,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMosqueEmblem() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, child) {
        final scale = 1.0 + 0.02 * sin(_pulseCtrl.value * 2 * pi);
        return Transform.scale(scale: scale, child: child);
      },
      child: SizedBox(
        width: 178,
        height: 178,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 178,
              height: 178,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            Container(
              width: 142,
              height: 142,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                  width: 1.2,
                ),
              ),
            ),
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mosque_rounded,
                color: AppColors.primaryColor,
                size: 58,
              ),
            ),
            Positioned(
              top: 34,
              right: 42,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: _gold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.nightlight_round,
                  color: _deepGreen,
                  size: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPanel(String prayerName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _isPlaying
                      ? Icons.volume_up_rounded
                      : Icons.notifications_active_rounded,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
              horizontalSpace(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPlaying ? 'الأذان يعمل الآن' : 'تنبيه وقت الصلاة',
                      textDirection: TextDirection.rtl,
                      style: TextStyles.font16PrimaryText.copyWith(
                        color: _deepGreen,
                        fontFamily: FontFamilyHelper.fontFamily1,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    verticalSpace(3),
                    Text(
                      prayerName,
                      textDirection: TextDirection.rtl,
                      style: TextStyles.font14WhiteText.copyWith(
                        color: AppColors.thinText.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(18),
          _buildPlayButton(),
          verticalSpace(10),
          GestureDetector(
            onTap: _close,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'إغلاق',
                style: TextStyle(
                  color: AppColors.thinText.withValues(alpha: 0.72),
                  fontSize: 15,
                  fontFamily: FontFamilyHelper.fontFamily1,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    final isStop = _isPlaying;
    final gradient = isStop
        ? [const Color(0xFFE85A5A), const Color(0xFFC62828)]
        : [AppColors.primaryColor, const Color(0xFF329A88)];
    const contentColor = Colors.white;

    return GestureDetector(
      onTap: _isLoading ? null : _toggleAdhan,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isStop ? Colors.red : AppColors.primaryColor).withValues(
                alpha: 0.28,
              ),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: contentColor,
                  strokeWidth: 2.5,
                ),
              )
            else
              Icon(
                isStop ? Icons.stop_rounded : Icons.play_arrow_rounded,
                color: contentColor,
                size: 28,
              ),
            horizontalSpace(10),
            Text(
              _isLoading
                  ? 'جاري التحميل...'
                  : (isStop ? 'إيقاف الأذان' : 'استمع للأذان'),
              textDirection: TextDirection.rtl,
              style: TextStyles.font16PrimaryText.copyWith(
                color: contentColor,
                fontFamily: FontFamilyHelper.fontFamily1,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClockPill extends StatelessWidget {
  final String time;
  const _ClockPill({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Text(
        time,
        style: TextStyles.font14WhiteText.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _PremiumBackground extends StatelessWidget {
  const _PremiumBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF061A17), Color(0xFF145246), Color(0xFF2F9A87)],
              stops: [0.0, 0.58, 1.0],
            ),
          ),
          child: SizedBox.expand(),
        ),
        Positioned.fill(
          child: CustomPaint(painter: _BackgroundPatternPainter()),
        ),
      ],
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  const _BackgroundPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white.withValues(alpha: 0.055);

    for (var i = 0; i < 7; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.50, size.height * 0.39),
        120.0 + i * 34,
        paint,
      );
    }

    final cornerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.035);

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.12),
      5,
      cornerPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.83, size.height * 0.24),
      3.5,
      cornerPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.76, size.height * 0.63),
      4,
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
