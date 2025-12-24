import 'adhkar_item_model.dart';

class AdhkarCategoryModel {
  final int id;
  final String category;
  final String? audio;
  final String? filename;
  final List<AdhkarItemModel> items;

  AdhkarCategoryModel({
    required this.id,
    required this.category,
    required this.items,
    this.audio,
    this.filename,
  });

  factory AdhkarCategoryModel.fromJson(Map<String, dynamic> json) {
    return AdhkarCategoryModel(
      id: json['id'] as int,
      category: json['category'] as String,
      audio: json['audio'] as String?,
      filename: json['filename'] as String?,
      items: (json['array'] as List<dynamic>?)
              ?.map((item) => AdhkarItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'audio': audio,
      'filename': filename,
      'array': items.map((item) => item.toJson()).toList(),
    };
  }
}

