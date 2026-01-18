// Design Comparison Service
// Compares user's canvas design with all demo designs to find missing connections

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'system_design_icons.dart';

// Import all canvas design files
import 'url_shortener_canvas_designs.dart';
import 'gaming_leaderboard_canvas_designs.dart';
import 'live_streaming_canvas_designs.dart';
import 'video_streaming_canvas_designs.dart';
import 'ride_sharing_canvas_designs.dart';
import 'collaborative_editor_canvas_designs.dart';
import 'pastebin_canvas_designs.dart';
import 'web_crawler_canvas_designs.dart';
import 'news_feed_canvas_designs.dart';

/// Enum for system design types
enum SystemType {
  urlShortener,
  gamingLeaderboard,
  liveStreaming,
  videoStreaming,
  rideSharing,
  collaborativeEditor,
  pastebin,
  webCrawler,
  newsFeed,
}

/// Represents a connection between two icons (by name)
class IconConnection {
  final String fromIcon;
  final String toIcon;
  final String? label;

  IconConnection({required this.fromIcon, required this.toIcon, this.label});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    // Direction matters: A→B is NOT equal to B→A
    return other is IconConnection &&
        other.fromIcon.toLowerCase() == fromIcon.toLowerCase() &&
        other.toIcon.toLowerCase() == toIcon.toLowerCase();
  }

  @override
  int get hashCode {
    // Use a directional hash to ensure A→B and B→A have different hashes
    // Multiply first value to break symmetry of XOR
    return (fromIcon.toLowerCase().hashCode * 37) ^
        toIcon.toLowerCase().hashCode;
  }

  @override
  String toString() => '$fromIcon → $toIcon${label != null ? ' ($label)' : ''}';
}

/// Result of comparing user design with a single demo design
class DesignComparisonResult {
  final String demoName;
  final String demoDescription;
  final List<IconConnection> demoConnections;
  final List<IconConnection> userConnections;
  final List<IconConnection> matchingConnections;
  final List<IconConnection> missingConnections;
  final List<IconConnection> extraConnections; // User has but demo doesn't
  final List<String> missingIcons;
  final double matchPercentage;

  DesignComparisonResult({
    required this.demoName,
    required this.demoDescription,
    required this.demoConnections,
    required this.userConnections,
    required this.matchingConnections,
    required this.missingConnections,
    required this.extraConnections,
    required this.missingIcons,
    required this.matchPercentage,
  });
}

/// Main comparison service
class DesignComparisonService {
  /// Get all demo designs for a specific system type
  static List<Map<String, dynamic>> getDemoDesigns(SystemType systemType) {
    switch (systemType) {
      case SystemType.urlShortener:
        return URLShortenerCanvasDesigns.getAllDesigns();
      case SystemType.gamingLeaderboard:
        return GamingLeaderboardCanvasDesigns.getAllDesigns();
      case SystemType.liveStreaming:
        return LiveStreamingCanvasDesigns.getAllDesigns();
      case SystemType.videoStreaming:
        return VideoStreamingCanvasDesigns.getAllDesigns();
      case SystemType.rideSharing:
        return RideSharingCanvasDesigns.getAllDesigns();
      case SystemType.collaborativeEditor:
        return CollaborativeEditorCanvasDesigns.getAllDesigns();
      case SystemType.pastebin:
        return PastebinCanvasDesigns.getAllDesigns();
      case SystemType.webCrawler:
        return WebCrawlerCanvasDesigns.getAllDesigns();
      case SystemType.newsFeed:
        return NewsFeedCanvasDesigns.getAllDesigns();
    }
  }

