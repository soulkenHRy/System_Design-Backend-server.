import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import './background_music.dart';
import './leaderboard_screen.dart';
import './saved_designs_list_screen.dart';
import './leaderboard_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Simple local unlock service (replaces removed PaymentService)
class _UnlockService {
  static const String _unlimitedDesignKey = 'unlimited_design_unlocked';

  static Future<bool> hasUnlimitedDesign() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_unlimitedDesignKey) ?? false;
  }
}

class SettingsScreen extends StatefulWidget {
  final double currentVolume;
  final BackgroundMusic backgroundMusic;

  const SettingsScreen({
    super.key,
    required this.currentVolume,
    required this.backgroundMusic,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _volume;
  bool _hasUnlimitedDesign = false;
  // bool _isLoadingPurchaseStatus = true; // Currently unused, can be used for loading indicator

  @override
  void initState() {
    super.initState();
    _volume = widget.currentVolume;
    _checkPurchaseStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkPurchaseStatus() async {
    try {
      final hasPurchased = await _UnlockService.hasUnlimitedDesign();
      if (mounted) {
        setState(() {
          _hasUnlimitedDesign = hasPurchased;
        });
      }
    } catch (e) {
      debugPrint('Error checking purchase status: $e');
    }
  }

  Future<void> _saveVolumeSettings(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('music_volume', volume);
  }

  void _showUnlimitedDesignDialog() {
    if (_hasUnlimitedDesign) {
      // User already has unlimited design - show info and launch
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF4A3420),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: const Color(0xFFFF6B35), width: 2),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: const Color(0xFFFF6B35),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Unlimited Design',
                  style: GoogleFonts.saira(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Unlimited Design Mode!',
                  style: GoogleFonts.saira(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '🎯 Design any system you can imagine\n'
                  '🚀 No limits on complexity or scale\n'
                  '💡 Practice with real-world scenarios\n'
                  '📝 Document your architectural decisions\n'
                  '🏆 Challenge yourself beyond the basics',
                  style: GoogleFonts.saira(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFF6B35).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '🤖 NOW AVAILABLE: AI-powered design evaluation, intelligent feedback system, and comprehensive architectural analysis!',
                    style: GoogleFonts.saira(
                      color: const Color(0xFFFF6B35),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: GoogleFonts.saira(color: Colors.white70, fontSize: 14),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _launchUnlimitedDesign();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Enter Unlimited Mode',
                  style: GoogleFonts.saira(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // User doesn't have unlimited design - show score requirement dialog
      _showScoreRequirementDialog();
    }
  }

  void _showScoreRequirementDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF4A3420),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: const Color(0xFFFF6B35), width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.lock_open, color: const Color(0xFFFF6B35), size: 28),
              const SizedBox(width: 12),
              Text(
                'Unlock Feature',
                style: GoogleFonts.saira(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unlock Requirements:',
                style: GoogleFonts.saira(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '🎯 Design any system you can imagine\n'
                '🚀 No limits on complexity or scale\n'
                '💡 Practice with real-world scenarios\n'
                '📝 Document your architectural decisions\n'
                '🏆 Challenge yourself beyond the basics\n'
                '🤖 AI-powered design evaluation',
                style: GoogleFonts.saira(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF6B35)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: const Color(0xFFFF6B35), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Score 450+ to Unlock',
                      style: GoogleFonts.saira(
                        color: const Color(0xFFFF6B35),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Got It!',
                style: GoogleFonts.saira(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _launchUnlimitedDesign() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SavedDesignsListScreen()),
    );
  }

  void _showBotDebugDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C1810),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.deepPurple, size: 28),
              const SizedBox(width: 12),
              Text(
                'Bot Debug Panel',
                style: GoogleFonts.saira(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Test the leaderboard bot algorithm.',
                  style: GoogleFonts.saira(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Clean test setup section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🧹 CLEAN TEST SETUP',
                        style: GoogleFonts.saira(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _debugButton(
                        'Reset Everything (Clean Slate)',
                        Icons.cleaning_services,
                        Colors.red,
                        () => _fullReset(),
                      ),
                      const SizedBox(height: 6),
                      _debugButton(
                        'Set User Score to 100',
                        Icons.score,
                        Colors.pink,
                        () => _setUserScore(100),
                      ),
                      const SizedBox(height: 6),
                      _debugButton(
                        'Set User Score to 500',
                        Icons.score,
                        Colors.pink,
                        () => _setUserScore(500),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Simulation section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⏰ SIMULATE TIME',
                        style: GoogleFonts.saira(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _debugButton(
                        'Simulate 1 Day',
                        Icons.today,
                        Colors.blue,
                        () => _simulateDaysPassing(1),
                      ),
                      const SizedBox(height: 6),
                      _debugButton(
                        'Simulate 7 Days (Week Flip)',
                        Icons.date_range,
                        Colors.green,
                        () => _simulateDaysPassing(7),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // View section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👁️ VIEW DATA',
                        style: GoogleFonts.saira(
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _debugButton(
                        'View Bot Scores',
                        Icons.visibility,
                        Colors.cyan,
                        () => _viewBotData(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: GoogleFonts.saira(color: Colors.white70),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _debugButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(text, style: GoogleFonts.saira(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
      ),
    );
  }

  /// Full reset - clears EVERYTHING for a clean test
  Future<void> _fullReset() async {
    Navigator.pop(context);

    final prefs = await SharedPreferences.getInstance();

    // Clear ALL test-related data
    await prefs.remove('persistent_bots_v2');
    await prefs.remove('bots_initialized');
    await prefs.remove('bots_last_update');
    await prefs.remove('bots_last_name_change');
    await prefs.remove('user_total_best_score');
    await prefs.remove('user_score_history');
    await prefs.remove('device_bot_seed');

    // Set a clean starting score
    await prefs.setInt('user_total_best_score', 0);
    await prefs.setStringList('user_score_history', []);

    // Generate fresh bots
    await LeaderboardBotManager.triggerLeaderboardBotUpdate();

    // Verify
    final newBots = prefs.getString('persistent_bots_v2');
    final botCount = newBots != null ? json.decode(newBots).length : 0;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🧹 Full reset! User score: 0, $botCount bots created.',
            style: GoogleFonts.saira(),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Set user score to a specific value for testing
  Future<void> _setUserScore(int score) async {
    Navigator.pop(context);

    final prefs = await SharedPreferences.getInstance();

    // Get old score for comparison
    final oldScore = prefs.getInt('user_total_best_score') ?? 0;

    // Set the new score
    await prefs.setInt('user_total_best_score', score);

    // Add to score history (with a fake old entry for improvement calculation)
    final scoreHistory = prefs.getStringList('user_score_history') ?? [];

    // Add an entry from "yesterday" with old score
    scoreHistory.add(
      json.encode({
        'score': oldScore,
        'timestamp':
            DateTime.now()
                .subtract(const Duration(hours: 25))
                .millisecondsSinceEpoch,
      }),
    );

    // Add current entry
    scoreHistory.add(
      json.encode({
        'score': score,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }),
    );

    await prefs.setStringList('user_score_history', scoreHistory);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ User score set to $score (was $oldScore). Improvement: ${score - oldScore}',
            style: GoogleFonts.saira(),
          ),
          backgroundColor: Colors.pink,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _simulateDaysPassing(int days) async {
    Navigator.pop(context); // Close dialog

    final prefs = await SharedPreferences.getInstance();

    // First, check if bots exist
    final botsJson = prefs.getString('persistent_bots_v2');

    if (botsJson == null || botsJson.isEmpty) {
      await LeaderboardBotManager.triggerLeaderboardBotUpdate();
    }

    // Re-fetch after potential generation
    final botsJsonString = prefs.getString('persistent_bots_v2');

    if (botsJsonString != null && botsJsonString.isNotEmpty) {
      try {
        final List<dynamic> botsData = json.decode(botsJsonString);
        final List<Map<String, dynamic>> bots =
            botsData.map((b) => Map<String, dynamic>.from(b)).toList();

        if (bots.isEmpty) {
          _showDebugError('No bots found! Click "Reset Everything" first.');
          return;
        }

        // Get user score for improvement calculation
        final userScore = prefs.getInt('user_total_best_score') ?? 0;

        if (userScore == 0) {
          _showDebugError('User score is 0! Set a score first.');
          return;
        }

        // Store BEFORE scores for comparison
        final beforeScores = <String, int>{};
        for (final bot in bots) {
          if (bot['isBot'] == true) {
            beforeScores[bot['username']] = bot['score'] ?? 0;
          }
        }

        // Get the ACTUAL user improvement from score history (same as real algorithm)
        final scoreHistory = prefs.getStringList('user_score_history') ?? [];
        int userImprovement = userScore; // Default to full score if no history

        if (scoreHistory.isNotEmpty) {
          // Find the oldest score in history to calculate improvement
          try {
            final oldestEntry = json.decode(scoreHistory.first);
            final oldScore = oldestEntry['score'] as int? ?? 0;
            userImprovement = userScore - oldScore;
          } catch (e) {
            // Use full score as improvement if parsing fails
          }
        }

        // Use the actual improvement (not 10% of score)
        final dailyImprovement = userImprovement.clamp(0, userImprovement);

        // Determine week cycle
        final now = DateTime.now();
        final daysSinceEpoch =
            now.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);

        for (int day = 0; day < days; day++) {
          final simulatedDay = daysSinceEpoch + day;
          final weekCycle = (simulatedDay ~/ 7) % 2;

          Map<int, double> multipliers;
          if (weekCycle == 0) {
            // Week pattern 0: Top ranks gain more
            multipliers = {
              1: 1.10,
              2: 1.10,
              3: 0.80,
              4: 0.80,
              5: 0.60,
              6: 0.60,
              7: 0.40,
              8: 0.40,
              9: 0.20,
              10: 0.20,
            };
          } else {
            // Week pattern 1: Bottom ranks gain more
            multipliers = {
              1: 0.20,
              2: 0.20,
              3: 0.40,
              4: 0.40,
              5: 0.60,
              6: 0.60,
              7: 0.80,
              8: 0.80,
              9: 1.10,
              10: 1.10,
            };
          }

          for (int i = 0; i < bots.length; i++) {
            final bot = bots[i];
            if (bot['isBot'] == true) {
              final targetRank = bot['targetRank'] ?? ((i ~/ 2) + 1);
              final multiplier = multipliers[targetRank.clamp(1, 10)] ?? 0.5;
              final scoreAddition = (dailyImprovement * multiplier).round();
              bot['score'] = (bot['score'] as int? ?? 0) + scoreAddition;
            }
          }
        }

        // Save updated bots
        await prefs.setString('persistent_bots_v2', json.encode(bots));
        await prefs.setInt(
          'bots_last_update',
          DateTime.now().millisecondsSinceEpoch,
        );

        // Show before/after comparison dialog
        if (mounted) {
          _showSimulationResults(
            beforeScores,
            bots,
            days,
            userScore,
            dailyImprovement,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: $e', style: GoogleFonts.saira()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ No bots found! Reset first.',
              style: GoogleFonts.saira(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSimulationResults(
    Map<String, int> beforeScores,
    List<Map<String, dynamic>> afterBots,
    int days,
    int userScore,
    int dailyImprovement,
  ) {
    // Sort bots by score descending
    afterBots.sort((a, b) => (b['score'] ?? 0).compareTo(a['score'] ?? 0));

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1a1a2e),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.green, width: 2),
            ),
            title: Text(
              '✅ Simulated $days Day(s)',
              style: GoogleFonts.saira(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'User Score: $userScore\nDaily Improvement: $dailyImprovement\nTotal Added: ${dailyImprovement * days} per bot (×multiplier)',
                        style: GoogleFonts.sourceCodePro(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bot Scores (Before → After):',
                      style: GoogleFonts.saira(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...afterBots.take(10).map((bot) {
                      final name = bot['username'] ?? 'Unknown';
                      final before = beforeScores[name] ?? 0;
                      final after = bot['score'] ?? 0;
                      final diff = after - before;
                      final rank = bot['targetRank'] ?? '?';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$rank',
                                style: GoogleFonts.saira(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                name.length > 12
                                    ? '${name.substring(0, 12)}...'
                                    : name,
                                style: GoogleFonts.saira(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '$before → $after',
                              style: GoogleFonts.sourceCodePro(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(+$diff)',
                              style: GoogleFonts.saira(
                                color: Colors.greenAccent,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: GoogleFonts.saira(color: Colors.white70),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _viewBotData() async {
    Navigator.pop(context); // Close current dialog

    final prefs = await SharedPreferences.getInstance();
    final botsJson = prefs.getString('persistent_bots_v2');
    final lastUpdate = prefs.getInt('bots_last_update') ?? 0;
    final userScore = prefs.getInt('user_total_best_score') ?? 0;
    final botsInitialized = prefs.getBool('bots_initialized') ?? false;
    final scoreHistory = prefs.getStringList('user_score_history') ?? [];

    String botInfo = '';
    final buffer = StringBuffer();

    buffer.writeln('=== DEBUG INFO ===');
    buffer.writeln('Bots Initialized: $botsInitialized');
    buffer.writeln('Your Score: $userScore');
    buffer.writeln('Score History Entries: ${scoreHistory.length}');
    buffer.writeln(
      'Last Update: ${lastUpdate > 0 ? DateTime.fromMillisecondsSinceEpoch(lastUpdate).toString() : "Never"}',
    );
    buffer.writeln('');

    if (botsJson != null && botsJson.isNotEmpty) {
      try {
        final decoded = json.decode(botsJson);
        if (decoded is List && decoded.isNotEmpty) {
          buffer.writeln('=== BOTS (${decoded.length} total) ===');

          // Sort by score descending
          final sortedBots = List<Map<String, dynamic>>.from(
            decoded.map((b) => Map<String, dynamic>.from(b)),
          );
          sortedBots.sort(
            (a, b) => (b['score'] ?? 0).compareTo(a['score'] ?? 0),
          );

          for (int i = 0; i < sortedBots.length && i < 10; i++) {
            final bot = sortedBots[i];
            final score = bot['score'] ?? 'NULL';
            final targetRank = bot['targetRank'] ?? 'NULL';
            final isBot = bot['isBot'] ?? 'NULL';
            buffer.writeln('${i + 1}. ${bot['username']}');
            buffer.writeln(
              '   Score: $score | TargetRank: $targetRank | isBot: $isBot',
            );
          }
          if (decoded.length > 10) {
            buffer.writeln('... and ${decoded.length - 10} more');
          }
        } else {
          buffer.writeln('Bot data is empty or invalid format');
        }
      } catch (e) {
        buffer.writeln('Error parsing: $e');
        buffer.writeln(
          'Raw data (first 200 chars): ${botsJson.substring(0, botsJson.length.clamp(0, 200))}',
        );
      }
    } else {
      buffer.writeln('No bot data found in storage!');
      buffer.writeln('Click "Reset All Bot Data" to generate bots.');
    }

    botInfo = buffer.toString();

    if (mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: const Color(0xFF2C1810),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.cyan, width: 2),
              ),
              title: Text(
                '🔍 Bot Debug Data',
                style: GoogleFonts.saira(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Text(
                    botInfo,
                    style: GoogleFonts.sourceCodePro(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: GoogleFonts.saira(color: Colors.white70),
                  ),
                ),
              ],
            ),
      );
    }
  }

  void _showDebugError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Debug Error: $message', style: GoogleFonts.saira()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Dynamic sizing for header
    final headerPadding = screenWidth * 0.04;
    final titleFontSize = screenWidth * 0.07; // 7% of screen width
    final iconSize = screenWidth * 0.06;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C1810), Color(0xFF3D2817), Color(0xFF4A3420)],
          ),
        ),
        child: Stack(
          children: [
            // Floating pixel elements background
            ...List.generate(20, (index) {
              final random = math.Random(index);
              return Positioned(
                left: random.nextDouble() * screenWidth,
                top: random.nextDouble() * screenHeight,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),

            SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(headerPadding),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: iconSize.clamp(20.0, 32.0),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Text(
                          'Settings',
                          style: GoogleFonts.saira(
                            textStyle: TextStyle(
                              fontSize: titleFontSize.clamp(24.0, 36.0),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.02),

                          // Volume Settings Card
                          _buildSettingsCard(
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            title: 'Music Volume',
                            icon: Icons.volume_up,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.volume_down,
                                      color: Colors.white70,
                                      size: screenWidth * 0.05,
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: _volume,
                                        min: 0.0,
                                        max: 1.0,
                                        divisions: 10,
                                        activeColor: const Color(0xFFFFE4B5),
                                        inactiveColor: Colors.white30,
                                        onChanged: (value) {
                                          setState(() {
                                            _volume = value;
                                          });
                                          widget.backgroundMusic.setVolume(
                                            value,
                                          );
                                          _saveVolumeSettings(value);
                                        },
                                      ),
                                    ),
                                    Icon(
                                      Icons.volume_up,
                                      color: Colors.white70,
                                      size: screenWidth * 0.05,
                                    ),
                                  ],
                                ),
                                Text(
                                  '${(_volume * 100).round()}%',
                                  style: GoogleFonts.saira(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Leaderboard Button
                          _buildSettingsButton(
                            title: 'Leaderboard',
                            icon: Icons.leaderboard,
                            color: const Color(0xFF4CAF50),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const LeaderboardScreen(),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Unlimited Design Button
                          _buildSettingsButton(
                            title:
                                _hasUnlimitedDesign
                                    ? 'Unlimited Design'
                                    : 'Unlimited Design 🔒',
                            icon:
                                _hasUnlimitedDesign
                                    ? Icons.auto_awesome
                                    : Icons.lock,
                            color: const Color(0xFFFF6B35),
                            onTap: () {
                              _showUnlimitedDesignDialog();
                            },
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // DEBUG: Leaderboard Bot Testing
                          _buildSettingsButton(
                            title: '🧪 Debug: Bot Algorithm Test',
                            icon: Icons.bug_report,
                            color: Colors.deepPurple,
                            onTap: () {
                              _showBotDebugDialog();
                            },
                          ),

                          // DEVELOPER TESTING FEATURES - REMOVE BEFORE PRODUCTION
                          // Uncomment below for testing only
                          /*
                          SizedBox(height: screenHeight * 0.02),

                          // Payment Testing Screen
                          _buildSettingsButton(
                            title: 'Payment System Testing',
                            icon: Icons.bug_report,
                            color: Colors.deepPurple,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaymentTestScreen(),
                                ),
                              ).then((_) => _checkPurchaseStatus());
                            },
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Developer Quick Unlock
                          _buildSettingsButton(
                            title: 'Developer: Unlock/Reset Feature',
                            icon: Icons.developer_mode,
                            color: Colors.purple,
                            onTap: () async {
                              if (_hasUnlimitedDesign) {
                                // Reset for testing
                                await PaymentService.resetPurchaseForTesting();
                                setState(() {
                                  _hasUnlimitedDesign = false;
                                });
                                _showErrorSnackbar('Feature locked (for testing)');
                              } else {
                                // Unlock instantly
                                await PaymentService.unlockUnlimitedDesign();
                                setState(() {
                                  _hasUnlimitedDesign = true;
                                });
                                _showSuccessSnackbar();
                              }
                            },
                          ),
                          */
                          // END DEVELOPER TESTING FEATURES
                          SizedBox(height: screenHeight * 0.02),

                          // Add bottom padding for scroll space - Dynamic
                          SizedBox(height: screenHeight * 0.05),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required double screenWidth,
    required double screenHeight,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final cardPadding = screenWidth * 0.04;
    final titleFontSize = screenWidth * 0.045;
    final iconSize = screenWidth * 0.06;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3420),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE4B5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFFFE4B5),
                size: iconSize.clamp(20.0, 28.0),
              ),
              SizedBox(width: screenWidth * 0.03),
              Text(
                title,
                style: GoogleFonts.saira(
                  textStyle: TextStyle(
                    fontSize: titleFontSize.clamp(16.0, 22.0),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          child,
        ],
      ),
    );
  }

  Widget _buildSettingsButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.045;
    final iconSize = screenWidth * 0.06;
    final arrowSize = screenWidth * 0.04;

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xFF4A3420),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: iconSize.clamp(20.0, 28.0)),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.saira(
                      textStyle: TextStyle(
                        fontSize: fontSize.clamp(14.0, 20.0),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: arrowSize.clamp(12.0, 18.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
