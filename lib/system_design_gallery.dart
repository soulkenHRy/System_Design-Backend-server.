import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'system_design_demo_canvas.dart';
import 'dart:math';

// Import all design data files
import 'url_shortener_canvas_designs.dart';
import 'gaming_leaderboard_canvas_designs.dart';
import 'live_streaming_canvas_designs.dart';
import 'video_streaming_canvas_designs.dart';
import 'ride_sharing_canvas_designs.dart';
import 'collaborative_editor_canvas_designs.dart';
import 'pastebin_canvas_designs.dart';
import 'web_crawler_canvas_designs.dart';
import 'news_feed_canvas_designs.dart';

/// Enum for different system design types
enum SystemDesignType {
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

/// Configuration for each system design type
class SystemDesignConfig {
  final String title;
  final String subtitle;
  final Color themeColor;
  final List<Color> gradientColors;
  final List<Map<String, dynamic>> Function() getDesigns;
  final List<Map<String, dynamic>> Function(Map<String, dynamic>)
  connectionsToLines;

  const SystemDesignConfig({
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.gradientColors,
    required this.getDesigns,
    required this.connectionsToLines,
  });
}

/// Universal gallery for all system design types
class SystemDesignGallery extends StatelessWidget {
  final SystemDesignType designType;

  const SystemDesignGallery({super.key, required this.designType});