  /// Get system type from system name string
  static SystemType? getSystemTypeFromName(String systemName) {
    final lowerName = systemName.toLowerCase();

    if (lowerName.contains('url') ||
        lowerName.contains('shortener') ||
        lowerName.contains('tiny')) {
      return SystemType.urlShortener;
    } else if (lowerName.contains('gaming') ||
        lowerName.contains('leaderboard') ||
        lowerName.contains('ranking')) {
      return SystemType.gamingLeaderboard;
    } else if (lowerName.contains('live') && lowerName.contains('stream')) {
      return SystemType.liveStreaming;
    } else if (lowerName.contains('video') ||
        lowerName.contains('netflix') ||
        lowerName.contains('youtube')) {
      return SystemType.videoStreaming;
    } else if (lowerName.contains('ride') ||
        lowerName.contains('uber') ||
        lowerName.contains('taxi')) {
      return SystemType.rideSharing;
    } else if (lowerName.contains('collab') ||
        lowerName.contains('editor') ||
        lowerName.contains('doc')) {
      return SystemType.collaborativeEditor;
    } else if (lowerName.contains('paste') ||
        lowerName.contains('bin') ||
        lowerName.contains('snippet')) {
      return SystemType.pastebin;
    } else if (lowerName.contains('crawl') ||
        lowerName.contains('spider') ||
        lowerName.contains('search engine')) {
      return SystemType.webCrawler;
    } else if (lowerName.contains('feed') ||
        lowerName.contains('facebook') ||
        lowerName.contains('twitter') ||
        lowerName.contains('social')) {
      return SystemType.newsFeed;
    }

    return null;
  }

  /// Extract connections from demo design data
  static List<IconConnection> extractDemoConnections(
    Map<String, dynamic> design,
  ) {
    final connections = <IconConnection>[];
    final icons = design['icons'] as List<dynamic>? ?? [];
    final conns = design['connections'] as List<dynamic>? ?? [];

    for (final conn in conns) {
      final fromIndex = conn['fromIconIndex'] as int;
      final toIndex = conn['toIconIndex'] as int;
      final label = conn['label'] as String?;

      if (fromIndex >= 0 &&
          fromIndex < icons.length &&
          toIndex >= 0 &&
          toIndex < icons.length) {
        final fromIcon = icons[fromIndex] as Map<String, dynamic>;
        final toIcon = icons[toIndex] as Map<String, dynamic>;

        connections.add(
          IconConnection(
            fromIcon: fromIcon['name'] as String,
            toIcon: toIcon['name'] as String,
            label: label,
          ),
        );
      }
    }

    return connections;
  }

  /// Extract icons from demo design
  static List<String> extractDemoIcons(Map<String, dynamic> design) {
    final icons = design['icons'] as List<dynamic>? ?? [];
    return icons
        .map((icon) => (icon as Map<String, dynamic>)['name'] as String)
        .toList();
  }

  /// Extract connections from user's canvas data
  /// User data format: connections with fromIconIndex and toIconIndex
  static List<IconConnection> extractUserConnections(
    List<dynamic> userIcons,
    List<dynamic> userConnections,
  ) {
    final connections = <IconConnection>[];

    // Process each connection
    for (final conn in userConnections) {
      final connData = conn as Map<String, dynamic>;
      final fromIndex = connData['fromIconIndex'] as int?;
      final toIndex = connData['toIconIndex'] as int?;

      if (fromIndex != null &&
          toIndex != null &&
          fromIndex >= 0 &&
          fromIndex < userIcons.length &&
          toIndex >= 0 &&
          toIndex < userIcons.length) {
        final fromIcon = userIcons[fromIndex] as Map<String, dynamic>;
        final toIcon = userIcons[toIndex] as Map<String, dynamic>;
        final fromName = fromIcon['name'] as String?;
        final toName = toIcon['name'] as String?;

        if (fromName != null && toName != null) {
          connections.add(IconConnection(fromIcon: fromName, toIcon: toName));
        }
      }
    }

    return connections;
  }

