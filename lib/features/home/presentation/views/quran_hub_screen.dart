import 'package:just_audio/just_audio.dart' as ja;
import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart' as qwt;

import '../../../../core/styles/colors/app_color.dart';
import '../../data/models/surah_model.dart';
import 'surah_detail_screen.dart';

class QuranHubScreen extends StatefulWidget {
  const QuranHubScreen({super.key});

  @override
  State<QuranHubScreen> createState() => _QuranHubScreenState();
}

class _QuranHubScreenState extends State<QuranHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<qwt.SurahMetadata> _surahs = [];
  List<qwt.SurahMetadata> _filtered = [];
  bool _isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSurahs();
    _searchCtrl.addListener(_filter);
  }

  void _loadSurahs() {
    try {
      _surahs = qwt.QuranService.instance.getAllSurahs();
      _filtered = List.from(_surahs);
    } catch (e) {
      debugPrint('Error loading surahs: $e');
    }
    setState(() => _isLoading = false);
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_surahs)
          : _surahs.where((s) {
              return s.nameAr.contains(q) ||
                  s.nameEn.toLowerCase().contains(q) ||
                  s.number.toString() == q;
            }).toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: NestedScrollView(
        headerSliverBuilder: (_, innerScrolled) => [_buildHeader()],
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor))
            : TabBarView(
                controller: _tabController,
                children: [
                  _ReadingTab(surahs: _filtered),
                  _AudioTab(surahs: _filtered),
                  _TafsirTab(surahs: _filtered),
                ],
              ),
      ),
    );
  }

  SliverAppBar _buildHeader() {
    return SliverAppBar(
      expandedHeight: 235,
      pinned: true,
      floating: false,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _HeaderBackground(searchCtrl: _searchCtrl),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: AppColors.primaryColor,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.55),
            labelStyle: const TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'القراءة'),
              Tab(text: 'الاستماع'),
              Tab(text: 'التفسير'),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header background widget ────────────────────────────────────────────────

class _HeaderBackground extends StatelessWidget {
  final TextEditingController searchCtrl;

