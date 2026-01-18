import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './personal_stat_screen.dart';
import './background_music.dart';
import './knowledge_bank_screen.dart';
import './design_system_screen.dart';
import './settings_screen.dart';
import './profile_screen.dart';
import './world_chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class PreStartScreen extends StatefulWidget {
  final VoidCallback onProceed;
  final VoidCallback? onUsernameChanged;
  const PreStartScreen({
    super.key,
    required this.onProceed,
    this.onUsernameChanged,
  });

  @override
  State<PreStartScreen> createState() => _PreStartScreenState();
}

class _PreStartScreenState extends State<PreStartScreen>
    with TickerProviderStateMixin {
  double _volume = 0.5; // Initial volume
  final BackgroundMusic _backgroundMusic = BackgroundMusic();

  late AnimationController _leavesController;
  late Animation<double> _leavesAnimation;

  Future<void> _loadVolumeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVolume = prefs.getDouble('music_volume') ?? 0.5;
    setState(() {
      _volume = savedVolume;
    });
  }

  Future<void> _initializeMusic() async {
    await _loadVolumeSettings(); // Load saved volume first
    await _backgroundMusic.initialize();
    await _backgroundMusic.setVolume(_volume);
    await _backgroundMusic.playBackgroundMusic();
  }

  @override
  void initState() {
    super.initState();
    _initializeMusic();

    // Initialize slow leaves floating animation
    _leavesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000), // Very slow 8 second cycle
    )..repeat();
    _leavesAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.linear)).animate(_leavesController);
  }

  @override
  void dispose() {
    _leavesController.dispose();
    super.dispose();
  }

  void _showSystemDesignHelp() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF2C1810),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFFF6B35), width: 2),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFFFF6B35),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'What is System Design?',
                    style: GoogleFonts.saira(
                      color: const Color(0xFFFFE4B5),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'System design is making sure all the different pieces work together smoothly, like a well-oiled machine.',
                    style: GoogleFonts.robotoSlab(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Think of it like a pizza delivery business:',
                    style: GoogleFonts.robotoSlab(
                      color: const Color(0xFFFF6B35),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint('The kitchen makes pizzas'),
                  _buildBulletPoint(
                    'The delivery drivers bring them to customers',
                  ),
                  _buildBulletPoint('The phone system takes orders'),
                  _buildBulletPoint('The payment system handles money'),
                  const SizedBox(height: 16),
                  Text(
                    'System design makes sure:',
                    style: GoogleFonts.robotoSlab(
                      color: const Color(0xFFFF6B35),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint('Orders reach the kitchen correctly'),
                  _buildBulletPoint('Drivers know where to go'),
                  _buildBulletPoint('Payments go through'),
                  _buildBulletPoint('Everything happens in the right order'),
                  const SizedBox(height: 16),
                  Text(
                    'If these pieces don\'t work together properly, you get chaos - wrong orders, cold pizzas, angry customers!',
                    style: GoogleFonts.robotoSlab(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'For Apps',
                    style: GoogleFonts.robotoSlab(
                      color: const Color(0xFFFF6B35),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Same idea - an app like Netflix has:',
                    style: GoogleFonts.robotoSlab(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint('A place that stores all the movies'),
                  _buildBulletPoint('A system that knows what you like'),
                  _buildBulletPoint('Servers that send video to your screen'),
                  _buildBulletPoint('A payment system for your subscription'),
                  const SizedBox(height: 16),
                  Text(
                    'System design makes sure all these parts talk to each other and work as one system, not a bunch of confused pieces.',
                    style: GoogleFonts.robotoSlab(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF6B35),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '✨ System design = making everything work together as a team.',
                      style: GoogleFonts.saira(
                        color: const Color(0xFFFFE4B5),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Got it!',
                  style: GoogleFonts.saira(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.robotoSlab(
              color: const Color(0xFFFF6B35),
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.robotoSlab(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Cozy pixel background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              // Cozy pixel-like gradient background
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2C1810), // Dark brown
                  Color(0xFF3D2817), // Medium brown
                  Color(0xFF4A3420), // Light brown
                  Color(0xFF5C4129), // Tan
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Cozy pixel-style stars/dots background
                ...List.generate(80, (index) {
                  final random = Random(index);
                  return Positioned(
                    left:
                        random.nextDouble() * MediaQuery.of(context).size.width,
                    top:
                        random.nextDouble() *
                        MediaQuery.of(context).size.height,
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4B5).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  );
                }),
                // Floating maple leaves animation
                ...List.generate(12, (index) {
                  final random = Random(
                    index + 100,
                  ); // Different seed for leaves
                  final startX =
                      random.nextDouble() * MediaQuery.of(context).size.width;
                  final startY =
                      random.nextDouble() * MediaQuery.of(context).size.height;
                  final amplitude =
                      30.0 + random.nextDouble() * 20.0; // Wave amplitude
                  final verticalSpeed =
                      0.3 + random.nextDouble() * 0.4; // Fall speed

                  return AnimatedBuilder(
                    animation: _leavesAnimation,
                    builder: (context, child) {
                      // Calculate floating position with wave motion
                      final progress = _leavesAnimation.value;
                      final waveX =
                          startX + amplitude * sin(progress * 2 * pi + index);
                      final waveY =
                          (startY +
                              (MediaQuery.of(context).size.height *
                                  1.5 *
                                  verticalSpeed *
                                  progress)) %
                          (MediaQuery.of(context).size.height + 100);

                      return Positioned(
                        left: waveX,
                        top: waveY - 50, // Start slightly above screen
                        child: child!,
                      );
                    },
                    child: Transform.rotate(
                      angle:
                          (index * 0.5) +
                          (_leavesAnimation.value *
                              pi *
                              0.25), // Gentle rotation
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: Stack(
                          children: [
                            // Maple leaf shape using positioned containers
                            // Center main body
                            Positioned(
                              left: 6,
                              top: 8,
                              child: Container(
                                width: 4,
                                height: 8,
                                decoration: BoxDecoration(
                                  color:
                                      [
                                        const Color(0xFF8B4513), // Brown
                                        const Color(0xFFD2691E), // Orange
                                        const Color(0xFFDC143C), // Red
                                        const Color(0xFFB22222), // Dark red
                                        const Color(0xFF228B22), // Green
                                      ][index % 5],
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                            ),
                            // Top center lobe
                            Positioned(
                              left: 7,
                              top: 2,
                              child: Container(
                                width: 2,
                                height: 6,
                                decoration: BoxDecoration(
                                  color:
                                      [
                                        const Color(0xFF8B4513), // Brown
                                        const Color(0xFFD2691E), // Orange
                                        const Color(0xFFDC143C), // Red
                                        const Color(0xFFB22222), // Dark red
                                        const Color(0xFF228B22), // Green
                                      ][index % 5],
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                            ),
                            // Left lobe
                            Positioned(
                              left: 2,
                              top: 4,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color:
                                      [
                                        const Color(0xFF8B4513), // Brown
                                        const Color(0xFFD2691E), // Orange
                                        const Color(0xFFDC143C), // Red
                                        const Color(0xFFB22222), // Dark red
                                        const Color(0xFF228B22), // Green
                                      ][index % 5],
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                            ),
                            // Right lobe
                            Positioned(
                              left: 10,
                              top: 4,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color:
                                      [
                                        const Color(0xFF8B4513), // Brown
                                        const Color(0xFFD2691E), // Orange
                                        const Color(0xFFDC143C), // Red
                                        const Color(0xFFB22222), // Dark red
                                        const Color(0xFF228B22), // Green
                                      ][index % 5],
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                            ),
                            // Left lower lobe
                            Positioned(
                              left: 4,
                              top: 9,
                              child: Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color:
                                      [
                                        const Color(0xFF8B4513), // Brown
                                        const Color(0xFFD2691E), // Orange
                                        const Color(0xFFDC143C), // Red
                                        const Color(0xFFB22222), // Dark red
                                        const Color(0xFF228B22), // Green
                                      ][index % 5],
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                            ),
                            // Right lower lobe
                            Positioned(
                              left: 9,
                              top: 9,
                              child: Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color:
                                      [
                                        const Color(0xFF8B4513), // Brown
                                        const Color(0xFFD2691E), // Orange
                                        const Color(0xFFDC143C), // Red
                                        const Color(0xFFB22222), // Dark red
                                        const Color(0xFF228B22), // Green
                                      ][index % 5],
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                            ),
                            // Stem
                            Positioned(
                              left: 7,
                              top: 14,
                              child: Container(
                                width: 2,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF654321), // Brown stem
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Centered button layout with proper spacing
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60), // Top spacing
                // Start Exam Button
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A3420),
                    borderRadius: BorderRadius.circular(
                      0,
                    ), // Sharp corners for pixel style
                    border: Border.all(
                      color: const Color(0xFFFFE4B5),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 0,
                        offset: const Offset(4, 4), // Sharp shadow
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onProceed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Text(
                          'Start Exam',
                          style: GoogleFonts.saira(
                            textStyle: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFE4B5),
                              fontFamily: 'monospace',
                              letterSpacing: 1.5,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30), // Spacing between buttons
                // Knowledge Bank Button
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D2817),
                    borderRadius: BorderRadius.circular(
                      0,
                    ), // Sharp corners for pixel style
                    border: Border.all(
                      color: const Color(0xFFFFE4B5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 0,
                        offset: const Offset(3, 3), // Sharp shadow
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const KnowledgeBankScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        child: Text(
                          'Knowledge Bank',
                          style: GoogleFonts.saira(
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFE4B5),
                              fontFamily: 'monospace',
                              letterSpacing: 1.2,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25), // Spacing between buttons
                // Design a System Button
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D2817),
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(
                      color: const Color(0xFFFFE4B5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 0,
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DesignSystemScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        child: Text(
                          'Design a System',
                          style: GoogleFonts.saira(
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFE4B5),
                              fontFamily: 'monospace',
                              letterSpacing: 1.2,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25), // Spacing between buttons
                // Personal Stats Button
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D2817),
                    borderRadius: BorderRadius.circular(
                      0,
                    ), // Sharp corners for pixel style
                    border: Border.all(
                      color: const Color(0xFFFFE4B5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 0,
                        offset: const Offset(3, 3), // Sharp shadow
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PersonalStatScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        child: Text(
                          'Personal Stats',
                          style: GoogleFonts.saira(
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFE4B5),
                              fontFamily: 'monospace',
                              letterSpacing: 1.2,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25), // Spacing between buttons
                // World Chat Button
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D2817),
                    borderRadius: BorderRadius.circular(
                      0,
                    ), // Sharp corners for pixel style
                    border: Border.all(
                      color: const Color(
                        0xFFFF6B35,
                      ), // Orange border for emphasis
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 0,
                        offset: const Offset(3, 3), // Sharp shadow
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WorldChatScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.public,
                              color: Color(0xFFFF6B35),
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'World Chat',
                              style: GoogleFonts.saira(
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFE4B5),
                                  fontFamily: 'monospace',
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60), // Bottom spacing
              ],
            ),
          ),
          // Profile button overlay
          Positioned(
            top: 50, // Fixed top position
            right:
                80, // Fixed right position, ensuring it stays left of settings button
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF4A3420),
                borderRadius: BorderRadius.circular(
                  0,
                ), // Sharp corners for pixel style
                border: Border.all(color: const Color(0xFFFFE4B5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                    // Notify main screen to refresh username
                    if (widget.onUsernameChanged != null) {
                      widget.onUsernameChanged!();
                    }
                  },
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFFFFE4B5),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          // Settings button overlay (replaces volume control)
          Positioned(
            top: 50, // Fixed top position
            right: 20, // Fixed right position
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF4A3420),
                borderRadius: BorderRadius.circular(
                  0,
                ), // Sharp corners for pixel style
                border: Border.all(color: const Color(0xFFFFE4B5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 0,
                    offset: const Offset(2, 2), // Sharp shadow
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => SettingsScreen(
                              currentVolume: _volume,
                              backgroundMusic: _backgroundMusic,
                            ),
                      ),
                    );
                    // Reload volume settings when returning from settings
                    await _loadVolumeSettings();
                    await _backgroundMusic.setVolume(_volume);
                  },
                  child: const Icon(
                    Icons.settings,
                    color: Color(0xFFFFE4B5),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          // Help button at bottom right
          Positioned(
            bottom: 30,
            right: 20,
            child: GestureDetector(
              onTap: _showSystemDesignHelp,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFE4B5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
