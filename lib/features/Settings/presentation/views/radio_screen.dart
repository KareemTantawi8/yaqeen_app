import 'package:flutter/material.dart';

class RadioScreen extends StatelessWidget {
  static const String routeName = '/radio';
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الراديو')),
      body: const Center(child: Text('شاشة الراديو')),
    );
  }
} 