  SystemDesignConfig get config {
    switch (designType) {
      case SystemDesignType.urlShortener:
        return SystemDesignConfig(
          title: 'URL Shortener Design Gallery',
          subtitle: 'TinyURL / bit.ly like system',
          themeColor: Colors.deepPurple,
          gradientColors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
          getDesigns: URLShortenerCanvasDesigns.getAllDesigns,
          connectionsToLines: URLShortenerCanvasDesigns.connectionsToLines,
        );
      case SystemDesignType.gamingLeaderboard:
        return SystemDesignConfig(
          title: 'Gaming Leaderboard Gallery',
          subtitle: 'Real-time ranking systems',
          themeColor: const Color(0xFF00BCD4),
          gradientColors: const [Color(0xFF00BCD4), Color(0xFF009688)],
          getDesigns: GamingLeaderboardCanvasDesigns.getAllDesigns,
          connectionsToLines: GamingLeaderboardCanvasDesigns.connectionsToLines,
        );
      case SystemDesignType.liveStreaming:
        return SystemDesignConfig(
          title: 'Live Streaming Gallery',
          subtitle: 'Twitch / YouTube Live like platform',
          themeColor: const Color(0xFFE91E63),
          gradientColors: const [Color(0xFFE91E63), Color(0xFF9C27B0)],
          getDesigns: LiveStreamingCanvasDesigns.getAllDesigns,
          connectionsToLines: LiveStreamingCanvasDesigns.connectionsToLines,
        );
      case SystemDesignType.videoStreaming:
        return SystemDesignConfig(
          title: 'Video Streaming Gallery',
          subtitle: 'Netflix / YouTube like platform',
          themeColor: const Color(0xFFE50914),
          gradientColors: const [Color(0xFFE50914), Color(0xFFB20710)],
          getDesigns: VideoStreamingCanvasDesigns.getAllDesigns,
          connectionsToLines: VideoStreamingCanvasDesigns.connectionsToLines,
        );
      case SystemDesignType.rideSharing:
        return SystemDesignConfig(
          title: 'Ride Sharing Gallery',
          subtitle: 'Uber / Lyft like platform',
          themeColor: const Color(0xFF00BCD4),
          gradientColors: const [Color(0xFF00BCD4), Color(0xFF0288D1)],
          getDesigns: RideSharingCanvasDesigns.getAllDesigns,
          connectionsToLines: RideSharingCanvasDesigns.connectionsToLines,
        );
      case SystemDesignType.collaborativeEditor:
        return SystemDesignConfig(
          title: 'Collaborative Editor Gallery',
          subtitle: 'Google Docs like platform',
          themeColor: const Color(0xFF4CAF50),
          gradientColors: const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          getDesigns: CollaborativeEditorCanvasDesigns.getAllDesigns,
          connectionsToLines:
              CollaborativeEditorCanvasDesigns.connectionsToLines,
        );
      case SystemDesignType.pastebin:
        return SystemDesignConfig(
          title: 'Pastebin Service Gallery',
          subtitle: 'Code/text sharing platform',
          themeColor: const Color(0xFFFF9800),
          gradientColors: const [Color(0xFFFF9800), Color(0xFFF57C00)],
          getDesigns: PastebinCanvasDesigns.getAllDesigns,
          connectionsToLines: PastebinCanvasDesigns.connectionsToLines,
        );
      case SystemDesignType.webCrawler:
        return SystemDesignConfig(
          title: 'Web Crawler Gallery',
          subtitle: 'Search engine / crawler system',
          themeColor: const Color(0xFF2196F3),
          gradientColors: const [Color(0xFF2196F3), Color(0xFF1565C0)],
          getDesigns: WebCrawlerCanvasDesigns.getAllDesigns,
          connectionsToLines: WebCrawlerCanvasDesigns.connectionsToLines,
        );
      case SystemDesignType.newsFeed:
        return SystemDesignConfig(
          title: 'News Feed Gallery',
          subtitle: 'Facebook / Twitter like feed',
          themeColor: const Color(0xFF1976D2),
          gradientColors: const [Color(0xFF1976D2), Color(0xFF0D47A1)],
          getDesigns: NewsFeedCanvasDesigns.getAllDesigns,
          connectionsToLines: NewsFeedCanvasDesigns.connectionsToLines,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = config;
    final designs = cfg.getDesigns();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
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
            ...List.generate(40, (index) {
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
            SafeArea(
              child: Column(
                children: [
                  // Header with back button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A3420),
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(
                              color: const Color(0xFFFFE4B5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 0,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: Color(0xFFFFE4B5),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cfg.title,
                                style: GoogleFonts.saira(
                                  textStyle: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFE4B5),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              Text(
                                cfg.subtitle,
                                style: GoogleFonts.saira(
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Designs List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: designs.length,
                      itemBuilder: (context, index) {
                        final design = designs[index];
                        final name = design['name'] as String;
                        final description = design['description'] as String;
                        final iconCount = (design['icons'] as List).length;
                        final connectionCount =
                            (design['connections'] as List).length;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A3420),
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(
                              color: cfg.themeColor.withOpacity(0.7),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 0,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap:
                                  () =>
                                      _openDesignInCanvas(context, design, cfg),
                              borderRadius: BorderRadius.circular(0),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: cfg.themeColor.withOpacity(
                                              0.3,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: cfg.themeColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: GoogleFonts.saira(
                                              textStyle: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFFE4B5),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Color(0xFFFFE4B5),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      description,
                                      style: GoogleFonts.saira(
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _buildStatChip(
                                          Icons.widgets,
                                          '$iconCount icons',
                                          cfg.themeColor,
                                        ),
                                        const SizedBox(width: 8),
                                        _buildStatChip(
                                          Icons.connecting_airports,
                                          '$connectionCount connections',
                                          Colors.green,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.saira(
              textStyle: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDesignInCanvas(
    BuildContext context,
    Map<String, dynamic> design,
    SystemDesignConfig cfg,
  ) {
    // Convert connections to lines for the canvas
    final lines = cfg.connectionsToLines(design);

    // Prepare canvas data with explanation
    final canvasData = {
      'icons': design['icons'],
      'lines': lines,
      'explanation': design['explanation'],
    };

    // Navigate to generic demo canvas screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SystemDesignDemoCanvas(
              designName: design['name'] as String,
              designData: canvasData,
              themeColor: cfg.themeColor,
            ),
      ),
    );
  }
}
