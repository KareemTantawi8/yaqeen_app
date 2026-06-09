import 'package:flutter/material.dart';
import 'hadith_model.dart';

class HadithTopic {
  final String name;
  final IconData icon;
  final Color color;
  final List<HadithModel> hadiths;

  const HadithTopic({
    required this.name,
    required this.icon,
    required this.color,
    required this.hadiths,
  });

  int get count => hadiths.length;
}
