class PodcastModel {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String webUrl;
  final bool isYouTube;

  const PodcastModel({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.webUrl,
    this.isYouTube = false,
  });

  factory PodcastModel.fromYouTube({
    required String videoId,
    required String title,
    required String author,
  }) {
    return PodcastModel(
      id: videoId,
      title: title,
      author: author,
      imageUrl: 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg',
      webUrl: 'https://www.youtube.com/watch?v=$videoId',
      isYouTube: true,
    );
  }

  factory PodcastModel.fromItunesJson(Map<String, dynamic> json) {
    return PodcastModel(
      id: json['collectionId']?.toString() ?? '',
      title: json['collectionName'] ?? json['trackName'] ?? '',
      author: json['artistName'] ?? '',
      imageUrl: json['artworkUrl600'] ?? json['artworkUrl100'] ?? '',
      webUrl: json['collectionViewUrl'] ?? json['trackViewUrl'] ?? '',
    );
  }
}
