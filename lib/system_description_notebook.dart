import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'system_database_manager.dart';
import 'ai_feedback_system.dart';
import 'evaluation_result.dart';
import 'leaderboard_api_service.dart';

// Data class for canvas validation
class CanvasValidationData {
  final List<Map<String, dynamic>> icons;
  final List<Map<String, dynamic>> connections;

  CanvasValidationData({required this.icons, required this.connections});
}

// Validation result with penalty info
class CanvasValidationResult {
  final List<String> warnings;
  final int blockedIconCount;
  final int isolatedIconCount;
  final int totalIconCount;
  final int totalConnectionCount;
  final int activeConnectionCount; // Connections with data flow
  final bool hasDataSource;

  CanvasValidationResult({
    required this.warnings,
    required this.blockedIconCount,
    required this.isolatedIconCount,
    required this.totalIconCount,
    required this.totalConnectionCount,
    required this.activeConnectionCount,
    required this.hasDataSource,
  });

  // Calculate score penalty (0-30 points max penalty)
  int get scorePenalty {
    int penalty = 0;

    // No data source = major penalty
    if (!hasDataSource && totalIconCount > 0) {
      penalty += 15;
    }

    // Blocked icons penalty (up to 10 points)
    if (totalIconCount > 0) {
      final blockedRatio = blockedIconCount / totalIconCount;
      penalty += (blockedRatio * 10).round();
    }

    // Isolated icons penalty (up to 5 points)
    if (totalIconCount > 0) {
      final isolatedRatio = isolatedIconCount / totalIconCount;
      penalty += (isolatedRatio * 5).round();
    }

    return penalty.clamp(0, 30);
  }

  // Data flow health percentage
  int get dataFlowHealth {
    if (totalConnectionCount == 0) return 0;
    return ((activeConnectionCount / totalConnectionCount) * 100).round();
  }

  // Canvas score (0-50 points) based on design complexity and data flow
  int get canvasScore {
    if (totalIconCount == 0) return 0;

    // Calculate a complexity multiplier based on icon count
    // 1-2 icons = 0.1x, 3-4 = 0.3x, 5-6 = 0.5x, 7-9 = 0.7x, 10+ = 1.0x
    double complexityMultiplier;
    if (totalIconCount >= 10) {
      complexityMultiplier = 1.0;
    } else if (totalIconCount >= 7) {
      complexityMultiplier = 0.7;
    } else if (totalIconCount >= 5) {
      complexityMultiplier = 0.5;
    } else if (totalIconCount >= 3) {
      complexityMultiplier = 0.3;
    } else {
      complexityMultiplier = 0.1; // 1-2 icons = very low multiplier
    }

    int score = 0;

    // COMPONENT QUANTITY BASE (up to 20 points)
    score += (20 * complexityMultiplier).round();

    // CONNECTION QUANTITY (up to 15 points) - also scaled
    double connectionScore = 0;
    if (totalConnectionCount >= 8) {
      connectionScore = 15;
    } else if (totalConnectionCount >= 5) {
      connectionScore = 10;
    } else if (totalConnectionCount >= 3) {
      connectionScore = 7;
    } else if (totalConnectionCount >= 1) {
      connectionScore = 3;
    }
    score += (connectionScore * complexityMultiplier).round();

    // DATA FLOW HEALTH (up to 10 points) - scaled by complexity
    final flowScore = ((dataFlowHealth / 100) * 10).round();
    score += (flowScore * complexityMultiplier).round();

    // DATA SOURCE BONUS (up to 5 points) - scaled by complexity
    if (hasDataSource) {
      score += (5 * complexityMultiplier).round();
    }

    return score.clamp(0, 50);
  }
}

class SystemDescriptionNotebook extends StatefulWidget {
  final String? systemId;
  final String? systemName;
  final List<String>? usedComponents;
  final Function(String, String, CanvasValidationData?)?
  onSubmitDesign; // Add callback for AI evaluation with canvas data
  final CanvasValidationData? canvasData; // Canvas data for validation

  const SystemDescriptionNotebook({
    super.key,
    this.systemId,
    this.systemName,
    this.usedComponents,
    this.onSubmitDesign, // Add the callback parameter
    this.canvasData, // Canvas data for validation
  });

  @override
  State<SystemDescriptionNotebook> createState() =>
      _SystemDescriptionNotebookState();
}

