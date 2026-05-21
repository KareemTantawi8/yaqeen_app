import 'dart:async';
import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:yaqeen_app/core/services/adhan_audio_player_service.dart';

class _Star {
  final double x;
  final double y;
  final double size;
  final double phase;
  _Star(this.x, this.y, this.size, this.phase);
}

class AdhanAlertPopup extends StatefulWidget {
  static const String routeName = '/adhan-alert';

  final String prayerName;

  const AdhanAlertPopup({super.key, required this.prayerName});

  @override
  State<AdhanAlertPopup> createState() => _AdhanAlertPopupState();
}

class _AdhanAlertPopupState extends State<AdhanAlertPopup>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _starCtrl;
  late final AnimationController _ringCtrl;

  bool _isPlaying = false;
  bool _isLoading = false;

  final _service = AdhanAudioPlayerService.instance;
  StreamSubscription? _playerSub;
  StreamSubscription? _clockSub;
  String _timeStr = '';

  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();

    final rng = Random(7);
    _stars = List.generate(25, (_) {
      return _Star(
        rng.nextDouble(),
        rng.nextDouble() * 0.5,
        1.5 + rng.nextDouble() * 2.5,
        rng.nextDouble() * 2 * pi,
      );
    });

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _playerSub = _service.player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isLoading = state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
        _isPlaying = state.playing && !_isLoading;
      });
    });

    // Clock updater
    _timeStr = _formatNow();
    _clockSub = Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) setState(() => _timeStr = _formatNow());
    });

    // Auto-play after entry animation settles
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _toggleAdhan();
    });
  }

  String _formatNow() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _starCtrl.dispose();
    _ringCtrl.dispose();
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

    return PopScope(
      // Stop adhan when user presses the Android back button
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _service.stop();
      },
      child: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1E1B), Color(0xFF112E29), Color(0xFF1A5C50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Twinkling stars ──────────────────────────────────────────
            AnimatedBuilder(
              animation: _starCtrl,
              builder: (context0, child0) {
                return CustomPaint(
                  size: size,
                  painter: _StarPainter(_stars, _starCtrl.value),
                );
              },
            ),

            // ── Expanding rings behind mosque ────────────────────────────
            Align(
              alignment: const Alignment(0, -0.15),
              child: AnimatedBuilder(
                animation: _ringCtrl,
                builder: (ctx, child) => CustomPaint(
                  size: const Size(260, 260),
                  painter: _RingPainter(_ringCtrl.value),
                ),
              ),
            ),

            // ── Main content ─────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: IconButton(
                        onPressed: _close,
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white70, size: 22),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Mosque icon with pulsing glow
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: _buildMosqueIcon(),
                  ),

                  const SizedBox(height: 36),

                  // "حان وقت صلاة"
                  FadeIn(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'حان وقت صلاة',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 20,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Prayer name – large, glowing
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 300),
                    child: AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (ctx2, child) {
                        final glow = 15 + 10 * sin(_pulseCtrl.value * 2 * pi);
                        return Text(
                          widget.prayerName,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: glow,
                                color: const Color(0xFF4ECDC4),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // "الله أكبر"
                  FadeIn(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 500),
                    child: const Text(
                      'الله أكبر',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Color(0xFF4ECDC4),
                        fontSize: 26,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Play / Stop button
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 600),
                    child: _buildPlayButton(),
                  ),

                  const SizedBox(height: 20),

                  // Current time
                  Text(
                    _timeStr,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 3,
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMosqueIcon() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (ctx, child) {
        final scale = 1.0 + 0.06 * sin(_pulseCtrl.value * 2 * pi);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(
                color: const Color(0xFF4ECDC4).withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4ECDC4)
                      .withOpacity(0.15 + 0.1 * sin(_pulseCtrl.value * 2 * pi)),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.mosque_rounded,
              color: Color(0xFF4ECDC4),
              size: 44,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayButton() {
    final isActive = _isPlaying;
    return GestureDetector(
      onTap: _isLoading ? null : _toggleAdhan,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [const Color(0xFFE53935), const Color(0xFFB71C1C)]
                : [const Color(0xFF26A69A), const Color(0xFF1A8F85)],
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: (isActive ? Colors.red : const Color(0xFF26A69A))
                  .withOpacity(0.4),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            else
              Icon(
                isActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
            const SizedBox(width: 12),
            Text(
              _isLoading
                  ? 'جاري التحميل...'
                  : (isActive ? 'إيقاف الأذان' : 'استمع للأذان'),
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom painters ──────────────────────────────────────────────────────────

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;

  _StarPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final opacity = (0.35 + 0.65 * ((sin(t * 2 * pi + s.phase) + 1) / 2))
          .clamp(0.1, 1.0);
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.t != t;
}

class _RingPainter extends CustomPainter {
  final double t;

  _RingPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const maxRadius = 130.0;

    for (int i = 0; i < 3; i++) {
      final progress = ((t + i / 3) % 1.0);
      final radius = progress * maxRadius;
      final opacity = (1.0 - progress) * 0.18;

      final paint = Paint()
        ..color = const Color(0xFF4ECDC4).withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.t != t;
}
