import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:yaqeen_app/features/Settings/presentation/views/widgets/allah_names_widget.dart';
import '../../../../core/common/widgets/default_app_bar.dart';
import '../../../../core/utils/spacing.dart';
import '../../data/models/allah_name_model.dart';
import '../../data/repo/all_name_load_data.dart';

class AllahNamesScreen extends StatefulWidget {
  static const String routeName = '/allah-names';
  const AllahNamesScreen({super.key});

  @override
  State<AllahNamesScreen> createState() => _AllahNamesScreenState();
}

class _AllahNamesScreenState extends State<AllahNamesScreen> {
  List<AllahNameModel> allahNames = [];
  bool isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? currentlyPlaying;

  @override
  void initState() {
    super.initState();
    loadAllahNames();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> loadAllahNames() async {
    try {
      final names = await AllNamesLoadData.loadFromAssets();
      setState(() {
        allahNames = names;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load Allah names: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> playSound(String soundFileName) async {
    try {
      if (currentlyPlaying == soundFileName) {
        await _audioPlayer.stop();
        setState(() => currentlyPlaying = null);
        return;
      }
      await _audioPlayer.setAsset('assets/sounds/$soundFileName');
      await _audioPlayer.play();
      setState(() => currentlyPlaying = soundFileName);
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() => currentlyPlaying = null);
        }
      });
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const DefaultAppBar(
                title: 'اسماء الله الحسني',
                icon: Icons.arrow_back,
              ),
              verticalSpace(16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.67,
                        ),
                        itemCount: allahNames.length,
                        itemBuilder: (context, index) {
                          final name = allahNames[index];
                          return AllahNamesWidget(
                            title: name.title,
                            enTitle: name.enTitle,
                            traTitle: name.traTitle,
                            // onTap: () => playSound(name.sound),
                            // icon: currentlyPlayin == name.sound
                            //     ? Icons.pause_circlge_filled
                            //     : Icons.play_arrow_outlined,
                            onTap: () {},
                          );
                        },
                      ),
              ),
              verticalSpace(16),
            ],
          ),
        ),
      ),
    );
  }
}
