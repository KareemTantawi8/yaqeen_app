import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../../../../core/common/widgets/launch_utils.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../data/models/podcast_model.dart';
import '../../../data/repo/podcast_service.dart';

class CustomCarousalWidget extends StatefulWidget {
  const CustomCarousalWidget({super.key});

  @override
  State<CustomCarousalWidget> createState() => _CustomCarousalWidgetState();
}

class _CustomCarousalWidgetState extends State<CustomCarousalWidget> {
  List<PodcastModel> _videos = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await PodcastService.fetchIslamicPodcasts();
    if (mounted) setState(() { _videos = data; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 4),
          child: Text(
            'بودكاستات إسلامية',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 22,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        verticalSpace(10),
        if (_isLoading)
          _Skeleton()
        else
          _Carousel(videos: _videos, onIndexChanged: (i) => setState(() => _currentIndex = i)),
        verticalSpace(10),
        if (!_isLoading && _videos.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_videos.length, (i) {
              final active = i == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: active ? 20 : 6,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primaryColor
                      : AppColors.primaryColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
      ],
    );
  }
}

class _Carousel extends StatelessWidget {
  final List<PodcastModel> videos;
  final ValueChanged<int> onIndexChanged;
  const _Carousel({required this.videos, required this.onIndexChanged});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 190,
        enlargeCenterPage: true,
        enlargeFactor: 0.15,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayCurve: Curves.easeInOutCubic,
        viewportFraction: 0.88,
        reverse: true,
        onPageChanged: (i, _) => onIndexChanged(i),
      ),
      items: videos.map((v) => _VideoCard(video: v)).toList(),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final PodcastModel video;
  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchExternalUrl(video.webUrl, context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Thumbnail ─────────────────────────────────────────
              Image.network(
                video.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF1B4B43),
                  child: const Icon(Icons.play_circle_fill,
                      size: 60, color: Colors.white24),
                ),
              ),

              // ── Dark gradient overlay ──────────────────────────────
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 1.0],
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.82),
                    ],
                  ),
                ),
              ),

              // ── YouTube badge (top-left) ───────────────────────────
              if (video.isYouTube)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.play_arrow, color: Colors.white, size: 14),
                        SizedBox(width: 3),
                        Text(
                          'YouTube',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Centered play button ───────────────────────────────
              Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.92),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 36,
                    color: Color(0xFF175A4F),
                  ),
                ),
              ),

              // ── Title + author at bottom ───────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        video.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Tajawal',
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        video.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.82),
                          fontSize: 11,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
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

class _Skeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