  const _HeaderBackground({required this.searchCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF206B5E), Color(0xFF164E45)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -40,
            top: -40,
            child: Opacity(
              opacity: 0.07,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 40),
                ),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 60,
            child: Opacity(
              opacity: 0.05,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 30),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'القرآن الكريم',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Tajawal',
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 17,
                      fontFamily: 'Amiri Quran',
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatChip(value: '114', label: 'سورة'),
                      const SizedBox(width: 10),
                      _StatChip(value: '30', label: 'جزء'),
                      const SizedBox(width: 10),
                      _StatChip(value: '6236', label: 'آية'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search bar
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: TextField(
                      controller: searchCtrl,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن سورة...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                      ),
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

class _StatChip extends StatelessWidget {
  final String value;
  final String label;

  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 11,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared surah card ────────────────────────────────────────────────────────

Widget _surahCard({
  required qwt.SurahMetadata surah,
  required VoidCallback onTap,
  Widget? trailing,
  bool isSelected = false,
}) {
  final bool meccan = surah.isMeccan;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    decoration: BoxDecoration(
      color: isSelected ? AppColors.primaryColor.withOpacity(0.06) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: isSelected
          ? Border.all(color: AppColors.primaryColor.withOpacity(0.35), width: 1)
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              // Action icon (left side in RTL = visually left)
              if (trailing != null) ...[
                trailing,
                const SizedBox(width: 10),
              ],

              // Info (expands to fill)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      surah.nameAr,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 19,
                        fontFamily: 'Amiri Quran',
                        color: Color(0xFF1A2221),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          surah.nameEn,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: meccan
                                ? Colors.orange.withOpacity(0.12)
                                : Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            meccan ? 'مكية' : 'مدنية',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w600,
                              color:
                                  meccan ? Colors.orange[800] : Colors.indigo[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${surah.ayahCount} آية',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Number badge (rightmost — visually first in RTL)
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ─── Reading tab ──────────────────────────────────────────────────────────────

class _ReadingTab extends StatelessWidget {
  final List<qwt.SurahMetadata> surahs;

  const _ReadingTab({required this.surahs});

  @override
  Widget build(BuildContext context) {
    if (surahs.isEmpty) return _emptyState('لا توجد نتائج');

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 90),
      itemCount: surahs.length,
      itemBuilder: (context, i) {
        final s = surahs[i];
        return _surahCard(
          surah: s,
          trailing: Icon(
            Icons.menu_book_rounded,
            size: 20,
            color: Colors.grey[400],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahDetailScreen(
                surah: Surah(
                  number: s.number,
                  name: s.nameAr,
                  englishName: s.nameEn,
                  englishNameTranslation: '',
                  numberOfAyahs: s.ayahCount,
                  revelationType: s.revelationType ??
                      (s.isMeccan ? 'Meccan' : 'Medinan'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Audio tab ────────────────────────────────────────────────────────────────

class _AudioTab extends StatefulWidget {
  final List<qwt.SurahMetadata> surahs;

  const _AudioTab({required this.surahs});

  @override
  State<_AudioTab> createState() => _AudioTabState();
}

class _AudioTabState extends State<_AudioTab>
    with AutomaticKeepAliveClientMixin {
  final ja.AudioPlayer _player = ja.AudioPlayer();
  int? _playingSurah;
  String _reciter = 'Alafasy_128kbps';

  static const Map<String, String> _reciters = {
    'Alafasy_128kbps': 'مشاري العفاسي',
    'Abdul_Basit_Mujawwad_128kbps': 'عبدالباسط مجود',
    'Abdurrahmaan_As-Sudais_192kbps': 'عبدالرحمن السديس',
    'Mishari_Alafasy_192kbps': 'مشاري العفاسي HD',
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Rebuild on play/pause and ayah change
    _player.playingStream.listen((_) { if (mounted) setState(() {}); });
    _player.currentIndexStream.listen((_) { if (mounted) setState(() {}); });
    _player.playerStateStream.listen((state) {
      if (state.processingState == ja.ProcessingState.completed && mounted) {
        setState(() { _playingSurah = null; });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  int get _currentAyah => (_player.currentIndex ?? 0) + 1;

  int get _totalAyahs {
    if (_playingSurah == null) return 0;
    try {
      return widget.surahs
          .firstWhere((s) => s.number == _playingSurah!)
          .ayahCount;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _loadAndPlay(int surahNumber) async {
    final meta = widget.surahs.firstWhere((s) => s.number == surahNumber);
    setState(() => _playingSurah = surahNumber);
    try {
      final sources = List.generate(meta.ayahCount, (i) {
        final url = qwt.QuranService.instance.getAudioUrl(
          surahNumber,
          i + 1,
          reciterIdentifier: _reciter,
        );
        return ja.AudioSource.uri(Uri.parse(url));
      });

      await _player.setAudioSource(
        ja.ConcatenatingAudioSource(children: sources),
        initialIndex: 0,
        initialPosition: Duration.zero,
      );
      await _player.play();
    } catch (e) {
      debugPrint('Playlist error: $e');
      if (mounted) {
        setState(() => _playingSurah = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'فشل تشغيل الصوت — تأكد من الاتصال بالإنترنت',
              style: TextStyle(fontFamily: 'Tajawal'),
              textAlign: TextAlign.right,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openAyahPicker(BuildContext context) {
    final total = _totalAyahs;
    if (total == 0) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'اختر آية',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A2221),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: total,
                  itemBuilder: (ctx, i) {
                    final ayah = i + 1;
                    final isCurrent =
                        (_player.currentIndex ?? 0) + 1 == ayah;
                    return GestureDetector(
                      onTap: () {
                        _player.seek(Duration.zero, index: i);
                        if (!_player.playing) _player.play();
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.primaryColor
                              : AppColors.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '$ayah',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: isCurrent
                                  ? Colors.white
                                  : AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggle(int surahNumber) async {
    if (_playingSurah == surahNumber) {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } else {
      await _player.stop();
      await _loadAndPlay(surahNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isPlaying = _player.playing;
    final currentAyah = _currentAyah;
    final totalAyahs = _totalAyahs;

    return Column(
      children: [
        // Reciter selector + now-playing strip
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'القارئ',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF1A2221),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _reciters.entries.map((e) {
                    final selected = _reciter == e.key;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(
                          e.value,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13,
                            color: selected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                        selected: selected,
                        selectedColor: AppColors.primaryColor,
                        backgroundColor: Colors.grey[100],
                        onSelected: (_) async {
                          final wasPlaying = _player.playing;
                          final prev = _playingSurah;
                          await _player.stop();
                          setState(() => _reciter = e.key);
                          if (wasPlaying && prev != null) {
                            await _loadAndPlay(prev);
                          }
                        },
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),

              if (_playingSurah != null) ...[
                const SizedBox(height: 10),
                _NowPlayingBar(
                  surahName: widget.surahs
                      .firstWhere((s) => s.number == _playingSurah,
                          orElse: () => widget.surahs.first)
                      .nameAr,
                  reciterName:
                      '${_reciters[_reciter] ?? ''} • آية $currentAyah / $totalAyahs',
                  isPlaying: isPlaying,
                  onToggle: () => _toggle(_playingSurah!),
                  onPickAyah: () => _openAyahPicker(context),
                ),
              ],
            ],
          ),
        ),

        Expanded(
          child: widget.surahs.isEmpty
              ? _emptyState('لا توجد نتائج')
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 90),
                  itemCount: widget.surahs.length,
                  itemBuilder: (_, i) {
                    final s = widget.surahs[i];
                    final selected = _playingSurah == s.number;
                    final playing = selected && isPlaying;

                    return _surahCard(
                      surah: s,
                      isSelected: selected,
                      trailing: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: playing
                              ? AppColors.primaryColor
                              : AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: playing
                              ? Colors.white
                              : AppColors.primaryColor,
                          size: 22,
                        ),
                      ),
                      onTap: () => _toggle(s.number),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _NowPlayingBar extends StatelessWidget {
  final String surahName;
  final String reciterName;
  final bool isPlaying;
  final VoidCallback onToggle;
  final VoidCallback? onPickAyah;

  const _NowPlayingBar({
    required this.surahName,
    required this.reciterName,
    required this.isPlaying,
    required this.onToggle,
    this.onPickAyah,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF206B5E), Color(0xFF164E45)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onPickAyah,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    surahName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Amiri Quran',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    reciterName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onPickAyah,
            child: Icon(
              Icons.format_list_numbered_rtl,
              color: Colors.white.withOpacity(0.8),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tafsir tab ───────────────────────────────────────────────────────────────

class _TafsirTab extends StatelessWidget {
  final List<qwt.SurahMetadata> surahs;

  const _TafsirTab({required this.surahs});

  @override
  Widget build(BuildContext context) {
    if (surahs.isEmpty) return _emptyState('لا توجد نتائج');

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 90),
      itemCount: surahs.length,
      itemBuilder: (context, i) {
        final s = surahs[i];
        return _surahCard(
          surah: s,
          trailing: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 18,
              color: AppColors.primaryColor,
            ),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _TafsirDetailScreen(surah: s),
            ),
          ),
        );
      },
    );
  }
}

// ─── Tafsir detail screen ─────────────────────────────────────────────────────

class _TafsirDetailScreen extends StatefulWidget {
  final qwt.SurahMetadata surah;

  const _TafsirDetailScreen({required this.surah});

  @override
  State<_TafsirDetailScreen> createState() => _TafsirDetailScreenState();
}

class _TafsirDetailScreenState extends State<_TafsirDetailScreen> {
  bool _isLoading = true;
  qwt.Surah? _data;
  Map<int, String> _tafsir = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    try {
      final svc = qwt.QuranService.instance;
      _data = svc.getSurah(widget.surah.number);
      _tafsir = svc.getTafsir(widget.surah.number);
    } catch (e) {
      debugPrint('Tafsir load error: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.surah.nameAr,
              style: const TextStyle(
                fontFamily: 'Amiri Quran',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'التفسير الميسر',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.surah.ayahCount} آية',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Tajawal',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor))
          : _data == null
              ? _emptyState('تعذّر تحميل التفسير')
              : ListView.builder(
                  padding:
                      const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 90),
                  itemCount: _data!.verses.length,
                  itemBuilder: (_, i) {
                    final v = _data!.verses[i];
                    final t = _tafsir[v.id];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Ayah header
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.06),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // juz / page info
                                Row(
                                  children: [
                                    _InfoBadge('ص ${v.page}'),
                                    const SizedBox(width: 8),
                                    _InfoBadge('ج ${v.juz}'),
                                  ],
                                ),
                                // ayah number
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${v.id}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Arabic verse
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: Text(
                              v.text,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 22,
                                fontFamily: 'Amiri Quran',
                                color: Color(0xFF1A2221),
                                height: 2.1,
                              ),
                            ),
                          ),

                          // Tafsir content
                          if (t != null) ...[
                            Divider(
                              indent: 20,
                              endIndent: 20,
                              color: AppColors.primaryColor.withOpacity(0.15),
                              height: 1,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 12, 20, 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'التفسير',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryColor,
                                          fontFamily: 'Tajawal',
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.auto_stories_rounded,
                                        size: 14,
                                        color: AppColors.primaryColor,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    t,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontFamily: 'Tajawal',
                                      color: Colors.grey[700],
                                      height: 1.9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                              child: Text(
                                'لا يوجد تفسير متاح لهذه الآية',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String text;

  const _InfoBadge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontFamily: 'Tajawal',
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────

Widget _emptyState(String msg) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off_rounded, size: 56, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text(
          msg,
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.grey[500],
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}
