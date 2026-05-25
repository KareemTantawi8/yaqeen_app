import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';
import '../../../core/extension/context_extension.dart';
import '../../../core/styles/colors/app_color.dart';

class AyahOptionsSheet extends StatefulWidget {
  const AyahOptionsSheet({
    super.key,
    required this.ayah,
    required this.surahName,
  });

  final Ayah ayah;
  final String surahName;

  @override
  State<AyahOptionsSheet> createState() => _AyahOptionsSheetState();
}

class _AyahOptionsSheetState extends State<AyahOptionsSheet> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  bool _showTafsir = false;
  bool _copied = false;
  String? _tafsirText;

  @override
  void initState() {
    super.initState();
    final tafsirMap = QuranService.instance.getTafsir(widget.ayah.surahNumber);
    _tafsirText = tafsirMap[widget.ayah.id];

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    if (mounted) setState(() => _isLoadingAudio = true);
    try {
      final audioUrl = QuranService.instance.getAudioUrl(
        widget.ayah.surahNumber,
        widget.ayah.id,
      );
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
      if (mounted) setState(() { _isPlaying = true; _isLoadingAudio = false; });
    } catch (_) {
      if (mounted) {
        setState(() { _isLoadingAudio = false; _isPlaying = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر تشغيل الصوت', style: TextStyle(fontFamily: 'Tajawal')),
          ),
        );
      }
    }
  }

  void _copyAyah() {
    Clipboard.setData(ClipboardData(text: widget.ayah.text));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.greyText300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'سورة ${widget.surahName} — الآية ${widget.ayah.id}',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: context.greyText500),
                  ),
                ],
              ),
            ),

            Divider(color: context.dividerColor),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ayah text box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        widget.ayah.text,
                        style: TextStyle(
                          fontFamily: 'Amiri Quran',
                          fontSize: 22,
                          color: context.highText,
                          height: 2.0,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action row: Audio + Copy
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            onTap: _toggleAudio,
                            icon: _isLoadingAudio
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    _isPlaying
                                        ? Icons.stop_rounded
                                        : Icons.volume_up_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                            label: _isPlaying ? 'إيقاف' : 'استمع',
                            bgColor: AppColors.primaryColor,
                            labelColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            onTap: _copyAyah,
                            icon: Icon(
                              _copied ? Icons.check_rounded : Icons.copy_rounded,
                              color: AppColors.primaryColor,
                              size: 22,
                            ),
                            label: _copied ? 'تم النسخ' : 'نسخ',
                            bgColor: AppColors.primaryColor.withOpacity(0.1),
                            labelColor: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    // Tafsir section
                    if (_tafsirText != null && _tafsirText!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => setState(() => _showTafsir = !_showTafsir),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: context.lightAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.menu_book_outlined,
                                    color: AppColors.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'التفسير',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontFamily: 'Tajawal',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                _showTafsir ? Icons.expand_less : Icons.expand_more,
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showTafsir) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.dividerColor),
                          ),
                          child: Text(
                            _tafsirText!,
                            style: TextStyle(
                              color: context.highText,
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              height: 1.8,
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ],
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.labelColor,
  });

  final VoidCallback onTap;
  final Widget icon;
  final String label;
  final Color bgColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontFamily: 'Tajawal',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
