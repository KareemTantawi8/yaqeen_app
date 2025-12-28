import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/styles/colors/app_color.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../data/models/reciter_model.dart';
import '../../../data/models/surah_model.dart';
import '../../../data/repo/quran_data_loader.dart';
import 'quran_reader_screen.dart';

class QuranByReciterTab extends StatefulWidget {
  const QuranByReciterTab({super.key});

  @override
  State<QuranByReciterTab> createState() => _QuranByReciterTabState();
}

class _QuranByReciterTabState extends State<QuranByReciterTab> {
  Reciter? _selectedReciter;
  List<Surah> _surahs = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSelectedReciter();
    _loadSurahs();
  }

  Future<void> _loadSelectedReciter() async {
    final prefs = await SharedPreferences.getInstance();
    final reciterIdentifier = prefs.getString('selected_reader_reciter') ?? 'ar.alafasy';
    setState(() {
      _selectedReciter = RecitersList.popular.firstWhere(
        (r) => r.identifier == reciterIdentifier,
        orElse: () => RecitersList.popular.first,
      );
    });
  }

  Future<void> _saveSelectedReciter(Reciter reciter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_reader_reciter', reciter.identifier);
  }

  Future<void> _loadSurahs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final surahs = await QuranDataLoader.loadSurahs();
      if (mounted) {
        setState(() {
          _surahs = surahs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showReciterSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor.withOpacity(0.8),
                          AppColors.primaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  horizontalSpace(12),
                  const Expanded(
                    child: Text(
                      'اختر القارئ المفضل',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.grey,
                  ),
                ],
              ),
              verticalSpace(16),
              const Divider(),
              verticalSpace(8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: RecitersList.popular.length,
                  itemBuilder: (context, index) {
                    final reciter = RecitersList.popular[index];
                    final isSelected = _selectedReciter?.identifier == reciter.identifier;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected 
                            ? AppColors.primaryColor.withAlpha(25)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.primaryColor
                              : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            _selectedReciter = reciter;
                          });
                          _saveSelectedReciter(reciter);
                          Navigator.pop(context);
                        },
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isSelected
                                  ? [
                                      AppColors.primaryColor,
                                      AppColors.primaryColor.withAlpha(178),
                                    ]
                                  : [
                                      Colors.grey.shade300,
                                      Colors.grey.shade400,
                                    ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSelected ? Icons.check_circle : Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          reciter.name,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primaryColor : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          reciter.englishName,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: AppColors.primaryColor,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
            verticalSpace(16),
            const Text(
              'جاري تحميل السور...',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            verticalSpace(16),
            Text(
              'حدث خطأ في التحميل',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                color: Colors.red[700],
              ),
            ),
            verticalSpace(8),
            ElevatedButton.icon(
              onPressed: _loadSurahs,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Reciter Selection Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withAlpha(204),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withAlpha(76),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showReciterSelectionDialog,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    horizontalSpace(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'القارئ الحالي',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          verticalSpace(4),
                          Text(
                            _selectedReciter?.name ?? 'اختر القارئ',
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (_selectedReciter != null)
                            Text(
                              _selectedReciter!.englishName,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        verticalSpace(8),
        
        // Surahs List
        Expanded(
          child: _surahs.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد سور متاحة',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSurahs,
                  color: AppColors.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _surahs.length,
                    itemBuilder: (context, index) {
                      final surah = _surahs[index];
                      return _buildSurahCard(surah);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSurahCard(Surah surah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_selectedReciter != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuranReaderScreen(
                    surah: surah,
                    reciter: _selectedReciter!,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.white),
                      horizontalSpace(8),
                      const Text(
                        'الرجاء اختيار قارئ أولاً',
                        style: TextStyle(fontFamily: 'Tajawal'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Surah Number Badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withAlpha(178),
                  ],
                ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      surah.number.toString(),
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                horizontalSpace(16),
                
                // Surah Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.name,
                        style: const TextStyle(
                          fontFamily: 'Amiri Quran',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      verticalSpace(4),
                      Row(
                        children: [
                          Icon(
                            surah.revelationType == 'Meccan'
                                ? Icons.mosque
                                : Icons.location_city,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          horizontalSpace(4),
                          Text(
                            surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          horizontalSpace(12),
                          Icon(
                            Icons.notes,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          horizontalSpace(4),
                          Text(
                            '${surah.numberOfAyahs} آية',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Play Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.headphones,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

