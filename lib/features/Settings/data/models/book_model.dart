class BookModel {
  final int id;
  final int sourceId;
  final String title;
  final String description;
  final String? fullDescription;
  final String type;
  final String? image;
  final List<BookAttachment> attachments;
  final List<BookAuthor> authors;
  final String? apiUrl;

  BookModel({
    required this.id,
    required this.sourceId,
    required this.title,
    required this.description,
    this.fullDescription,
    required this.type,
    this.image,
    required this.attachments,
    required this.authors,
    this.apiUrl,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] ?? 0,
      sourceId: json['source_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fullDescription: json['full_description'],
      type: json['type'] ?? '',
      image: json['image'],
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((e) => BookAttachment.fromJson(e))
              .toList()
          : [],
      authors: json['prepared_by'] != null
          ? (json['prepared_by'] as List)
              .map((e) => BookAuthor.fromJson(e))
              .toList()
          : [],
      apiUrl: json['api_url'],
    );
  }

  // Get the first PDF attachment URL, or null if none exists
  String? get pdfUrl {
    if (attachments.isEmpty) return null;
    
    try {
      final pdfAttachment = attachments.firstWhere(
        (attachment) => attachment.extensionType == 'PDF',
      );
      return pdfAttachment.url.isNotEmpty ? pdfAttachment.url : null;
    } catch (e) {
      // No PDF found, try to get first attachment
      final firstAttachment = attachments.first;
      return firstAttachment.url.isNotEmpty ? firstAttachment.url : null;
    }
  }

  bool get hasUrl => pdfUrl != null;
}

class BookAttachment {
  final int order;
  final String size;
  final String extensionType;
  final String description;
  final String url;

  BookAttachment({
    required this.order,
    required this.size,
    required this.extensionType,
    required this.description,
    required this.url,
  });

  factory BookAttachment.fromJson(Map<String, dynamic> json) {
    return BookAttachment(
      order: json['order'] ?? 0,
      size: json['size'] ?? '',
      extensionType: json['extension_type'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
    );
  }

  static BookAttachment empty() {
    return BookAttachment(
      order: 0,
      size: '',
      extensionType: '',
      description: '',
      url: '',
    );
  }
}

class BookAuthor {
  final int id;
  final int sourceId;
  final String title;
  final String type;
  final String? description;
  final String? apiUrl;

  BookAuthor({
    required this.id,
    required this.sourceId,
    required this.title,
    required this.type,
    this.description,
    this.apiUrl,
  });

  factory BookAuthor.fromJson(Map<String, dynamic> json) {
    return BookAuthor(
      id: json['id'] ?? 0,
      sourceId: json['source_id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      description: json['description'],
      apiUrl: json['api_url'],
    );
  }
}

class BooksResponse {
  final List<BookModel> books;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNext;
  final bool hasPrev;

  BooksResponse({
    required this.books,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasNext,
    required this.hasPrev,
  });

  factory BooksResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List?;
    final links = json['links'] as Map<String, dynamic>?;

    return BooksResponse(
      books: data != null
          ? data.map((e) => BookModel.fromJson(e)).toList()
          : [],
      currentPage: links?['current_page'] ?? 1,
      totalPages: links?['pages_number'] ?? 1,
      totalItems: links?['total_items'] ?? 0,
      hasNext: links?['next'] != null && (links?['next'] as String).isNotEmpty,
      hasPrev: links?['prev'] != null && (links?['prev'] as String).isNotEmpty,
    );
  }
}

