import 'dart:math';
import 'package:flutter/material.dart';
import './pre_start_screen.dart';
import './start_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import './leaderboard_screen.dart'; // ADD THIS LINE - Import leaderboard to access bot manager

void main() async {
  // Ensure Flutter binding is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();

  // IMPORTANT: Trigger bot update on app startup
  // This ensures timer calculations happen even when app was closed
  try {
    await LeaderboardBotManager.triggerLeaderboardBotUpdate();
    //print('DEBUG: Bot update triggered successfully on app startup');
  } catch (e) {
    //print('DEBUG: Error triggering bot update on startup: $e');
    // Continue app launch even if bot update fails
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Quiz Game'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _hasUsername = false;
  String _currentUsername = '';
  final TextEditingController _usernameController = TextEditingController();

  late AnimationController _jiggleController;
  late Animation<double> _jiggleAnimation;

  late AnimationController _leavesController;
  late Animation<double> _leavesAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForExistingUsername();

    // Initialize jiggle animation with safe values
    _jiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _jiggleAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_jiggleController);

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

  String _getSystemUsername() {
    if (kIsWeb) return 'User';
    try {
      // Try to get system username (non-web only)
      return String.fromEnvironment('USER', defaultValue: '') != ''
          ? const String.fromEnvironment('USER')
          : 'User';
    } catch (e) {
      return 'User';
    }
  }

  Future<void> _checkForExistingUsername() async {
    final prefs = await SharedPreferences.getInstance();
    // Use the same userName key as profile screen
    final savedUsername = prefs.getString('userName') ?? _getSystemUsername();

    setState(() {
      _hasUsername = true;
      _currentUsername = savedUsername;
    });
  }

  Future<void> _refreshUsername() async {
    await _checkForExistingUsername();
  }

  Future<void> _saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    // Use the same userName key as profile screen
    await prefs.setString('userName', username);

    setState(() {
      _hasUsername = true;
      _currentUsername = username;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _jiggleController.dispose();
    _leavesController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _jiggleController.stop();
      _leavesController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _jiggleController.repeat(reverse: true);
      _leavesController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic positions based on screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Text position (fixed)
    const textTop = 450.0;
    const textContainerHeight = 52.0; // Padding + text height
    final textBottom = textTop + textContainerHeight;

    // Button position (dynamic)
    const referenceHeight = 800.0;
    const originalBottom = 115.0;
    final scaleFactor = screenHeight / referenceHeight;
    final buttonBottom = originalBottom * scaleFactor;
    final buttonTop =
        screenHeight - buttonBottom - 48; // 48 is approximate button height

    // Username position (centered between text and button)
    final availableSpace = buttonTop - textBottom;
    final usernameTop =
        textBottom + (availableSpace / 2) - 25; // -25 to center the container

    return Scaffold(
      body: Stack(
        children: [
          // Main container with cozy pixel background
          Container(
            width: screenWidth,
            height: screenHeight,
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
                ...List.generate(50, (index) {
                  final random = Random(index);
                  return Positioned(
                    left: random.nextDouble() * screenWidth,
                    top: random.nextDouble() * screenHeight,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4B5).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
                // Floating maple leaves animation
                ...List.generate(12, (index) {
                  final random = Random(
                    index + 100,
                  ); // Different seed for leaves
                  final startX = random.nextDouble() * screenWidth;
                  final startY = random.nextDouble() * screenHeight;
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
                              (screenHeight * 1.5 * verticalSpeed * progress)) %
                          (screenHeight + 100);

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
                // Quiz/Education themed Logo
                Positioned(
                  top: 320,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _jiggleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_jiggleAnimation.value * 0.02),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 90,
                        height: 75,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A3420),
                          borderRadius: BorderRadius.circular(0),
                          border: Border.all(
                            color: const Color(0xFFFFE4B5),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 0,
                              offset: const Offset(4, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Main book
                            Positioned(
                              top: 15,
                              left: 15,
                              child: Container(
                                width: 35,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B4513),
                                  borderRadius: BorderRadius.circular(0),
                                  border: Border.all(
                                    color: const Color(0xFFFFE4B5),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Book spine lines
                                    Container(
                                      width: 25,
                                      height: 2,
                                      color: const Color(0xFFFFE4B5),
                                    ),
                                    const SizedBox(height: 3),
                                    Container(
                                      width: 20,
                                      height: 2,
                                      color: const Color(0xFFFFE4B5),
                                    ),
                                    const SizedBox(height: 3),
                                    Container(
                                      width: 25,
                                      height: 2,
                                      color: const Color(0xFFFFE4B5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Second book (slightly offset)
                            Positioned(
                              top: 20,
                              left: 25,
                              child: Container(
                                width: 30,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD2691E),
                                  borderRadius: BorderRadius.circular(0),
                                  border: Border.all(
                                    color: const Color(0xFFFFE4B5),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            // Graduation cap
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Column(
                                children: [
                                  // Cap top (square)
                                  Container(
                                    width: 20,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C1810),
                                      borderRadius: BorderRadius.circular(0),
                                      border: Border.all(
                                        color: const Color(0xFFFFE4B5),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  // Cap base
                                  Container(
                                    width: 15,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C1810),
                                      borderRadius: BorderRadius.circular(0),
                                      border: Border.all(
                                        color: const Color(0xFFFFE4B5),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Question mark symbol
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Text(
                                '?',
                                style: GoogleFonts.saira(
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF90EE90),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ),
                            // Quiz score indicator
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF90EE90),
                                  borderRadius: BorderRadius.circular(0),
                                  border: Border.all(
                                    color: const Color(0xFF2C1810),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'A+',
                                  style: GoogleFonts.saira(
                                    textStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C1810),
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Knowledge indicator dots
                            Positioned(
                              top: 5,
                              left: 5,
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF90EE90),
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD700),
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC143C),
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Pixel-style animated text overlay
                Positioned(
                  top: 450,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C1810),
                      borderRadius: BorderRadius.circular(
                        0,
                      ), // Sharp corners for pixel feel
                      border: Border.all(
                        color: const Color(0xFFFFE4B5),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 0,
                          offset: const Offset(
                            4,
                            4,
                          ), // Sharp shadow for pixel effect
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _jiggleAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_jiggleAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: const Text(
                        'Start Your System Design Journey',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFE4B5),
                          fontFamily: 'monospace',
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // Username Input Section
                if (!_hasUsername)
                  Positioned(
                    top: usernameTop,
                    left: 40,
                    right: 40,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D2817),
                        borderRadius: BorderRadius.circular(
                          0,
                        ), // Sharp corners for pixel feel
                        border: Border.all(
                          color: const Color(0xFFFFE4B5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 0,
                            offset: const Offset(
                              3,
                              3,
                            ), // Sharp shadow for pixel effect
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _usernameController,
                            style: GoogleFonts.saira(
                              textStyle: const TextStyle(
                                color: Color(0xFFFFE4B5),
                                fontSize: 18,
                                fontFamily: 'monospace',
                              ),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your username',
                              hintStyle: GoogleFonts.saira(
                                textStyle: TextStyle(
                                  color: const Color(
                                    0xFFFFE4B5,
                                  ).withOpacity(0.7),
                                  fontSize: 16,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF2C1810),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  0,
                                ), // Sharp corners
                                borderSide: const BorderSide(
                                  color: Color(0xFFFFE4B5),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  0,
                                ), // Sharp corners
                                borderSide: const BorderSide(
                                  color: Color(0xFFFFE4B5),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  0,
                                ), // Sharp corners
                                borderSide: const BorderSide(
                                  color: Color(0xFF90EE90),
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A3420),
                              borderRadius: BorderRadius.circular(
                                0,
                              ), // Sharp corners for pixel feel
                              border: Border.all(
                                color: const Color(0xFFFFE4B5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 0,
                                  offset: const Offset(
                                    3,
                                    3,
                                  ), // Sharp shadow for pixel effect
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  final username =
                                      _usernameController.text.trim();
                                  if (username.isNotEmpty) {
                                    _saveUsername(username);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  child: Text(
                                    'Enter',
                                    style: GoogleFonts.saira(
                                      textStyle: const TextStyle(
                                        fontSize: 18,
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
                        ],
                      ),
                    ),
                  ),
                // Welcome back message and Proceed button
                if (_hasUsername)
                  Positioned(
                    top: usernameTop,
                    left: 40,
                    right: 40,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D2817),
                        borderRadius: BorderRadius.circular(
                          0,
                        ), // Sharp corners for pixel feel
                        border: Border.all(
                          color: const Color(0xFFFFE4B5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 0,
                            offset: const Offset(
                              3,
                              3,
                            ), // Sharp shadow for pixel effect
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Welcome back, $_currentUsername!',
                            style: GoogleFonts.saira(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFE4B5),
                                fontFamily: 'monospace',
                                letterSpacing: 1.2,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A3420),
                              borderRadius: BorderRadius.circular(
                                0,
                              ), // Sharp corners for pixel feel
                              border: Border.all(
                                color: const Color(0xFFFFE4B5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 0,
                                  offset: const Offset(
                                    3,
                                    3,
                                  ), // Sharp shadow for pixel effect
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
                                          (context) => PreStartScreen(
                                            onProceed: () {
                                              // Navigate to the actual quiz/exam screen
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const StartScreen(),
                                                ),
                                              );
                                            },
                                            onUsernameChanged: _refreshUsername,
                                          ),
                                    ),
                                  );
                                  // Refresh username when returning from PreStartScreen
                                  await _refreshUsername();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  child: Text(
                                    'Proceed',
                                    style: GoogleFonts.saira(
                                      textStyle: const TextStyle(
                                        fontSize: 18,
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
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
