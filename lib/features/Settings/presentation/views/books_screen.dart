import 'package:flutter/material.dart';

class BooksScreen extends StatelessWidget {
  static const String routeName = '/books';
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('كتب')),
      body: const Center(child: Text('شاشة الكتب')),
    );
  }
} 