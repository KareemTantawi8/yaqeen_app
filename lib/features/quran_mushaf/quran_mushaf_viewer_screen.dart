import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';
import '../../core/extension/context_extension.dart';
import '../../core/styles/colors/app_color.dart';
import 'widgets/ayah_options_sheet.dart';
import 'widgets/ayah_selection_sheet.dart';

class QuranMushafViewerScreen extends StatefulWidget {
  const QuranMushafViewerScreen({super.key});
  static const String routeName = '/quran-mushaf-viewer';

  @override
  State<QuranMushafViewerScreen> createState() =>
      _QuranMushafViewerScreenState();
}

class _QuranMushafViewerScreenState extends State<QuranMushafViewerScreen> {
  static const int _totalPages = 604;

  final PageController _pageController = PageController();
  int _currentPage = 1;
  List<Ayah> _currentPageAyahs = [];
  String _currentSurahName = '';
  int _currentJuz = 1;
  bool _isNightMode = false;
  double _fontSize = 20;

  @override
  void initState() {
    super.initState();
    _updatePageInfo(1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updatePageInfo(int page) {
    try {
      final ayahs = QuranService.instance.getPage(page);
      final surahName = ayahs.isNotEmpty
          ? QuranService.instance.getSurahNameArabic(ayahs.first.surahNumber)
          : '';
      final juz = ayahs.isNotEmpty ? ayahs.first.juz : 1;
      setState(() {
        _currentPage = page;
        _currentPageAyahs = ayahs;
        _currentSurahName = surahName;
        _currentJuz = juz;
      });
    } catch (_) {
      setState(() {
        _currentPage = page;
        _currentPageAyahs = [];
        _currentSurahName = '';
        _currentJuz = 1;
      });
    }
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;
    _pageController.animateToPage(
      page - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _onAyahTap(Ayah ayah) {
    final surahName =
        QuranService.instance.getSurahNameArabic(ayah.surahNumber);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AyahOptionsSheet(ayah: ayah, surahName: surahName),
    );
  }

  void _showAyahList() {
    if (_currentPageAyahs.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AyahSelectionSheet(
        ayahs: _currentPageAyahs,
        pageNumber: _currentPage,
        onAyahSelected: (ayah, surahName) => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AyahOptionsSheet(ayah: ayah, surahName: surahName),
        ),
      ),
    );
  }

  void _showSurahList() {
    final surahs = QuranService.instance.getAllSurahs();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SurahListSheet(
        surahs: surahs,
        currentSurahName: _currentSurahName,
        onSurahSelected: (firstPage) {
          Navigator.pop(context);
          _goToPage(firstPage);
        },
      ),
    );
  }

  void _showPageJumpDialog() {
    final controller = TextEditingController(text: '$_currentPage');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'انتقل إلى صفحة',
          style: TextStyle(
              fontFamily: 'Tajawal',
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          autofocus: true,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 20),
          decoration: InputDecoration(
            hintText: '١ — ٦٠٤',
            hintStyle:
                TextStyle(fontFamily: 'Tajawal', color: context.greyText400),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primaryColor, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء',
                style: TextStyle(
                    color: context.greyText500, fontFamily: 'Tajawal')),
          ),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page >= 1 && page <= _totalPages) {
                Navigator.pop(ctx);
                _goToPage(page);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('اذهب',
                style:
                    TextStyle(color: Colors.white, fontFamily: 'Tajawal')),
          ),
        ],
      ),
    );
  }

  // ── Computed colors based on night mode ──────────────────────────────────
  Color get _bgColor =>
      _isNightMode ? const Color(0xFF121212) : const Color(0xFFF5F7F6);
  Color get _cardColor =>
      _isNightMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get _pageColor =>
      _isNightMode ? const Color(0xFF1A1A0A) : const Color(0xFFFFF8E7);
  Color get _pageBorderColor =>
      _isNightMode ? const Color(0xFF5A4A20) : const Color(0xFFBF8840);
  Color get _textColor =>
      _isNightMode ? const Color(0xFFE8D5A3) : const Color(0xFF1A0A00);
  Color get _labelColor =>
      _isNightMode ? Colors.white70 : AppColors.primaryColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ───────────────────────────────────────────────────
            _buildTopBar(),

            // ── Info strip ───────────────────────────────────────────────
            _buildInfoStrip(),

            // ── Page view + overlaid arrows ───────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  // Mushaf pages
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _totalPages,
                    onPageChanged: (index) => _updatePageInfo(index + 1),
                    itemBuilder: (_, index) {
                      final pageNum = index + 1;
                      final ayahs = QuranService.instance.getPage(pageNum);
                      return _MushafPage(
                        key: ValueKey(pageNum),
                        ayahs: ayahs,
                        pageNumber: pageNum,
                        fontSize: _fontSize,
                        pageColor: _pageColor,
                        borderColor: _pageBorderColor,
                        textColor: _textColor,
                        onAyahTap: _onAyahTap,
                      );
                    },
                  ),

                  // ── Left arrow — التالية (next page, higher number) ──────
                  Positioned(
                    left: 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _OverlayArrow(
                        icon: Icons.chevron_left_rounded,
                        enabled: _currentPage < _totalPages,
                        onTap: () => _goToPage(_currentPage + 1),
                      ),
                    ),
                  ),

                  // ── Right arrow — السابقة (previous page, lower number) ──
                  Positioned(
                    right: 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _OverlayArrow(
                        icon: Icons.chevron_right_rounded,
                        enabled: _currentPage > 1,
                        onTap: () => _goToPage(_currentPage - 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom bar ────────────────────────────────────────────────
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: _cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          _CircleBtn(
            icon: Icons.arrow_forward_ios,
            onTap: () => Navigator.pop(context),
            bgColor: context.lightAccent,
            iconColor: AppColors.primaryColor,
          ),
          Expanded(
            child: Text(
              'المصحف الشريف',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _labelColor,
                fontFamily: 'Tajawal',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _CircleBtn(
            icon: _isNightMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            onTap: () => setState(() => _isNightMode = !_isNightMode),
            bgColor: context.lightAccent,
            iconColor: AppColors.primaryColor,
          ),
          const SizedBox(width: 6),
          _CircleBtn(
            icon: Icons.format_list_bulleted_rounded,
            onTap: _showSurahList,
            bgColor: context.lightAccent,
            iconColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStrip() {
    return Container(
      color: _cardColor,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Font size controls
          Row(
            children: [
              _SmallBtn(
                icon: Icons.text_decrease,
                onTap: () =>
                    setState(() => _fontSize = (_fontSize - 1).clamp(14, 30)),
              ),
              const SizedBox(width: 4),
              _SmallBtn(
                icon: Icons.text_increase,
                onTap: () =>
                    setState(() => _fontSize = (_fontSize + 1).clamp(14, 30)),
              ),
            ],
          ),

          // Surah + juz info
          Column(
            children: [
              Text(
                _currentSurahName.isNotEmpty ? 'سورة $_currentSurahName' : '—',
                style: TextStyle(
                  color: _labelColor,
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'الجزء $_currentJuz',
                style: TextStyle(
                  color: context.greyText500,
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // Page number (tappable)
          GestureDetector(
            onTap: _showPageJumpDialog,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.primaryColor.withAlpha(80)),
              ),
              child: Text(
                '$_currentPage / $_totalPages',
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: _cardColor,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryColor,
              inactiveTrackColor: AppColors.primaryColor.withAlpha(40),
              thumbColor: AppColors.primaryColor,
              overlayColor: AppColors.primaryColor.withAlpha(30),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 7),
              trackHeight: 3,
            ),
            child: Slider(
              value: _currentPage.clamp(1, _totalPages).toDouble(),
              min: 1,
              max: _totalPages.toDouble(),
              onChanged: (v) => _goToPage(v.round().clamp(1, _totalPages)),
            ),
          ),

          // آيات الصفحة button
          GestureDetector(
            onTap: _showAyahList,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withAlpha(80),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.format_list_numbered_rtl,
                      color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'آيات هذه الصفحة',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Tajawal',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overlay Arrow Button ──────────────────────────────────────────────────────

class _OverlayArrow extends StatelessWidget {
  const _OverlayArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 56,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primaryColor.withAlpha(220)
              : Colors.grey.withAlpha(80),
          borderRadius: BorderRadius.circular(10),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withAlpha(100),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 28,
          color: enabled ? Colors.white : Colors.white38,
        ),
      ),
    );
  }
}

// ── Mushaf Page (StatefulWidget for TapGestureRecognizer lifecycle) ───────────

class _MushafPage extends StatefulWidget {
  const _MushafPage({
    super.key,
    required this.ayahs,
    required this.pageNumber,
    required this.fontSize,
    required this.pageColor,
    required this.borderColor,
    required this.textColor,
    required this.onAyahTap,
  });

  final List<Ayah> ayahs;
  final int pageNumber;
  final double fontSize;
  final Color pageColor;
  final Color borderColor;
  final Color textColor;
  final void Function(Ayah) onAyahTap;

  @override
  State<_MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends State<_MushafPage> {
  final Map<String, TapGestureRecognizer> _recognizers = {};

  @override
  void initState() {
    super.initState();
    _rebuildRecognizers();
  }

  @override
  void didUpdateWidget(_MushafPage old) {
    super.didUpdateWidget(old);
    if (old.ayahs != widget.ayahs || old.onAyahTap != widget.onAyahTap) {
      _rebuildRecognizers();
    }
  }

  void _rebuildRecognizers() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    _recognizers.clear();
    for (final ayah in widget.ayahs) {
      final key = '${ayah.surahNumber}:${ayah.id}';
      _recognizers[key] = TapGestureRecognizer()
        ..onTap = () => widget.onAyahTap(ayah);
    }
  }

  @override
  void dispose() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    super.dispose();
  }

  static String _toArabic(int n) {
    const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => d[int.parse(c)]).join();
  }

  @override
  Widget build(BuildContext context) {
    // Group ayahs by surah for headers
    final groups = <_SurahGroup>[];
    for (final ayah in widget.ayahs) {
      if (groups.isEmpty || groups.last.surahNumber != ayah.surahNumber) {
        groups.add(_SurahGroup(surahNumber: ayah.surahNumber, ayahs: []));
      }
      groups.last.ayahs.add(ayah);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: widget.pageColor,
          border: Border.all(color: widget.borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top page number
            _PageEdge(
              number: _toArabic(widget.pageNumber),
              borderColor: widget.borderColor,
            ),

            // Content: surah headers + tappable ayah text
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final group in groups) ...[
                        if (group.ayahs.first.id == 1)
                          _SurahHeader(
                            meta: QuranService.instance
                                .getSurahMetadata(group.surahNumber),
                            borderColor: widget.borderColor,
                            textColor: widget.borderColor,
                          ),
                        // Build RichText with one TapGestureRecognizer per ayah
                        RichText(
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            children: [
                              for (final ayah in group.ayahs)
                                TextSpan(
                                  text:
                                      '${ayah.text} ﴿${_toArabic(ayah.id)}﴾ ',
                                  style: TextStyle(
                                    fontFamily: 'Amiri Quran',
                                    fontSize: widget.fontSize,
                                    color: widget.textColor,
                                    height: 2.3,
                                  ),
                                  recognizer: _recognizers[
                                      '${ayah.surahNumber}:${ayah.id}'],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Bottom page number
            _PageEdge(
              number: _toArabic(widget.pageNumber),
              borderColor: widget.borderColor,
              isBottom: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahGroup {
  final int surahNumber;
  final List<Ayah> ayahs;
  _SurahGroup({required this.surahNumber, required this.ayahs});
}

// ── Shared page chrome ────────────────────────────────────────────────────────

class _PageEdge extends StatelessWidget {
  const _PageEdge({
    required this.number,
    required this.borderColor,
    this.isBottom = false,
  });

  final String number;
  final Color borderColor;
  final bool isBottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: isBottom
            ? Border(top: BorderSide(color: borderColor))
            : Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Text(
        number,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Amiri Quran',
          fontSize: 12,
          color: borderColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({
    required this.meta,
    required this.borderColor,
    required this.textColor,
  });

  final SurahMetadata meta;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final showBismillah = meta.number != 1 && meta.number != 9;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: borderColor.withAlpha(20),
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            meta.nameAr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri Quran',
              fontSize: 22,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showBismillah) ...[
            const SizedBox(height: 4),
            Text(
              'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri Quran',
                fontSize: 16,
                color: textColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Surah List Sheet ──────────────────────────────────────────────────────────

class _SurahListSheet extends StatefulWidget {
  const _SurahListSheet({
    required this.surahs,
    required this.currentSurahName,
    required this.onSurahSelected,
  });

  final List<SurahMetadata> surahs;
  final String currentSurahName;
  final void Function(int firstPage) onSurahSelected;

  @override
  State<_SurahListSheet> createState() => _SurahListSheetState();
}

class _SurahListSheetState extends State<_SurahListSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.surahs
        .where((s) =>
            s.nameAr.contains(_query) ||
            s.nameEn.toLowerCase().contains(_query.toLowerCase()) ||
            '${s.number}'.contains(_query))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.greyText300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: context.greyText500),
                  ),
                  const Text(
                    'فهرس السور',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontFamily: 'Tajawal',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(fontFamily: 'Tajawal'),
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ابحث عن سورة...',
                  hintStyle: TextStyle(
                      fontFamily: 'Tajawal',
                      color: context.greyText400),
                  prefixIcon:
                      Icon(Icons.search, color: context.greyText400),
                  filled: true,
                  fillColor: context.inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            Divider(color: context.dividerColor, height: 1),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: filtered.length,
                separatorBuilder: (context, index) =>
                    Divider(color: context.dividerColor, height: 1),
                itemBuilder: (context, index) {
                  final surah = filtered[index];
                  final isActive =
                      surah.nameAr == widget.currentSurahName;
                  return _SurahListTile(
                    surah: surah,
                    isActive: isActive,
                    onTap: () {
                      try {
                        final verses = QuranService.instance
                            .getSurah(surah.number)
                            .verses;
                        if (verses.isNotEmpty) {
                          widget.onSurahSelected(verses.first.page);
                        }
                      } catch (_) {}
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahListTile extends StatelessWidget {
  const _SurahListTile({
    required this.surah,
    required this.isActive,
    required this.onTap,
  });

  final SurahMetadata surah;
  final bool isActive;
  final VoidCallback onTap;

  static String _toArabic(int n) {
    const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => d[int.parse(c)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isActive ? AppColors.primaryColor.withAlpha(15) : null,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryColor
                    : AppColors.primaryColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _toArabic(surah.number),
                  style: TextStyle(
                    color:
                        isActive ? Colors.white : AppColors.primaryColor,
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    surah.nameAr,
                    style: TextStyle(
                      color: isActive
                          ? AppColors.primaryColor
                          : context.highText,
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية'} — ${_toArabic(surah.ayahCount)} آية',
                    style: TextStyle(
                      color: context.greyText500,
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_left,
              color:
                  isActive ? AppColors.primaryColor : context.greyText400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small Reusable Widgets ────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({
    required this.icon,
    required this.onTap,
    required this.bgColor,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color bgColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  const _SmallBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: context.lightAccent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryColor, size: 18),
      ),
    );
  }
}
