class HadeethEncCategory {
  final String id;
  final String title;
  final int hadeethsCount;
  final String? parentId;

  const HadeethEncCategory({
    required this.id,
    required this.title,
    required this.hadeethsCount,
    this.parentId,
  });

  factory HadeethEncCategory.fromJson(Map<String, dynamic> json) {
    return HadeethEncCategory(
      id: json['id'].toString(),
      title: (json['title'] as String?) ?? '',
      hadeethsCount: json['hadeeths_count'] is int
          ? json['hadeeths_count'] as int
          : int.tryParse(json['hadeeths_count']?.toString() ?? '0') ?? 0,
      parentId: json['parent_id']?.toString(),
    );
  }
}

class HadeethEncListItem {
  final String id;
  final String title;

  const HadeethEncListItem({required this.id, required this.title});

  factory HadeethEncListItem.fromJson(Map<String, dynamic> json) {
    return HadeethEncListItem(
      id: json['id'].toString(),
      title: (json['title'] as String?) ?? '',
    );
  }
}

class HadeethEncPage {
  final List<HadeethEncListItem> data;
  final int currentPage;
  final int lastPage;
  final int totalItems;

  const HadeethEncPage({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.totalItems,
  });

  bool get hasMore => currentPage < lastPage;

  factory HadeethEncPage.fromJson(Map<String, dynamic> json) {
    final meta = (json['meta'] as Map<String, dynamic>?) ?? {};
    final dataList = (json['data'] as List<dynamic>?) ?? [];
    return HadeethEncPage(
      data: dataList
          .map((e) => HadeethEncListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage:
          int.tryParse(meta['current_page']?.toString() ?? '1') ?? 1,
      lastPage: meta['last_page'] is int
          ? meta['last_page'] as int
          : int.tryParse(meta['last_page']?.toString() ?? '1') ?? 1,
      totalItems: meta['total_items'] is int
          ? meta['total_items'] as int
          : int.tryParse(meta['total_items']?.toString() ?? '0') ?? 0,
    );
  }
}

class HadeethEncHadith {
  final String id;
  final String title;
  final String hadeeth;
  final String hadeethIntro;
  final String explanation;
  final List<String> hints;
  final String grade;
  final String attribution;
  final String reference;

  const HadeethEncHadith({
    required this.id,
    required this.title,
    required this.hadeeth,
    required this.hadeethIntro,
    required this.explanation,
    required this.hints,
    required this.grade,
    required this.attribution,
    required this.reference,
  });

  // Returns the prophetic speech only (text within « »), falling back to full text
  String get matn {
    final start = hadeeth.indexOf('«');
    final end = hadeeth.lastIndexOf('»');
    if (start != -1 && end != -1 && end > start) {
      return hadeeth.substring(start + 1, end).trim();
    }
    return hadeeth;
  }

  factory HadeethEncHadith.fromJson(Map<String, dynamic> json) {
    final rawHints = (json['hints'] as List<dynamic>?) ?? [];
    return HadeethEncHadith(
      id: json['id']?.toString() ?? '',
      title: (json['title'] as String?) ?? '',
      hadeeth: (json['hadeeth'] as String?) ?? '',
      hadeethIntro: (json['hadeeth_intro'] as String?) ?? '',
      explanation: (json['explanation'] as String?) ?? '',
      hints: rawHints.map((e) => e.toString()).toList(),
      grade: (json['grade'] as String?) ?? '',
      attribution: (json['attribution'] as String?) ?? '',
      reference: (json['reference'] as String?) ?? '',
    );
  }
}
