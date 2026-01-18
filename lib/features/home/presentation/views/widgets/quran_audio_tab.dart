import 'package:flutter/material.dart';
import 'full_surah_player_screen.dart';

/// Secondary Tab: Audio Recitation
/// Features: Audio playback, Reciter selection, Playlist management
/// 
/// Note: This reuses FullSurahPlayerScreen content but renders it within the tab context
class QuranAudioTab extends StatefulWidget {
  const QuranAudioTab({super.key});

  @override
  State<QuranAudioTab> createState() => _QuranAudioTabState();
}

class _QuranAudioTabState extends State<QuranAudioTab>
    with SingleTickerProviderStateMixin {
  // Reuse the existing FullSurahPlayerScreen logic
  // For now, we'll extract just the content part
  // In a production app, you'd want to refactor FullSurahPlayerScreen
  // to separate the Scaffold from the content
  
  @override
  Widget build(BuildContext context) {
    // Using FullSurahPlayerScreen content as-is
    // It will work but may have some styling quirks due to nested Scaffolds
    // For now, this maintains functionality while we can refactor later
    return const FullSurahPlayerScreen();
  }
}