  /// Compare user's design with a single demo design
  static DesignComparisonResult compareWithDemo(
    List<dynamic> userIcons,
    List<dynamic> userConnections,
    Map<String, dynamic> demoDesign,
  ) {
    final demoConnections = extractDemoConnections(demoDesign);
    final userConnectionsList = extractUserConnections(
      userIcons,
      userConnections,
    );
    final demoIconNames = extractDemoIcons(demoDesign);
    final userIconNames =
        userIcons
            .map((icon) => (icon as Map<String, dynamic>)['name'] as String)
            .toList();

    // Find matching connections
    final matchingConnections = <IconConnection>[];
    for (final userConn in userConnectionsList) {
      if (demoConnections.contains(userConn)) {
        matchingConnections.add(userConn);
      }
    }

    // Find missing connections (in demo but not in user's design)
    final missingConnections = <IconConnection>[];
    for (final demoConn in demoConnections) {
      if (!userConnectionsList.contains(demoConn)) {
        missingConnections.add(demoConn);
      }
    }

    // Find extra connections (user has but demo doesn't)
    final extraConnections = <IconConnection>[];
    for (final userConn in userConnectionsList) {
      if (!demoConnections.contains(userConn)) {
        extraConnections.add(userConn);
      }
    }

    // Find missing icons
    final missingIcons = <String>[];
    for (final demoIcon in demoIconNames) {
      final hasIcon = userIconNames.any(
        (name) => name.toLowerCase() == demoIcon.toLowerCase(),
      );
      if (!hasIcon) {
        missingIcons.add(demoIcon);
      }
    }

    // Calculate match percentage
    final totalDemoConnections = demoConnections.length;
    final matchPercentage =
        totalDemoConnections > 0
            ? (matchingConnections.length / totalDemoConnections) * 100
            : 0.0;

    return DesignComparisonResult(
      demoName: demoDesign['name'] as String? ?? 'Unknown',
      demoDescription: demoDesign['description'] as String? ?? '',
      demoConnections: demoConnections,
      userConnections: userConnectionsList,
      matchingConnections: matchingConnections,
      missingConnections: missingConnections,
      extraConnections: extraConnections,
      missingIcons: missingIcons,
      matchPercentage: matchPercentage,
    );
  }

  /// Compare user's design with ALL demo designs of a system type
  static List<DesignComparisonResult> compareWithAllDemos(
    SystemType systemType,
    List<dynamic> userIcons,
    List<dynamic> userConnections,
  ) {
    final demoDesigns = getDemoDesigns(systemType);
    final results = <DesignComparisonResult>[];

    for (final demo in demoDesigns) {
      results.add(compareWithDemo(userIcons, userConnections, demo));
    }

    // Sort by match percentage (highest first)
    results.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));

    return results;
  }

  /// Get demo design data for visual rendering
  static Map<String, dynamic>? getDemoDesignByIndex(
    SystemType systemType,
    int index,
  ) {
    final designs = getDemoDesigns(systemType);
    if (index >= 0 && index < designs.length) {
      return designs[index];
    }
    return null;
  }
}

// ==========================================
// UI WIDGET: Visual Design Comparison Dialog
// ==========================================

class DesignComparisonDialog extends StatefulWidget {
  final SystemType systemType;
  final List<dynamic> userIcons;
  final List<dynamic> userConnections;

  const DesignComparisonDialog({
    super.key,
    required this.systemType,
    required this.userIcons,
    required this.userConnections,
  });

  @override
  State<DesignComparisonDialog> createState() => _DesignComparisonDialogState();
}

class _DesignComparisonDialogState extends State<DesignComparisonDialog> {
  int _selectedDemoIndex = 0;
  bool _showDebugInfo = false;

