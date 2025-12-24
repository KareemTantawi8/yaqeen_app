import 'package:flutter/material.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../data/models/reciter_model.dart';
import '../../../data/models/surah_model.dart';
import '../../../data/repo/quran_data_loader.dart';
import 'surah_audio_player_screen.dart';

class ReciterSurahsScreen extends StatefulWidget {
  final Reciter reciter;

  const ReciterSurahsScreen({super.key, required this.reciter});

  @override
  State<ReciterSurahsScreen> createState() => _ReciterSurahsScreenState();
}

class _ReciterSurahsScreenState extends State<ReciterSurahsScreen> {
  List<Surah> _surahs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    try {
      final surahs = await QuranDataLoader.loadSurahs();
      if (mounted) {
        setState(() {
          _surahs = surahs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading surahs: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: screenHeight * 0.25,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'reciter_${widget.reciter.identifier}',
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.85),
                        const Color(0xFF1A5F54),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      
                      // Content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            verticalSpace(screenHeight * 0.05),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                            verticalSpace(16),
                            Text(
                              widget.reciter.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            verticalSpace(4),
                            Text(
                              widget.reciter.englishName,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.05,
                screenHeight * 0.03,
                screenWidth * 0.05,
                screenHeight * 0.02,
              ),
              child: Row(
                children: [
                  Container(
                    width: screenWidth * 0.01,
                    height: screenHeight * 0.03,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  horizontalSpace(screenWidth * 0.03),
                  Text(
                    'السور القرآنية',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A2221),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    ),
                    child: Text(
                      '${_surahs.length} سورة',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading or Surahs List
          if (_isLoading)
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final surah = _surahs[index];
                    return _buildSurahCard(context, surah, index);
                  },
                  childCount: _surahs.length,
                ),
              ),
            ),

          SliverToBoxAdapter(child: verticalSpace(screenHeight * 0.025)),
        ],
      ),
    );
  }

  Widget _buildSurahCard(BuildContext context, Surah surah, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: screenWidth * 0.02,
            offset: Offset(0, screenHeight * 0.0025),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahAudioPlayerScreen(
                  reciter: widget.reciter,
                  surah: surah,
                  allSurahs: _surahs,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              children: [
                // Number Badge
                Container(
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  child: Center(
                    child: Text(
                      '${surah.number}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                horizontalSpace(screenWidth * 0.04),
                
                // Surah Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        surah.englishName,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A2221),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      verticalSpace(screenHeight * 0.005),
                      Row(
                        children: [
                          Icon(
                            surah.type == 'Meccan' 
                                ? Icons.location_on_outlined 
                                : Icons.location_city_outlined,
                            size: screenWidth * 0.035,
                            color: Colors.grey[600],
                          ),
                          horizontalSpace(screenWidth * 0.01),
                          Flexible(
                            child: Text(
                              '${surah.type} • ${surah.numberOfAyahs} آيات',
                              style: TextStyle(
                                fontSize: screenWidth * 0.0325,
                                fontFamily: 'Tajawal',
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arabic name and play icon
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      surah.name,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontFamily: 'Amiri Quran',
                        color: const Color(0xFF2B7669),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    verticalSpace(screenHeight * 0.005),
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.015),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: AppColors.primaryColor,
                        size: screenWidth * 0.05,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

