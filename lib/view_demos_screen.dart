import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'url_shortener_designs_gallery.dart';
import 'system_design_gallery.dart';
import 'dart:math';

class ViewDemosScreen extends StatelessWidget {
  final String folderPath;
  const ViewDemosScreen({super.key, required this.folderPath});

  @override
  Widget build(BuildContext context) {
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Demo Files',
                            style: GoogleFonts.saira(
                              textStyle: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFE4B5),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Browse Architecture Examples',
                      style: GoogleFonts.saira(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Demos List
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      children: [
                        _buildGalleryTile(
                          context,
                          'Gaming Leaderboard Designs (10 Designs)',
                          'View all 10 gaming leaderboard architectures',
                          const Color(0xFF00BCD4),
                          SystemDesignType.gamingLeaderboard,
                        ),
                        _buildGalleryTile(
                          context,
                          'Live Streaming Designs (10 Designs)',
                          'View all 10 live streaming platform architectures',
                          const Color(0xFFE91E63),
                          SystemDesignType.liveStreaming,
                        ),
                        _buildGalleryTile(
                          context,
                          'Video Streaming Designs (10 Designs)',
                          'View all 10 Netflix-like streaming architectures',
                          const Color(0xFFE50914),
                          SystemDesignType.videoStreaming,
                        ),
                        _buildGalleryTile(
                          context,
                          'Ride Sharing Designs (10 Designs)',
                          'View all 10 Uber-like ride sharing architectures',
                          const Color(0xFF00BCD4),
                          SystemDesignType.rideSharing,
                        ),
                        _buildGalleryTile(
                          context,
                          'Collaborative Editor Designs (10 Designs)',
                          'View all 10 Google Docs-like architectures',
                          const Color(0xFF4CAF50),
                          SystemDesignType.collaborativeEditor,
                        ),
                        _buildUrlShortenerTile(context),
                        _buildGalleryTile(
                          context,
                          'Pastebin Service Designs (10 Designs)',
                          'View all 10 Pastebin-like architectures',
                          const Color(0xFFFF9800),
                          SystemDesignType.pastebin,
                        ),
                        _buildGalleryTile(
                          context,
                          'Web Crawler Designs (10 Designs)',
                          'View all 10 search engine/crawler architectures',
                          const Color(0xFF2196F3),
                          SystemDesignType.webCrawler,
                        ),
                        _buildGalleryTile(
                          context,
                          'News Feed Designs (10 Designs)',
                          'View all 10 Facebook-like feed architectures',
                          const Color(0xFF1976D2),
                          SystemDesignType.newsFeed,
                        ),
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildUrlShortenerTile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3420),
        borderRadius: BorderRadius.circular(0),
        border: Border.all(
          color: const Color(0xFF764BA2).withOpacity(0.7),
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
          borderRadius: BorderRadius.circular(0),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const URLShortenerDesignsGallery(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF764BA2).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: const Icon(
                    Icons.architecture,
                    color: Color(0xFF764BA2),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'URL Shortener Canvas Designs (10 Designs)',
                        style: GoogleFonts.saira(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFE4B5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View all 10 predefined URL shortener architectures',
                        style: GoogleFonts.saira(
                          textStyle: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF764BA2).withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFFFE4B5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryTile(
    BuildContext context,
    String title,
    String subtitle,
    Color themeColor,
    SystemDesignType designType,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3420),
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: themeColor.withOpacity(0.7), width: 1),
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
          borderRadius: BorderRadius.circular(0),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => SystemDesignGallery(designType: designType),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Icon(Icons.architecture, color: themeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.saira(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFE4B5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.saira(
                          textStyle: TextStyle(
                            fontSize: 12,
                            color: themeColor.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFFFE4B5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