  @override
  Widget build(BuildContext context) {
    final results = DesignComparisonService.compareWithAllDemos(
      widget.systemType,
      widget.userIcons,
      widget.userConnections,
    );

    if (results.isEmpty) {
      return Dialog(
        backgroundColor: const Color(0xFF1a1a2e),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No demo designs available.',
            style: GoogleFonts.saira(color: Colors.white),
          ),
        ),
      );
    }

    final selectedResult = results[_selectedDemoIndex];
    final demoDesign = DesignComparisonService.getDemoDesignByIndex(
      widget.systemType,
      _selectedDemoIndex,
    );

    return Dialog(
      backgroundColor: const Color(0xFF1a1a2e),
      insetPadding: const EdgeInsets.all(12),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            // Compact header
            _buildHeader(context, results, selectedResult),

            // Demo tabs
            _buildDemoTabs(results),

            // Main content: Side by side visual comparison
            Expanded(
              child: Row(
                children: [
                  // Your Design
                  Expanded(
                    child: _buildDesignCanvas(
                      title: 'Your Design',
                      icons: widget.userIcons,
                      lines: [],
                      connections: widget.userConnections,
                      matchingConnections: selectedResult.matchingConnections,
                      missingConnections: [],
                      isUserDesign: true,
                    ),
                  ),
                  // Divider
                  Container(width: 2, color: Colors.white24),
                  // Demo Design
                  Expanded(
                    child: _buildDesignCanvas(
                      title: selectedResult.demoName,
                      icons: demoDesign?['icons'] ?? [],
                      lines: [],
                      connections: demoDesign?['connections'] ?? [],
                      matchingConnections: selectedResult.matchingConnections,
                      missingConnections: selectedResult.missingConnections,
                      isUserDesign: false,
                    ),
                  ),
                ],
              ),
            ),

            // Detailed breakdown section
            _buildDetailedBreakdown(selectedResult),

            // Bottom stats bar
            _buildStatsBar(selectedResult),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    List<DesignComparisonResult> results,
    DesignComparisonResult selectedResult,
  ) {
    final color = _getMatchColor(selectedResult.matchPercentage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          // Score circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              color: color.withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                '${selectedResult.matchPercentage.toStringAsFixed(0)}%',
                style: GoogleFonts.saira(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Compare Designs',
              style: GoogleFonts.saira(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoTabs(List<DesignComparisonResult> results) {
    return Container(
      height: 44,
      color: Colors.black12,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          final isSelected = index == _selectedDemoIndex;
          final color = _getMatchColor(result.matchPercentage);

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => setState(() => _selectedDemoIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.2) : Colors.black26,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Row(
                    children: [
                      Text(
                        '${result.matchPercentage.toStringAsFixed(0)}%',
                        style: GoogleFonts.saira(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'D${index + 1}',
                        style: GoogleFonts.saira(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesignCanvas({
    required String title,
    required List<dynamic> icons,
    required List<dynamic> lines,
    List<dynamic>? connections,
    required List<IconConnection> matchingConnections,
    required List<IconConnection> missingConnections,
    required bool isUserDesign,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // Title bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isUserDesign
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.purple.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(7),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isUserDesign ? Icons.person : Icons.auto_awesome,
                  size: 16,
                  color: isUserDesign ? Colors.blue : Colors.purple,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.saira(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Canvas with icons
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(7),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return InteractiveViewer(
                    minScale: 0.3,
                    maxScale: 2.0,
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: MiniCanvasPainter(
                        icons: icons,
                        lines: lines,
                        connections: connections,
                        matchingConnections: matchingConnections,
                        missingConnections: missingConnections,
                        isUserDesign: isUserDesign,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBreakdown(DesignComparisonResult result) {
    // Extract icon names for debugging
    final userIconNames =
        widget.userIcons
            .map((icon) => (icon as Map<String, dynamic>)['name'] as String)
            .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.black12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Detailed Analysis',
                style: GoogleFonts.saira(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              // Debug toggle button
              InkWell(
                onTap: () => setState(() => _showDebugInfo = !_showDebugInfo),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showDebugInfo
                            ? Icons.visibility_off
                            : Icons.info_outline,
                        size: 12,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showDebugInfo ? 'Hide Details' : 'Debug Info',
                        style: GoogleFonts.saira(
                          fontSize: 10,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Debug info section
          if (_showDebugInfo) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.cyan.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.bug_report,
                        size: 14,
                        color: Colors.cyan,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Debug Information',
                        style: GoogleFonts.saira(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildDebugRow('Your Icons', userIconNames.join(', ')),
                  _buildDebugRow(
                    'Demo Icons',
                    result.demoConnections
                        .map((c) => c.fromIcon)
                        .toSet()
                        .toList()
                        .join(', '),
                  ),
                  _buildDebugRow(
                    'Your Connections',
                    '${widget.userConnections.length}',
                  ),
                  _buildDebugRow(
                    'Demo Connections',
                    '${result.demoConnections.length}',
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          SizedBox(
            height: 200, // Fixed height for scrollable breakdown sections
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Missing Icons
                if (result.missingIcons.isNotEmpty)
                  Expanded(
                    child: _buildBreakdownSection(
                      title: 'Missing Icons (${result.missingIcons.length})',
                      icon: Icons.widgets,
                      color: Colors.orange,
                      items:
                          result.missingIcons.map((iconName) {
                            final category = SystemDesignIcons.getCategory(
                              iconName,
                            );
                            if (category != null) {
                              return '$iconName\n   📁 $category';
                            }
                            return iconName;
                          }).toList(),
                      subtitle: 'Add these components (category shown below)',
                    ),
                  ),
                if (result.missingIcons.isNotEmpty &&
                    result.missingConnections.isNotEmpty)
                  const SizedBox(width: 12),
                // Missing Connections
                if (result.missingConnections.isNotEmpty)
                  Expanded(
                    child: _buildBreakdownSection(
                      title:
                          'Missing Connections (${result.missingConnections.length})',
                      icon: Icons.cancel,
                      color: Colors.red,
                      items:
                          result.missingConnections.map((c) {
                            final fromCategory = SystemDesignIcons.getCategory(
                              c.fromIcon,
                            );
                            final toCategory = SystemDesignIcons.getCategory(
                              c.toIcon,
                            );
                            String info = '${c.fromIcon} → ${c.toIcon}';
                            if (fromCategory != null || toCategory != null) {
                              info +=
                                  '\n   📁 ${fromCategory ?? "?"} → ${toCategory ?? "?"}';
                            }
                            return info;
                          }).toList(),
                      subtitle: 'Connect these components',
                    ),
                  ),
                if ((result.missingIcons.isNotEmpty ||
                        result.missingConnections.isNotEmpty) &&
                    result.extraConnections.isNotEmpty)
                  const SizedBox(width: 12),
                // Extra Connections
                if (result.extraConnections.isNotEmpty)
                  Expanded(
                    child: _buildBreakdownSection(
                      title:
                          'Extra Connections (${result.extraConnections.length})',
                      icon: Icons.add_circle,
                      color: Colors.amber,
                      items:
                          result.extraConnections.map((c) {
                            final fromCategory = SystemDesignIcons.getCategory(
                              c.fromIcon,
                            );
                            final toCategory = SystemDesignIcons.getCategory(
                              c.toIcon,
                            );
                            String info = '${c.fromIcon} → ${c.toIcon}';
                            if (fromCategory != null || toCategory != null) {
                              info +=
                                  '\n   📁 ${fromCategory ?? "?"} → ${toCategory ?? "?"}';
                            }
                            return info;
                          }).toList(),
                      subtitle: 'Not in this demo design',
                    ),
                  ),
              ],
            ),
          ),
          if (result.missingIcons.isEmpty &&
              result.missingConnections.isEmpty &&
              result.extraConnections.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '🎉 Perfect match! Your design matches the demo exactly.',
                  style: GoogleFonts.saira(
                    fontSize: 13,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.saira(
                fontSize: 10,
                color: Colors.cyan.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.saira(fontSize: 10, color: Colors.white60),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
    String? subtitle,
  }) {
    // Group items by category
    final Map<String, List<String>> groupedItems = {};

    for (final item in items) {
      final parts = item.split('\n');
      final mainText = parts[0];
      final categoryText =
          parts.length > 1
              ? parts[1].replaceAll('📁', '').trim()
              : 'Uncategorized';

      // For connections like "Category1 → Category2", extract appropriately
      String category;
      if (categoryText.contains('→')) {
        // It's a connection - use the first category
        category = categoryText.split('→')[0].trim();
        if (category == '?') category = 'Unknown';
      } else {
        category = categoryText;
      }

      groupedItems.putIfAbsent(category, () => []);
      groupedItems[category]!.add(mainText);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.saira(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.saira(
                fontSize: 10,
                color: Colors.white38,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children:
                  groupedItems.entries.map((entry) {
                    return _CategoryExpansionTile(
                      category: entry.key,
                      items: entry.value,
                      color: color,
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(DesignComparisonResult result) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: Icons.check_circle,
            color: Colors.green,
            value: '${result.matchingConnections.length}',
            label: 'Match',
          ),
          _buildStatItem(
            icon: Icons.cancel,
            color: Colors.red,
            value: '${result.missingConnections.length}',
            label: 'Missing',
          ),
          _buildStatItem(
            icon: Icons.add_circle,
            color: Colors.amber,
            value: '${result.extraConnections.length}',
            label: 'Extra',
          ),
          _buildStatItem(
            icon: Icons.widgets,
            color: Colors.orange,
            value: '${result.missingIcons.length}',
            label: 'Need',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.saira(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.saira(fontSize: 10, color: Colors.white54),
        ),
      ],
    );
  }

  Color _getMatchColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}

// ==========================================
// Category Expansion Tile for grouped items
// ==========================================

class _CategoryExpansionTile extends StatefulWidget {
  final String category;
  final List<String> items;
  final Color color;

  const _CategoryExpansionTile({
    required this.category,
    required this.items,
    required this.color,
  });

  @override
  State<_CategoryExpansionTile> createState() => _CategoryExpansionTileState();
}

class _CategoryExpansionTileState extends State<_CategoryExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 16,
                  color: widget.color,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.folder,
                  size: 12,
                  color: widget.color.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${widget.category} (${widget.items.length})',
                    style: GoogleFonts.saira(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  widget.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          Text(
                            '•',
                            style: GoogleFonts.saira(
                              fontSize: 10,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item,
                              style: GoogleFonts.saira(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
      ],
    );
  }
}

// ==========================================
// Mini Canvas Painter for visual comparison
// ==========================================

class MiniCanvasPainter extends CustomPainter {
  final List<dynamic> icons;
  final List<dynamic> lines;
  final List<dynamic>? connections;
  final List<IconConnection> matchingConnections;
  final List<IconConnection> missingConnections;
  final bool isUserDesign;

  MiniCanvasPainter({
    required this.icons,
    required this.lines,
    this.connections,
    required this.matchingConnections,
    required this.missingConnections,
    required this.isUserDesign,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (icons.isEmpty) return;

    // Calculate bounds to fit all icons
    double minX = double.infinity, minY = double.infinity;
    double maxX = 0, maxY = 0;

    for (final icon in icons) {
      final x = (icon['positionX'] as num?)?.toDouble() ?? 0;
      final y = (icon['positionY'] as num?)?.toDouble() ?? 0;
      minX = math.min(minX, x);
      minY = math.min(minY, y);
      maxX = math.max(maxX, x + 60);
      maxY = math.max(maxY, y + 60);
    }

    // Add padding
    minX -= 40;
    minY -= 40;
    maxX += 40;
    maxY += 40;

    final contentWidth = maxX - minX;
    final contentHeight = maxY - minY;

    // Scale to fit
    final scaleX = size.width / contentWidth;
    final scaleY = size.height / contentHeight;
    final scale = math.min(scaleX, scaleY) * 0.9;

    // Center offset
    final offsetX = (size.width - contentWidth * scale) / 2 - minX * scale;
    final offsetY = (size.height - contentHeight * scale) / 2 - minY * scale;

    // Draw grid
    _drawGrid(canvas, size);

    // Draw connections/lines
    if (connections != null && connections!.isNotEmpty) {
      _drawConnections(canvas, scale, offsetX, offsetY);
    } else if (lines.isNotEmpty) {
      _drawUserLines(canvas, scale, offsetX, offsetY);
    }

    // Draw icons
    _drawIcons(canvas, scale, offsetX, offsetY);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..strokeWidth = 1;

    const gridSize = 30.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawUserLines(
    Canvas canvas,
    double scale,
    double offsetX,
    double offsetY,
  ) {
    for (final line in lines) {
      final startX =
          ((line['startX'] as num?)?.toDouble() ?? 0) * scale + offsetX;
      final startY =
          ((line['startY'] as num?)?.toDouble() ?? 0) * scale + offsetY;
      final endX = ((line['endX'] as num?)?.toDouble() ?? 0) * scale + offsetX;
      final endY = ((line['endY'] as num?)?.toDouble() ?? 0) * scale + offsetY;

      // Determine color based on the line color (green = valid, red = invalid)
      final lineColor = line['color'] as int? ?? Colors.grey.value;
      Color color;
      if (lineColor == Colors.green.value) {
        color = Colors.green;
      } else if (lineColor == Colors.red.value) {
        color = Colors.red;
      } else {
        color = Colors.grey;
      }

      final paint =
          Paint()
            ..color = color
            ..strokeWidth = 2 * scale.clamp(0.5, 1.5)
            ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      _drawArrow(
        canvas,
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
        scale,
      );
    }
  }

  void _drawConnections(
    Canvas canvas,
    double scale,
    double offsetX,
    double offsetY,
  ) {
    if (connections == null) return;

    for (final conn in connections!) {
      final fromIndex = conn['fromIconIndex'] as int?;
      final toIndex = conn['toIconIndex'] as int?;

      if (fromIndex == null ||
          toIndex == null ||
          fromIndex < 0 ||
          fromIndex >= icons.length ||
          toIndex < 0 ||
          toIndex >= icons.length)
        continue;

      final fromIcon = icons[fromIndex];
      final toIcon = icons[toIndex];

      final fromName = fromIcon['name'] as String;
      final toName = toIcon['name'] as String;

      // Check if this connection is matched or missing
      final isMatched = matchingConnections.any(
        (c) =>
            c.fromIcon.toLowerCase() == fromName.toLowerCase() &&
            c.toIcon.toLowerCase() == toName.toLowerCase(),
      );

      final isMissing = missingConnections.any(
        (c) =>
            c.fromIcon.toLowerCase() == fromName.toLowerCase() &&
            c.toIcon.toLowerCase() == toName.toLowerCase(),
      );

      final startX =
          ((fromIcon['positionX'] as num?)?.toDouble() ?? 0) * scale +
          offsetX +
          30 * scale;
      final startY =
          ((fromIcon['positionY'] as num?)?.toDouble() ?? 0) * scale +
          offsetY +
          30 * scale;
      final endX =
          ((toIcon['positionX'] as num?)?.toDouble() ?? 0) * scale +
          offsetX +
          30 * scale;
      final endY =
          ((toIcon['positionY'] as num?)?.toDouble() ?? 0) * scale +
          offsetY +
          30 * scale;

      Color color;
      if (isMatched) {
        color = Colors.green;
      } else if (isMissing) {
        color = Colors.red;
      } else {
        color = Colors.orange; // Extra connections (user has but demo doesn't)
      }

      final paint =
          Paint()
            ..color = color.withOpacity(0.8)
            ..strokeWidth = 2 * scale.clamp(0.5, 1.5)
            ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      _drawArrow(
        canvas,
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
        scale,
      );
    }
  }

  void _drawArrow(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double scale,
  ) {
    final arrowLength = 8.0 * scale.clamp(0.5, 1.5);
    const arrowAngle = 0.5;

    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);

    final arrowP1 = Offset(
      end.dx - arrowLength * math.cos(angle - arrowAngle),
      end.dy - arrowLength * math.sin(angle - arrowAngle),
    );

    final arrowP2 = Offset(
      end.dx - arrowLength * math.cos(angle + arrowAngle),
      end.dy - arrowLength * math.sin(angle + arrowAngle),
    );

    canvas.drawLine(end, arrowP1, paint);
    canvas.drawLine(end, arrowP2, paint);
  }

  void _drawIcons(Canvas canvas, double scale, double offsetX, double offsetY) {
    for (int i = 0; i < icons.length; i++) {
      final icon = icons[i];
      final x =
          ((icon['positionX'] as num?)?.toDouble() ?? 0) * scale + offsetX;
      final y =
          ((icon['positionY'] as num?)?.toDouble() ?? 0) * scale + offsetY;
      final name = icon['name'] as String? ?? '';

      final iconSize = 50 * scale.clamp(0.3, 1.0);

      // Draw icon background
      final bgPaint =
          Paint()
            ..color = const Color(0xFF2d3748)
            ..style = PaintingStyle.fill;

      final borderPaint =
          Paint()
            ..color = Colors.white24
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, iconSize, iconSize),
        Radius.circular(6 * scale),
      );

      canvas.drawRRect(rect, bgPaint);
      canvas.drawRRect(rect, borderPaint);

      // Draw icon symbol (using first 2 letters as placeholder)
      final textPainter = TextPainter(
        text: TextSpan(
          text: _getIconAbbreviation(name),
          style: TextStyle(
            color: Colors.white,
            fontSize: 12 * scale.clamp(0.4, 1.0),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + (iconSize - textPainter.width) / 2,
          y + (iconSize - textPainter.height) / 2,
        ),
      );

      // Draw name label background for better visibility
      final labelBgPaint =
          Paint()
            ..color = const Color(0xFF1a1a2e).withOpacity(0.9)
            ..style = PaintingStyle.fill;

      // Always draw name below icon with better visibility
      final namePainter = TextPainter(
        text: TextSpan(
          text: name,
          style: TextStyle(
            color: const Color(0xFFFFE4B5), // Cream color for visibility
            fontSize: 9 * scale.clamp(0.6, 1.2),
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      namePainter.layout(maxWidth: iconSize * 2 + 40);

      // Draw background for name label
      final labelRect = Rect.fromLTWH(
        x + (iconSize - namePainter.width) / 2 - 4,
        y + iconSize + 2,
        namePainter.width + 8,
        namePainter.height + 4,
      );
      canvas.drawRect(labelRect, labelBgPaint);

      // Draw border around label
      final labelBorderPaint =
          Paint()
            ..color = const Color(0xFFFFE4B5).withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5;
      canvas.drawRect(labelRect, labelBorderPaint);

      // Draw the name text
      namePainter.paint(
        canvas,
        Offset(x + (iconSize - namePainter.width) / 2, y + iconSize + 4),
      );
    }
  }

  String _getIconAbbreviation(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }
    return name.toUpperCase();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// Helper function to show comparison dialog
// ==========================================

void showDesignComparisonDialog({
  required BuildContext context,
  required String systemName,
  required List<dynamic> userIcons,
  required List<dynamic> userConnections,
}) {
  final systemType = DesignComparisonService.getSystemTypeFromName(systemName);

  if (systemType == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cannot compare: Unknown system type "$systemName"',
          style: GoogleFonts.saira(),
        ),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  showDialog(
    context: context,
    builder:
        (context) => DesignComparisonDialog(
          systemType: systemType,
          userIcons: userIcons,
          userConnections: userConnections,
        ),
  );
}
