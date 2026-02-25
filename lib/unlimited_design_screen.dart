import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'system_design_canvas_screen_fixed.dart';
import 'system_description_notebook.dart'; // For CanvasValidationData
import 'inline_training_data_ai_service.dart'; // Use the pure Dart AI service
import 'design_manager.dart';
import 'saved_designs_list_screen.dart';
import 'leaderboard_api_service.dart';

class UnlimitedDesignScreen extends StatefulWidget {
  final SavedDesign? initialDesign;

  const UnlimitedDesignScreen({super.key, this.initialDesign});

  @override
  State<UnlimitedDesignScreen> createState() => _UnlimitedDesignScreenState();
}

class _UnlimitedDesignScreenState extends State<UnlimitedDesignScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _systemNameController = TextEditingController();
  String _currentSystemName = "My Unlimited Design";
  bool _showNameEditor = false;
  String? _currentDesignId;
  GlobalKey<SystemDesignCanvasScreenState> _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // Changed to 1 tab

    // Initialize from saved design if provided
    if (widget.initialDesign != null) {
      _currentSystemName = widget.initialDesign!.name;
      _currentDesignId = widget.initialDesign!.id;
    } else {
      // Create completely new design project
      _currentDesignId = DesignManager.generateId();
      _currentSystemName =
          "New Design Project ${DateTime.now().millisecondsSinceEpoch % 1000}";
    }

    _systemNameController.text = _currentSystemName;
  }

  @override
  void dispose() {
    // Auto-save design to DesignManager when leaving the screen
    _autoSaveOnDispose();
    _tabController.dispose();
    _systemNameController.dispose();
    super.dispose();
  }

  // Auto-save design when leaving the screen (synchronous trigger)
  void _autoSaveOnDispose() {
    try {
      final canvasData = _canvasKey.currentState?.getCanvasData() ?? {};
      final notes = "Auto-saved notes";

      final design = SavedDesign(
        id: _currentDesignId!,
        name: _currentSystemName,
        createdAt: widget.initialDesign?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        canvasData: canvasData,
        notes: widget.initialDesign?.notes ?? notes,
      );

      // Trigger the save asynchronously
      DesignManager.saveDesign(design).then((_) {
        print('DEBUG: Auto-saved design on dispose: $_currentSystemName');
      });
    } catch (e) {
      print('ERROR: Failed to auto-save on dispose: $e');
    }
  }

  Future<void> _saveSystemName() async {
    setState(() {
      _currentSystemName =
          _systemNameController.text.isNotEmpty
              ? _systemNameController.text
              : "My Unlimited Design";
      _showNameEditor = false;
    });

    // Save the design with the new name immediately
    await _saveDesign();
  }

  Future<void> _saveDesign() async {
    try {
      // Get canvas data from the canvas screen
      final canvasData = _canvasKey.currentState?.getCanvasData() ?? {};

      // Get notes data (placeholder for now since notes are in canvas)
      final notes = "Notes from unlimited design"; // TODO: Get actual notes

      final design = SavedDesign(
        id: _currentDesignId!,
        name: _currentSystemName,
        createdAt: widget.initialDesign?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        canvasData: canvasData,
        notes: notes,
      );

      await DesignManager.saveDesign(design);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Design "$_currentSystemName" saved successfully!'),
          backgroundColor: const Color(0xFFFF6B35),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save design: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Save design with actual notes content
  Future<void> _saveDesignWithNotes(String actualNotes) async {
    try {
      // Get canvas data from the canvas screen
      final canvasData = _canvasKey.currentState?.getCanvasData() ?? {};

      final design = SavedDesign(
        id: _currentDesignId!,
        name: _currentSystemName,
        createdAt: widget.initialDesign?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        canvasData: canvasData,
        notes:
            actualNotes, // Use the actual design notes instead of placeholder
      );

      await DesignManager.saveDesign(design);

      print(
        '✅ SAVE: Saved design "${_currentSystemName}" with ${actualNotes.length} character notes',
      );
    } catch (e) {
      print('❌ SAVE: Failed to save design: $e');
    }
  }

  void _showSavedDesigns() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => SavedDesignsListScreen()));
  }

  // Submit design for AI evaluation using our trained model
  // Score breakdown: 50% canvas design (data flow) + 50% notes quality
  Future<void> _submitDesignForEvaluation(
    String question,
    String notes,
    CanvasValidationData? canvasData,
  ) async {
    print(
      '🚀🚀🚀 SUBMIT: Starting evaluation for ${notes.length} character design 🚀🚀🚀',
    );
    print('🚀🚀🚀 SUBMIT: This is the duplicate detection function! 🚀🚀🚀');

    if (notes.trim().isEmpty) {
      _showErrorDialog("Please provide your system design details first.");
      return;
    }

    // Check for similar existing designs before evaluation
    if (await _checkForSimilarDesign(notes)) {
      print(
        '🚨🚨🚨 SUBMIT: Duplicate detected - showing dialog instead of evaluating 🚨🚨🚨',
      );
      _showDuplicateDesignDialog();
      return;
    }

    print(
      '✅✅✅ SUBMIT: No duplicates found - proceeding with AI evaluation ✅✅✅',
    );
    // Auto-save the design before evaluation
    try {
      await _saveDesignWithNotes(notes);
    } catch (e) {
      // Continue with evaluation even if save fails
    }

    // Clear any cached results to ensure fresh evaluation
    try {
      final prefs = await SharedPreferences.getInstance();
      final systemId = _currentSystemName.toLowerCase().replaceAll(' ', '_');
      await prefs.remove('evaluation_$systemId');
    } catch (e) {
      // Cache clear failed, continue anyway
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              backgroundColor: const Color(0xFF4A3420),
              content: Row(
                children: [
                  CircularProgressIndicator(color: const Color(0xFFFF6B35)),
                  const SizedBox(width: 16),
                  Text(
                    'AI is evaluating your design...',
                    style: GoogleFonts.saira(color: Colors.white),
                  ),
                ],
              ),
            ),
      );

      // Use our new inline training data AI model for evaluation
      final aiResult = await InlineTrainingDataAIService.evaluateDesign(
        question:
            question.isNotEmpty
                ? question
                : "Design a comprehensive system architecture",
        answer: notes,
      );

      // Calculate canvas score (50% of total) based on data flow health
      int canvasScore = 0;
      if (canvasData != null) {
        final validationResult = _calculateCanvasValidationResult(canvasData);
        canvasScore = validationResult.canvasScore; // 0-50 points
      }

      // Calculate notes score (50% of total) from AI evaluation
      // AI originally gives 0-100, we scale to 0-50
      final notesScore = ((aiResult.score / 100) * 50).round().clamp(0, 50);

      // Combined total score
      final totalScore = canvasScore + notesScore;

      // Create result with combined scoring
      final combinedResult = {
        'score': totalScore,
        'canvasScore': canvasScore,
        'notesScore': notesScore,
        'feedback':
            aiResult.feedback +
            '\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n' +
            '📊 SCORE BREAKDOWN\n' +
            '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n' +
            '🎨 Canvas Design Score: $canvasScore/50\n' +
            '   (Based on data flow & component connectivity)\n' +
            '📝 Notes Description Score: $notesScore/50\n' +
            '   (Based on system design explanation quality)\n' +
            '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n' +
            '🏆 TOTAL SCORE: $totalScore/100\n',
        'concepts': aiResult.concepts,
        'category': aiResult.category,
        'isSystemDesignRelated': aiResult.isSystemDesignRelated,
      };

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success snackbar with combined score
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'AI evaluation complete! Score: $totalScore/100 (Canvas: $canvasScore + Notes: $notesScore)',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Save the evaluation result to SharedPreferences for the notebook to access
      await _saveEvaluationResult(_currentSystemName, combinedResult);

      // Show results dialog
      _showAIFeedbackDialog(combinedResult);
    } catch (e) {
      // Close loading dialog if open
      try {
        Navigator.of(context).pop();
      } catch (popError) {
        // Dialog already closed
      }

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error evaluating design. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );

      _showErrorDialog("Error evaluating design: $e");
    }
  }

  // Calculate canvas validation result from canvas data
  // Used for the 50% canvas score calculation
  CanvasValidationResult _calculateCanvasValidationResult(
    CanvasValidationData canvasData,
  ) {
    final icons = canvasData.icons;
    final connections = canvasData.connections;

    // Data source icon names (same as in system_design_canvas_screen_fixed.dart)
    final dataSourceIcons = {
      'User',
      'Client',
      'Mobile App',
      'Web Browser',
      'IoT Device',
      'External API',
      'Third Party Service',
      'Webhook',
      'Sensor',
      'Admin Panel',
      'Dashboard',
      'File Upload',
      'Stream Source',
      'Event Source',
    };

    // Check if there's at least one data source
    bool hasDataSource = icons.any(
      (icon) => dataSourceIcons.contains(icon['name']),
    );

    // Count active (green) connections
    int activeConnectionCount =
        connections.where((c) => c['isGreen'] == true).length;

    // Find isolated icons (not connected to anything)
    Set<int> connectedIconIndices = {};
    for (var conn in connections) {
      if (conn['fromIconIndex'] != null)
        connectedIconIndices.add(conn['fromIconIndex']);
      if (conn['toIconIndex'] != null)
        connectedIconIndices.add(conn['toIconIndex']);
    }
    int isolatedIconCount = icons.length - connectedIconIndices.length;
    if (isolatedIconCount < 0) isolatedIconCount = 0;

    // Count blocked icons (icons that don't receive data flow)
    // For simplicity, count icons that are connected but not receiving green connections
    int blockedIconCount = 0;
    if (hasDataSource && icons.isNotEmpty) {
      // Icons that are connected but not part of active (green) flow
      Set<int> activeFlowIcons = {};
      for (var conn in connections) {
        if (conn['isGreen'] == true) {
          if (conn['fromIconIndex'] != null)
            activeFlowIcons.add(conn['fromIconIndex']);
          if (conn['toIconIndex'] != null)
            activeFlowIcons.add(conn['toIconIndex']);
        }
      }
      // Blocked = connected but not in active flow
      for (int i = 0; i < icons.length; i++) {
        if (connectedIconIndices.contains(i) && !activeFlowIcons.contains(i)) {
          blockedIconCount++;
        }
      }
    }

    return CanvasValidationResult(
      warnings: [], // Not used for scoring
      blockedIconCount: blockedIconCount,
      isolatedIconCount: isolatedIconCount,
      totalIconCount: icons.length,
      totalConnectionCount: connections.length,
      activeConnectionCount: activeConnectionCount,
      hasDataSource: hasDataSource,
    );
  }

  // Save evaluation result to SharedPreferences for notebook access
  Future<void> _saveEvaluationResult(
    String systemId,
    Map<String, dynamic> result,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cleanSystemId = _currentSystemName
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');
      final currentScore = result['score'] ?? 0;

      // Create EvaluationResult object
      final evaluationResult = {
        'score': currentScore,
        'feedback': result['feedback'] ?? 'No feedback available',
        'isSystemDesignRelated': true,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Save to SharedPreferences with the same key format the notebook expects
      await prefs.setString(
        'evaluation_$cleanSystemId',
        json.encode(evaluationResult),
      );

      // LEADERBOARD INTEGRATION: Save best score for leaderboard
      final bestScoreKey = 'best_score_unlimited_design_$cleanSystemId';
      final bestTimestampKey =
          'best_score_timestamp_unlimited_design_$cleanSystemId';
      final previousBestScore = prefs.getInt(bestScoreKey) ?? 0;

      if (currentScore > previousBestScore) {
        await prefs.setInt(bestScoreKey, currentScore);
        await prefs.setInt(
          bestTimestampKey,
          DateTime.now().millisecondsSinceEpoch,
        );

        // UPDATE TOTAL BEST SCORE for leaderboard scoring algorithm
        await _updateTotalBestScore(prefs);

        // UPDATE USER SCORE HISTORY for leaderboard scoring algorithm
        final newTotalScore = prefs.getInt('user_total_best_score') ?? 0;
        await _updateUserScoreHistory(prefs, newTotalScore);

        // Submit score to online leaderboard (async, non-blocking)
        _submitScoreToOnlineLeaderboard(
          'Unlimited Design: $_currentSystemName',
          currentScore,
        );

        // Verify the save worked
        final verifyScore = prefs.getInt(bestScoreKey);
        print(
          '🏆 NEW BEST SCORE for $cleanSystemId: $currentScore (previous: $previousBestScore)',
        );
        print('✅ Saved to SharedPreferences successfully');
        print('🔍 Verification read: $verifyScore');

        // Show achievement notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🏆 New personal best: $currentScore points! Check leaderboard.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Save failed, continue anyway
    }
  }

  void _showAIFeedbackDialog(Map<String, dynamic> feedback) {
    // Debug: Print what feedback we're showing
    print('🎨 Showing feedback dialog with: ${feedback['score']}/100');
    print('📄 Feedback content length: ${feedback['feedback']?.length ?? 0}');
    print('📄 Raw feedback: ${feedback['feedback']}');
    print(
      '📄 First 100 chars: ${feedback['feedback']?.substring(0, feedback['feedback']?.length != null && feedback['feedback']!.length > 100 ? 100 : feedback['feedback']?.length ?? 0)}',
    );

    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF4A3420),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: const Color(0xFFFF6B35), width: 2),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: const Color(0xFFFF6B35),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Judge Feedback',
                        style: GoogleFonts.saira(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Show which AI method was used
                      Text(
                        'Method: ${feedback['breakdown']?['ai_type'] ?? 'training_data_based'}',
                        style: GoogleFonts.saira(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: const Color(0xFFFF6B35),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Score: ${feedback['score']}/100',
                          style: GoogleFonts.saira(
                            color: const Color(0xFFFF6B35),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Feedback
                  _buildFeedbackSection(
                    '💬 Feedback',
                    feedback['feedback'] ?? 'No feedback provided',
                  ),
                  const SizedBox(height: 12),

                  // Keywords Found
                  if (feedback['keywords_found'] != null &&
                      (feedback['keywords_found'] as List).isNotEmpty)
                    _buildFeedbackSection(
                      '� Concepts Identified',
                      'Found: ${(feedback['keywords_found'] as List).join(', ')}',
                    ),
                  if (feedback['keywords_found'] != null &&
                      (feedback['keywords_found'] as List).isNotEmpty)
                    const SizedBox(height: 12),

                  // Suggestions
                  if (feedback['suggestions'] != null &&
                      (feedback['suggestions'] as List).isNotEmpty)
                    _buildFeedbackSection(
                      '🚀 Suggestions',
                      (feedback['suggestions'] as List).join('\n• '),
                    ),
                  if (feedback['suggestions'] != null &&
                      (feedback['suggestions'] as List).isNotEmpty)
                    const SizedBox(height: 12),

                  // Encouragement based on score
                  _buildFeedbackSection(
                    '🌟 Encouragement',
                    _getEncouragementMessage(feedback['score'] ?? 0),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Thanks!',
                  style: GoogleFonts.saira(color: const Color(0xFFFF6B35)),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildFeedbackSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.saira(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: GoogleFonts.saira(
            color: Colors.white70,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF4A3420),
            title: Text('Error', style: GoogleFonts.saira(color: Colors.red)),
            content: Text(error, style: GoogleFonts.saira(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: GoogleFonts.saira(color: const Color(0xFFFF6B35)),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        foregroundColor: Colors.white,
        title: GestureDetector(
          onTap: () async {
            if (_showNameEditor) {
              // If in edit mode, save the name and exit edit mode
              await _saveSystemName();
            } else {
              // If not in edit mode, enter edit mode
              setState(() {
                _showNameEditor = true;
              });
            }
          },
          child: Row(
            children: [
              Expanded(
                child:
                    _showNameEditor
                        ? TextField(
                          controller: _systemNameController,
                          style: GoogleFonts.saira(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter system name...',
                            hintStyle: GoogleFonts.saira(
                              color: Colors.white54,
                              fontSize: 18,
                            ),
                          ),
                          onSubmitted: (_) async => await _saveSystemName(),
                        )
                        : Text(
                          _currentSystemName,
                          style: GoogleFonts.saira(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
              Icon(
                _showNameEditor ? Icons.check : Icons.edit,
                color: Colors.white54,
                size: 20,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSavedDesigns,
            icon: Icon(Icons.folder, color: Colors.white, size: 24),
            tooltip: 'Saved Designs',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFF6B35),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFFFF6B35),
          labelStyle: GoogleFonts.saira(fontWeight: FontWeight.bold),
          tabs: [Tab(text: 'Design Canvas')], // Only Canvas tab
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(), // Disable swiping
        children: [
          // Canvas Tab with Submit functionality
          SystemDesignCanvasScreen(
            key: _canvasKey,
            systemName: _currentSystemName,
            initialCanvasData: widget.initialDesign?.canvasData,
            initialNotes:
                widget.initialDesign?.notes, // Pass notes from shared design
            onSubmitDesign:
                _submitDesignForEvaluation, // New callback for submission
          ),
        ],
      ),
    );
  }

  String _getEncouragementMessage(int score) {
    if (score >= 80) {
      return 'Excellent work! Your system design shows deep understanding and attention to detail.';
    } else if (score >= 60) {
      return 'Good progress! You\'re on the right track with solid system design fundamentals.';
    } else if (score >= 40) {
      return 'Keep learning! Focus on scalability, performance, and architectural patterns.';
    } else if (score >= 20) {
      return 'Great start! Study the training examples to improve your system design skills.';
    } else {
      return 'Every expert was once a beginner. Keep practicing and refer to the training examples!';
    }
  }

  // Update user score history for leaderboard scoring algorithm
  Future<void> _updateUserScoreHistory(
    SharedPreferences prefs,
    int currentScore,
  ) async {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final historyEntry = jsonEncode({
      'score': currentScore,
      'timestamp': currentTime,
    });

    // Get existing history
    final scoreHistory = prefs.getStringList('user_score_history') ?? [];

    // Add new entry
    scoreHistory.add(historyEntry);

    // Keep only last 30 days of history (remove older entries)
    final thirtyDaysAgo =
        DateTime.now()
            .subtract(const Duration(days: 30))
            .millisecondsSinceEpoch;
    scoreHistory.removeWhere((entry) {
      try {
        final data = jsonDecode(entry);
        final timestamp = data['timestamp'] as int;
        return timestamp < thirtyDaysAgo;
      } catch (e) {
        return true; // Remove invalid entries
      }
    });

    // Save updated history
    await prefs.setStringList('user_score_history', scoreHistory);

    print('📈 SCORE HISTORY UPDATED: Added score $currentScore to history');
    print('📊 Total history entries: ${scoreHistory.length}');
  }

  /// Submit score to the online leaderboard API (non-blocking)
  void _submitScoreToOnlineLeaderboard(String systemName, int score) async {
    try {
      if (LeaderboardApiConfig.useOnlineLeaderboard) {
        await LeaderboardApiService.instance.submitScore(
          systemName: systemName,
          score: score,
        );
        print('🌐 Score submitted to online leaderboard: $systemName = $score');
      }
    } catch (e) {
      // Silently fail - online leaderboard is optional
      print('Failed to submit score to online leaderboard: $e');
    }
  }

  // Update total best score by calculating sum of all best scores
  Future<void> _updateTotalBestScore(SharedPreferences prefs) async {
    int totalBestScore = 0;

    // Regular system design scores
    final systemNames = [
      'url_shortener_(e.g.,_tinyurl)',
      'pastebin_service_(e.g.,_pastebin.com)',
      'web_crawler',
      'social_media_news_feed_(e.g.,_facebook,_x/twitter)',
      'video_streaming_service_(e.g.,_netflix,_youtube)',
      'ride-sharing_service_(e.g.,_uber,_lyft)',
      'collaborative_editor_(e.g.,_google_docs,_figma)',
      'live_streaming_platform_(e.g.,_twitch,_youtube_live)',
      'global_gaming_leaderboard',
    ];

    for (final systemName in systemNames) {
      final bestScore = prefs.getInt('best_score_$systemName') ?? 0;
      totalBestScore += bestScore;
    }

    // Unlimited design scores
    final unlimitedDesignKeys =
        prefs
            .getKeys()
            .where((key) => key.startsWith('best_score_unlimited_design_'))
            .toList();

    for (final key in unlimitedDesignKeys) {
      final bestScore = prefs.getInt(key) ?? 0;
      totalBestScore += bestScore;
    }

    // Save total best score
    await prefs.setInt('user_total_best_score', totalBestScore);

    print('🎯 TOTAL SCORE UPDATED: $totalBestScore');
    print(
      '   Regular systems contribute: ${totalBestScore - unlimitedDesignKeys.fold(0, (sum, key) => sum + (prefs.getInt(key) ?? 0))}',
    );
    print(
      '   Unlimited design contributes: ${unlimitedDesignKeys.fold(0, (sum, key) => sum + (prefs.getInt(key) ?? 0))}',
    );
  }

  // Check if current design is similar to any existing saved designs
  Future<bool> _checkForSimilarDesign(String currentNotes) async {
    try {
      final savedDesigns = await DesignManager.getSavedDesigns();
      print(
        '🔍 DUPLICATE CHECK: Found ${savedDesigns.length} saved designs to compare against',
      );

      if (savedDesigns.isEmpty) {
        print(
          '🔍 DUPLICATE CHECK: No saved designs found - allowing submission',
        );
        return false;
      }

      print(
        '🔍 DUPLICATE CHECK: Current notes: "${currentNotes.substring(0, currentNotes.length > 100 ? 100 : currentNotes.length)}..."',
      );
      print('🔍 DUPLICATE CHECK: FULL current notes: "$currentNotes"');

      for (int i = 0; i < savedDesigns.length; i++) {
        final design = savedDesigns[i];

        // Skip comparing with the current design (if it's being updated)
        if (design.id == _currentDesignId) {
          print(
            '🔍 DUPLICATE CHECK: Skipping comparison with current design (${design.id})',
          );
          continue;
        }

        final similarity = _calculateSimilarity(currentNotes, design.notes);
        print('🔍 DUPLICATE CHECK: FULL saved design notes: "${design.notes}"');
        print(
          '🔍 DUPLICATE CHECK: Design ${i + 1} "${design.name}": ${(similarity * 100).toStringAsFixed(1)}% similar',
        );

        if (similarity >= 0.8) {
          // 80% or more similarity
          print(
            '🚨 DUPLICATE DETECTED! Similarity: ${(similarity * 100).toStringAsFixed(2)}% (>= 80%)',
          );
          return true;
        }
      }
      print('✅ DUPLICATE CHECK: No duplicates found - allowing submission');
      return false;
    } catch (e) {
      print('❌ DUPLICATE CHECK: Error checking similarity: $e');
      // If there's an error checking, allow the design to proceed
      return false;
    }
  }

  // Calculate similarity between two text strings (0.0 to 1.0)
  // Focuses on comparing only the "System Description" part
  double _calculateSimilarity(String text1, String text2) {
    if (text1.isEmpty && text2.isEmpty) return 1.0;
    if (text1.isEmpty || text2.isEmpty) return 0.0;

    // Extract only the description part from both texts
    final description1 = _extractDescription(text1);
    final description2 = _extractDescription(text2);

    print(
      '   📝 Extracted description 1: "${description1.substring(0, description1.length > 50 ? 50 : description1.length)}..."',
    );
    print(
      '   📝 Extracted description 2: "${description2.substring(0, description2.length > 50 ? 50 : description2.length)}..."',
    );

    // If no descriptions found, fall back to full text comparison
    final compareText1 = description1.isNotEmpty ? description1 : text1;
    final compareText2 = description2.isNotEmpty ? description2 : text2;

    // Normalize texts: lowercase, remove extra spaces, basic cleanup
    final normalized1 =
        compareText1.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    final normalized2 =
        compareText2.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

    if (normalized1 == normalized2) return 1.0;

    // Simple word-based similarity
    final words1 = normalized1.split(' ').toSet();
    final words2 = normalized2.split(' ').toSet();

    final intersection = words1.intersection(words2).length;
    final union = words1.union(words2).length;

    final similarity = union > 0 ? intersection / union : 0.0;

    // Debug output for similarity calculation
    print(
      '   📊 Words1: ${words1.length}, Words2: ${words2.length}, Common: $intersection, Total: $union → ${(similarity * 100).toStringAsFixed(1)}%',
    );

    return similarity;
  }

  // Extract the description part from the design notes
  String _extractDescription(String notes) {
    // Look for "System Description:" section
    final lines = notes.split('\n');
    bool inDescription = false;
    String description = '';

    for (String line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.toLowerCase().contains('system description:')) {
        inDescription = true;
        continue;
      }

      if (inDescription) {
        // Stop when we hit another section (like "Components Used:")
        if (trimmedLine.toLowerCase().contains('components used:') ||
            trimmedLine.toLowerCase().contains('architecture:') ||
            trimmedLine.toLowerCase().contains('design patterns:') ||
            (trimmedLine.endsWith(':') && trimmedLine.length > 3)) {
          break;
        }

        // Skip empty lines
        if (trimmedLine.isNotEmpty) {
          description += trimmedLine + ' ';
        }
      }
    }

    return description.trim();
  }

  // Show dialog when duplicate design is detected
  void _showDuplicateDesignDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Design Already Exists'),
              ],
            ),
            content: Text(
              'This design appears to be very similar (80%+ match) to one of your previously saved designs. Please modify your design to make it more unique before submitting for evaluation.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK', style: TextStyle(color: Color(0xFFFF6B35))),
              ),
            ],
          ),
    );
  }
}
