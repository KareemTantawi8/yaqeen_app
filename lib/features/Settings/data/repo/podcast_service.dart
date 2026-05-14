import 'package:flutter/foundation.dart';
import '../models/podcast_model.dart';

class PodcastService {
  // Curated Arabic Islamic YouTube videos — verified via YouTube oEmbed API.
  // Thumbnails: https://i.ytimg.com/vi/{id}/hqdefault.jpg (no API key needed)
  // Opens in YouTube app when tapped.
  static final List<PodcastModel> _arabicVideos = [
    // ── مشاري راشد العفاسي ───────────────────────────────────────────
    PodcastModel.fromYouTube(
      videoId: 'MPofPHAklTQ',
      title: 'القرآن الكريم كاملاً - مشاري العفاسي',
      author: 'مشاري راشد العفاسي',
    ),
    PodcastModel.fromYouTube(
      videoId: '_qxDdRiBKV8',
      title: 'تلاوة رائعة - خشوع ينسيك هموم الدنيا',
      author: 'مشاري راشد العفاسي',
    ),
    // ── خالد الراشد ──────────────────────────────────────────────────
    PodcastModel.fromYouTube(
      videoId: 'DUtwKLzdeu4',
      title: 'أروع محاضرة تسمعها عن الصلاة',
      author: 'خالد الراشد',
    ),
    PodcastModel.fromYouTube(
      videoId: 'cpBpXliBEeI',
      title: 'الذي يراك حين تقوم',
      author: 'خالد الراشد',
    ),
    PodcastModel.fromYouTube(
      videoId: 'AhOmyThighw',
      title: 'قوافل العائدين',
      author: 'خالد الراشد',
    ),
    // ── نبيل العوضي ──────────────────────────────────────────────────
    PodcastModel.fromYouTube(
      videoId: 'Ivjz33krNvo',
      title: 'هدية السماء إلى الأرض',
      author: 'نبيل العوضي',
    ),
    PodcastModel.fromYouTube(
      videoId: 'docyV_3Ufq4',
      title: 'محاضرة مؤثرة - كاملة',
      author: 'نبيل العوضي',
    ),
    // ── مصطفى حسني ───────────────────────────────────────────────────
    PodcastModel.fromYouTube(
      videoId: 'C6hZejBfjhw',
      title: 'حصن التسليم لأقدار الله',
      author: 'مصطفى حسني',
    ),
    // ── محمد العريفي ──────────────────────────────────────────────────
    PodcastModel.fromYouTube(
      videoId: 'gJGoQJRvrPk',
      title: 'فابتغوا عند الله الرزق',
      author: 'محمد العريفي',
    ),
    PodcastModel.fromYouTube(
      videoId: 'sfcmdhlGubo',
      title: 'الإخلاص لله',
      author: 'محمد العريفي',
    ),
    // ── عمر عبد الكافي ───────────────────────────────────────────────
    PodcastModel.fromYouTube(
      videoId: 'cufPDdi2fMA',
      title: 'ماذا يحدث لتارك السنة؟',
      author: 'عمر عبد الكافي',
    ),
    PodcastModel.fromYouTube(
      videoId: 'cMz6CsfBkH4',
      title: 'أسئلة في الدين',
      author: 'عمر عبد الكافي',
    ),
  ];

  static Future<List<PodcastModel>> fetchIslamicPodcasts() async {
    debugPrint('PodcastService: returning ${_arabicVideos.length} curated Arabic Islamic videos');
    return _arabicVideos;
  }
}