class _SystemDescriptionNotebookState extends State<SystemDescriptionNotebook> {
  late TextEditingController _controller;
  late String currentSystemId;
  late String displaySystemName;
  bool _isEvaluating = false;
  EvaluationResult? _lastEvaluation;

  @override
  void initState() {
    super.initState();
    // Create unique system ID or use provided one
    currentSystemId =
        widget.systemId ?? 'system_${DateTime.now().millisecondsSinceEpoch}';
    displaySystemName = widget.systemName ?? 'Current System';
    _controller = TextEditingController();
    _loadNote();
    _loadEvaluation();

    // Migrate existing notes to new database (run once)
    _migrateNotesIfNeeded();
  }

  // Add method to refresh evaluation - call this when notebook is opened after AI evaluation
  Future<void> refreshEvaluation() async {
    _loadEvaluation();
    if (mounted) {
      setState(() {}); // Refresh the UI
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh evaluation when the widget becomes visible again
    // This handles the case where user submits via notebook, evaluation completes,
    // and then user opens notebook again
    _loadEvaluation();
  }

  void _migrateNotesIfNeeded() async {
    // Migration is no longer needed since we use specific databases
  }

  void _loadNote() async {
    // Load from specific system database
    final savedNote = await SystemDatabaseManager.loadNotesFromSpecificDatabase(
      displaySystemName,
    );

    if (savedNote != null && savedNote.isNotEmpty) {
      setState(() {
        _controller.text = savedNote;
      });
      return;
    }

    // Fallback to old SharedPreferences method
    final prefs = await SharedPreferences.getInstance();
    final oldNote = prefs.getString('systemNote_$currentSystemId');
    setState(() {
      _controller.text =
          oldNote ??
          '# $displaySystemName\n\nDescribe your system architecture here...';
    });
  }

  void _saveNote() async {
    // Check for duplicate notes across other systems
    final currentNotes = _controller.text.trim();
    if (currentNotes.length > 50) {
      // Only check if notes are substantial
      final duplicateSystem = await _checkForDuplicateNotes(currentNotes);
      if (duplicateSystem != null) {
        final shouldProceed = await _showDuplicateWarningDialog(
          duplicateSystem,
        );
        if (!shouldProceed) {
          return; // Don't save if user cancels
        }
      }
    }

    // Save to specific system database for parallel comparison
    await SystemDatabaseManager.saveNotesToSpecificDatabase(
      displaySystemName,
      _controller.text,
    );

    // Also save to SharedPreferences for backward compatibility
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('systemNote_$currentSystemId', _controller.text);
  }

  /// Check if current notes are too similar to notes from other systems
  /// Returns the name of the similar system if found, null otherwise
  Future<String?> _checkForDuplicateNotes(String currentNotes) async {
    final systemNames = [
      'URL Shortener (e.g., TinyURL)',
      'Pastebin Service (e.g., Pastebin.com)',
      'Web Crawler',
      'Social Media News Feed (e.g., Facebook, X/Twitter)',
      'Video Streaming Service (e.g., Netflix, YouTube)',
      'Ride-Sharing Service (e.g., Uber, Lyft)',
      'Collaborative Editor (e.g., Google Docs, Figma)',
      'Live Streaming Platform (e.g., Twitch, YouTube Live)',
      'Global Gaming Leaderboard',
    ];

    for (final systemName in systemNames) {
      // Skip the current system
      if (systemName == displaySystemName) continue;

      // Load notes from this system
      final otherNotes =
          await SystemDatabaseManager.loadNotesFromSpecificDatabase(systemName);

      if (otherNotes != null && otherNotes.trim().length > 50) {
        // Calculate similarity
        final similarity = _calculateTextSimilarity(currentNotes, otherNotes);

        if (similarity >= 0.70) {
          // 70% or more similarity
          return systemName;
        }
      }
    }

    return null;
  }

  /// Calculate text similarity between two strings (0.0 to 1.0)
  /// Uses Jaccard similarity on word sets
  double _calculateTextSimilarity(String text1, String text2) {
    // Normalize texts: lowercase, remove special chars, split into words
    final words1 = _normalizeAndTokenize(text1);
    final words2 = _normalizeAndTokenize(text2);

    if (words1.isEmpty || words2.isEmpty) return 0.0;

    // Convert to sets for Jaccard similarity
    final set1 = words1.toSet();
    final set2 = words2.toSet();

    // Jaccard similarity: intersection / union
    final intersection = set1.intersection(set2).length;
    final union = set1.union(set2).length;

    return union > 0 ? intersection / union : 0.0;
  }

  /// Normalize text and split into words
  Set<String> _normalizeAndTokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove punctuation
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2) // Ignore very short words
        .toSet();
  }

  /// Show warning dialog when duplicate notes are detected
  Future<bool> _showDuplicateWarningDialog(String similarSystemName) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1a1a2e),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Duplicate Design Detected',
                  style: GoogleFonts.sourceCodePro(
                    color: Colors.orange,
                    fontSize: 18,
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
                  'Your notes are more than 70% similar to:',
                  style: GoogleFonts.roboto(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.system_update_alt,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          similarSystemName,
                          style: GoogleFonts.sourceCodePro(
                            color: Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Each system should have unique design notes. Would you like to:',
                  style: GoogleFonts.roboto(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Go Back & Edit',
                  style: GoogleFonts.roboto(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  foregroundColor: Colors.orange,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Save Anyway',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  void _loadEvaluation() async {
    final prefs = await SharedPreferences.getInstance();
    final evaluationJson = prefs.getString('evaluation_$currentSystemId');
    if (evaluationJson != null) {
      setState(() {
        _lastEvaluation = EvaluationResult.fromJson(jsonDecode(evaluationJson));
      });
    }
  }

  void _saveEvaluation(EvaluationResult result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'evaluation_$currentSystemId',
      jsonEncode(result.toJson()),
    );

    // Store evaluation data for leaderboard (same logic as LeaderboardScreen.addEvaluationScore)
    final evaluationData = {
      'score': result.score,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'systemName': widget.systemName,
      'feedback': result.feedback,
    };
    await prefs.setString(
      'evaluation_$currentSystemId',
      jsonEncode(evaluationData),
    );

    // Track best score per system for leaderboard
    final bestScoreKey = 'best_score_$currentSystemId';
    final currentBestScore = prefs.getInt(bestScoreKey) ?? 0;
    if (result.score > currentBestScore) {
      await prefs.setInt(bestScoreKey, result.score);
      await prefs.setString(
        'best_score_system_$currentSystemId',
        widget.systemName ?? displaySystemName,
      );
      await prefs.setInt(
        'best_score_timestamp_$currentSystemId',
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    // Mark that this system has been completed (evaluated)
    await prefs.setBool('system_completed_$currentSystemId', true);

    // Also save the general completion flag for leaderboard access
    await prefs.setBool('has_completed_system_design', true);

    // Update the user's overall best score for leaderboard display (from all systems)
    await _updateOverallBestScore(prefs);

    // Submit score to online leaderboard (async, non-blocking)
    _submitScoreToOnlineLeaderboard(
      widget.systemName ?? displaySystemName,
      result.score,
    );
  }

  /// Submit score to the online leaderboard API (non-blocking)
  void _submitScoreToOnlineLeaderboard(String systemName, int score) async {
    try {
      if (LeaderboardApiConfig.useOnlineLeaderboard) {
        await LeaderboardApiService.instance.submitScore(
          systemName: systemName,
          score: score,
        );
      }
    } catch (e) {
      // Silently fail - online leaderboard is optional
      print('Failed to submit score to online leaderboard: $e');
    }
  }

  Future<void> _updateOverallBestScore(SharedPreferences prefs) async {
    // Calculate total of best scores from all systems
    final systemNames = [
      'URL Shortener (e.g., TinyURL)',
      'Pastebin Service (e.g., Pastebin.com)',
      'Web Crawler',
      'Social Media News Feed (e.g., Facebook, X/Twitter)',
      'Video Streaming Service (e.g., Netflix, YouTube)',
      'Ride-Sharing Service (e.g., Uber, Lyft)',
      'Collaborative Editor (e.g., Google Docs, Figma)',
      'Live Streaming Platform (e.g., Twitch, YouTube Live)',
      'Global Gaming Leaderboard',
    ];

    int totalBestScore = 0;
    String bestSystemOverall = '';
    int highestSingleScore = 0;

    for (final systemName in systemNames) {
      final systemId = systemName.toLowerCase().replaceAll(' ', '_');
      final bestScore = prefs.getInt('best_score_$systemId') ?? 0;

      if (bestScore > 0) {
        totalBestScore += bestScore;

        // Track which system gave the highest single score
        if (bestScore > highestSingleScore) {
          highestSingleScore = bestScore;
          bestSystemOverall = systemName;
        }
      }
    }

    // INCLUDE UNLIMITED DESIGN SCORES in total calculation
    final unlimitedDesignKeys =
        prefs
            .getKeys()
            .where((key) => key.startsWith('best_score_unlimited_design_'))
            .toList();

    for (final key in unlimitedDesignKeys) {
      final bestScore = prefs.getInt(key) ?? 0;
      if (bestScore > 0) {
        totalBestScore += bestScore;

        // Track which system gave the highest single score (including unlimited design)
        if (bestScore > highestSingleScore) {
          highestSingleScore = bestScore;
          final systemId = key.replaceFirst('best_score_unlimited_design_', '');
          final displayName = systemId
              .replaceAll('_', ' ')
              .split(' ')
              .map(
                (word) =>
                    word.isEmpty
                        ? word
                        : word[0].toUpperCase() + word.substring(1),
              )
              .join(' ');
          bestSystemOverall = 'Unlimited Design: $displayName';
        }
      }
    }

    // Save overall statistics
    await prefs.setInt('user_total_best_score', totalBestScore);
    await prefs.setInt('user_highest_single_score', highestSingleScore);
    await prefs.setString('user_best_system_overall', bestSystemOverall);

    // Track user score history for bot calculations
    await _updateUserScoreHistory(prefs, totalBestScore);
  }

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
  }

  // Build comprehensive notes for AI evaluation
  String _buildComprehensiveNotes() {
    String notes = '';

    // Add system overview
    notes += 'System: ${displaySystemName}\n\n';

    // Add user's description from notebook
    if (_controller.text.trim().isNotEmpty) {
      notes += 'System Description:\n${_controller.text.trim()}\n\n';
    }

    // Add components used (if available)
    if (widget.usedComponents != null && widget.usedComponents!.isNotEmpty) {
      notes += 'Components Used:\n';
      for (String component in widget.usedComponents!) {
        notes += '- $component\n';
      }
      notes += '\n';
    }

    // Add architectural insights based on components
    if (widget.usedComponents != null && widget.usedComponents!.isNotEmpty) {
      notes += 'Architectural Insights:\n';
      if (widget.usedComponents!.contains('Load Balancer')) {
        notes += '- Implements load balancing for scalability\n';
      }
      if (widget.usedComponents!.contains('Database')) {
        notes += '- Uses database for data persistence\n';
      }
      if (widget.usedComponents!.contains('Cache')) {
        notes += '- Implements caching for performance optimization\n';
      }
      if (widget.usedComponents!.contains('API Gateway')) {
        notes += '- Uses API gateway for service orchestration\n';
      }
      if (widget.usedComponents!.contains('Message Queue')) {
        notes += '- Uses message queues for asynchronous processing\n';
      }
      if (widget.usedComponents!.contains('CDN')) {
        notes += '- Implements CDN for content delivery optimization\n';
      }
      if (widget.usedComponents!.contains('Microservice')) {
        notes += '- Uses microservices architecture for modularity\n';
      }
      notes += '\n';
    }

    notes +=
        'The design focuses on creating a scalable and maintainable system architecture.';

    return notes;
  }

  void _submitForEvaluation() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write some notes before submitting'),
        ),
      );
      return;
    }

    // Validate the canvas design before submitting
    if (widget.canvasData != null) {
      final validationResult = _validateCanvasDesign();
      if (validationResult.warnings.isNotEmpty) {
        _showValidationWarningDialog(validationResult);
        return;
      }
    }

    _proceedWithSubmission();
  }

  // Validate the canvas design for issues
  CanvasValidationResult _validateCanvasDesign() {
    final warnings = <String>[];
    final canvasData = widget.canvasData;
    if (canvasData == null) {
      return CanvasValidationResult(
        warnings: [],
        blockedIconCount: 0,
        isolatedIconCount: 0,
        totalIconCount: 0,
        totalConnectionCount: 0,
        activeConnectionCount: 0,
        hasDataSource: false,
      );
    }

    final icons = canvasData.icons;
    final connections = canvasData.connections;

    // Data source icons - same as defined in the canvas screen
    const dataSourceIcons = {
      'Mobile Client',
      'Desktop Client',
      'Tablet Client',
      'Web Browser',
      'User',
      'Admin User',
      'Group Users',
      'Third Party API',
      'Weather Service',
      'Social Media API',
      'GPS Tracking',
      'Scheduler',
      'Alert System',
      'Push Notification',
    };

    // Build connection graph for analysis
    Map<int, Set<int>> outgoingConnections = {};
    Set<int> connectedIconsAsTail = {};
    Set<int> connectedIconsAsHead = {};
    int greenConnectionCount = 0;

    for (final conn in connections) {
      final fromIndex = conn['fromIconIndex'] as int?;
      final toIndex = conn['toIconIndex'] as int?;
      final isGreen = conn['isGreen'] as bool? ?? false;

      if (fromIndex != null && toIndex != null && isGreen) {
        greenConnectionCount++;
        outgoingConnections.putIfAbsent(fromIndex, () => {});
        outgoingConnections[fromIndex]!.add(toIndex);

        connectedIconsAsTail.add(fromIndex);
        connectedIconsAsHead.add(toIndex);
      }
    }

    // Find source icons in the design
    Set<int> sourceIconIndices = {};
    for (int i = 0; i < icons.length; i++) {
      final iconName = icons[i]['name'] as String? ?? '';
      if (dataSourceIcons.contains(iconName)) {
        sourceIconIndices.add(i);
      }
    }

    // Check 1: Icons not connected to any data source (data flow blockage)
    Set<int> iconsReachableFromSource = Set.from(sourceIconIndices);
    List<int> queue = sourceIconIndices.toList();

    while (queue.isNotEmpty) {
      final currentIcon = queue.removeAt(0);
      final nextIcons = outgoingConnections[currentIcon] ?? {};

      for (final nextIcon in nextIcons) {
        if (!iconsReachableFromSource.contains(nextIcon)) {
          iconsReachableFromSource.add(nextIcon);
          queue.add(nextIcon);
        }
      }
    }

    // Find icons that are NOT reachable from any data source
    List<String> blockedIcons = [];
    for (int i = 0; i < icons.length; i++) {
      final iconName = icons[i]['name'] as String? ?? '';
      if (!sourceIconIndices.contains(i) &&
          !iconsReachableFromSource.contains(i)) {
        // This icon is not a source and not reachable from any source
        if (connectedIconsAsHead.contains(i) ||
            connectedIconsAsTail.contains(i)) {
          // It has connections but still not reachable - data flow blockage
          blockedIcons.add(iconName);
        }
      }
    }

    if (blockedIcons.isNotEmpty) {
      warnings.add(
        '⚠️ DATA FLOW BLOCKAGE: The following icons are not connected to any data source:\n'
        '   ${blockedIcons.take(5).join(', ')}${blockedIcons.length > 5 ? ' and ${blockedIcons.length - 5} more' : ''}',
      );
    }

    // Check 2: Isolated icons (no connections at all)
    List<String> isolatedIcons = [];
    for (int i = 0; i < icons.length; i++) {
      final iconName = icons[i]['name'] as String? ?? '';
      if (!connectedIconsAsTail.contains(i) &&
          !connectedIconsAsHead.contains(i)) {
        isolatedIcons.add(iconName);
      }
    }

    if (isolatedIcons.isNotEmpty) {
      warnings.add(
        '⚠️ ISOLATED ICONS: The following icons have no connections:\n'
        '   ${isolatedIcons.take(5).join(', ')}${isolatedIcons.length > 5 ? ' and ${isolatedIcons.length - 5} more' : ''}',
      );
    }

    // Check 3: No data sources in the design
    if (sourceIconIndices.isEmpty && icons.isNotEmpty) {
      warnings.add(
        '⚠️ NO DATA SOURCE: Your design has no data source icons (like Mobile Client, User, Web Browser, etc.).\n'
        '   Without a data source, data flow cannot be visualized.',
      );
    }

    // Count active connections (connections where tail icon is reachable from source)
    int activeConnectionCount = 0;
    for (final conn in connections) {
      final fromIndex = conn['fromIconIndex'] as int?;
      final isGreen = conn['isGreen'] as bool? ?? false;
      if (fromIndex != null &&
          isGreen &&
          iconsReachableFromSource.contains(fromIndex)) {
        activeConnectionCount++;
      }
    }

    return CanvasValidationResult(
      warnings: warnings,
      blockedIconCount: blockedIcons.length,
      isolatedIconCount: isolatedIcons.length,
      totalIconCount: icons.length,
      totalConnectionCount: greenConnectionCount,
      activeConnectionCount: activeConnectionCount,
      hasDataSource: sourceIconIndices.isNotEmpty,
    );
  }

  // Show warning dialog and ask user to confirm or fix
  void _showValidationWarningDialog(CanvasValidationResult result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2C1810),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFFF6B35), width: 2),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFF6B35),
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  'Design Issues Found',
                  style: GoogleFonts.saira(
                    color: const Color(0xFFFFE4B5),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score penalty summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.trending_down,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Estimated Score Penalty: -${result.scorePenalty} points',
                              style: GoogleFonts.saira(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              result.dataFlowHealth >= 70
                                  ? Icons.bolt
                                  : Icons.bolt_outlined,
                              color:
                                  result.dataFlowHealth >= 70
                                      ? Colors.green
                                      : Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Data Flow Health: ${result.dataFlowHealth}% (${result.activeConnectionCount}/${result.totalConnectionCount} active)',
                                style: GoogleFonts.saira(
                                  color:
                                      result.dataFlowHealth >= 70
                                          ? Colors.green
                                          : Colors.orange,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Issues detected:',
                    style: GoogleFonts.robotoSlab(
                      color: const Color(0xFFFFE4B5),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...result.warnings.map(
                    (w) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFF6B35).withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        w,
                        style: GoogleFonts.robotoSlab(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tip: Connect all icons in a chain from data sources (like Mobile Client or User) to ensure data flows through your entire system.',
                    style: GoogleFonts.robotoSlab(
                      color: Colors.white54,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFFE4B5),
                ),
                child: Text(
                  'Go Back & Fix',
                  style: GoogleFonts.saira(fontSize: 14),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _proceedWithSubmission();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Submit Anyway',
                  style: GoogleFonts.saira(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _proceedWithSubmission() {
    // Auto-save notes before submitting for evaluation
    _saveNote();

    // Show brief confirmation that notes are saved
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notes saved and submitting for evaluation...'),
        duration: Duration(seconds: 1),
      ),
    );

    // If we have the main canvas submit callback (unlimited design), use that
    if (widget.onSubmitDesign != null) {
      print(
        '📝📝📝 NOTEBOOK: Using unlimited design callback - should call duplicate detection! 📝📝📝',
      );
      // Build comprehensive notes from the notebook content
      String comprehensiveNotes = _buildComprehensiveNotes();

      print(
        '📝📝📝 NOTEBOOK: Built comprehensive notes: ${comprehensiveNotes.length} characters 📝📝📝',
      );

      // Call the main canvas submit function with canvas data for scoring
      widget.onSubmitDesign!(
        "Design: ${displaySystemName}",
        comprehensiveNotes,
        widget.canvasData, // Pass canvas data for 50/50 scoring
      );

      // Close the notebook since evaluation will happen in the main screen
      Navigator.of(context).pop();
      return;
    }

    print(
      '📝📝📝 NOTEBOOK: No callback found - using original AI system (no duplicate detection) 📝📝📝',
    );
    // Use original AIFeedbackSystem for standalone design evaluation
    _evaluateWithOriginalAI();
  }

  void _evaluateWithOriginalAI() async {
    final displaySystemName = widget.systemName ?? widget.systemId ?? 'System';

    setState(() {
      _isEvaluating = true;
    });

    try {
      // Use your original AIFeedbackSystem exactly as it was with index-based matching
      final aiResult = await AIFeedbackSystem.generateFeedbackForSystem(
        displaySystemName,
        canvasComponents: widget.usedComponents,
      );

      // Calculate canvas score (50% of total) based on data flow health
      int canvasScore = 0;
      if (widget.canvasData != null) {
        final validationResult = _validateCanvasDesign();
        canvasScore = validationResult.canvasScore; // 0-50 points
      }

      // Calculate notes score (50% of total) from AI evaluation
      // AI originally gives 0-100, we scale to 0-50
      final notesScore = ((aiResult.score / 100) * 50).round().clamp(0, 50);

      // Combined total score
      final totalScore = canvasScore + notesScore;

      // Build comprehensive feedback showing both scores
      String feedback = aiResult.feedback;
      feedback += '\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
      feedback += '📊 SCORE BREAKDOWN\n';
      feedback += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
      feedback += '🎨 Canvas Design Score: $canvasScore/50\n';
      feedback += '   (Based on data flow & component connectivity)\n';
      feedback += '📝 Notes Description Score: $notesScore/50\n';
      feedback += '   (Based on system design explanation quality)\n';
      feedback += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
      feedback += '🏆 TOTAL SCORE: $totalScore/100\n';

      // Convert AIFeedbackResult to EvaluationResult for compatibility
      final result = EvaluationResult(
        score: totalScore,
        canvasScore: canvasScore,
        notesScore: notesScore,
        feedback: feedback,
        isSystemDesignRelated: true,
      );

      setState(() {
        _lastEvaluation = result;
        _isEvaluating = false;
      });

      _saveEvaluation(result);
      _showEvaluationResult(result);
    } catch (error) {
      setState(() {
        _isEvaluating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Evaluation failed: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEvaluationResult(EvaluationResult result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2C1810),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFFF6B35), width: 2),
            ),
            title: Row(
              children: [
                Icon(
                  result.score >= 70 ? Icons.emoji_events : Icons.assessment,
                  color:
                      result.score >= 70
                          ? Colors.amber
                          : const Color(0xFFFF6B35),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Evaluation Results',
                  style: GoogleFonts.saira(
                    color: const Color(0xFFFFE4B5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Score Display
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            result.score >= 70
                                ? Colors.green.withOpacity(0.2)
                                : result.score >= 40
                                ? Colors.orange.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              result.score >= 70
                                  ? Colors.green.withOpacity(0.5)
                                  : result.score >= 40
                                  ? Colors.orange.withOpacity(0.5)
                                  : Colors.red.withOpacity(0.5),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${result.score}/100',
                          style: GoogleFonts.saira(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color:
                                result.score >= 70
                                    ? Colors.green
                                    : result.score >= 40
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Feedback
                    Text(
                      result.feedback,
                      style: GoogleFonts.robotoSlab(
                        fontSize: 14,
                        color: const Color(0xFFFFE4B5).withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.saira(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _saveNote(); // Save before disposing
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Save before navigating back
        _saveNote();
        return true;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
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
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2C1810),
                        const Color(0xFF3D2817).withOpacity(0.9),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFFF6B35).withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _saveNote();
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFFFFE4B5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$displaySystemName - Notes',
                          style: GoogleFonts.saira(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFE4B5),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isEvaluating ? null : _submitForEvaluation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isEvaluating
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text(
                                  widget.onSubmitDesign != null
                                      ? 'Submit for AI Evaluation'
                                      : 'Submit',
                                  style: GoogleFonts.saira(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),

                // Simple text area for notes
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C1810).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF6B35).withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      onChanged: (text) {
                        // Auto-save as user types
                        _saveNote();
                      },
                      maxLines: null,
                      expands: true,
                      style: GoogleFonts.robotoSlab(
                        fontSize: 14,
                        color: const Color(0xFFFFE4B5),
                        height: 1.6,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            'Write your system design notes here...\n\nDescribe:\n• System components and their roles\n• Data flow between components\n• Scalability considerations\n• Trade-offs in your design',
                        hintStyle: GoogleFonts.robotoSlab(
                          color: const Color(0xFFFFE4B5).withOpacity(0.4),
                          fontSize: 14,
                        ),
                      ),
                      contextMenuBuilder: (context, editableTextState) {
                        final List<ContextMenuButtonItem> buttonItems =
                            editableTextState.contextMenuButtonItems;
                        // Remove paste button
                        buttonItems.removeWhere(
                          (item) => item.type == ContextMenuButtonType.paste,
                        );
                        return AdaptiveTextSelectionToolbar.buttonItems(
                          anchors: editableTextState.contextMenuAnchors,
                          buttonItems: buttonItems,
                        );
                      },
                    ),
                  ),
                ),

                // Simple evaluation message
                if (_lastEvaluation != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C1810),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF6B35).withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color:
                              _lastEvaluation!.score >= 70
                                  ? Colors.amber
                                  : const Color(0xFFFF6B35),
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Score: ${_lastEvaluation!.score}/100',
                          style: GoogleFonts.saira(
                            fontSize: 16,
                            color: const Color(0xFFFFE4B5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showEvaluationResult(_lastEvaluation!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'View Feedback',
                              style: GoogleFonts.saira(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    ); // WillPopScope
  }
}
