import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/styles/colors/app_color.dart';
import '../../../../core/utils/spacing.dart';

class MesphaScreen extends StatefulWidget {
  static const String routeName = '/mespha';
  const MesphaScreen({super.key});

  @override
  State<MesphaScreen> createState() => _MesphaScreenState();
}

class _MesphaScreenState extends State<MesphaScreen>
    with TickerProviderStateMixin {
  int _count = 0;
  int _totalCount = 0;
  int _targetCount = 33;
  int _completedSets = 0;
  int _todayCount = 0;
  int _streak = 0;
  bool _soundEnabled = true;
  
  late AnimationController _beadController;
  late AnimationController _particleController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, dynamic>> _dhikrOptions = [
    {
      'name': 'سبحان الله',
      'count': 33,
      'color': const Color(0xFF2B7669),
      'meaning': 'Glory be to Allah',
      'reward': 'ثواب عظيم'
    },
    {
      'name': 'الحمد لله',
      'count': 33,
      'color': const Color(0xFF6B5B95),
      'meaning': 'Praise be to Allah',
      'reward': 'ثواب عظيم'
    },
    {
      'name': 'الله أكبر',
      'count': 33,
      'color': const Color(0xFF00796B),
      'meaning': 'Allah is the Greatest',
      'reward': 'ثواب عظيم'
    },
    {
      'name': 'لا إله إلا الله',
      'count': 100,
      'color': const Color(0xFF1976D2),
      'meaning': 'There is no god but Allah',
      'reward': 'أجر كبير'
    },
    {
      'name': 'استغفر الله',
      'count': 100,
      'color': const Color(0xFF7B1FA2),
      'meaning': 'I seek forgiveness from Allah',
      'reward': 'مغفرة الذنوب'
    },
  ];

  String _selectedDhikr = 'سبحان الله';
  Color _currentColor = const Color(0xFF2B7669);
  List<Offset> _particles = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    
    _beadController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _beadController.dispose();
    _particleController.dispose();
    _bounceController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  Future<void> _playSound() async {
    if (_soundEnabled) {
      // Play system click sound (works on all platforms without audio files)
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0];
    final savedDate = prefs.getString('mespha_date') ?? '';
    
    setState(() {
      _count = prefs.getInt('mespha_count') ?? 0;
      _totalCount = prefs.getInt('mespha_total') ?? 0;
      _completedSets = prefs.getInt('mespha_sets') ?? 0;
      _streak = prefs.getInt('mespha_streak') ?? 0;
      _soundEnabled = prefs.getBool('mespha_sound') ?? true;
      _selectedDhikr = prefs.getString('mespha_dhikr') ?? 'سبحان الله';
      
      if (savedDate == today) {
        _todayCount = prefs.getInt('mespha_today') ?? 0;
      } else {
        _todayCount = 0;
        if (savedDate.isNotEmpty) {
          final lastDate = DateTime.parse(savedDate);
          final diff = DateTime.now().difference(lastDate).inDays;
          if (diff > 1) {
            _streak = 0;
          }
        }
      }
      
      final selectedOption = _dhikrOptions.firstWhere(
        (d) => d['name'] == _selectedDhikr,
        orElse: () => _dhikrOptions[0],
      );
      _targetCount = selectedOption['count'] as int;
      _currentColor = selectedOption['color'] as Color;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0];
    
    await prefs.setInt('mespha_count', _count);
    await prefs.setInt('mespha_total', _totalCount);
    await prefs.setInt('mespha_sets', _completedSets);
    await prefs.setInt('mespha_today', _todayCount);
    await prefs.setInt('mespha_streak', _streak);
    await prefs.setBool('mespha_sound', _soundEnabled);
    await prefs.setString('mespha_dhikr', _selectedDhikr);
    await prefs.setString('mespha_date', today);
  }

  void _incrementCounter() {
    // Play sound
    _playSound();
    
    // Haptic feedback
    if (_soundEnabled) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    
    _beadController.forward(from: 0);
    _bounceController.forward().then((_) => _bounceController.reverse());
    
    // Create particle effect
    _createParticles();

    setState(() {
      _count++;
      _totalCount++;
      _todayCount++;
      
      if (_count >= _targetCount) {
        HapticFeedback.heavyImpact();
        _completedSets++;
        _count = 0;
        _showCompletionDialog();
      }
    });
    
    _saveData();
  }

  void _createParticles() {
    setState(() {
      _particles = List.generate(8, (index) {
        final angle = (index * 45) * math.pi / 180;
        return Offset(
          math.cos(angle) * 100,
          math.sin(angle) * 100,
        );
      });
    });
    _particleController.forward(from: 0);
  }

  void _resetCounter() {
    HapticFeedback.mediumImpact();
    setState(() {
      _count = 0;
    });
    _saveData();
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            const Text(
              'تم إعادة تعيين العداد',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: _currentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _changeDhikr(Map<String, dynamic> dhikr) {
    setState(() {
      _selectedDhikr = dhikr['name'] as String;
      _targetCount = dhikr['count'] as int;
      _currentColor = dhikr['color'] as Color;
      _count = 0;
    });
    _saveData();
    Navigator.pop(context);
  }

  void _showDhikrOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildDhikrSelector(),
    );
  }

  void _showStatsDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.08),
        ),
        child: _buildStatsContent(screenWidth),
      ),
    );
  }

  void _showCompletionDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.08),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildCompletionContent(screenWidth),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(sw, sh),
            _buildQuickStats(sw, sh),
            verticalSpace(sh * 0.02),
            _buildDhikrCard(sw, sh),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildBeadsVisualization(sw, sh),
                  _buildMainCounter(sw, sh),
                  _buildParticles(sw),
                ],
              ),
            ),
            _buildBottomControls(sw, sh),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.all(sw * 0.04),
      child: Row(
        children: [
          _buildCircleButton(
            Icons.arrow_back_ios_new,
            () => Navigator.pop(context),
            sw,
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                'المسبحة الإلكترونية',
                style: TextStyle(
                  fontSize: sw * 0.05,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A2221),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.whatshot, color: Colors.orange, size: sw * 0.04),
                  horizontalSpace(sw * 0.01),
                  Text(
                    '$_streak يوم متتالي',
                    style: TextStyle(
                      fontSize: sw * 0.03,
                      fontFamily: 'Tajawal',
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          _buildCircleButton(
            Icons.bar_chart_rounded,
            _showStatsDialog,
            sw,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, double sw) {
    return Container(
      decoration: BoxDecoration(
        color: _currentColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: _currentColor.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _currentColor.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: _currentColor, size: sw * 0.06),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildQuickStats(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      child: Row(
        children: [
          _buildStatBubble('اليوم', _todayCount, Icons.today, sw, sh),
          horizontalSpace(sw * 0.03),
          _buildStatBubble('الإجمالي', _totalCount, Icons.all_inclusive, sw, sh),
          horizontalSpace(sw * 0.03),
          _buildStatBubble('المجموعات', _completedSets, Icons.check_circle, sw, sh),
        ],
      ),
    );
  }

  Widget _buildStatBubble(String label, int value, IconData icon, double sw, double sh) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: sh * 0.015),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _currentColor.withOpacity(0.08),
              _currentColor.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(sw * 0.04),
          border: Border.all(
            color: _currentColor.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _currentColor.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(sw * 0.02),
              decoration: BoxDecoration(
                color: _currentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _currentColor, size: sw * 0.05),
            ),
            verticalSpace(sh * 0.008),
            Text(
              '$value',
              style: TextStyle(
                fontSize: sw * 0.055,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w900,
                color: _currentColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: sw * 0.028,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDhikrCard(double sw, double sh) {
    final selected = _dhikrOptions.firstWhere(
      (d) => d['name'] == _selectedDhikr,
      orElse: () => _dhikrOptions[0],
    );
    
    return GestureDetector(
      onTap: _showDhikrOptions,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: sw * 0.04),
        padding: EdgeInsets.all(sw * 0.045),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _currentColor.withOpacity(0.12),
              _currentColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(sw * 0.05),
          border: Border.all(color: _currentColor.withOpacity(0.25), width: 2),
          boxShadow: [
            BoxShadow(
              color: _currentColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(sw * 0.035),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_currentColor, _currentColor.withOpacity(0.8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _currentColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.spa, color: Colors.white, size: sw * 0.06),
            ),
            horizontalSpace(sw * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected['name'] as String,
                    style: TextStyle(
                      fontSize: sw * 0.05,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w900,
                      color: _currentColor,
                    ),
                  ),
                  Text(
                    selected['meaning'] as String,
                    style: TextStyle(
                      fontSize: sw * 0.032,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(sw * 0.02),
              decoration: BoxDecoration(
                color: _currentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(sw * 0.02),
              ),
              child: Icon(Icons.tune, color: _currentColor, size: sw * 0.06),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeadsVisualization(double sw, double sh) {
    return SizedBox(
      width: sw * 0.85,
      height: sw * 0.85,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(_targetCount, (index) {
          final angle = (index * 360 / _targetCount) * math.pi / 180;
          final radius = sw * 0.35;
          final x = radius * math.cos(angle);
          final y = radius * math.sin(angle);
          final isActive = index < _count;
          
          return Transform.translate(
            offset: Offset(x, y),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: sw * 0.028,
              height: sw * 0.028,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive
                    ? LinearGradient(
                        colors: [_currentColor, _currentColor.withOpacity(0.7)],
                      )
                    : null,
                color: isActive ? null : Colors.grey[300],
                border: Border.all(
                  color: isActive ? _currentColor.withOpacity(0.3) : Colors.grey[400]!,
                  width: 1.5,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: _currentColor.withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMainCounter(double sw, double sh) {
    return GestureDetector(
      onTap: _incrementCounter,
      child: ScaleTransition(
        scale: _bounceAnimation,
        child: Container(
          width: sw * 0.5,
          height: sw * 0.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _currentColor,
                _currentColor.withOpacity(0.85),
                _currentColor.withOpacity(0.7),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _currentColor.withOpacity(0.4),
                blurRadius: 35,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: _currentColor.withOpacity(0.2),
                blurRadius: 60,
                spreadRadius: 15,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Inner white ring for depth
              Container(
                width: sw * 0.48,
                height: sw * 0.48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
              ),
              // Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_count',
                    style: TextStyle(
                      fontSize: sw * 0.16,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  verticalSpace(sh * 0.005),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.045,
                      vertical: sh * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(sw * 0.03),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '/ $_targetCount',
                      style: TextStyle(
                        fontSize: sw * 0.042,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticles(double sw) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: _particles.map((particle) {
            final progress = _particleController.value;
            final opacity = 1.0 - progress;
            return Transform.translate(
              offset: particle * progress,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: sw * 0.02,
                  height: sw * 0.02,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentColor,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBottomControls(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.all(sw * 0.04),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(sw * 0.04),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _resetCounter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[800],
                  padding: EdgeInsets.symmetric(vertical: sh * 0.022),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(sw * 0.04),
                    side: BorderSide(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  elevation: 0,
                ),
                icon: Icon(Icons.refresh_rounded, size: sw * 0.06),
                label: Text(
                  'إعادة تعيين',
                  style: TextStyle(
                    fontSize: sw * 0.04,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          horizontalSpace(sw * 0.03),
          Container(
            decoration: BoxDecoration(
              color: _soundEnabled
                  ? _currentColor.withOpacity(0.12)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(sw * 0.04),
              border: Border.all(
                color: _soundEnabled
                    ? _currentColor.withOpacity(0.3)
                    : Colors.grey[300]!,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _soundEnabled
                      ? _currentColor.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _soundEnabled ? Icons.volume_up : Icons.volume_off,
                color: _soundEnabled ? _currentColor : Colors.grey[600],
                size: sw * 0.07,
              ),
              onPressed: () {
                setState(() {
                  _soundEnabled = !_soundEnabled;
                });
                _saveData();
                HapticFeedback.mediumImpact();
                
                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          _soundEnabled ? Icons.volume_up : Icons.volume_off,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _soundEnabled ? 'تم تفعيل الصوت' : 'تم إيقاف الصوت',
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: _currentColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrSelector() {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.all(sw * 0.05),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: sw * 0.15,
            height: sh * 0.006,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          verticalSpace(sh * 0.025),
          Text(
            'اختر الذكر',
            style: TextStyle(
              fontSize: sw * 0.06,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w900,
            ),
          ),
          verticalSpace(sh * 0.025),
          ...List.generate(_dhikrOptions.length, (index) {
            final dhikr = _dhikrOptions[index];
            final isSelected = dhikr['name'] == _selectedDhikr;
            
            return Container(
              margin: EdgeInsets.only(bottom: sh * 0.015),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _changeDhikr(dhikr),
                  borderRadius: BorderRadius.circular(sw * 0.04),
                  child: Container(
                    padding: EdgeInsets.all(sw * 0.04),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (dhikr['color'] as Color).withOpacity(0.1)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(sw * 0.04),
                      border: Border.all(
                        color: isSelected
                            ? (dhikr['color'] as Color)
                            : Colors.grey[200]!,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(sw * 0.03),
                          decoration: BoxDecoration(
                            color: dhikr['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${dhikr['count']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sw * 0.04,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        horizontalSpace(sw * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dhikr['name'] as String,
                                style: TextStyle(
                                  fontSize: sw * 0.045,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? (dhikr['color'] as Color)
                                      : Colors.grey[800],
                                ),
                              ),
                              Text(
                                dhikr['meaning'] as String,
                                style: TextStyle(
                                  fontSize: sw * 0.03,
                                  fontFamily: 'Tajawal',
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: dhikr['color'] as Color,
                            size: sw * 0.06,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          verticalSpace(sh * 0.02),
        ],
      ),
    );
  }

  Widget _buildCompletionContent(double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.08),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_currentColor, _currentColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(sw * 0.08),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.white,
            size: sw * 0.2,
          ),
          verticalSpace(20),
          const Text(
            'أحسنت! ✨',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w800,
            ),
          ),
          verticalSpace(12),
          Text(
            'أتممت $_targetCount من $_selectedDhikr',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Tajawal',
            ),
          ),
          verticalSpace(24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'متابعة',
              style: TextStyle(
                color: _currentColor,
                fontSize: 18,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.06),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'الإحصائيات',
            style: TextStyle(
              fontSize: sw * 0.06,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w900,
              color: _currentColor,
            ),
          ),
          verticalSpace(20),
          _buildStatRow('اليوم', _todayCount, sw),
          _buildStatRow('الإجمالي', _totalCount, sw),
          _buildStatRow('المجموعات', _completedSets, sw),
          _buildStatRow('سلسلة الأيام', _streak, sw),
          verticalSpace(20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentColor,
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.1,
                vertical: sw * 0.04,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(sw * 0.04),
              ),
            ),
            child: const Text(
              'إغلاق',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value, double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sw * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.04,
              fontFamily: 'Tajawal',
              color: Colors.grey[700],
            ),
          ),
          Text(
            '$value',
            style: TextStyle(
              fontSize: sw * 0.05,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w900,
              color: _currentColor,
            ),
          ),
        ],
      ),
    );
  }
}
